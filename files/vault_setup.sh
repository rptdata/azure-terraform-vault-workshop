#!/bin/sh

# Note: This script requires that the VAULT_ADDR, VAULT_TOKEN, and MYSQL_HOST environment variables be set.
# Example:
# export VAULT_ADDR=http://127.0.0.1:8200
# export VAULT_TOKEN=root
# export MYSQL_HOST=bugsbunny-mysql-server

# Enable Auditing
vault audit enable file file_path=/${HOME}/vault.log

# Enable database secrets engine
vault secrets enable -path=lob_a/workshop/database database

# Configure our secret engine
vault write lob_a/workshop/database/config/wsmysqldatabase \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(${MYSQL_HOST}.mysql.database.azure.com:3306)/" \
    allowed_roles="workshop-app" \
    username="hashicorp@${MYSQL_HOST}" \
    password="Password123!"

# Create our roles
vault write lob_a/workshop/database/roles/workshop-app-long \
    db_name=wsmysqldatabase \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"

vault write lob_a/workshop/database/roles/workshop-app \
    db_name=wsmysqldatabase \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="5m" \
    max_ttl="1h"

# Install app prerequisites
sudo apt-get -y update > /dev/null 2>&1
sudo apt install -y python3-pip > /dev/null 2>&1
sudo pip3 install mysql-connector-python hvac Flask > /dev/null 2>&1

echo "Script complete."