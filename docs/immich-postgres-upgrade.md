# Immich Postgres 14 -> 18 upgrade

Immich's database image pins the Postgres major in its tag. Renovate bumps that tag like
any other, but a Postgres data directory is not forward compatible, so the new server
refuses to start against the old cluster:

```
FATAL:  database files are incompatible with server
DETAIL: The data directory was initialized by PostgreSQL version 14, which is not
        compatible with this version 18
```

The fix is a dump, a fresh `initdb`, and a restore.
[`postgres-major-upgrade.md`](./postgres-major-upgrade.md) covers that shape for the
plain-Postgres services (atuin, sure, tandoor) and its PGDATA section applies here too.
This runbook exists because Immich's cluster carries vector extensions, and because this
particular bump changes three things at once:

| | Before | After |
| --- | --- | --- |
| Postgres | 14 | 18 |
| Vector index extension | VectorChord 0.4.3 | VectorChord 1.1.1 |
| Vector type extension | pgvecto.rs 0.2.0 (`pgvectors`) | pgvector 0.8.5 |

The third row is the one that bites. **There is no `18-…-pgvectors…` tag** — pgvecto.rs
is not built for Postgres 18 at all, and Immich dropped support for it in 3.0. If the
database still contains the `vectors` extension, its `CREATE EXTENSION vectors` will fail
on the new image and take the whole restore down with it. Preflight gates on this.

## Parameters

Everything below reads from `immich/.env`, so source it rather than hardcoding:

| | Value |
| --- | --- |
| Compose dir | `~/cloud-config/immich` |
| DB service / container / network | `database` / `immich_postgres` / `immich_default` |
| Role / database | `${DB_USERNAME}` / `${DB_DATABASE_NAME}` (default `postgres` / `immich`) |
| Data directory | `${DB_DATA_LOCATION}` (`~/cloud-data/immich/postgres`) |

The dump lands in `~/pg18-upgrade`, deliberately *not* in `UPLOAD_LOCATION/backups` —
`cloud-data/immich/upload` is in `restic_exclude.txt`, so anything written there sits
outside the offsite backup. The old `postgres` directory *is* covered by restic, so the
nightly snapshot taken before you start is a second rollback.

## Four things that will silently ruin this

