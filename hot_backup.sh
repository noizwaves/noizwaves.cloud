#!/usr/bin/env bash

source hot.env

DEST="s3://us-east-1.linodeobjects.com/$BUCKET_NAME/"
CONTAINERS="resilio-sync standardnotes_sync standardnotes_mariadb freshrss freshrss_mariadb bitwarden"

LAST_FULL_BACKUP_FILE=last-full-backup.txt
LAST_FULL_BACKUP=0
if [[ -f $LAST_FULL_BACKUP_FILE ]]; then
  LAST_FULL_BACKUP="$(cat $LAST_FULL_BACKUP_FILE)"
fi

NOW=$(date +"%s")
SECS_SINCE_FULL="$(($NOW-$LAST_FULL_BACKUP))"

# first full backup in just under 7 days
if [[ SECS_SINCE_FULL -ge "$((60 * 60 * 24 * 7 - 600))" ]]; then
  COMMAND=full
  # TODO: update $LAST_FULL_BACKUP_FILE only upon successful backup
  echo "$NOW" > $LAST_FULL_BACKUP_FILE
else
  COMMAND=incr
fi

docker stop $CONTAINERS

docker run --rm \
  --hostname duplicity \
  --user 1000:1000 \
  -v ~/cloud-data:/data/cloud-data:ro \
  -v ~/cloud-config:/data/cloud-config:ro \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e PASSPHRASE="${PASSPHRASE}" \
  -e TZ=America/Denver \
  wernight/duplicity \
  duplicity $COMMAND \
  --progress \
  --include '/data/' \
  --exclude '**' \
  /data/ ${DEST}

docker start $CONTAINERS
