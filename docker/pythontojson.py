import json
import os

ldap_config = os.getenv('PHPLDAPADMIN_LDAP_HOSTS', '[]')
ldap_config = ldap_config.replace('#PYTHON2BASH:', '');
ldap_config = eval(ldap_config)

print(json.dumps(ldap_config))
