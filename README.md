# noizwaves.cloud

A self hosted cloud

## Setup
1.  Create a new Ubuntu 20.04 VM
    1.  Username `adam`
    1.  SSH Server installed
    1.  NTP `$ sudo apt install ntp`
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
1.  `$ sudo systemctl enable docker`
1.  `$ docker network create web`

## Traefik
1.  `$ cd traefik`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`

## Authelia
1.  `$ cd authelia`
1.  Create a user database
    1.  `$ cp config/users_database.yml.tmpl config/users_database.yml`
    1.  Follow steps in comments to create users
1.  Create secrets
    1.  `$ openssl rand -base64 32 > .secrets/jwt.txt`
    1.  `$ openssl rand -base64 32 > .secrets/session.txt`
    1.  `$ openssl rand -base64 32 > .secrets/mysql_password.txt`
1.  `$ docker-compose up -d`

## Bitwarden
1.  `$ cd bitwarden_rs`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  Change value of `SIGNUPS_ALLOWED` to `'true'`
1.  `$ docker-compose up -d`
1.  Create user
1.  Change value of `SIGNUPS_ALLOWED` to `'false'`
1.  `$ docker-compose up -d`

## Seafile
1.  `$ cd seafile`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Log in, navigate to `System Admin > Settings` and update `SERVICE_URL` & `FILE_SERVER_ROOT`
1.  Edit config files at `SEAFILE_DATA=$(docker volume inspect seafile_data --format '{{ .Mountpoint }}')`
    1.  Edit the value of `FILE_SERVER_ROOT` in `$SEAFILE_DATA/seafile/conf/seahub_settings.py`
    1.  Edit the value of `enabled` in `$SEAFILE_DATA/seafile/conf/seafdav.conf`
    1.  Edit `$SEAFILE_DATA/seafile/conf/ccnet.conf`
1.  Restart memcached `$ docker-compose restart memcached`

## Nextcloud
1.  `$ cd nextcloud`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  Update the value of `TRUSTED_PROXIES` in the `docker-compose.yml` file
1.  `$ docker-compose up -d`
1.  Open [Nextcloud](https://nextcloud.noizwaves.cloud)
1.  Configure application to use MySQL with the following settings:
    1.  Database name: `nextcloud`
    1.  Username: `nextcloud`
    1.  Password: value from `.env`
    1.  Host: `mariadb`
1.  Edit `/config/www/nextcloud/config/config.php`
    1.  Add `trusted_proxies` array that includes `web` network CIDR (`$ docker network inspect web`)

## FreshRSS
1.  `$ cd freshrss`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Open [FreshRSS](https://freshrss.noizwaves.cloud)
1.  Configure application

## Duplicati
1.  `$ cd duplicati`
1.  `$ docker-compose up -d`
1.  Configure [Duplicati](https://duplicati.noizwaves.cloud/ngax/index.html#/settings) appropriately
    1.  Add web password
    1.  Restrict access to `duplicati.noizwaves.cloud`
1.  Configure backups appropriately

## Private SSH-based proxy

### Server

1.  Create instance
1.  `ufw` enable 22
1.  Configure NGINX with `noizwaves-cloud-private-proxy.conf`:
    ```
    stream {
        upstream web_server {
            server 192.168.196.57:443;
        }

        server {
            listen 8443;
            proxy_pass web_server;
        }
    }
    ```

### Client

1.  `$ cd proxy_client`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values for the server
1.  `$ docker network create noizwaves_cloud_proxy`
1.  `$ docker-compose up -d`
1.  Find proxy container's IP address (`$IP_ADDRESS`) in `$ docker-compose logs -f`
1.  Add entry to `/etc/hosts` that resolve to `$IP_ADDRESS`, ie:
    ```
    $IP_ADDRESS    bitwarden.noizwaves.cloud nextcloud.noizwaves.cloud seafile.noizwaves.cloud authelia.noizwaves.cloud monitor.noizwaves.cloud
    ```

## Maintenance

### Upgrading to newer images

1.  Update tags to desired newer value
1.  Recreate containers via `$ docker-compose up --force-recreate --build -d`