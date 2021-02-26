#!/bin/bash

cd "$(basename "$(dirname "$0")")" || exit 1

source .env || exit 1

function render_template() {
  eval "echo \"$(cat $1)\""
}

render_template odoo.conf.tpl > ./odoo/etc/odoo.conf

mkdir -p ~/.docker
render_template config.json.tpl > ~/.docker/config.json
chmod u+rw,g-rwx,o-rwx ~/.docker

# echo "${DOCKER_PASSWORD}" | docker login --username="${DOCKER_LOGIN}" --password-stdin ${ODOO_IMAGE}

cd ../syslog-ng && docker-compose up -d

cd ../invoicing || exit 1

docker-compose pull

docker-compose run --rm -u root odoo chown odoo: /var/lib/odoo /mnt/extra-addons

docker-compose up -d
