#!/bin/bash

#== If webRoot has not been difined, we will set appRoot to webRoot
if [[ ! -n "$WEB_ROOT" ]]; then
  export WEB_ROOT=$APP_ROOT
fi

#== Composer install.
if [[ -f "$APP_ROOT/composer.json" ]]; then
  cd $APP_ROOT && composer install;
fi
if [[ -f "$WEB_ROOT/composer.json" ]]; then
  cd $WEB_ROOT && composer install;
fi

# #Securing file permissions and ownership
# #https://www.drupal.org/docs/security-in-drupal/securing-file-permissions-and-ownership
[[ ! -d "$WEB_ROOT/sites/default/files" ]] && mkdir --mode 775 "$WEB_ROOT/sites/default/files"
chown -R www:www-data .;

#== Use Drush to create site installed
drush -y site-install standard --account-name=$DRUPAL_ADMIN --account-pass=$DRUPAL_ADMINPWD --db-url=mysql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME;