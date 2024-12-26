# noizwaves.cloud

A self hosted cloud

## Requirements

1.  Install Ansible locally via:
    - `brew install ansible ansible-lint`
    - `pacman -S ansible`
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
1.  Bootstrap as root using `bash <(curl https://raw.githubusercontent.com/noizwaves/noizwaves.cloud/main/ansible/bootstrap.sh)`
1.  Connect to Tailscale
1.  Run anisble playbook
1.  Populate `.envrc`
1.  Setup crontabs
1.  [Setup Samba](https://ubuntu.com/tutorials/install-and-configure-samba#1-overview)
    -  add shared directories
    -  set cloud Samba password
1.  Add to the inventory and ssh config

### Automation

1.  `$ crontab -e`
1.  Enable automated daily 1am hot backups with this cron config:
```
SHELL=/bin/bash
MAILTO=""
HOME=/home/cloud

0 1 * * * ./cloud-config/backups/hot/backup.sh >cloud-config/hot_backup.log 2>&1
```
1.  Enable DNS healthchecks with cron config:
```
*/2 * * * * host www.google.com 127.0.0.1 && <healthchecks.io health check>
```

## Foundation

- [Authelia](./authelia/)
- [Traefik](./traefik/)
- [Watchtower](./watchtower/)
- [Adguard Home](./adguard/)
- [ntfy](./ntfy/)

## Applications

- [Homebox](./homebox/)
- [Bitwarden](./bitwarden/)
- [Speedtest](./speedtest/)
- [UpSnap](./upsnap/)
- [Resilio Sync](./resilio-sync/)
- [FreshRSS](./freshrss/)
- [Fotos Adam](./fotos/) and [Fotos Lauren](./fotos-lauren/)
- [Tandoor](./tandoor/)
- [Plex](./plex/)
- [Filebrowser](./filebrowser/)
- [Vikunja](./vikunja/)
- [Syncthing](./syncthing/)
- [Gitea](./gitea/)
- [Atuin](./atuin/)
- [Homebox](./homebox/)
- [Immich](./immich/)
- [Scrutiny](./scrutiny/)
- [Ubooquity](./ubooquity/)

## Inactive

- [k3s](./k3s/)
- [Pi-hole](./pihole)
- [minio](./minio/)
- [InfluxDB](./influxdb/)
- [Seafile](./seafile/)
- [Nextcloud](./nextcloud/)
- [Standard Notes](./standardnotes/)
- [Firefly III](./firefly-iii/)
- [Photostructure](./photostructure/)
- [Photoprism](./photoprism/)
- [Registry](./registry/)
- [Focalboard](./focalboard/)
- [Running](./running/)
- [Drone](./drone/)
- [Trilium](./trilium/)
- [Matrix](./matrix/)
- [Backblaze](./backblaze/)
- [Elastic](./elastic/)
- [Fasten](./fasten/)
- [Home Assistant](./homeassistant/)
- [k2d](./k2d/)
- [netbootxyz](./netbootxyz/)

## Maintenance

### Upgrading to newer images

1.  Update tags to desired newer value
1.  Recreate containers via `$ docker-compose up --force-recreate --build -d`

## Disaster Recovery

1.  `$ cd cloud-config`
1.  `$ cp backups/backup.env.tmpl backups/backup.env`
1.  Set appropriate values

### Hot

#### Setup

1.  `$ cd cloud-config`
1.  `$ cp backups/hot/hot.env.tmpl backups/hot/hot.env`
1.  Set appropriate values

#### Backup

1.  Install crontab as mentioned above

#### Restore (partial data loss)

1.  `$ cd ~/cloud-config`
1.  Edit `backups/hot/restore.sh` to specify path to restore
1.  Restore backup by `$ ./backups/hot/restore.sh`
1.  `$ git restore backups/hot/restore.sh`

#### Restore (disaster recovery)

1.  Set up restore device
    1.  Follow steps for adding new node
    1.  Install Docker using `sudo apt-get install docker.io`
1.  `$ git clone https://github.com/noizwaves/noizwaves.cloud.git ~/cloud-config-recovery`
1.  `$ cd ~/cloud-config-recovery`
1.  Obtain secrets pack
1.  Populate config
    1.  `$ cp backups/hot/hot.env.tmpl backups/hot/hot.env`
    1.  Set secrets and `RESTORE_DIR`
1.  `$ .backups/hot/restore.sh`
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
1.  `$ cp backups/cold/cold.env.tmpl backups/cold/cold.env`
1.  Set appropriate values

#### Backup

1.  SSH into `noizwaves.cloud`
1.  Connect cold backup USB drive to host
1.  Mount backup drive via `$ pmount /dev/sda backup`
1.  Mount bigbackup drive via `$ pmount /dev/sdb bigbackup`
1.  Run a backup via `$ ~/cloud-config/backups/cold/backup.sh`
1.  Unmount drives via `$ pumount backup` and `$ pumount bigbackup`

#### Restore (partial data loss)

1.  `$ cd ~/cloud-config`
1.  Edit `backups/cold/restore.sh` to specify path to restore
1.  Connect cold backup drive
1.  Mount drive via `$ pmount /dev/sda backup`
1.  Restore backup by `$ ./backups/cold/restore.sh`
1.  Unmount drive via `$ pumount backup`
1.  `$ git restore backups/cold/restore.sh`

#### Restore (disaster recovery)

1.  Set up restore device
    1.  Follow steps for adding new node
    1.  Install Docker using `sudo apt-get install docker.io`
1.  `$ git clone https://github.com/noizwaves/noizwaves.cloud.git ~/cloud-config-recovery`
1.  `$ cd ~/cloud-config-recovery`
1.  Obtain secrets pack
1.  Connect cold backup USB drive to restore target
1.  `$ pmount /dev/sda backup`
    1.  `$ cp backups/cold/cold.env.tmpl backups/cold/cold.env`
    1.  Set `RESTORE_DIR`
1.  `$ ./backups/cold/restore.sh`
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

