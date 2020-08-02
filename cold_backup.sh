#!/usr/bin/env bash

SOURCE_DIR=/home/cloud/
BACKUP_DIR=/media/backup/

CONTAINERS="resilio-sync standardnotes_sync standardnotes_mariadb freshrss freshrss_mariadb"

docker stop $CONTAINERS

sudo rsync -avh \
  --include="cloud-data" --include="cloud-data/**" \
  --include="cloud-config" --include="cloud-config/**" \
  --exclude="*" \
  --delete \
  "$SOURCE_DIR" "$BACKUP_DIR"

docker start $CONTAINERS