#!/usr/bin/env bash

BACKUP_DIR=/media/backup

# For testing a restore
RESTORE_DIR=/home/cloud/restored/
# and for an actual restore
# RESTORE_DIR=/home/cloud/

sudo rsync -avh \
  "$BACKUP_DIR" "$RESTORE_DIR"