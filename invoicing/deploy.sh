#!/bin/bash

sudo chown ${USER} ${CONTAINER_VOLUME} -R
sudo chgrp docker ${CONTAINER_VOLUME} -R

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

# Add the user to the docker group and refresh/activate it

sudo gpasswd -a ${USER} docker
newgrp docker

cd ${CONTAINER_VOLUME}/syslog-ng || exit 1

docker-compose run --rm -u root syslog chown root: /etc/logrotate.d/ -R

ln -s ${CONTAINER_VOLUME}/invoicing/.env .env

docker-compose up -d

cd ${CONTAINER_VOLUME}/invoicing || exit 1

docker-compose pull

docker-compose run --rm -u root odoo chown odoo: /var/lib/odoo /mnt/extra-addons

docker-compose up -d
