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

## Public proxy

1.  Create instance
1.  `ufw` enable 22 and 443 only
1.  Create and install custom Origin CA certificate from Cloudflare (following [1](https://autoize.com/why-cloudflares-flexible-ssl-setting-is-unsafe/), [2](https://support.cloudflare.com/hc/en-us/articles/115000479507#h_30e5cf09-6e98-48e1-a9f1-427486829feb), and [3](https://www.digicert.com/kb/csr-ssl-installation/nginx-openssl.htm#ssl_certificate_install))
1.  Install [Origin Pull CA](https://support.cloudflare.com/hc/en-us/articles/204899617-Authenticated-Origin-Pulls)
1.  Configure Cloudflare for
    1.  SSL/TLS encryption mode to `Full (strict)`
    1.  Always Use HTTPS to `On`
    1.  Automatic HTTPS Rewrites to `On`
    1.  Authenticated Origin Pulls to `On`
1.  Configure NGINX with `noizwaves-cloud-proxy.conf`:
    ```
    server {
        listen 443;
        ssl_certificate /etc/nginx/cf_origin_noizwaves.cloud.crt;
        ssl_certificate_key /etc/nginx/cf_origin_noizwaves.cloud.key;

        ssl_client_certificate /etc/ssl/certs/origin-pull-ca.pem;
        ssl_verify_client on;

        server_name authelia.noizwaves.cloud seafile.noizwaves.cloud nextcloud.noizwaves.cloud;

        location / {
                proxy_set_header X-Forwarded-For $remote_addr;
                proxy_set_header Host $host;
                proxy_pass https://10.242.64.186:443;
        }
    }
    ```

## Maintenance

### Upgrading to newer images

1.  Update tags to desired newer value
1.  Recreate containers via `$ docker-compose up --force-recreate --build -d`