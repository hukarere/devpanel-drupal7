#!/bin/bash

#== If webRoot has not been difined, we will set appRoot to webRoot
if [[ ! -n "$WEB_ROOT" ]]; then
  export WEB_ROOT=$APP_ROOT
fi

STATIC_FILES_PATH="$WEB_ROOT/sites/default/files/";

#Create static directory
if [ ! -d "$STATIC_PATH" ]; then
  mkdir -p $STATIC_FILES_PATH;
fi;

#== Extract static files
if [[ -f "$APP_ROOT/.devpanel/dumps/files.tgz" ]]; then
  tar xzf "$APP_ROOT/.devpanel/dumps/files.tgz" -C $STATIC_FILES_PATH;
fi
#== Import mysql files
if [[ -f "$APP_ROOT/.devpanel/dumps/db.sql.tgz" ]]; then
  SQLFILE=$(tar tzf $APP_ROOT/.devpanel/dumps/db.sql.tgz)
  tar xzf "$APP_ROOT/.devpanel/dumps/db.sql.tgz" -C /tmp/
  mysql -h$DB_HOST -u$DB_USER -p$DB_PASSWORD $DB_NAME < /tmp/$SQLFILE
  rm /tmp/$SQLFILE
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
[[ ! -d "$WEB_ROOT/sites/default/files" ]] && mkdir --mode 775 "$WEB_ROOT/sites/default/files" || chmod 775 -R "$WEB_ROOT/sites/default/files"
chown -R www:www-data .;

#== Create settings files
[[ ! -f "$WEB_ROOT/sites/default/settings.php" ]] && cp $APP_ROOT/.devpanel/drupal8-settings.php $WEB_ROOT/sites/default/settings.php;

if [[ ! -z "$DRUPAL_HASH_SALT" ]]; then

cat <<EOF >> $WEB_ROOT/sites/default/settings.php
\$drupal_hash_salt = getenv('DRUPAL_HASH_SALT');
EOF

else
echo "DRUPAL_HASH_SALT environment is not set, Random new hash salt..."
cat <<EOF >> $WEB_ROOT/sites/default/settings.php
\$drupal_hash_salt = "$(openssl rand -base64 32)";;
EOF

fi