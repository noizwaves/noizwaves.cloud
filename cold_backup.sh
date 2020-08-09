#!/usr/bin/env bash

source ~/cloud-config/backup.env
source ~/cloud-config/cold.env

SOURCE_DIR=/home/cloud/

docker stop $CONTAINERS

sudo rsync -avh \
  --include="cloud-data" --include="cloud-data/**" \
  --include="cloud-config" --include="cloud-config/**" \
  --exclude="*" \
  --delete \
  "$SOURCE_DIR" "$BACKUP_DIR"

docker start $CONTAINERS
