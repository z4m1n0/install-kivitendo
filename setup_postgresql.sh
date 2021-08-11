#!/bin/bash
set +e
## check correct start #########################################################
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

while getopts 'p:d:D:' OPTION; do
  case "$OPTION" in
    p)
      PASSWD="$OPTARG"
      ;;
    d)
      DIR="$OPTARG"
      ;;
    D)
      postgres_dir="$OPTARG"
      ;;
  esac
done

if [ -z "$PASSWD" ] || [ -z "$DIR" ] ; then
  echo "Usage: $0 -p passwd -d install_dir [-D postgres_dir]"
  exit 1
fi
################################################################################

if [ -n "$postgres_dir" ]; then
  POSTGRES_DIR=$postgres_dir
elif [ -d "/var/lib/postgres/data" ]; then
  POSTGRES_DIR="/var/lib/postgres/data"
elif [ -d "/var/lib/pgsql/data" ]; then
  POSTGRES_DIR="/var/lib/pgsql/data"
elif [ -d "/etc/postgresql/" ]; then
  POSTGRES_DIR="/etc/postgresql/"
else
  echo "Can't find postgres directory. You can provit it with the option -P !"
  echo "Usage: $0 -p passwd -d install_dir [-P postgres_dir]"
  exit 1
fi

# cd in a directory which all user can access
cd /

read -p "Change password of user postgres to selected password (default: postgres)? [Y/n] : " CHANGE_POSTGRES_PASSWD
CHANGE_POSTGRES_PASSWD=${CHANGE_POSTGRES_PASSWD:-"Y"}
if [ "$CHANGE_POSTGRES_PASSWD" = "y" ] || [ "$CHANGE_POSTGRES_PASSWD" = "Y" ]; then
  sudo -u postgres -H -- psql -d template1 -c "ALTER ROLE postgres WITH password '$PASSWD'"
  echo "Password changed"
fi

echo "change config postgres"
sed -i "s/^.*listen_addresses =.*$/listen_addresses = 'localhost'/" $POSTGRES_DIR/postgresql.conf

sed -i "/^.*local all kivitendo password.*$/d" $POSTGRES_DIR/pg_hba.conf
echo "local all kivitendo password" >> $POSTGRES_DIR/pg_hba.conf

sed -i "/^.*host all kivitendo 127.0.0.1 255.255.255.255 password.*$/d" $POSTGRES_DIR/pg_hba.conf
echo "host all kivitendo 127.0.0.1 255.255.255.255 password" >> $POSTGRES_DIR/pg_hba.conf

#TODO: do't use dialog and test
if [ -d "$DIR/kivitendo-crm" ]; then
dialog --title "Datenbank installieren" --backtitle "kivitendo installieren" --yesno "Möchten Sie die Beispiel-Datenbank installieren?" 7 60
response=$?
else
response=1
fi

case $response in
  0) echo "Datenbank wird installiert."
    sudo -u postgres -H -- createdb kivitendo_auth
    sudo -u postgres -H -- createdb demo-db
    sudo -u postgres -H -- psql kivitendo_auth < $DIR/kivitendo-crm/install/kivitendo_auth.sql
    sudo -u postgres -H -- psql demo-db < $DIR/kivitendo-crm/install/demo-db.sql
    echo "Beim Login: Benutzername: demo, Password: kivitendo"
    echo "***************************************************"
    if [ "$PASSWD" != "kivitendo" ]; then
      echo "Es wurde ein eigenes Passwort vergeben."
      echo "Dieses Passwort muss in der Mandantenkonfiguration eingetragen werden!"
      echo "(http://localhost/kivitendo/controller.pl?action=Admin/login)"
    fi
    ;;
  1) 
    read -p "Please ensure that the database is up and running! (Enter to continue)" CHANGE_POSTGRES_PASSWD
    echo "Datenbank wird initalisiert."
    echo 'CREATE EXTENSION IF NOT EXISTS plpgsql;\q' | sudo -u postgres -H -- psql template1
    echo "create user kivitendo for psql"
    sudo -u postgres -H -- createuser -d -P kivitendo
    echo "Es muss noch am Ende eine Datenbank angelegt werden!"
    echo "(http://localhost/kivitendo/controller.pl?action=Admin/login)"
    ;;
esac

systemctl restart postgresql.service
