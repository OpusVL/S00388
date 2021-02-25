#!/bin/bash

source .env

function render_template() {
  eval "echo \"$(cat $1)\""
}

render_template odoo.conf.tpl > ./odoo/etc/odoo.conf

mkdir -p ~/.docker
render_template config.json.tpl.tpl > ~/.docker.config.json
chmod u+rw,g-rwx,o-rwx ~/.docker
