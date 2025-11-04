#!/bin/bash
set -e

export PATH=$PATH:/usr/local/bin

mkdir -p /var/www/ghost
chown ghostuser:ghostuser /var/www/ghost
chmod 775 /var/www/ghost
cd /var/www/ghost

ghost install \
  --db mysql \
  --dbhost "$1" \
  --dbuser "$2" \
  --dbpass "$3" \
  --dbname "$4" \
  --no-prompt \
  --no-setup-nginx \
  --no-setup-ssl \
  --no-setup-systemd \
  --url "$5"


runcmd:
  - /bin/bash cloud-init/install-ghost.sh "${mysql_ip}" "ghost" "${db_pass}" "ghost_db" "http://${nginx_ip}"