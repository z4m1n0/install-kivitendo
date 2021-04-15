#!/bin/bash
set +e

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Password for DB-user kivitendo asked later."
read -p "Password [kivitendo]: " PASSWD
PASSWD=${PASSWD:-"kivitendo"}

read -p "Installation directory, without appended Slash [/var/www]: " DIR
DIR=${DIR:-"/var/www"}

./setup_kivitendo.sh -p $PASSWD -d $DIR

./setup_postgresql.sh -p $PASSWD -d $DIR

./setup_apache2.sh -d $DIR

echo "
Installation finished!
kivitendo can be opened under:
http://localhost/kivitendo/
"
