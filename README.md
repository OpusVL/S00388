<img src="./.assets/nhs-digital-logo.svg" height="150px">

# gpit-invoicing

GP IT Futures invoicing system

This repository has been specifically designed to act as a launcher from within the AWS appserver.

The Terraform script should call a `git clone` onto the appserver and call the `./invoicing/deploy.sh` script. The deploy script should handle the pull and up of the Odoo invoicing services.

## Dependencies

PostgreSQL - Amazon RDS Database

Odoo Container Set - Odoo Odoo cron services

OpusVL Documentation: [Link](https://wiki.opusvl.io/wiki/GPIT_-_Amazon_AWS#Terraform_.2F_aws-vault)

## Basic Features

Docker container set using docker-compose to provide an instance of Odoo from the OpusVL repository.

## Change Log

2021-03-15 Removed syslog-ng and move to direct logging to cloudwatch
