# Vikunja

1.  `$ mkdir -p ~/cloud-data/vikunja/files ~/cloud-data/vikunja/mariadb`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  Clone source code
    1.  `$ mkdir ~/workspace`
    1.  `$ git clone https://kolaente.dev/vikunja/api.git ~/workspace/vikunja-api`
    1.  `$ git clone https://kolaente.dev/vikunja/frontend.git ~/workspace/vikunja-frontend`
1.  `$ docker-compose up -d`
1.  Open [Vikunja](https://vikunja.noizwaves.cloud)
