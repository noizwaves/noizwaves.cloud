# Matrix (Synapse)

1.  `$ mkdir -p ~/cloud-data/matrix/data ~/cloud-data/matrix/postgres ~/cloud-data/matrix/telegram`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose run --rm -e SYNAPSE_SERVER_NAME=matrix.noizwaves.cloud -e SYNAPSE_REPORT_STATS=no synapse generate`
1.  Edit Synapse config using `$ vim ~/cloud-data/matrix/data/homeserver.yaml`
1.  Generate Telegram config using `$ docker-compose run --rm telegram`
1.  Edit Telegram config using `$ vim ~/cloud-data/matrix/telegram/config.yaml`
1   Generate Telegram appservice registration using `$ docker-compose run --rm telegram`
1.  `$ docker-compose up -d`
1.  Register users by running `$ docker-compose exec synapse register_new_matrix_user -c /data/homeserver.yaml http://localhost:8008`
1.  Open [Synapse](https://matrix.noizwaves.cloud)

## iMessage Bridge
Based upon the [instructions](https://docs.mau.fi/bridges/go/imessage/mac/setup.html).

Prepare synapse on server:
1.  `$ mkdir -p ~/cloud-data/matrix/imessage plugins`
1.  `$ wget -o plugins/shared_secret_authenticator.py https://raw.githubusercontent.com/devture/matrix-synapse-shared-secret-auth/master/shared_secret_authenticator.py`
1.  Edit `~/cloud-data/matrix/data/homeserver.yaml` and add a new item to `password_providers`:
    ```yaml
    - module: "shared_secret_authenticator.SharedSecretAuthenticator"
        config:
        sharedSecret: "${SHARED_SECRET_AUTH_SECRET}"
    ```
    Where:
    - `SHARED_SECRET_AUTH_SECRET` = `$ pwgen -s 128 1`

Prepare bridge on mac:
1.  Identify mac to use to run bridge and setup iCloud (Messages and Contacts)
1.  Download latest release of [mautrix-imessage](https://mau.dev/mautrix/imessage/-/pipelines?scope=branches&page=1) to mac
1.  Extract to a folder
1.  `$ cp example-config.yaml config.yaml` and edit values:
    - `homeserver.address` to `https://matrix.noizwaves.cloud`
    - `homeserver.websocket_proxy` to `wss://matrix-wsproxy.noizwaves.cloud`
    - `homeserver.domain` to `noizwaves.cloud`
    - `bridge.user` to `@adam:noizwaves.cloud`
    - `bridge.login_shared_secret` to `${SHARED_SECRET_AUTH_SECRET}`
1.  `$ ./mautrix-imessage -g`
1.  Ensure that `config.yaml` contains `appservice.as_token` and `appservice.hs_token` from `registration.yaml`
1.  Copy `registration.yaml` from mac to `~/cloud-data/matrix/imessage/registration.yaml` on server

Prepare wsproxy on server:
1.  `cp .env_wsproxy.tmpl .env_wsproxy`
1.  Input appropriate values (from `~/cloud-data/matrix/imessage/registration.yaml`)
1.  Ensure that the `~/cloud-data/matrix/imessage:/bridges/imessage` volume mount is present for `synapse`
1.  `$ docker-compose up -d synapse wsproxy`

Start iMessage bridge on mac:
1.  `$ ./mautrix-imessage` (and if required, grant permission to read Contacts)
