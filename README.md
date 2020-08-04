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
    1.  `$ sudo ufw enable`
    1.  `$ sudo ufw reload`
1.  Set up Docker
    1.  `$ sudo apt install -y docker.io docker-compose`
    1.  `$ sudo usermod -aG docker cloud`
    1.  `$ sudo systemctl enable docker`
    1.  `$ docker network create web`
    1.  Update Docker config at `~/.docker/config.json` with
        ```json
        {
            "psFormat": "table {{.Names}}\t{{.Status}}\t{{.Image}}"
        }
        ```
1.  Install ZeroTier One
    1.  ```
        curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import && \
        if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi
        ```
    1.  `sudo cat /var/lib/zerotier-one/authtoken.secret >> ~/.zeroTierOneAuthToken`
    1.  `chmod 0600 ~/.zeroTierOneAuthToken`
1.  `$ mkdir ~/cloud-config ~/cloud-data`
1.  Copy configuration to VM via `$ rsync -avzhe ssh ~/workspace/noizwaves.cloud/ $HOSTNAME:/home/cloud/cloud-config/ --exclude=".git" --exclude=".idea"`
1.  `$ cd ~/cloud-config`
1.  `$ cp .envrc.tmpl .envrc` and change values as appropriate
1.  `$ direnv allow`

## Traefik
1.  `$ cd traefik`
1.  `$ mkdir -p ~/cloud-data/traefik/letsencrypt`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Open Traefik dashboard at `https://traefik.${CLOUD_DOMAIN}`

## Pi-hole
1.  `$ cd pihole`
1.  `$ mkdir -p ~/cloud-data/pihole/config ~/cloud-data/pihole/dnsmasq`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`

## Authelia
1.  `$ cd authelia`
1.  Create a user database
    1.  `$ cp config/users_database.yml.tmpl config/users_database.yml`
    1.  Follow steps in comments to create users
1.  Create configuration
    1.  `$ cp config/configuration.yml.tmpl config/configuration.yml`
    1.  Replace all `${CLOUD_DOMAIN}` with desired value
1.  Create secrets
    1.  `$ openssl rand -base64 32 > .secrets/jwt.txt`
    1.  `$ openssl rand -base64 32 > .secrets/session.txt`
    1.  `$ openssl rand -base64 32 > .secrets/mysql_password.txt`
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

## Duplicati
1.  `$ cd duplicati`
1.  `$ docker-compose up -d`
1.  Configure [Duplicati](https://duplicati.noizwaves.cloud/ngax/index.html#/settings) appropriately
    1.  Add web password
    1.  Restrict access to `duplicati.${CLOUD_DOMAIN}`
1.  Configure backups appropriately or import `backup-duplicati-config.json`
    1.  Add a `run-script-before` advanced option of `/scripts/stop.sh`
    1.  Add a `run-script-after` advanced option of `/scripts/start.sh`

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

### Hot backup

1.  SSH into `noizwaves.cloud`
1.  `cd cloud-config`
1.  (if not set up) `cp hot.env.tmpl hot.env` and fill in appropriate values
1.  `./hot_backup.sh`

### Cold backup

1.  SSH into `noizwaves.cloud`
1.  Connect cold backup USB drive to host
1.  Mount drive via `$ pmount /dev/sda backup`
1.  Run a restore via `$ ~/cloud-config/cold_backup.sh`
1.  Unmount drive via `$ pumount backup`

### Cold restore

1.  SSH into `noizwaves.cloud`
1.  Connect cold backup USB drive to host
1.  Mount drive via `$ pmount /dev/sda backup`
1.  Edit `~/cloud-config/cold_restore.sh` to set desired restore point
1.  Run a restore via `$ ~/cloud-config/cold_restore.sh`
1.  Unmount drive via `$ pumount backup`

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