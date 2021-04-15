#!/bin/bash
set -e

## Memo und Script zur Installation von kivitendo unter Ubuntu 18.04 Bionic (LTS)
echo "Pakete installieren"
apt-get update && apt-get upgrade
apt-get install make gcc apache2 libapache2-mod-fcgid libarchive-zip-perl libclone-perl libconfig-std-perl libdatetime-perl libdbd-pg-perl libdbi-perl libemail-address-perl libemail-mime-perl libfcgi-perl libjson-perl liblist-moreutils-perl libnet-smtp-ssl-perl libnet-sslglue-perl libparams-validate-perl libpdf-api2-perl librose-db-object-perl librose-db-perl librose-object-perl libsort-naturally-perl libstring-shellquote-perl libtemplate-perl libtext-csv-xs-perl libtext-iconv-perl liburi-perl libxml-writer-perl libyaml-perl libfile-copy-recursive-perl libgd-gd2-perl libimage-info-perl libalgorithm-checkdigits-perl postgresql git perl-doc libapache2-mod-php php-gd php-imap php-mail php-mail-mime php-pgsql php-fpdf imagemagick fonts-freefont-ttf php-curl dialog php-enchant aspell-de libcgi-pm-perl libdatetime-set-perl libfile-mimeinfo-perl liblist-utilsby-perl libpbkdf2-tiny-perl libregexp-ipv6-perl libtext-unidecode-perl libdaemon-generic-perl libfile-flock-perl libfile-slurp-perl libset-crontab-perl apt install libdatetime-event-cron-perl python3 python3-serial

cpan HTML::Restrict
cpan CGI
cpan Mozilla::CA

pear install  Contact_Vcard_Build Contact_Vcard_Parse


dialog --title "Latex installieren" --backtitle "kivitendo installieren" --yesno "Möchten Sie Latex installieren?" 7 60


response=$?
case $response in
   0) echo "Latex wird installiert."
      apt-get install texlive-base-bin texlive-latex-recommended texlive-fonts-recommended texlive-latex-extra texlive-lang-german texlive-generic-extra
      ;;
   1) echo "Latex wird nicht installiert."
      ;;
esac

