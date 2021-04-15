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

HTTPD_DIR="/etc/httpd/conf"

echo "Enable fcgi"

sed -i "s/^.*LoadModule actions_module modules\/mod_actions.so.*$/LoadModule actions_module modules\/mod_actions.so/" $HTTPD_DIR/httpd.conf

sed -i "/^.*LoadModule fcgid_module modules\/mod_fcgid.so.*$/d" $HTTPD_DIR/httpd.conf
sed -i "s/^.*<IfModule unixd_module>.*$/<IfModule unixd_module>\nLoadModule fcgid_module modules\/mod_fcgid.so/" $HTTPD_DIR/httpd.conf

sed -i "s/^.*Include conf\/extra\/httpd-mpm.conf.*$/Include conf\/extra\/httpd-mpm.conf/" $HTTPD_DIR/httpd.conf

sed -i "/^.*Include conf\/extra\/httpd-mpm.conf.*$/d" $HTTPD_DIR/httpd.conf
echo "Include conf/extra/httpd-mpm.conf" >> $HTTPD_DIR/httpd.conf


echo "Virtuellen Host anlegen"
if ! [ -d "$HTTPD_DIR/vhosts" ]; then
  mkdir $HTTPD_DIR/vhosts
fi

if [ -f $HTTPD_DIR/vhosts/kivitendo.conf ]; then
    echo "Lösche vorherigen Virtuellen Host"
    rm -f $HTTPD_DIR/vhosts/kivitendo.conf
fi

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
" >> $HTTPD_DIR/vhosts/kivitendo.conf
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
" >> $HTTPD_DIR/vhosts/kivitendo.conf
fi

echo "Enable vhost"
sed -i "/^.*Include conf\/vhosts\/kivitendo.conf.*$/d" $HTTPD_DIR/httpd.conf
echo "Include conf/vhosts/kivitendo.conf" >> $HTTPD_DIR/httpd.conf

systemctl restart httpd.service
