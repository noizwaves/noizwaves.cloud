# Filebrowser

1.  `$ mkdir ~/cloud-data/filebrowser`
1.  `$ touch ~/cloud-data/filebrowser/database.db`
1.  `$ cp filebrowser.json.tmpl ~/cloud-data/filebrowser/filebrowser.json`
1.  Input appropriate values
1.  Initialize configuration by running
    ```
    $ docker run --rm \
        -v /home/cloud/cloud-data/filebrowser/filebrowser.json:/.filebrowser.json \
        -v /home/cloud/cloud-data/filebrowser/database.db:/database.db \
        filebrowser/filebrowser \
        config init
    ```
1.  Switch to Proxy Header based authentication method by running
    ```
    $ docker run --rm \
        -v /home/cloud/cloud-data/filebrowser/filebrowser.json:/.filebrowser.json \
        -v /home/cloud/cloud-data/filebrowser/database.db:/database.db \
        filebrowser/filebrowser \
        config set --auth.method=proxy --auth.header=Remote-User
    ```
1.  Create admin users by running
    ```
    $ docker run --rm \
        -v /home/cloud/cloud-data/filebrowser/filebrowser.json:/.filebrowser.json \
        -v /home/cloud/cloud-data/filebrowser/database.db:/database.db \
        filebrowser/filebrowser \
        users add $USERNAME $PASSWORD --perm.admin=true --perm.execute=false
    ```
1.  `$ docker-compose up -d`
1.  Open [Filebrowser](https://filebrowser.noizwaves.cloud)
