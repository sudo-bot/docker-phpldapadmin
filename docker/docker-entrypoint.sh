#!/bin/sh -l
##
# @license MPL-2.0
# @author William Desportes <williamdes@wdes.fr>
##

set -eu

# License: MIT - 2016-2021 Bertrand Gouny
# if there is no config
if [ ! -e "/var/www/phpldapadmin/config/config.php" ]; then

  # on container first start customise the container config file
  if [ ! -e "$FIRST_START_DONE" ]; then

    get_salt() {
      salt=$(</dev/urandom tr -dc '1324567890#<>,()*.^@$% =-_~;:/{}[]+!`azertyuiopqsdfghjklmwxcvbnAZERTYUIOPQSDFGHJKLMWXCVBN' | head -c64 | tr -d '\\')
    }

    # phpLDAPadmin cookie secret
    get_salt
    sed -i "s|{{ PHPLDAPADMIN_CONFIG_BLOWFISH }}|${salt}|g" ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/config/config.php

    touch $FIRST_START_DONE
  fi

  log-helper debug "link ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/config/config.php to /var/www/phpldapadmin/config/config.php"
  cp -f ${CONTAINER_SERVICE_DIR}/phpldapadmin/assets/config/config.php /var/www/phpldapadmin/config/config.php
  php -l /var/www/phpldapadmin/config/config.php
fi

export PHPLDAPADMIN_LDAP_HOSTS="$(rustpython /usr/local/sbin/pythontojson.py)"

log-helper debug 'Starting...'
horust --unsuccessful-exit-finished-failed
log-helper debug 'Stopped.'
