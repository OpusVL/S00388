#!/bin/bash

source .env

function render_template() {
  eval "echo \"$(cat $1)\""
}

render_template odoo.conf.tpl > ./odoo/etc/odoo.conf
