#!/usr/bin/env bash

set -eou pipefail

mkdir -p /media/ozo/backup/TV
rsync -av /mnt/media2/TV/ /media/ozo/backup/TV

mkdir -p /media/thecup/backup/{Movies,Music,Games,Photography,Videos,Books}
rsync -av /mnt/media2/Movies/ /media/thecup/backup/Movies
rsync -av /mnt/media2/Music/ /media/thecup/backup/Music
rsync -av /mnt/media2/Games/ /media/thecup/backup/Games
rsync -av /mnt/media2/Photography/ /media/thecup/backup/Photography
rsync -av /mnt/media2/Videos/ /media/thecup/backup/Videos
rsync -av /mnt/media2/Books/ /media/thecup/backup/Books

