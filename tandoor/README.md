# Tandoor

1.  `$ mkdir -p ~/cloud-data/tandoor/postgres ~/cloud-data/tandoor/staticfiles ~/cloud-data/tandoor/mediafiles`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Open [Tandoor](https://tandoor.noizwaves.cloud)

## Upgrading an existing deployment

`.env` is a one-time copy of the template, so new settings do not reach a running
instance. To pick up the redis cache, add `REDIS_HOST` and `REDIS_PORT` to the
existing `.env` before `docker-compose up -d`.
