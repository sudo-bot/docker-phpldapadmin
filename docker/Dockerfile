# syntax=docker/dockerfile:1
FROM alpine:3.17

ARG VERSION="1.2.6.5"
ARG DIST_URL="https://github.com/leenooks/phpLDAPadmin/archive/refs/tags/${VERSION}.tar.gz"
ARG BUILD_DATE
ARG VCS_REF

# Set user and group
ARG user=deploy
ARG group=deploy

ENV CONTAINER_SERVICE_DIR="/container/service"
ENV FIRST_START_DONE="/container/first-start-done"

COPY --from=botsudo/docker-rustpython:latest /usr/local/bin/rustpython /usr/local/bin/rustpython
COPY --from=botsudo/docker-rustpython:latest /usr/local/share/sbom/rustpython.spdx.json /usr/local/share/sbom/rustpython.spdx.json

RUN apk add --no-cache --update nginx curl bash musl \
    openssl libgcc \
    php81-fpm php81 php81-session \
    php81-json php81-curl php81-xml php81-gettext php81-mbstring php81-ldap php81-ctype && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing horust && \
    horust --help && nginx -v && php-fpm81 -v && php -v && \
    mkdir -p /var/log/php81 && \
    mkdir /run/phpfpm && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    ln -sf /dev/stderr /var/log/php81/error.log && \
    date -R > /build_date && \
    printf '{"build_date": "%s", "timestamp": %i}' "$(date -R)" "$(date +%s)" > /build_date.json && \
    addgroup -S ${group} && \
    adduser -G ${group} -G nginx -s /bin/sh -h /var/www/phpldapadmin -S ${user} && \
    id deploy && \
    chown -R deploy:deploy /var/log/php81 /var/lib/nginx /run/nginx /run/phpfpm && \
    chmod -R 770 /var/log/php81 /var/lib/nginx /run/nginx /run/phpfpm && \
    mkdir /container && \
    chown deploy:deploy /container && \
    rustpython --help

WORKDIR /var/www/phpldapadmin

COPY docker-entrypoint.sh /
COPY log-helper /usr/local/sbin/
COPY pythontojson.py /usr/local/sbin/
COPY --chown=deploy:deploy horust/ /etc/horust/
COPY nginx-default.conf /etc/nginx/http.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm-www-pool.conf /etc/php81/php-fpm.d/www.conf
COPY --chown=deploy:deploy config.php ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/config/config.php


# Switch to user
USER deploy:deploy

RUN curl -# -L -o phpldapadmin.tar.gz ${DIST_URL} && \
    tar -xzf phpldapadmin.tar.gz -C /var/www/phpldapadmin --strip-components=1 && \
    rm phpldapadmin.tar.gz && \
    rm -vr ./doc/ ./.gitignore ./*.md && \
    php -l lib/functions.php

COPY <<-EOT /usr/local/share/sbom/phpldapadmin.spdx.json
{
    "spdxVersion": "SPDX-2.3",
    "dataLicense": "CC0-1.0",
    "SPDXID": "SPDXRef-DOCUMENT",
    "name": "docker-phpldapadmin",
    "packages": [
        {
            "name": "phpldapadmin",
            "SPDXID": "SPDXRef-Package-phpldapadmin",
            "versionInfo": "${VERSION}",
            "originator": "Person: Deon George",
            "downloadLocation": "${DIST_URL}",
            "sourceInfo": "dowloaded from GitHub releases",
            "licenseConcluded": "GPL-2.0-or-later",
            "licenseDeclared": "GPL-2.0-or-later",
            "copyrightText": "NOASSERTION",
            "description": "phpLDAPadmin"
        }
    ],
    "externalRefs": [
        {
            "referenceCategory": "SECURITY",
            "referenceLocator": "cpe:2.3:a:phpldapadmin_project:phpldapadmin",
            "referenceType": "cpe23Type"
        },
        {
            "referenceCategory": "SECURITY",
            "referenceLocator": "cpe:/a:phpldapadmin_project:phpldapadmin",
            "referenceType": "cpe22Type"
        },
        {
            "referenceCategory": "PACKAGE_MANAGER",
            "referenceLocator": "pkg:deb/debian/phpldapadmin",
            "referenceType": "purl"
        }
    ]
}
EOT

# Metadata
LABEL org.label-schema.vendor="Sudo-Bot" \
    org.label-schema.url="https://github.com/sudo-bot/docker-phpldapadmin#readme" \
    org.label-schema.name="docker-phpldapadmin" \
    org.label-schema.description="A phpLDAPadmin image" \
    org.label-schema.version=${VERSION} \
    org.label-schema.vcs-url="https://github.com/sudo-bot/docker-phpldapadmin.git" \
    org.label-schema.vcs-ref=${VCS_REF} \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.docker.schema-version="1.0" \
    \
    com.docker.extension.publisher-url="https://github.com/sudo-bot" \
    \
    org.opencontainers.image.title="Docker phpLDAPadmin server" \
    org.opencontainers.image.description="A phpLDAPadmin image" \
    org.opencontainers.image.authors="williamdes@wdes.fr" \
    org.opencontainers.image.url="https://github.com/sudo-bot/docker-phpldapadmin#readme" \
    org.opencontainers.image.documentation="https://github.com/sudo-bot/docker-phpldapadmin#readme" \
    org.opencontainers.image.source="https://github.com/sudo-bot/docker-phpldapadmin" \
    org.opencontainers.image.vendor="Sudo-Bot" \
    org.opencontainers.image.licenses="MPL-2.0" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.version=${VERSION} \
    org.opencontainers.image.revision=${VCS_REF} \
    org.opencontainers.image.ref.name="${VERSION}"

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
