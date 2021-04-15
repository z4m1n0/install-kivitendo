#!/bin/bash
set +e

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

./install_dependencies_arch.sh
./install_and_setup_kivitendo_for_httpd.sh
