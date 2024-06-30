# noizwaves.cloud

A self hosted cloud

## Requirements

1.  Install Ansible locally via `brew install ansible ansible-lint`
1.  Install Ansible packages via:
    1.   `ansible-galaxy install willshersystems.sshd`

## Setup

1.  `ansible-playbook -i inventory.yaml playbook.yaml`
1.  SSH into nodes and manage individual applications directly

### Adding new machines

For each new machine:

1.  Install Ubuntu LTS
    1.  Username: `cloud`
    1.  Enable SSH server
    1.  Import SSH keys from GitHub
1.  Bootstrap using `bash <(curl https://raw.githubusercontent.com/noizwaves/noizwaves.cloud/main/ansible/bootstrap.sh)`
1.  Connect to Tailscale
1.  Setup crontabs
1.  Add to the inventory and ssh config

### Automation

1.  `$ crontab -e`
1.  Enable automated daily 1am hot backups with this cron config:
```
SHELL=/bin/bash
MAILTO=""
HOME=/home/cloud

0 1 * * * ./cloud-config/hot_backup.sh >>cloud-config/hot_backup.log 2>&1
```
1.  Enable DNS healthchecks with cron config:
```
*/2 * * * * host www.google.com 127.0.0.1 && <healthchecks.io health check>
```
## K3s (Kubernetes)
See [here](./k3s/README.md)

## Traefik
1.  `$ cd traefik`
1.  `$ mkdir -p ~/cloud-data/traefik/letsencrypt`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Open Traefik dashboard at `https://traefik.odroid.noizwaves.cloud`

## Watchtower
1.  `$ cd watchtower`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`

## Pi-hole
1.  `$ cd pihole`
1.  `$ mkdir -p ~/cloud-data/pihole/config ~/cloud-data/pihole/dnsmasq`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`

## Authelia
1.  `$ cd authelia`
1.  `$ mkdir -p ~/cloud-data/authelia/mariadb ~/cloud-data/authelia/redis`
1.  Create a user database
    1.  `$ cp config/users_database.yml.tmpl config/users_database.yml`
    1.  Follow steps in comments to create users
1.  Create configuration
    1.  `$ cp config/configuration.yml.tmpl config/configuration.yml`
    1.  Replace all `${CLOUD_DOMAIN}` with desired value
1.  Create secrets
    1.  `$ mkdir -p .secrets`
    1.  `$ openssl rand -base64 32 > .secrets/jwt.txt`
    1.  `$ openssl rand -base64 32 > .secrets/session.txt`
    1.  `$ openssl rand -base64 32 > .secrets/mysql_password.txt`
    1.  `$ cp .env.tmpl .env`
    1.  Fill in appropriate values
1.  `$ docker-compose up -d`

