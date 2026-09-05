# Vikunja

1.  `$ mkdir -p ~/cloud-data/vikunja/files ~/cloud-data/vikunja/mariadb`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Open [Vikunja](https://vikunja.noizwaves.cloud)

## Upgrading 0.24.x to 2.x

The 0.24 -> 1.0 schema migration renames the team permission column and is the
riskiest step; take a real dump first, because the file-level restic backup of a
running MariaDB is not guaranteed consistent.

1.  Take the instance down so nothing writes mid-dump
    1.  `$ docker-compose stop app`
1.  Dump the database and snapshot the attachments
    1.  `$ docker-compose exec db mysqldump -u root -p vikunja > ~/vikunja-pre-2.x.sql`
    1.  `$ sudo cp -a ~/cloud-data/vikunja/files ~/vikunja-files-pre-2.x`
1.  Update `.env` for the renamed secret
    1.  Rename `VIKUNJA_SERVICE_JWTSECRET` to `VIKUNJA_SERVICE_SECRET`
    1.  Delete the duplicate `VIKUNJA_SERVICE_JWTTTL` line, keeping one
1.  Confirm `~/cloud-data/vikunja/files` is writable by uid 1000 — since v1.0
    Vikunja verifies this at startup and exits if it fails
1.  `$ docker-compose up -d`
1.  Watch the migrations run: `$ docker-compose logs -f app`
1.  Strip inline-rendering from attachments uploaded before the SVG XSS fix
    1.  `$ docker-compose exec app /app/vikunja/vikunja repair file-mime-types`
1.  Log in (every existing session is invalidated by the 2.0 auth rebuild) and
    check that projects, tasks, teams and attachments are all present

### Rolling back

Restoring the dump requires the 0.24.6 image — the 2.x schema is not backward
compatible, and 0.24.6 will not start against a migrated database.

1.  `$ docker-compose down`
1.  Pin `image:` back to `vikunja/vikunja:0.24.6` and revert `.env`
1.  Drop and recreate the database, then
    `$ docker-compose exec -T db mysql -u root -p vikunja < ~/vikunja-pre-2.x.sql`
1.  `$ docker-compose up -d`
