#!/usr/bin/env bash

source ~/cloud-config/backup.env
source ~/cloud-config/cold.env

mkdir -p "$RESTORE_DIR"

sudo rsync -avh \
  "$BACKUP_DIR" "$RESTORE_DIR"
