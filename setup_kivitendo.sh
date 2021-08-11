#!/bin/bash
set +e
## check correct start #########################################################
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

while getopts 'p:d:' OPTION; do
  case "$OPTION" in
    p)
      PASSWD="$OPTARG"
      ;;
    d)
      DIR="$OPTARG"
      ;;
  esac
done

if [ -z "$PASSWD" ] || [ -z "$DIR" ]; then
  echo "Usage: $0 -p passwd -d install_dir"
  exit 1
fi
################################################################################

if [ ! -d $DIR/kivitendo-erp ]; then
    git clone https://github.com/kivitendo/kivitendo-erp.git $DIR/kivitendo-erp
fi

read -p "Choose Stable-Version? [Y/n] : " CHECKOUT_STABLE
CHECKOUT_STABLE=${CHECKOUT_STABLE:-"Y"}
if [ "$CHECKOUT_STABLE" = "y" ] || [ "$CHECKOUT_STABLE" = "Y" ]; then
  #echo "last stable version selected"
  #cd $DIR/kivitendo-erp
  #git checkout `git tag -l | egrep -ve "(alpha|beta|rc)" | tail -1`


  cd $DIR/kivitendo-erp
  var=$(git tag | xargs -I@ git log --format=format:"%ai @%n" -1 @ | sort | awk '{print $4,v++,"off"}' | tail -n 8)
  _temp="/tmp/answer.$$"

  #TODO don't use dialog
  dialog --backtitle "ERP-Version wählen, ESC für Git" --radiolist "Wähle Tag der ausgecheckt werden soll (Leertaste), ESC für aktuelle Git-Version!" 20 50 8 $var 2>$_temp
  result=`cat $_temp`

  gitlog=$(git log -1 --pretty=oneline --abbrev-commit)

  if [ -z "$result" ]; then
       dialog --title "Aktuelle Git" --msgbox "Aktuelle Entwicklerversion:\n$gitlog" 8 66
  else
      dialog --title "Ausgewählter Tag" --msgbox "$result wird ausgecheckt!" 6 44
      git checkout $result
  fi
fi

echo "create additional folder and set owner for folders"
cd $DIR/kivitendo-erp
if [ ! -d ./webdav ]; then
  mkdir webdav
fi
chown -R http: users spool webdav
chown http: templates users

echo "create config/kivitendo.conf"
cp -f $DIR/kivitendo-erp/config/kivitendo.conf.default $DIR/kivitendo-erp/config/kivitendo.conf

echo "kivitendo.conf bearbeiten"
sed -i "s/admin_password.*$/admin_password = $PASSWD/" $DIR/kivitendo-erp/config/kivitendo.conf
sed -i "s/password =$/password = $PASSWD/" $DIR/kivitendo-erp/config/kivitendo.conf


# TODO: Test crm
read -p "Install crm (NOT TESTED)? [y/N] : " INSTALL_CRM
INSTALL_CRM=${INSTALL_CRM:-"N"}
if [[ "$INSTALL_CRM" = "y" || "$INSTALL_CRM" = "Y" ]]; then
  git clone https://github.com/kivitendo/kivitendo-crm.git $DIR/

  echo "ERP-Plugins install"
  sed -i '$adocument.write("<script type='text/javascript' src='crm/js/ERPplugins.js'></script>")' $DIR/kivitendo-erp/js/kivi.js

  chown -R www-data: $DIR/kivitendo-crm/*
  ln -s $DIR/kivitendo-crm/ $DIR/kivitendo-erp/crm

  ##Menü verlinken oder kopieren:
  ln -s $DIR/kivitendo-crm/menu/10-crm-menu.yaml $DIR/kivitendo-erp/menus/user/10-crm-menu.yaml

  ##Rechte für CRM ermöglichen:
  ln -s $DIR/kivitendo-crm/update/add_crm_master_rights.sql $DIR/kivitendo-erp/sql/Pg-upgrade2-auth/add_crm_master_rights.sql

  ##Übersetzungen anlegen:
  mkdir $DIR/kivitendo-erp/locale/de/more
  ln -s $DIR/kivitendo-crm/menu/t8e/menu.de $DIR/kivitendo-erp/locale/de/crm-menu.de
  ln -s $DIR/kivitendo-crm/menu/t8e/menu-admin.de $DIR/kivitendo-erp/locale/de/crm-menu-admin.de
fi