## Minio
1. `$ cd minio`
1. `$ mkdir -p ~/cloud-data/minio/data`
1. `$ cp .env.tmpl .env`
1. Fill in appropriate values
1. `$ docker-compose up -d`
1. Navigate to [Minio Console](https://minio.dell.noizwaves.cloud)
1. Use S3-compatible API using:
    - Bucket Name: `s3://BUCKET_NAME`
    - Endpoint URL: `https://s3.dell.noizwaves.cloud`
    - Region Name: `dell`

## InfluxDB
1. `$ cd influxdb`
1. `$ mkdir -p ~/cloud-data/influxdb/data`
1. `$ docker-compose up -d`
1. Visit [influxdb](https://influxdb.noizwaves.cloud) and set up data collection

## Bitwarden
1.  `$ cd bitwarden`
1.  `$ mkdir -p ~/cloud-data/bitwarden/data`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  Change value of `SIGNUPS_ALLOWED` to `'true'`
1.  `$ docker-compose up -d`
1.  Create user
1.  Change value of `SIGNUPS_ALLOWED` to `'false'`
1.  `$ docker-compose up -d`

## Speedtest
1.  `$ cd speedtest`
1.  `$ docker-compose up -d`
1.  Visit [Speedtest](https://speedtest.noizwaves.cloud)

## UpSnap
1. `$ cd upsnap`
1. `$ mkdir -p ~/cloud-data/upsnap/data`
1. `$ docker-compose up -d`
1. Visit [UpSnap](http://upsnap.noizwaves.cloud:8090)

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
1.  `$ mkdir -p ~/cloud-data/nextcloud/data ~/cloud-data/nextcloud/config ~/cloud-data/nextcloud/mariadb`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Open [Nextcloud](https://nextcloud.noizwaves.cloud)
1.  Configure application to use MySQL with the following settings:
    1.  Database name: `nextcloud`
    1.  Username: `nextcloud`
    1.  Password: value from `.env`
    1.  Host: `mariadb`
1.  Edit `/config/www/nextcloud/config/config.php`
    1.  Add `trusted_proxies` array that includes `web` network CIDR (`$ docker network inspect web`)

## Resilio Sync
1.  `$ cd resilio-sync`
1.  `$ mkdir -p ~/cloud-data/resilio-sync/data ~/cloud-data/resilio-sync/config`
1.  `$ docker-compose up -d`
1.  Open [Resilio Sync](https://resilio.noizwaves.cloud)
1.  Configure application

## FreshRSS
1.  `$ cd freshrss`
1.  `$ mkdir -p ~/cloud-data/freshrss/config ~/cloud-data/freshrss/mariadb`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Open [FreshRSS](https://freshrss.noizwaves.cloud)
1.  Configure application
    1.  Database type: `MySQL`
    1.  Host: `mariadb`
    1.  Database username: `freshrss`
    1.  Database password: `<value from .env file>`
    1.  Database: `freshrss`
    1.  Table prefix: `` (empty string)

## Standard Notes
1.  `$ cd ~/cloud-config/standardnotes`
1.  `$ mkdir -p ~/cloud-data/standardnotes/mariadb`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Open [Standard Notes web](https://notes-web.noizwaves.cloud)
1.  Create account
1.  Install extensions (via `Extensions > Import Extension > url > Enter > Install`):
    - https://notes.noizwaves.cloud/extensions/markdown-pro/extension.json
    - https://notes.noizwaves.cloud/extensions/folders/extension.json

## Fotos
1.  `$ cd fotos`
1.  `$ mkdir -p ~/cloud-data/fotos/thumbnails/v2 ~/cloud-data/fotos/normals`
1.  Create WebDAV credentials via `$ htpasswd -c credentials.list <username>` and then enter the password.
1.  `$ docker-compose up -d`

1.  `$ cd .../fotos-lauren`
1.  `$ mkdir -p ~/cloud-data/fotos-lauren/thumbnails/v2 ~/cloud-data/fotos-lauren/normals`
1.  Create WebDAV credentials via `$ htpasswd -c credentials.list <username>` and then enter the password.
1.  `$ docker-compose up -d`

## Firefly III
1.  `$ cd firefly-iii`
1.  `$ mkdir -p ~/cloud-data/firefly-iii/export ~/cloud-data/firefly-iii/upload ~/cloud-data/firefly-iii/mariadb`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Open [Firefly III](https://firefly.noizwaves.cloud)

## PhotoStructure
1.  `$ cd photostructure`
1.  `$ mkdir -p ~/cloud-data/photostructure/library ~/cloud-data/photostructure/tmp ~/cloud-data/photostructure/config ~/cloud-data/photostructure/logs`
1.  `$ docker-compose up -d`
1.  Open [Photostructure](https://photostructure.noizwaves.cloud)

## Photoprism
1.  `$ cd photoprism`
1.  `$ mkdir -p ~/cloud-data/photoprism/storage`
1.  `$ docker-compose up -d`
1.  Open [Photoprism](https://photoprism.noizwaves.cloud)

## Tandoor
1.  `$ cd tandoor`
1.  `$ mkdir -p ~/cloud-data/tandoor/postgres ~/cloud-data/tandoor/staticfiles ~/cloud-data/tandoor/mediafiles`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Open [Tandoor](https://tandoor.noizwaves.cloud)

## Plex (inspired by [pierre-emmanuelJ/plex-traefik](https://github.com/pierre-emmanuelJ/plex-traefik))
1.  `$ cd plex`
1.  `$ mkdir -p ~/cloud-data/plex/config ~/cloud-data/plex/data ~/cloud-data/plex/transcode`
1.  Generate a [claim](https://www.plex.tv/claim)
1.  `$ docker-compose up -d`
1.  Open [Plex](https://plex.noizwaves.cloud)

### AV1 Direct Play to AppleTV
This [moves AV1 transcoding](https://github.com/currifi/plex_av1_tvos) from the server onto the AppleTV.
1.  `$ curl -Ls -o ~/cloud-data/plex/config/Library/Application\ Support/Plex\ Media\ Server/Profiles/tvOS.xml https://raw.githubusercontent.com/currifi/plex_av1_tvos/main/tvOS.xml`
1.  `$ docker-compose restart`

## Registry (Docker container registry)
1.  `$ cd registry`
1.  `$ mkdir -p ~/cloud-data/registry/data`
1.  `$ docker compose up -d`
1.  `$ docker login registry.noizwaves.cloud`

## Focalboard
1.  `$ cd focalboard`
1.  `$ mkdir ~/cloud-data/focalboard/files`
1.  `$ touch ~/cloud-data/focalboard/focalboard.db`
1.  `$ cp config.json.tmpl ~/cloud-data/focalboard/config.json`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Open [Focalboard](https://focalboard.noizwaves.cloud)

## Filebrowser
1.  `$ cd filebrowser`
1.  `$ mkdir ~/cloud-data/filebrowser`
1.  `$ touch ~/cloud-data/filebrowser/database.db`
1.  `$ cp filebrowser.json.tmpl ~/cloud-data/filebrowser/filebrowser.json`
1.  Input appropriate values
1.  Initialize configuration by running
    ```
    $ docker run --rm \
        -v /home/cloud/cloud-data/filebrowser/filebrowser.json:/.filebrowser.json \
        -v /home/cloud/cloud-data/filebrowser/database.db:/database.db \
        filebrowser/filebrowser \
        config init
    ```
1.  Switch to Proxy Header based authentication method by running
    ```
    $ docker run --rm \
        -v /home/cloud/cloud-data/filebrowser/filebrowser.json:/.filebrowser.json \
        -v /home/cloud/cloud-data/filebrowser/database.db:/database.db \
        filebrowser/filebrowser \
        config set --auth.method=proxy --auth.header=Remote-User
    ```
1.  Create admin users by running
    ```
    $ docker run --rm \
        -v /home/cloud/cloud-data/filebrowser/filebrowser.json:/.filebrowser.json \
        -v /home/cloud/cloud-data/filebrowser/database.db:/database.db \
        filebrowser/filebrowser \
        users add $USERNAME $PASSWORD --perm.admin=true --perm.execute=false
    ```
1.  `$ docker-compose up -d`
1.  Open [Filebrowser](https://filebrowser.noizwaves.cloud)

## Adguard Home
For private network DNS resolution
1.  `$ cd adguard`
1.  `$ mkdir -p ~/cloud-data/adguard/work ~/cloud-data/adguard/conf ~/cloud-data/adguard/tailscale`
1.  `$ docker-compose up -d`
1.  Open [Adguard Home](http://adguard.dell.noizwaves.cloud) and set it up

## Running
1.  `$ cd running`
1.  `$ docker-compose up -d`
1.  Open [Running](https://running.noizwaves.cloud)

## Vikunja
1.  `$ cd vikunja`
1.  `$ mkdir -p ~/cloud-data/vikunja/files ~/cloud-data/vikunja/mariadb`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  Clone source code
    1.  `$ mkdir ~/workspace`
    1.  `$ git clone https://kolaente.dev/vikunja/api.git ~/workspace/vikunja-api`
    1.  `$ git clone https://kolaente.dev/vikunja/frontend.git ~/workspace/vikunja-frontend`
1.  `$ docker-compose up -d`
1.  Open [Vikunja](https://vikunja.noizwaves.cloud)

## Syncthing
1.  `$ cd syncthing`
1.  `$ mkdir -p ~/cloud-data/syncthing/config`
1.  `$ docker-compose up -d`
1.  Open [Syncthing](https://syncthing.noizwaves.cloud)
1.  Open [Vikunja](https://vikunja.noizwaves.cloud)

## Gitea
1.  `$ cd gitea`
1.  `$ mkdir -p ~/cloud-data/gitea/data`
1.  `$ docker-compose up -d`
1.  Open [Gitea](https://gitea.noizwaves.cloud) and complete initialization
1.  Update configuration
    1. `webhook.ALLOWED_HOST_LIST` to `*.noizwaves.cloud`

## Drone
1.  `$ cd drone`
1.  `$ mkdir -p ~/cloud-data/drone/data`
1.  `$ cp .env.tmpl .env`
1.  Update values in `.env`
1.  `$ docker-compose up -d`
1.  Open [Drone](https://drone.noizwaves.cloud) and complete installation

## Trilio
1.  `$ cd trilio`
1.  `$ mkdir -p ~/cloud-data/trilio`
1.  `$ docker-compose up -d`
1.  Open [Trilio](https://trilio.noizwaves.cloud)

## Matrix (Synapse)
1.  `$ cd matrix`
1.  `$ mkdir -p ~/cloud-data/matrix/data ~/cloud-data/matrix/postgres ~/cloud-data/matrix/telegram`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose run --rm -e SYNAPSE_SERVER_NAME=matrix.noizwaves.cloud -e SYNAPSE_REPORT_STATS=no synapse generate`
1.  Edit Synapse config using `$ vim ~/cloud-data/matrix/data/homeserver.yaml`
1.  Generate Telegram config using `$ docker-compose run --rm telegram`
1.  Edit Telegram config using `$ vim ~/cloud-data/matrix/telegram/config.yaml`
1   Generate Telegram appservice registration using `$ docker-compose run --rm telegram`
1.  `$ docker-compose up -d`
1.  Register users by running `$ docker-compose exec synapse register_new_matrix_user -c /data/homeserver.yaml http://localhost:8008`
1.  Open [Synapse](https://matrix.noizwaves.cloud)

### iMessage Bridge
Based upon the [instructions](https://docs.mau.fi/bridges/go/imessage/mac/setup.html).

Prepare synapse on server:
1.  `$ cd matrix`
1.  `$ mkdir -p ~/cloud-data/matrix/imessage plugins`
1.  `$ wget -o plugins/shared_secret_authenticator.py https://raw.githubusercontent.com/devture/matrix-synapse-shared-secret-auth/master/shared_secret_authenticator.py`
1.  Edit `~/cloud-data/matrix/data/homeserver.yaml` and add a new item to `password_providers`:
    ```yaml
    - module: "shared_secret_authenticator.SharedSecretAuthenticator"
        config:
        sharedSecret: "${SHARED_SECRET_AUTH_SECRET}"
    ```
    Where:
    - `SHARED_SECRET_AUTH_SECRET` = `$ pwgen -s 128 1`

Prepare bridge on mac:
1.  Identify mac to use to run bridge and setup iCloud (Messages and Contacts)
1.  Download latest release of [mautrix-imessage](https://mau.dev/mautrix/imessage/-/pipelines?scope=branches&page=1) to mac
1.  Extract to a folder
1.  `$ cp example-config.yaml config.yaml` and edit values:
    - `homeserver.address` to `https://matrix.noizwaves.cloud`
    - `homeserver.websocket_proxy` to `wss://matrix-wsproxy.noizwaves.cloud`
    - `homeserver.domain` to `noizwaves.cloud`
    - `bridge.user` to `@adam:noizwaves.cloud`
    - `bridge.login_shared_secret` to `${SHARED_SECRET_AUTH_SECRET}`
1.  `$ ./mautrix-imessage -g`
1.  Ensure that `config.yaml` contains `appservice.as_token` and `appservice.hs_token` from `registration.yaml`
1.  Copy `registration.yaml` from mac to `~/cloud-data/matrix/imessage/registration.yaml` on server

Prepare wsproxy on server:
1.  `cp .env_wsproxy.tmpl .env_wsproxy`
1.  Input appropriate values (from `~/cloud-data/matrix/imessage/registration.yaml`)
1.  Ensure that the `~/cloud-data/matrix/imessage:/bridges/imessage` volume mount is present for `synapse`
1.  `$ docker-compose up -d synapse wsproxy`

Start iMessage bridge on mac:
1.  `$ ./mautrix-imessage` (and if required, grant permission to read Contacts)

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
    $IP_ADDRESS    bitwarden.noizwaves.cloud nextcloud.noizwaves.cloud seafile.noizwaves.cloud authelia.noizwaves.cloud traefik.noizwaves.cloud
    ```

## Maintenance

### Upgrading to newer images

1.  Update tags to desired newer value
1.  Recreate containers via `$ docker-compose up --force-recreate --build -d`

## Disaster Recovery

1.  `$ cd cloud-config`
1.  `$ cp backup.env.tmpl backup.env`
1.  Set appropriate values

### Hot

#### Setup

1.  `$ cd cloud-config`
1.  `$ cp hot.env.tmpl hot.env`
1.  Set appropriate values

#### Backup

1.  Install crontab as mentioned above

#### Restore (partial data loss)

1.  `$ cd ~/cloud-config`
1.  Edit `hot_restore.sh` to specify path to restore
1.  Restore backup by `$ ./hot_restore.sh`
1.  `$ git restore hot_restore.sh`

#### Restore (disaster recovery)

1.  Set up restore device
    1.  Follow steps for adding new node
    1.  Install Docker using `sudo apt-get install docker.io`
1.  `$ git clone https://github.com/noizwaves/noizwaves.cloud.git ~/cloud-config-recovery`
1.  `$ cd ~/cloud-config-recovery`
1.  Obtain secrets pack
1.  Populate config
    1.  `$ cp hot.env.tmpl hot.env`
    1.  Set secrets and `RESTORE_DIR`
1.  `$ ./hot_restore.sh`
1.  `$ mv ~/recovery/cloud-config ~/`
1.  `$ mv ~/recovery/cloud-data ~/`
1.  Update configuration in `~/cloud-config/.envrc`
1.  Manually add DNS entry for Adguard to Cloudflare
1.  Start foundational services (`traefik`, `authelia`, `adguard`)
1.  Manually add DNS entries to Adguard
1.  Start applications, adding DNS entries to Adguard

### Cold

#### Setup

1.  `$ cd cloud-config`
1.  `$ cp cold.env.tmpl cold.env`
1.  Set appropriate values

#### Backup

1.  SSH into `noizwaves.cloud`
1.  Connect cold backup USB drive to host
1.  Mount drive via `$ pmount /dev/sda backup`
1.  Run a restore via `$ ~/cloud-config/cold_backup.sh`
1.  Unmount drive via `$ pumount backup`

#### Restore (partial data loss)

1.  `$ cd ~/cloud-config`
1.  Edit `cold_restore.sh` to specify path to restore
1.  Connect cold backup drive
1.  Mount drive via `$ pmount /dev/sda backup`
1.  Restore backup by `$ ./cold_restore.sh`
1.  Unmount drive via `$ pumount backup`
1.  `$ git restore cold_restore.sh`
1.  Disconnect drive

#### Restore (disaster recovery)

1.  Set up restore device
    1.  Follow steps for adding new node
    1.  Install Docker using `sudo apt-get install docker.io`
1.  `$ git clone https://github.com/noizwaves/noizwaves.cloud.git ~/cloud-config-recovery`
1.  `$ cd ~/cloud-config-recovery`
1.  Obtain secrets pack
1.  Connect cold backup USB drive to restore target
1.  Obtain secrets pack
1.  `$ pmount /dev/sda backup`
    1.  `$ cp cold.env.tmpl cold.env`
    1.  Set `RESTORE_DIR`
1.  `$ ./cold_restore.sh`
1.  `$ pumount backup`
1.  Disconnect drive
1.  `$ mv ~/recovery/cloud-config ~/`
1.  `$ mv ~/recovery/cloud-data ~/`
1.  Update configuration in `~/cloud-config/.envrc`
1.  Manually add DNS entry for Adguard to Cloudflare
1.  Start foundational services (`traefik`, `authelia`, `adguard`)
1.  Manually add DNS entries to Adguard
1.  Start applications, adding DNS entries to Adguard

### Recover from disaster

How to recover from total hardware failure/destruction

1.  Obtain secrets pack from secure storage
1.  Prepare restore target device
1.  Perform either a cold or hot restore

## Misc

### Useful diagnostic tools

### iotop
1.  `sudo apt install iotop`
1.  `iotop`

### iozone
1.  `sudo apt install iozone3`
1.  `sudo iozone -e -I -a -s 100M -r 4k -r 16k -r 512k -r 1024k -r 16384k -i 0 -i 1 -i 2`

### hdparm
1.  `sudo apt install hdparm`
1.  `sudo hdparm -t /dev/nvme0n1`

### inxi
1.  `sudo apt install inxi`
1.  `inxi -Dxxx`

