# BookOrbit

1. `mkdir -p ~/cloud-data/bookorbit/{postgres,data}` as the host user with UID/GID `1000:1000`.
1. `cp .env.tmpl .env` and populate each secret with an independent value from `openssl rand -hex 32`.
1. Ensure `CLOUD_DOMAIN` and `TZ` are set in the shared `.envrc`, Traefik is running on the external `web` network, and DNS for `bookorbit.${CLOUD_DOMAIN}` points to the host.
1. `docker compose up -d`
1. Visit [BookOrbit](https://bookorbit.noizwaves.cloud) and create the administrator account using `SETUP_BOOTSTRAP_TOKEN` from `.env`.
1. Create a library with the folder `/books`.

The existing `/mnt/media2/Books` library is mounted read-only. Reading and scanning are available; uploads, Book Dock finalization into this library, and metadata writes to book files require a writable mount.

App data and PostgreSQL are stored under `~/cloud-data/bookorbit`. Include `bookorbit` and `bookorbit_postgres` in the host's backup container stop/start list before backing up these directories.

See the upstream [installation guide](https://bookorbit.app/installation).
