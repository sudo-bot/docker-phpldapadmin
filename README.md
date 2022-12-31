# A Docker phpldapadmin image

This image uses:

- Alpine as a base image
- [Horsut](https://github.com/FedericoPonzi/Horust#readme) to manage the services
- Nginx as a web server with PHP-FPM
- [Rust Python](https://github.com/RustPython/RustPython) to provide a single binary for `PYTHON2BASH` to work

## TODO

- SSL support
- HTTPS support

### Supported ENVs

- `PHPLDAPADMIN_LDAP_HOSTS` (Only `#PYTHON2BASH:` format)

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
            PHPLDAPADMIN_LDAP_HOSTS: "#PYTHON2BASH:[{'ldap-server': [{'server': [{'tls': False}]},{'login': [{'bind_id': 'cn=admin,dc=example,dc=org'}]}]}]"
        depends_on:
            ldap-server:
                condition: service_healthy
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

    ldap-server:
        image: botsudo/docker-openldap
        command: ldap
        restart: on-failure:5
        mem_limit: 256M
        mem_reservation: 100M
        healthcheck:
            test: 'ldapwhoami -D "cn=$${DOCKER_LDAP_HEALTHCHECK_USERNAME}" -w "$${DOCKER_LDAP_HEALTHCHECK_PASSWORD}"'
            start_period: 5s
            interval: 10s
            timeout: 5s
            retries: 3
        environment:
            # 256 to enable debug
            # See: https://www.openldap.org/doc/admin24/slapdconf2.html
            LDAP_LOG_LEVEL: 0
            LDAP_OPENLDAP_GID: 0
            LDAP_OPENLDAP_UID: 0
            LDAP_BASE_DN: "dc=example,dc=org"
            LDAP_AUTH_BASE_DN: "ou=people,dc=example,dc=org"
            LDAP_ADMIN_PASSWORD: "ldapadminpass"
            LDAP_CONFIG_PASSWORD: "ldapconfigpass"
            LDAP_MONITOR_PASSWORD: "{SSHA}1h+K1VIdptHytwoqDd+z+ozORIKmGvG3" # monitor
            # Only used by healthcheck command defined above
            DOCKER_LDAP_HEALTHCHECK_USERNAME: monitor
            DOCKER_LDAP_HEALTHCHECK_PASSWORD: monitor
            # never | allow | try | demand
            LDAP_TLS_VERIFY_CLIENT: "never"
            # Add ldaps:/// to SSL listen
            LDAP_LISTEN_URLS: "ldap:/// ldapi:///"

```
