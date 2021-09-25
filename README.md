# noizwaves.cloud

A self hosted cloud

## Setup
1.  Create a new Ubuntu 20.04 VM
    1.  Username `cloud`
    1.  Disable password requirement for sudoing by adding `cloud    ALL=(ALL) NOPASSWD:ALL` to `$ sudo visudo`
    1.  SSH Server installed
        1.  Add public key to `~/.ssh/authorized_keys`
        1.  Lock down SSHD config `/etc/ssh/sshd_config`
            1.  `PasswordAuthentication no` to disable password-based logins
            1.  `PermitRootLogin no` to disable root login
    1.  NTP `$ sudo apt install ntp`
    1.  USB automount `$ sudo apt install pmount`
    1.  Direnv `$ sudo apt install direnv` and [setup Bash hook](https://direnv.net/docs/hook.html#bash) (`eval "$(direnv hook bash)"`)
    1.  Configure timezone
        1.  `$ echo "US/Denver" | sudo tee /etc/timezone`
        1.  `$ sudo dpkg-reconfigure --frontend noninteractive tzdata`
1.  Disable local DNS resolver
    1.  `$ echo 'nameserver 1.1.1.1' | sudo tee /etc/resolv.conf`
    1.  `$ echo 'nameserver 9.9.9.9' | sudo tee -a /etc/resolv.conf`
    1.  `$ sudo systemctl disable systemd-resolved`
    1.  `$ sudo systemctl stop systemd-resolved`
1.  Configure ufw
    1.  `$ sudo ufw allow 22/tcp`
    1.  `$ sudo ufw allow 53/tcp`
    1.  `$ sudo ufw allow 53/udp`
    1.  `$ sudo ufw allow 80/tcp`
    1.  `$ sudo ufw allow 443/tcp`
    1.  `$ sudo ufw allow 2049/tcp`
    1.  `$ sudo ufw enable`
    1.  `$ sudo ufw reload`
1.  Set up Docker
    1.  `$ sudo apt install -y docker.io docker-compose`
    1.  `$ sudo usermod -aG docker cloud`
    1.  `$ sudo systemctl enable docker`
    1.  `$ docker network create web`
    1.  `$ docker network create public`
    1.  Update Docker config at `~/.docker/config.json` with
        ```json
        {
            "psFormat": "table {{.Names}}\t{{.Status}}\t{{.Image}}"
        }
        ```
1.  Install Samba
    1.  `$ sudo apt install -y samba`
    1.  `$ sudo ufw allow samba`
    1.  Add shares following [this guide](https://ubuntu.com/tutorials/install-and-configure-samba#3-setting-up-samba)
1.  Install NFS Server
    1.  `$ sudo apt install -y nfs-kernel-server`
    1.  `$ sudo vim /etc/exports` to add shares following [this guide](https://ubuntu.com/server/docs/service-nfs)
1.  Install ZeroTier One
    1.  ```
        curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import && \
        if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi
        ```
    1.  `sudo cat /var/lib/zerotier-one/authtoken.secret >> ~/.zeroTierOneAuthToken`
    1.  `chmod 0600 ~/.zeroTierOneAuthToken`
1.  Install minikube
    1.  `$ curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb`
    1.  `$ sudo dpkg -i minikube_latest_amd64.deb`
    1.  `$ minikube config set driver docker`
    1.  `$ minikube start`
1.  `$ mkdir ~/cloud-config ~/cloud-data`
1.  Copy configuration to VM via `$ rsync -avzhe ssh ~/workspace/noizwaves.cloud/ $HOSTNAME:/home/cloud/cloud-config/ --exclude=".git" --exclude=".idea"`
1.  `$ cd ~/cloud-config`
1.  `$ cp .envrc.tmpl .envrc` and change values as appropriate
1.  `$ direnv allow`

### Backups

1.  `$ crontab -e`
1.  Enable automated daily 1am hot backups with this cron config:
```
SHELL=/bin/bash
MAILTO=""
HOME=/home/cloud

0 1 * * * ./cloud-config/hot_backup.sh >> cloud-config/hot_backup.log
```

## Traefik
1.  `$ cd traefik`
1.  `$ mkdir -p ~/cloud-data/traefik/letsencrypt`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Open Traefik dashboard at `https://traefik.${CLOUD_DOMAIN}`

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
1.  `$ mkdir -p ~/cloud-data/fotos/thumbnails`
1.  (optional) rsync existing thumbnails from host using `$ rsync -avzhe ssh ~/workspace/fotos/thumbnails/ noizwaves.cloud:/home/cloud/cloud-data/fotos/thumbnails/`
1.  Create WebDAV credentials via `$ htpasswd -c credentials.list <username>` and then enter the password.
1.  `$ docker-compose up -d`

1.  `$ cd .../fotos-lauren`
1.  `$ mkdir -p ~/cloud-data/fotos-lauren/thumbnails`
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
1.  Set up the Adguard Tailscale connection by:
    1.  `$ docker-compose exec tailscale tailscale up`
    1.  Use the printed URL to join the container to the Tailscale network
1.  Set up Adguard by visiting `http://$IP_ADDRESS:3000` where `$IP_ADDRESS` is the Tailscale IP address
1.  Open [Adguard Home](http://adguard.noizwaves.cloud)
1.  Add custom DNS records into `Filters > DNS rewrites`
1.  Update Tailscale DNS for nameserver of `$IP_ADDRESS` restricted to search domain of `noizwaves.cloud`

## Running
1.  `$ cd running`
1.  `$ docker-compose up -d`
1.  Open [Running](https://running.noizwaves.cloud)

## Vikunja
1.  `$ cd vikunja`
1.  `$ mkdir -p ~/cloud-data/vikunja/files ~/cloud-data/vikunja/mariadb`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Open [Vikunja](https://vikunja.noizwaves.cloud)

## Syncthing
1.  `$ cd syncthing`
1.  `$ mkdir -p ~/cloud-data/syncthing/config`
1.  `$ docker-compose up -d`
1.  Open [Syncthing](https://syncthing.noizwaves.cloud)
1.  Open [Vikunja](https://vikunja.noizwaves.cloud)

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
1.  `$ docker-compose run --rm -e SYNAPSE_SERVER_NAME=matrix.${CLOUD_DOMAIN} -e SYNAPSE_REPORT_STATS=no synapse generate`
1.  Edit Synapse config using `$ vim ~/cloud-data/matrix/data/homeserver.yaml`
1.  Generate Telegram config using `$ docker-compose run --rm telegram`
1.  Edit Telegram config using `$ vim ~/cloud-data/matrix/telegram/config.yaml`
1   Generate Telegram appservice registration using `$ docker-compose run --rm telegram`
1.  `$ docker-compose up -d`
1.  Open [Synapse](https://matrix.noizwaves.cloud)

## Cloudflare Argo Tunnels (Experimental)
1.  `$ cd cloudflare`
1.  `$ mkdir -p ~/cloud-data/cloudflare/data`
1.  `$ sudo chown -R 65532:65532 ~/cloud-data/cloudflare/data`
1.  Log into Cloudflare using `docker-compose run --rm -v ~/cloud-data/cloudflare/data:/home/nonroot/.cloudflared cloudflare tunnel login`
1.  Create tunnel using `docker-compose run --rm -v ~/cloud-data/cloudflare/data:/home/nonroot/.cloudflared cloudflare tunnel create traefik` and note the tunnel UUID
1.  Create a config using `vim ~/cloud-data/cloudflare/data/config.yml` that looks like:
    ```yaml
    tunnel: ${UUID}
    credentials-file: /home/nonroot/.cloudflared/${UUID}.json
    originRequest:
      noTLSVerify: true

    ingress:
      - hostname: ${SERVICE}.${CLOUD_DOMAIN}
        service: https://traefik:443
      - ...
  - service: http_status:404
    ```
1.  `$ sudo chown -R 65532:65532 ~/cloud-data/cloudflare/data`
1.  Create DNS entries for each service by running `docker-compose run --rm -v ~/cloud-data/cloudflare/data:/home/nonroot/.cloudflared cloudflare tunnel route dns traefik ${SERVICE}`
1.  Start tunnel using `docker-compose up -d`

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

1.  `$ cd cloud-config`
1.  `$ cp hot.env.tmpl hot.env`
1.  Set appropriate values

#### Backup

1.  Install crontab as mentioned above

#### Restore

1.  Start restore target device
1.  Obtain secrets pack
1.  `$ git clone https://github.com/noizwaves/noizwaves.cloud.git ~/noizwaves.cloud_restore`
1.  `$ cd ~/noizwaves.cloud_restore`
1.  Populate secrets by:
    1.  `$ cp hot.env.tmpl hot.env`
    1.  Setting secrets and `RESTORE_DIR`
1.  Restore backup by `$ ./hot_restore.sh`

### Cold (duplicity)

1.  `$ cd cloud-config`
1.  `$ cp cold.env.tmpl cold.env`
1.  Set appropriate values

#### Backup

1.  SSH into `noizwaves.cloud`
1.  Connect cold backup USB drive to host
1.  Mount drive via `$ pmount /dev/sda backup`
1.  Run a restore via `$ ~/cloud-config/cold_backup.sh`
1.  Unmount drive via `$ pumount backup`

#### Restore

1.  Start restore target device
1.  Obtain secrets pack
1.  `$ git clone https://github.com/noizwaves/noizwaves.cloud.git ~/noizwaves.cloud_restore`
1.  `$ cd ~/noizwaves.cloud_restore`
1.  Connect cold backup USB drive to restore target
1.  Mount drive via `$ pmount /dev/sda backup` or GUI
1.  Populate secrets by:
    1.  `$ cp cold.env.tmpl cold.env`
    1.  Set `RESTORE_DIR`
1.  Restore backup by `$ ./cold_restore.sh`
1.  Unmount drive via `$ pumount backup` og UI

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