# Backblaze Personal Backup

1.  `$ mkdir -p ~/cloud-data/backblaze/config`
1.  `$ docker-compose up -d`
1.  [Open](https://backblaze.noizwaves.cloud) and [follow installation instructions](https://hub.docker.com/r/tessypowder/backblaze-personal-wine#installation)
1.  Mount drives:
    1.  `$ ln -s /mnt/media2 ~/cloud-data/backblaze/config/wine/dosdevices/f:`
1. `$ docker-compose restart`

Notes:
- Container `C:` is at `~/cloud-data/backblaze/config/wine/drive_c/`

## Upgrading Backblaze

To upgrade the installed Backblaze application:
1. `docker exec -it -u app:app backblaze bash` to connect to the running container
1. `cd /config/wine`
1. `mv install_backblaze.exe install_backblaze.exe.previous`
1. `curl -L "https://www.backblaze.com/win32/install_backblaze.exe" --output "install_backblaze.exe"`
1. `wine64 "install_backblaze.exe" &` to launch the installer
1. Complete the installation/upgrade in the web UI
1. `rm install_backblaze.exe.original`

## Misc

### Open Task Manager
```
docker exec -it -u app:app backblaze wine64 taskmgr
```
