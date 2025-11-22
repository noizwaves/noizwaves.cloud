#!/usr/bin/env bash
set -e

source ~/cloud-config/backups/backup.env
source ~/cloud-config/backups/cold/cold.env

if [ ! -d /media/backup/restic ]; then
  echo "backup drive is not mounted!"
  exit 1
fi

if [ ! -d /media/bigbackup/restic ]; then
  echo "bigbackup drive is not mounted!"
  exit 1
fi

# Perform a btrfs scrub
echo "Starting btrfs scrub of /media/backup"
sudo btrfs scrub start -B /media/backup

echo "Starting btrfs scrub of /media/bigbackup"
sudo btrfs scrub start -B /media/bigbackup

# Perform a restic check
restic --repo /media/backup/restic/odroid --insecure-no-password \
  check \
  --read-data

restic --repo /media/bigbackup/restic/odroid --insecure-no-password \
  check \
  --read-data
