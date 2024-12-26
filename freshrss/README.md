# FreshRSS

1.  `$ mkdir -p ~/cloud-data/freshrss/config ~/cloud-data/freshrss/mariadb`
1.  `$ cp .env.tmpl .env`
1.  Input appropriate values
1.  `$ docker-compose up -d`
1.  Open [FreshRSS](https://freshrss.noizwaves.cloud)
1.  Configure application
    1.  Database type: `MySQL`
    1.  Host: `mariadb`
    1.  Database username: `freshrss`
    1.  Database password: `<value from .env file>`
    1.  Database: `freshrss`
    1.  Table prefix: `` (empty string)
