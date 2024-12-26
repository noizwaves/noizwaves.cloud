# backups

## Setup

1.  `$ cp backup.env.tmpl backup.env`
1.  Set appropriate values

## Recovering from a disaster

How to recover from total hardware failure/destruction

1.  Obtain secrets pack from secure storage
1.  Prepare restore target device
1.  Perform either a cold or hot restore

## Hot

### Setup

1.  `$ cd hot`
1.  `$ cp hot.env.tmpl hot.env`
1.  Set appropriate values

### Backup

1.  Install crontab as mentioned in the [setup docs](../README.md).

### Restore (partial data loss)

1.  `$ cd ~/cloud-config`
1.  Edit `backups/hot/hot.env` to specify path to restore
1.  Restore backup by `$ ./backups/hot/restore.sh`
1.  `$ git restore backups/hot/restore.sh`

### Restore (full data loss)

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

## Cold

### Setup

1.  `$ cd cold`
1.  `$ cp cold.env.tmpl cold.env`
1.  Set appropriate values

### Backup

1.  SSH into `odroid`
1.  Connect cold backup USB drive to host
1.  Mount backup drive via `$ pmount /dev/sda backup`
1.  Mount bigbackup drive via `$ pmount /dev/sdb bigbackup`
1.  Run a backup via `$ ~/cloud-config/backups/cold/backup.sh`
1.  Unmount drives via `$ pumount backup` and `$ pumount bigbackup`

### Restore (partial data loss)

1.  Edit `backups/cold/cold.env` to specify path to restore
1.  Connect cold backup drive
1.  Mount drive via `$ pmount /dev/sda backup`
1.  Restore backup by `$ ./backups/cold/restore.sh`
1.  Unmount drive via `$ pumount backup`
1.  `$ git restore backups/cold/restore.sh`

### Restore (full data loss)

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

