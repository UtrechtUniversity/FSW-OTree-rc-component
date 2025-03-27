#!/bin/bash

# Define the Nginx configuration file path
nginx_conf="/etc/nginx/conf.d/ssl_main.conf"

# Let Nginx serve the docker container running on port 8000 instead of a static web page
sed -i 's|root /var/www/html;|location \/ {\n     \tproxy_pass http:\/\/localhost:8000;\n     \tproxy_set_header X-Forwarded-Proto $scheme;\n     \tproxy_set_header X-Forwarded-Port $server_port;\n     \tproxy_set_header X-Real-IP $remote_addr;\n     \tproxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n     \tproxy_set_header X-Forwarded-Host $server_name;\n     \tproxy_set_header Host $host;\n     \tproxy_set_header Upgrade $http_upgrade;\n     \tproxy_set_header Connection $connection_upgrade;\n}|' "$nginx_conf"
sed -i 's|index index.html index.htm;||' "$nginx_conf"

# Restart nginx to reload configuration
systemctl restart nginx.service

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
