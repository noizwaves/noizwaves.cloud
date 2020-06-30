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

## Traefik
1.  `$ cd traefik`
1.  `$ cp .envrc.tmpl .envrc`
1.  Input appropriate values
1.  `$ docker-compose up -d`
