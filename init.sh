#!/bin/bash

# Define the Nginx configuration file path
nginx_conf="/etc/nginx/conf.d/ssl_main.conf"

# Let Nginx serve the docker container running on port 8000 instead of a static web page
sed -i 's|root /var/www/html;|location \/ {\n    \tproxy_pass http:\/\/localhost:8000;\n    \tproxy_set_header Host $host;\n    \tproxy_set_header X-Real-IP $remote_addr;\n    }|' "$nginx_conf"
sed -i 's|index index.html index.htm;||' "$nginx_conf"

# Restart nginx to reload configuration
systemctl restart nginx.service

parameters=$PLUGIN_PARAMETERS
echo $parameters | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' > /var/parameters.txt