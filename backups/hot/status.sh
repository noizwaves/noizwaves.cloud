#!/usr/bin/env bash

source ~/cloud-config/backups/backup.env
source ~/cloud-config/backups/hot/hot.env

restic snapshots --compact
