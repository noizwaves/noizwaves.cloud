#!/usr/bin/env bash

if [ ! -d /media/bigbackup/rsync ]; then
  echo "Destination directory missing. Is bigbackup mounted?"
  exit 1
fi

rsync --archive --noatime --progress --itemize-changes --stats --delete --delete-excluded  \
  --exclude-from media_excludes.txt \
  /mnt/media2/ \
  /media/bigbackup/rsync/media2
