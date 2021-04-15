#!/bin/bash
set +e
## check correct start #########################################################
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

while getopts 'd:' OPTION; do
  case "$OPTION" in
    d)
      DIR="$OPTARG"
      ;;
  esac
done

if [ -z "$DIR" ]; then
  echo "Usage: $0 -d install_dir"
  exit 1
fi
################################################################################

APACHE_DIR="$APACHE_DIR"

a2enmod fcgid

echo "Virtuellen Host anlegen"
if [ -f $APACHE_DIR/sites-available/kivitendo.conf ]; then
    echo "Lösche vorherigen Virtuellen Host"
    rm -f $APACHE_DIR/sites-available/kivitendo.conf
fi
touch $APACHE_DIR/sites-available/kivitendo.conf

if [ -d "$DIR/kivitendo-crm" ]; then
echo "AddHandler fcgid-script .fpl
AliasMatch ^/kivitendo/[^/]+\.pl $DIR/kivitendo-erp/dispatcher.fpl
Alias       /kivitendo/          $DIR/kivitendo-erp/
FcgidMaxRequestLen 10485760
<Directory $DIR/kivitendo-erp>
  AllowOverride All
  Options ExecCGI Includes FollowSymlinks
  AddHandler cgi-script .py
  DirectoryIndex login.pl
  AddDefaultCharset UTF-8
  Require all granted
</Directory>
<Directory $DIR/kivitendo-erp/users>
  Require all denied
</Directory>
<Directory $DIR/kivitendo-crm>
  AddDefaultCharset UTF-8
  Require all denied
</Directory>
" >> $APACHE_DIR/sites-available/kivitendo.conf
else
echo "AddHandler fcgid-script .fpl
AliasMatch ^/kivitendo/[^/]+\.pl $DIR/kivitendo-erp/dispatcher.fpl
Alias       /kivitendo/          $DIR/kivitendo-erp/
FcgidMaxRequestLen 10485760
<Directory $DIR/kivitendo-erp>
  AllowOverride All
  Options ExecCGI Includes FollowSymlinks
  AddDefaultCharset UTF-8
  Require all granted
</Directory>
<Directory $DIR/kivitendo-erp/users>
  Require all denied
</Directory>
" >> $APACHE_DIR/sites-available/kivitendo.conf

ln -sf $APACHE_DIR/sites-available/kivitendo.conf $APACHE_DIR/sites-enabled/kivitendo.conf
fi

service apache2 restart
