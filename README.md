# noizwaves.cloud

A self hosted cloud

## Setup
1.  Create a new Ubuntu 20.04 VM
    1.  Username `adam`
    1.  SSH Server installed
1.  Install SSH key for `adam`
1.  Take VM snapshot

## Firewall
1.  `$ sudo ufw enable`
1.  `$ sudo ufw allow 22/tcp`
1.  `$ sudo ufw allow 80/tcp`
1.  `$ sudo ufw allow 443/tcp`
1.  `$ sudo ufw reload`

## Docker
1.  `$ sudo apt install -y docker.io docker-compose`
1.  `$ sudo usermod -aG docker adam`
1.  `$ docker network create web`

## Traefik
1.  `$ cd traefik`
1.  `$ cp .envrc.tmpl .envrc`
1.  Input appropriate values
1.  `$ docker-compose up -d`

## Seafile
1.  `$ cd seafile`
1.  `$ cp .envrc.tmpl .envrc`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Log in and update `SERVICE_URL` & `FILE_SERVER_ROOT`
1.  Edit the value of `FILE_SERVER_ROOT` in `/opt/seafile-data/seafile/conf/seahub_settings.py`
