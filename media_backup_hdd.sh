#!/usr/bin/env bash

set -eou pipefail

if findmnt --mountpoint /media/ozo >>/dev/null; then
  mkdir -p /media/ozo/backup/TV
  # to delete, add "--delete"
  rsync -av --exclude-from media_backup_tv_excludes.txt /mnt/media2/TV/ /media/ozo/backup/TV
else
  echo "ozo is not mounted, skipping"
fi

if findmnt --mountpoint /media/thecup >>/dev/null; then
  mkdir -p /media/thecup/backup/{Movies,Music,Games,Photography,Videos,Books}
  rsync -av /mnt/media2/Movies/ /media/thecup/backup/Movies
  rsync -av /mnt/media2/Music/ /media/thecup/backup/Music
  rsync -av /mnt/media2/Games/ /media/thecup/backup/Games
  rsync -av /mnt/media2/Photography/ /media/thecup/backup/Photography
  rsync -av /mnt/media2/Videos/ /media/thecup/backup/Videos
  rsync -av /mnt/media2/Books/ /media/thecup/backup/Books
else
  echo "thecup is not mounted, skipping"
fi

