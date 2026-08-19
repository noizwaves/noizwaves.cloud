# Seafile

1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Log in, navigate to `System Admin > Settings` and update `SERVICE_URL` & `FILE_SERVER_ROOT`
1.  Edit config files at `SEAFILE_DATA=$(docker volume inspect seafile_data --format '{{ .Mountpoint }}')`
    1.  Edit the value of `FILE_SERVER_ROOT` in `$SEAFILE_DATA/seafile/conf/seahub_settings.py`
    1.  Edit the value of `enabled` in `$SEAFILE_DATA/seafile/conf/seafdav.conf`
    1.  Edit `$SEAFILE_DATA/seafile/conf/ccnet.conf`
1.  Restart memcached `$ docker-compose restart memcached`
