#!/usr/bin/env bash

source ~/cloud-config/backups/backup.env
source ~/cloud-config/backups/hot/hot.env

if [ -z "$RESTORE_DIR" ]; then
	echo "RESTORE_DIR is not set; set in hot.env"
	exit 1
fi

if [ -d "$RESTORE_DIR" ]; then
	echo "$RESTORE_DIR already exists; delete it then re-run"
	exit 1
fi

mkdir -p "$RESTORE_DIR"

# By default will restore everything in snapshot, with absolute paths to $RESTORE_DIR
#
# To include only certain files in the restore, add:
# --include /home/cloud/cloud-data
#
# To restore just a specific folder to $RESTORE_DIR, change to:
# restic restore latest:<PATH> --target "$RESTORE_DIR"
restic restore latest --target "$RESTORE_DIR"
