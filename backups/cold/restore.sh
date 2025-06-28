#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $DIR/../backup.env
source $DIR/cold.env

if [ -z "$BACKUP_DIR" ]; then
  echo "BACKUP_DIR is not set; set in cold.env"
  exit 1
fi

if [ -z "$RESTORE_DIR" ]; then
	echo "RESTORE_DIR is not set; set in cold.env"
	exit 1
fi

if [ -d "${RESTORE_DIR}" ]; then
	echo "${RESTORE_DIR} already exists; delete it then re-run"
	exit 1
fi

mkdir -p "$RESTORE_DIR"

# By default will restore latest backup from backup drive, with absolute paths to $RESTORE_DIR
#
# To include only certain files in the restore, add:
# --include /home/cloud/cloud-data
#
# To restore just a specific folder to $RESTORE_DIR, change to:
# restic restore latest:<PATH> --target "$RESTORE_DIR"
#
# To restore from big backup, change to:
# --repo /media/bigbackup/restic/odroid --password-file /media/bigbackup/restic/odroid.password
restic --repo "$BACKUP_DIR" --insecure-no-password \
	restore latest --target "$RESTORE_DIR"
