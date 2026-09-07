# FileBrowser Quantum

Configuration lives in [config.yaml](./config.yaml) and is mounted read-only into the container, so
changes are made here rather than on the host.

## Setup

1.  `$ mkdir -p ~/cloud-data/filebrowser/data`
1.  `$ docker compose up -d`
1.  Open [Filebrowser](https://filebrowser.noizwaves.cloud)

Authelia handles the login and passes the username through the `Remote-User` header, so there is no
password to set. The account is created on first request, and `adam` is granted admin.

The first indexing pass over the media sources takes a while. Follow it with
`$ docker compose logs -f`.

## Changing configuration

1.  Edit [config.yaml](./config.yaml)
1.  `$ docker compose up -d --force-recreate`

## Migrating from Filebrowser

[Upstream filebrowser was archived](https://hacdias.com/2026/07/28/filebrowser/) on 2026-09-01 with
known session token and logout vulnerabilities that will not be fixed. Quantum is a fork with no
import path from the old database, so users, shares and per-user settings do not carry over —
existing share links are gone for good.

The old data is left behind at `~/cloud-data/filebrowser/{database,config}` so the previous image
can be brought back if needed. Delete those directories once the new deployment is trusted.
