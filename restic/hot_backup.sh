#!/usr/bin/env bash

# from cold.env
source ~/cloud-config/hot.env

export RESTIC_REPOSITORY="b2:$BUCKET_NAME:restic/odroid"
export RESTIC_PASSWORD=$PASSPHRASE
export B2_ACCOUNT_ID=$AWS_ACCESS_KEY_ID
export B2_ACCOUNT_KEY=$AWS_SECRET_ACCESS_KEY

restic backup \
  --files-from odroid_backup.txt \
  --exclude-file odroid_exclude.txt
