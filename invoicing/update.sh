#!/bin/bash

docker-compose pull
docker-compose stop odoo odoo-cron

cd ../maintenance || exit 1

docker-compose up -d

cd ../invoicing || exit 1

docker-compose run --rm odoo -u ${ODOO_MODULES:-all} --stop-after-init

cd ../maintenance || exit 1

docker-compose up -d

cd ../invoicing || exit 1

docker-compose up -d
