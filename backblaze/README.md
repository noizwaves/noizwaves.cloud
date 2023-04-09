# Backblaze Personal Backup

1.  `$ mkdir -p ~/cloud-data/backblaze/config`
1.  `$ docker-compose up -d`
1.  [Open](https://backblaze.noizwaves.cloud) and [follow installation instructions](https://hub.docker.com/r/tessypowder/backblaze-personal-wine#installation)
1.  Mount drives:
    1.  `$ ln -s /mnt/media ~/cloud-data/backblaze/config/wine/dosdevices/e:`
    1.  `$ ln -s /mnt/media2 ~/cloud-data/backblaze/config/wine/dosdevices/f:`
1. `$ docker-compose restart`

Notes:
- Container `C:` is at `~/cloud-data/backblaze/config/wine/drive_c/`
