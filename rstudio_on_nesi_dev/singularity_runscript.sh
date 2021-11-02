#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $(basename $0) NGINX_PORT PROXY_URL"
    exit 1
fi

module load R/$RVER Python

NGINX_PORT="$1"
PROXY_URL="${2#/}"

# trick to find a free port (see https://unix.stackexchange.com/a/132524 and jupyter-server-proxy source code)
RSTUDIO_PORT="$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')"

# create Nginx configuration template file for rstudio reverse proxy
cat << EOF > /var/lib/rstudio-server/nginx.conf
pid /tmp/nginx.pid;
worker_processes 1;
$([[ $LOGLEVEL = "DEBUG" ]]  && echo "error_log /dev/stdout debug;")
daemon off;

  events {
    worker_connections 1024;
  }

http {
  root /tmp/;
  access_log /tmp/access.log;

  client_body_temp_path /tmp/client_body/;
  fastcgi_temp_path /tmp/fastcgi/;
  proxy_temp_path /tmp/proxy/;
  scgi_temp_path /tmp/scgi/;
  uwsgi_temp_path /tmp/uwsgi/;

  map \$http_upgrade \$connection_upgrade {
    default upgrade;
    ''      close;
  }

  server {
    listen $NGINX_PORT;

    location / {
      proxy_pass http://localhost:$RSTUDIO_PORT;
      proxy_redirect http://localhost:$RSTUDIO_PORT http://\$http_host/$PROXY_URL;
      proxy_redirect https://localhost:$RSTUDIO_PORT https://\$http_host/$PROXY_URL;
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection \$connection_upgrade;
      proxy_read_timeout 20d;
    }
  }
}
EOF

rserver_cmd="/usr/lib/rstudio-server/bin/rserver \
--www-port "$RSTUDIO_PORT" \
--auth-none 0 \
--auth-pam-helper-path /usr/bin/pam-helper \
--server-data-dir /tmp \
--rsession-which-r=$(which R)"

nginx_cmd="nginx -c /var/lib/rstudio-server/nginx.conf \
-p /tmp \
-e /dev/nginx_error.log"

echo "rserver cmd: ${rserver_cmd}"
echo "nginx cmd: ${nginx_cmd}"
$rserver_cmd & 
$nginx_cmd