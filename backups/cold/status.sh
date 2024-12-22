#!/usr/bin/env bash

source ~/cloud-config/backups/backup.env
source ~/cloud-config/backups/cold/cold.env

restic --repo /media/backup/restic/odroid --insecure-no-password \
	snapshots --compact

restic --repo /media/bigbackup/restic/odroid --password-file /media/bigbackup/restic/odroid.password \
	snapshots --compact
