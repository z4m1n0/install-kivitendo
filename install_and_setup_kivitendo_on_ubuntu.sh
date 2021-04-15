#!/bin/bash set -e
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

./install_dependencies_ubuntu-18_04.sh
./install_and_setup_kivitendo_for_apache2.sh
