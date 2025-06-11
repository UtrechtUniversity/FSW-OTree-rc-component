#!/bin/bash

# This script runs just before the Docker compose project in this repository
# is started. It modifies the webserver configuration, then picks up parameters
# supplied through the Research Cloud portal, creating a configuration file in
# a well known location for one of the containers ('otree')

# Define the Nginx configuration file path
nginx_conf="/etc/nginx/conf.d/ssl_main.conf"

# Define two variables containing the correct reverse proxy configuration for
# the two Docker containers
#otree_conf="location \/ {\n     \tproxy_pass http:\/\/otree:8000\/;\n     \tproxy_set_header X-Forwarded-Proto $scheme;\n     \tproxy_set_header X-Forwarded-Port $server_port;\n     \tproxy_set_header X-Real-IP $remote_addr;\n     \tproxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n     \tproxy_set_header X-Forwarded-Host $server_name;\n     \tproxy_set_header Host $host;\n     \tproxy_set_header Upgrade $http_upgrade;\n     \tproxy_set_header Connection $connection_upgrade;\n}"
#locust_conf="location \/locust\/ {\n     \tproxy_pass http:\/\/locust:8089\/;\n     \tproxy_set_header X-Forwarded-Proto $scheme;\n     \tproxy_set_header X-Forwarded-Port $server_port;\n     \tproxy_set_header X-Real-IP $remote_addr;\n     \tproxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n     \tproxy_set_header X-Forwarded-Host $server_name;\n     \tproxy_set_header Host $host;\n     \tproxy_set_header Upgrade $http_upgrade;\n     \tproxy_set_header Connection $connection_upgrade;\n}"

# Let Nginx serve the Docker containers running on port 8000, 8089 respectively
# instead of the regular static web page 'index.html'

# Note the use of double quotes around the sed expression. This is crucial
# It allows for environment variable substitution
sed -i "s|root /var/www/html;|location \/ {\n     \tproxy_pass http:\/\/localhost:8000\/;\n     \tproxy_set_header X-Forwarded-Proto $scheme;\n     \tproxy_set_header X-Forwarded-Port $server_port;\n     \tproxy_set_header X-Real-IP $remote_addr;\n     \tproxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n     \tproxy_set_header X-Forwarded-Host $server_name;\n     \tproxy_set_header Host $host;\n     \tproxy_set_header Upgrade $http_upgrade;\n     \tproxy_set_header Connection $connection_upgrade;\n}|" "$nginx_conf"
sed -i "s|index index.html index.htm;||" "$nginx_conf"

# Restart nginx to reload configuration
systemctl restart nginx.service

# The environment variable 'PLUGIN_PARAMETERS' will contain the parameters from the
# Research Cloud portal, supplied upon workspace creating, in JSON format
# Store incoming parameters as-is so we can check their value
echo $PLUGIN_PARAMETERS > /etc/parameters.txt

# Root has full access (7), root group have read access (6), not world-readable (0)
chmod 760 /etc/parameters.txt

# Replace single quotes with double quotes for jq to function
# write all parameters to an environment file in the format
# <parameter>=<value>
echo $PLUGIN_PARAMETERS \
  | sed "s/'/\"/g" \
  | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' \
  > /etc/otree.env

# Root has full access (7), root group have read access (6), not world-readable (0)
# chown root:docker /etc/otree.env
chmod 760 /etc/otree.env
