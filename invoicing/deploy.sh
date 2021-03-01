#!/bin/bash

# NOTE: This should run as the root user as when AWS starts the AMI it runs as root

if [[ "${EUID}" -ne 0 ]]; then
  echo "This must be run as root"
  exit 1
fi

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

DIR=$(basename "$(dirname "$0")")

cd ${DIR} || exit 1

source .env || exit 1

function render_template() {
  eval "echo \"$(cat $1)\""
}

chown ubuntu ../ -R
chgrp docker ../ -R

# Render the odoo.conf template file 

render_template odoo.conf.tpl > ./odoo/etc/odoo.conf

# Enable login to the registry without username / password

mkdir -p ~/.docker
render_template config.json.tpl > ~/.docker/config.json
chmod u+rw,g-rwx,o-rwx ~/.docker

# echo "${DOCKER_PASSWORD}" | docker login --username="${DOCKER_LOGIN}" --password-stdin ${ODOO_IMAGE}

# Add the user to the docker group

gpasswd -a ubuntu docker

# Start syslog - if you use tcp then this MUST be running or the Odoo container wont start

cd ../syslog-ng || exit 1

ln -s ../invoicing/.env .env

docker-compose run --rm -u root syslog chown root: /etc/logrotate.d/ -R

docker-compose up -d

# Start Odoo

cd ../invoicing || exit 1

docker-compose pull

docker-compose run --rm -u root odoo chown odoo: /var/lib/odoo /mnt/extra-addons

docker-compose up -d

cd /home/ubuntu || exit 1

cp ${DIR}/.zshrc .
tar xf ${DIR}/oh-my-zsh.tgz

chown ubuntu: .zshrc .oh-my-zsh -R
