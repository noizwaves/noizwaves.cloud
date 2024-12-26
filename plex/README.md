# Plex

1.  `$ mkdir -p ~/cloud-data/plex/config ~/cloud-data/plex/data ~/cloud-data/plex/transcode`
1.  Generate a [claim](https://www.plex.tv/claim)
1.  `$ docker-compose up -d`
1.  Open [Plex](https://plex.noizwaves.cloud)

## AV1 Direct Play to AppleTV
This [moves AV1 transcoding](https://github.com/currifi/plex_av1_tvos) from the server onto the AppleTV.
1.  `$ curl -Ls -o ~/cloud-data/plex/config/Library/Application\ Support/Plex\ Media\ Server/Profiles/tvOS.xml https://raw.githubusercontent.com/currifi/plex_av1_tvos/main/tvOS.xml`
1.  `$ docker-compose restart`

## References

- Inspired by [pierre-emmanuelJ/plex-traefik](https://github.com/pierre-emmanuelJ/plex-traefik)
