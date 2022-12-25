# A Docker phpldapadmin image

## Usage

Note: you need to login to ghcr.io using your GitHub account:

```sh
docker login ghcr.io
```

```yml
version: "2.3"

services:
    phpldapadmin:
    image: ghcr.io/sudo-bot/docker-phpldapadmin/docker-phpldapadmin:latest
    environment:
        BASE_URL: http://phpldapadmin
        DB_HOST: mariadb.local
        DB_NAME: phpldapadmin
        DB_USERNAME: phpldapadmin
        DB_PASSWORD: phpldapadmin
        # DEBUG_MODE: true
        # French is the default lang
        DEFAULT_LANG: french
    healthcheck:
        test:
        [
            "CMD",
            "curl",
            "-s",
            "--fail",
            "http://127.0.0.1/.nginx/status",
                ]
        start_period: 5s
        interval: 15s
        timeout: 1s
    networks:
        # The network where mariadb.local resolves to an IP
        mynetwork:
    ports:
        - "127.0.0.36:80:80"
```
