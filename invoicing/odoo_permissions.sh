#!/bin/sh

# Change the ownership of the odoo folder to match the odoo container user.

docker-compose run --rm -u root odoo chown odoo: /var/lib/odoo /mnt/extra-addons