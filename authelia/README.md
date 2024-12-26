# Authelia

1.  `$ mkdir -p ~/cloud-data/authelia/mariadb ~/cloud-data/authelia/redis`
1.  Create a user database
    1.  `$ cp config/users_database.yml.tmpl config/users_database.yml`
    1.  Follow steps in comments to create users
1.  Create configuration
    1.  `$ cp config/configuration.yml.tmpl config/configuration.yml`
    1.  Replace all `${CLOUD_DOMAIN}` with desired value
1.  Create secrets
    1.  `$ mkdir -p .secrets`
    1.  `$ openssl rand -base64 32 > .secrets/jwt.txt`
    1.  `$ openssl rand -base64 32 > .secrets/session.txt`
    1.  `$ openssl rand -base64 32 > .secrets/mysql_password.txt`
    1.  `$ cp .env.tmpl .env`
    1.  Fill in appropriate values
1.  `$ docker-compose up -d`
