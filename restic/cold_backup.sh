#!/usr/bin/env bash

export RESTIC_REPOSITORY=/media/bigbackup/restic/odroid
export RESTIC_PASSWORD_FILE="${RESTIC_REPOSITORY}.password"

if [ ! -d "$RESTIC_REPOSITORY" ]; then
  echo "Directory ${RESTIC_REPOSITORY} missing. Is bigbackup mounted?"
  exit 1
fi

restic backup \
  --files-from odroid_backup.txt \
  --exclude-file odroid_exclude.txt
