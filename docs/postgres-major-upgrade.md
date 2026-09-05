# Postgres major version upgrades

Postgres data directories are not forward compatible across major versions. Bumping
the image tag alone leaves the server refusing to start against the existing cluster,
so every major bump needs a dump, a fresh `initdb`, and a restore.

This runbook was written for the 15/16 -> 18 upgrade of `atuin`, `sure` and `tandoor`,
but the shape applies to any future major bump.

## The PGDATA move in Postgres 18

Postgres 18 relocated the image defaults:

| | 16 and earlier | 18 |
| --- | --- | --- |
| `PGDATA` | `/var/lib/postgresql/data` | `/var/lib/postgresql/18/docker` |
| Declared volume | `/var/lib/postgresql/data` | `/var/lib/postgresql` |

A compose file still bind mounting to `/var/lib/postgresql/data` gets no error. The
server initialises a brand new empty cluster at the container-local `PGDATA` and the
app comes up looking freshly installed, so the data loss only becomes obvious once the
container is recreated. Mount the parent instead and let the image pick the path:

```yaml
volumes:
  - ../../cloud-data/<app>/postgres:/var/lib/postgresql
```

The version now lives inside the data directory (`postgres/18/docker/`), which is what
lets a future `19` cluster be built alongside the old one.

## Per-service parameters

| Service | Compose dir | DB container | Compose network | DB host | Role / database |
| --- | --- | --- | --- | --- | --- |
| atuin | `atuin/` | `atuin_postgres` | `atuin_backend` | `db` | `atuin` / `atuin` |
| sure | `sure/` | `sure_db` | `sure` | `db` | `sure_user` / `sure_production` |
| tandoor | `tandoor/` | `tandoor_postgres` | `tandoor_backend` | `postgres` | `djangouser` / `djangodb` |

All three clusters hold a single application database and a single role, which happens
to be the superuser the entrypoint creates from `POSTGRES_USER`. That is why a plain
`pg_dump` of the one database is enough — there are no extra roles or databases for
`pg_dumpall` to carry across, and the entrypoint recreates the role and the empty
database on first boot. Confirm this still holds before reusing the runbook:

```sh
docker exec <db container> psql -U <role> -d <db> -Atc \
  "select rolname from pg_roles where rolname not like 'pg\_%'"
docker exec <db container> psql -U <role> -d <db> -Atc \
  "select datname from pg_database where not datistemplate"
```

Extensions in use (`pgcrypto`, `pg_trgm`, `unaccent`) all ship with the official image,
so nothing extra needs installing. `pg_dump` emits its own `CREATE EXTENSION`
statements.

## Procedure

Run one service at a time and confirm it is healthy before starting the next. All
commands run on the host as `cloud`, from `~/cloud-config`.

### 1. Dump

Quiesce the app so nothing writes mid-dump, then dump with the **new** version's
`pg_dump` — Postgres supports a newer dump client against an older server, not the
reverse.

```sh
mkdir -p ~/pg18-upgrade
cd ~/cloud-config/<app>

docker compose stop <app services>   # everything except the db

docker run --rm --network <compose network> \
  -e PGPASSWORD="$(docker inspect <db container> \
    --format '{{range .Config.Env}}{{println .}}{{end}}' \
    | sed -n 's/^POSTGRES_PASSWORD=//p')" \
  postgres:18-alpine \
  pg_dump -h <db host> -U <role> -d <database> \
  > ~/pg18-upgrade/<app>.sql
```

Sanity check the dump before going any further — a truncated dump that is never read
back is the main way this procedure loses data:

```sh
tail -1 ~/pg18-upgrade/<app>.sql   # expect: -- PostgreSQL database dump complete
grep -c '^COPY ' ~/pg18-upgrade/<app>.sql
```

### 2. Swap the data directory

Move the old cluster aside rather than deleting it. It is the rollback, and these
directories are under 100 MB each.

```sh
docker compose down
mv ~/cloud-data/<app>/postgres ~/cloud-data/<app>/postgres-pg<old major>
mkdir ~/cloud-data/<app>/postgres
```

The new directory must be owned by `1000:1000` — the compose files run the DB as that
uid, and the entrypoint creates `18/docker` inside it.

### 3. Initialise and restore

```sh
docker compose up -d <db service>
docker compose logs -f <db service>   # wait for "database system is ready to accept connections"

docker run --rm -i --network <compose network> \
  -e PGPASSWORD="..." \
  postgres:18-alpine \
  psql -v ON_ERROR_STOP=1 -h <db host> -U <role> -d <database> \
  < ~/pg18-upgrade/<app>.sql
```

`ON_ERROR_STOP=1` matters. Without it `psql` reports success after skipping every
statement it could not apply.

### 4. Start and verify

```sh
docker compose up -d
```

Check the server version, that the tables came back, and that the app itself reads its
own data — a restore can succeed structurally while the app fails on something like a
missing sequence value.

```sh
docker exec <db container> psql -U <role> -d <database> -Atc "show server_version"
docker exec <db container> psql -U <role> -d <database> -Atc \
  "select count(*) from information_schema.tables where table_schema = 'public'"
```

## Rollback

Until the old directory is deleted, rollback is a directory swap plus reverting the
compose change:

```sh
cd ~/cloud-config/<app>
docker compose down
mv ~/cloud-data/<app>/postgres ~/cloud-data/<app>/postgres-pg18-failed
mv ~/cloud-data/<app>/postgres-pg<old major> ~/cloud-data/<app>/postgres
git -C ~/cloud-config checkout <previous commit> -- <app>/docker-compose.yml
docker compose up -d
```

## Cleanup

Once all three services have run normally for a while — long enough to cover a backup
cycle and any weekly/monthly app jobs — drop the old clusters and dumps:

```sh
rm -rf ~/cloud-data/atuin/postgres-pg15 \
       ~/cloud-data/sure/postgres-pg16 \
       ~/cloud-data/tandoor/postgres-pg16
rm -rf ~/pg18-upgrade
```

Leaving them costs ~240 MB, so there is no hurry.
