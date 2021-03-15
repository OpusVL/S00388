#!/bin/bash

# NOTE: This should run as the root user as when AWS starts the AMI it runs as root

if [[ "${EUID}" -ne 0 ]]; then
  echo "This must be run as root"
  exit 1
fi

#if [[ 1 -ne 1 ]]; then
# START Docker install
# Install from the oficial docker repository and remove the existing

systemctl stop docker.service docker.socket

apt-get purge -y docker-ce docker-ce-cli containerd.io

apt-get update

apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    zsh

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io

systemctl stop docker.service docker.socket

systemctl start docker

curl -L "https://github.com/docker/compose/releases/download/1.28.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

### END Docker install
#fi

SCRIPT_PATH=/srv/container-deployments

cd ${SCRIPT_PATH}/invoicing || exit 1

source .env || exit 1

function render_template() {
  eval "echo \"$(cat $1)\""
}

chown ubuntu ${SCRIPT_PATH} -R
chgrp docker ${SCRIPT_PATH} -R

# Render the odoo.conf template file 

render_template odoo.conf.tpl > ./odoo/etc/odoo.conf

# Enable login to the registry without username / password

mkdir -p ~/.docker
render_template config.json.tpl > ~/.docker/config.json
chmod u+rw,g-rwx,o-rwx ~/.docker

# echo "${DOCKER_PASSWORD}" | docker login --username="${DOCKER_LOGIN}" --password-stdin ${ODOO_IMAGE}

# Add the user to the docker group

gpasswd -a ubuntu docker

# Start Odoo

cd ${SCRIPT_PATH}/invoicing || exit 1

docker-compose pull

docker-compose run --rm -u root odoo chown odoo: /var/lib/odoo /mnt/extra-addons

docker-compose up -d

cd /home/ubuntu || exit 1

echo "Script path: ${SCRIPT_PATH}"

cp ${SCRIPT_PATH}/.zshrc .
tar xf ${SCRIPT_PATH}/oh-my-zsh.tgz --directory /

chown ubuntu: .zshrc .oh-my-zsh -R

cp ${SCRIPT_PATH}/motd.uat /etc/motd