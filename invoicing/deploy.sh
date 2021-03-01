#!/bin/bash

DIR=$(basename "$(dirname "$0")")

cd ${DIR} || exit 1

source .env || exit 1

function render_template() {
  eval "echo \"$(cat $1)\""
}

sudo chown ${USER} ${DIR} -R
sudo chgrp docker ${DIR} -R

render_template odoo.conf.tpl > ./odoo/etc/odoo.conf

mkdir -p ~/.docker
render_template config.json.tpl > ~/.docker/config.json
chmod u+rw,g-rwx,o-rwx ~/.docker

# echo "${DOCKER_PASSWORD}" | docker login --username="${DOCKER_LOGIN}" --password-stdin ${ODOO_IMAGE}

# Add the user to the docker group and refresh/activate it

sudo gpasswd -a ${USER} docker
newgrp docker

cd ${DIR}/syslog-ng || exit 1

docker-compose run --rm -u root syslog chown root: /etc/logrotate.d/ -R

ln -s ${DIR}/invoicing/.env .env

docker-compose up -d

cd ${DIR}/invoicing || exit 1

docker-compose pull

docker-compose run --rm -u root odoo chown odoo: /var/lib/odoo /mnt/extra-addons

docker-compose up -d
