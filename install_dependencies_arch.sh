#!/bin/bash
set +e

if ! command -v yay &> /dev/null; then
  echo "You need to install yay (Yet Another Yogurt) first!!"
  echo "(https://aur.archlinux.org/packages/yay/)"
  exit 1
fi

echo "Install packages"
yay -Su -y
pacman -S make gcc apache mod_fcgid perl-file-slurper perl-set-infinite perl-archive-zip perl-clone perl-datetime perl-datetime-set perl-dbd-pg perl-dbi perl-email-address perl-email-mime perl-fcgi perl-cgi perl-json perl-list-moreutils perl-params-validate perl-pdf-api2 perl-sort-naturally perl-string-shellquote perl-template-toolkit perl-text-iconv perl-uri perl-xml-writer perl-yaml perl-file-copy-recursive perl-image-info postgresql git perl

yay -S perl-config-std perl-algorithm-checkdigits perl-rose-db-object perl-rose-db perl-rose-object perl-text-csv-xs perl-regexp-ipv6 perl-pbkdf2-tiny perl-html-restrict perl-file-flock perl-daemon-generic perl-cam-pdf perl-datetime-event-cron

######## Optional and Developer
read -p "Install all dependencies (optional and developer)? [Y/n] : " ALL_DEPENDENCIES
ALL_DEPENDENCIES=${ALL_DEPENDENCIES:-"Y"}

if [ "$ALL_DEPENDENCIES" = "y" ] || [ "$ALL_DEPENDENCIES" = "Y" ]; then
  pacman -S perl-net-smtp-ssl perl-gd perl-net-ldap-server perl-log-log4perl perl-test-deep perl-test-output perl-test-exception perl-extutils-depends
  cpan inc::Module::Install::DSL
  yay -S perl-net-sslglue perl-yaml-libyaml perl-dbix-log4perl perl-devel-repl perl-moose perl-sys-cpu perl-thread-pool-simple perl-uri-find 
fi

############# CRM
#TODO
##########################################

read -p "Install Latex? [Y/n] : " INSTALL_LATEX
INSTALL_LATEX=${INSTALL_LATEX:-"Y"}
if [ "$INSTALL_LATEX" = "y" ] || [ "$INSTALL_LATEX" = "Y" ]; then
  echo "Latex wird installiert."
  pacman -S texlive-core texlive-latexextra texlive-pictures
fi
