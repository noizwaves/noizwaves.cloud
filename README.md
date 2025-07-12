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
1.  Run ansible playbook
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

- [Homepage](./homepage/)
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
- [Beszel](./beszel/)
- [Home Assistant](./homeassistant/)

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
- [k2d](./k2d/)
- [netbootxyz](./netbootxyz/)

## Maintenance

### Upgrading to newer images

1.  Update tags to desired newer value
1.  Recreate containers via `$ docker-compose up --force-recreate --build -d`

## Disaster Recovery and Backups

See [backups](./backups/).

## Useful diagnostic tools

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