1. **The mount point has to move.** Postgres 18 relocated `PGDATA` to
   `/var/lib/postgresql/18/docker` and declares its volume at `/var/lib/postgresql`.
   Keep the old `:/var/lib/postgresql/data` mount and you get *no error*: the image
   initialises an empty cluster at the container-local path, Immich comes up looking
   freshly installed, and the loss only surfaces when the container is recreated. The
   compose change in step 3 mounts the parent instead. (This is also why the no-op
   `PG_DATA` typo in our compose file is gone — it never did anything, and on 18 it reads
   as reassurance that isn't there.)
2. **The `search_path` rewrite.** `pg_dump` emits
   `set_config('search_path', '', false)`, and replaying it as-is leaves vector columns
   unable to resolve their types. The `sed` in step 5 is
   [Immich's documented workaround](https://docs.immich.app/administration/backup-and-restore/#restore-cli).
3. **`--single-transaction --set ON_ERROR_STOP=on`.** Without it `psql` exits 0 after
   skipping every statement it could not apply, and you find out weeks later.
4. **The cluster must be untouched by the Immich server.** Restore into a database the
   server has already migrated and you get `relation already exists` and foreign key
   violations. Only `database` is started before the restore.

## Preflight

```sh
cd ~/cloud-config/immich
set -a; . ./.env; set +a
alias pg14='docker compose exec -T database psql -U "$DB_USERNAME" -d "$DB_DATABASE_NAME" -Atc'

docker compose ps
pg14 "show server_version"
```

### Gate: is pgvecto.rs really gone?

Immich 3.x migrates itself off pgvecto.rs onto VectorChord, so this *should* already be
clean — but check, because it is the one failure this procedure cannot recover from
halfway through.

```sh
# Expect: vchord, vector, and friends. A row for `vectors` is the problem case.
pg14 "select extname, extversion from pg_extension order by extname"

# Expect udt_schema = public, udt_name = vector for both rows
pg14 "select table_name, udt_schema, udt_name from information_schema.columns
      where column_name = 'embedding'"
```

- **Both embedding columns are `public.vector`, no `vectors` extension** — good, carry on.
- **`vectors` extension present but columns are already `public.vector`** — leftover. Drop
  it on the old cluster before dumping (no `CASCADE`; an error here means something still
  depends on it, which you want to know about):
  ```sh
  docker compose exec -T database psql -U "$DB_USERNAME" -d "$DB_DATABASE_NAME" \
    -c "DROP EXTENSION vectors;" -c "DROP SCHEMA vectors;"
  ```
- **Columns are still `vectors.vector`** — stop. The database is genuinely still on
  pgvecto.rs, and that has to be migrated to VectorChord *first*, on Postgres 14, using
  the current image which has both extensions. Follow
  [Migrating from pgvecto.rs](https://docs.immich.app/administration/postgres-standalone/#migrating-from-pgvectors)
  (automatic path), confirm this gate passes, then come back.

### Capacity and a baseline

```sh
pg14 "select pg_size_pretty(pg_database_size('$DB_DATABASE_NAME'))"
du -sh "$DB_DATA_LOCATION"
df -h ~/cloud-data          # needs room for the dump plus a second cluster

# Confirm the single-role, single-database assumption the entrypoint relies on
pg14 "select rolname from pg_roles where rolname not like 'pg\_%'"
pg14 "select datname from pg_database where not datistemplate"

# Row counts to compare after the restore
pg14 "select relname, n_live_tup from pg_stat_user_tables order by n_live_tup desc limit 10" \
  | tee ~/pg18-upgrade-rowcounts-before.txt
```

Data checksums need no thought this time: Postgres 18 enables them at `initdb` by
default, so the new cluster gets them whether or not the old one had them.

If `docker compose ps` shows the database crash-looping, the host is already on a newer
tag. Put it back on 14 for the dump:

```sh
git -C ~/cloud-config checkout main -- immich/docker-compose.yml
docker compose up -d database
```

## 1. Quiesce

Stop everything that writes, leaving only the database up. Writes landing after the dump
are lost at cutover, so this is correctness, not tidiness.

```sh
docker compose stop server machine-learning redis
```

## 2. Dump, with the new version's client

Postgres supports a *newer* `pg_dump` against an older server, not the reverse, and this
jump spans four majors — so the dump is taken by the 18 image's `pg_dump` reaching the
running 14 server over the compose network. `--entrypoint` is required: Immich's image
entrypoint refuses to run when `PGDATA` is on overlayfs, which it is in a client-only
container.

```sh
mkdir -p ~/pg18-upgrade
docker network ls | grep immich   # confirm the network is named immich_default
docker run --rm --network immich_default \
  -e PGPASSWORD="$DB_PASSWORD" \
  --entrypoint pg_dump \
  ghcr.io/immich-app/postgres:18-vectorchord1.1.1-pgvector0.8.5 \
  --clean --if-exists -h database -U "$DB_USERNAME" -d "$DB_DATABASE_NAME" \
  | gzip > ~/pg18-upgrade/immich.sql.gz
```

Check the dump before going near the data directory. A truncated dump that is never read
back is the main way this procedure loses data. Postgres 18 wraps its dumps in
`\restrict`/`\unrestrict` guards, so the completion marker is not the last line:

```sh
ls -lh ~/pg18-upgrade/immich.sql.gz
zgrep -c "PostgreSQL database dump complete" ~/pg18-upgrade/immich.sql.gz   # expect: 1
zgrep -c '^COPY ' ~/pg18-upgrade/immich.sql.gz
```

## 3. Strip the vector indexes from the dump

`clip_index` and `face_index` were built by VectorChord 0.4.3; replaying that DDL against
1.1.1 is the least predictable part of the restore, and rebuilding them is slow enough
that you do not want it inside the restore transaction either. They are derived data —
Immich recreates them on startup — so drop them from the dump and let it. This also
leaves the 14 cluster completely untouched as a rollback.

```sh
zcat ~/pg18-upgrade/immich.sql.gz \
  | grep -vE '^CREATE INDEX (clip_index|face_index) ' \
  | gzip > ~/pg18-upgrade/immich-noidx.sql.gz

# Expect: 2 before, 0 after
zgrep -cE '^CREATE INDEX (clip_index|face_index) ' ~/pg18-upgrade/immich.sql.gz
zgrep -cE '^CREATE INDEX (clip_index|face_index) ' ~/pg18-upgrade/immich-noidx.sql.gz
```

If the first count is not 2, look at what the statements actually are before filtering
blind — `zgrep 'vchordrq' ~/pg18-upgrade/immich.sql.gz`.

## 4. Swap the data directory and the image

Move the old cluster aside rather than deleting it — it is the rollback.

```sh
docker compose down
mv ~/cloud-data/immich/postgres ~/cloud-data/immich/postgres-pg14
mkdir ~/cloud-data/immich/postgres
```

The new directory must be owned by `1000:1000`; the compose file runs the DB as that uid,
and the image creates `18/docker` inside it.

Then take the compose change, and confirm both halves of it landed — the tag *and* the
mount point:

```sh
git -C ~/cloud-config pull
grep -A14 '^  database:' docker-compose.yml
```

```yaml
    image: ghcr.io/immich-app/postgres:18-vectorchord1.1.1-pgvector0.8.5@sha256:6e384bf4aa03866473395961786f40006555e4cd008b98f92bf4a44e5ab7b012
    volumes:
      - ${DB_DATA_LOCATION}:/var/lib/postgresql
```

## 5. Initialise and restore

```sh
docker compose create
docker start immich_postgres
docker compose logs -f database   # wait for "database system is ready to accept connections"
```

Confirm the cluster landed where it should before restoring into it — this is the check
that catches the wrong mount point while it is still cheap:

```sh
ls ~/cloud-data/immich/postgres          # expect: 18
docker exec -i immich_postgres psql -U "$DB_USERNAME" -d "$DB_DATABASE_NAME" -Atc "show data_directory"
```

Restore, with the `search_path` rewrite and error handling from the notes above:

```sh
gunzip --stdout ~/pg18-upgrade/immich-noidx.sql.gz \
  | sed "s/SELECT pg_catalog.set_config('search_path', '', false);/SELECT pg_catalog.set_config('search_path', 'public, pg_catalog', true);/g" \
  | docker exec -i immich_postgres psql --username="$DB_USERNAME" --dbname="$DB_DATABASE_NAME" \
      --single-transaction --set ON_ERROR_STOP=on
```

A freshly restored cluster has no planner statistics, which makes the first minutes of
Immich far slower than the old install:

```sh
docker exec -i immich_postgres vacuumdb --analyze --username="$DB_USERNAME" --dbname="$DB_DATABASE_NAME"
```

## 6. Start and verify

```sh
docker compose up -d
docker compose logs -f server
```

`Reindexing clip_index` / `Reindexing face_index` is expected here — that is Immich
building the indexes stripped in step 3, and on a large library it can sit there for many
minutes. It is only a problem if it errors, or if the indexes never appear:

```sh
docker exec -i immich_postgres psql -U "$DB_USERNAME" -d "$DB_DATABASE_NAME" -Atc \
  "select indexname from pg_indexes where indexname in ('clip_index','face_index')"
```

If they are still missing once the server is idle, create them by hand via
[the manual VectorChord migration steps](https://docs.immich.app/administration/postgres-standalone/#migrating-from-pgvectors).

```sh
docker exec -i immich_postgres psql -U "$DB_USERNAME" -d "$DB_DATABASE_NAME" -Atc "show server_version"
docker exec -i immich_postgres psql -U "$DB_USERNAME" -d "$DB_DATABASE_NAME" -Atc \
  "select extname, extversion from pg_extension order by extname"
docker exec -i immich_postgres psql -U "$DB_USERNAME" -d "$DB_DATABASE_NAME" -Atc \
  "select relname, n_live_tup from pg_stat_user_tables order by n_live_tup desc limit 10" \
  | diff ~/pg18-upgrade-rowcounts-before.txt -
```

If background jobs behave oddly afterwards, Redis is still holding the queue state from
before the cutover; `docker compose stop redis && rm -rf ~/cloud-data/immich/redis/* &&
docker compose up -d redis` clears it, at the cost of re-queuing outstanding work.

Then confirm in the app, since a restore can be structurally complete and still leave
Immich broken: log in, load the timeline, open an asset, and **run a search** — search is
what actually exercises VectorChord.

## Rollback

Until the old directory is deleted, rollback is a directory swap plus reverting the
compose change. Both parts matter: the old image needs the old mount point back.

```sh
cd ~/cloud-config/immich
docker compose down
mv ~/cloud-data/immich/postgres ~/cloud-data/immich/postgres-pg18-failed
mv ~/cloud-data/immich/postgres-pg14 ~/cloud-data/immich/postgres
git -C ~/cloud-config checkout <commit before the upgrade> -- immich/docker-compose.yml
docker compose up -d
```

## Cleanup

Once Immich has run normally long enough to cover a backup cycle and the nightly jobs:

```sh
rm -rf ~/cloud-data/immich/postgres-pg14
rm -rf ~/pg18-upgrade ~/pg18-upgrade-rowcounts-before.txt
```
