#!/bin/bash

set -euo pipefail

#######################################
# Starts Rstudio server and proxies with nginx
#
# Arguments:
#   NGINX_PORT: port number
#   PROXY_URL: localhost
#
# Optional Env Variables: (default value)
#   RSTUDIO_PORT:         (random open port)  Will fail if manually selected port unavailable.
#   LOGLEVEL:             unset               Set to "DEBUG" for extra output.
#   XDG_CONFIG_HOME:      ("$HOME/.config")   Used for config files if set.
#######################################

if [ $# -ne 2 ]; then
  echo "Usage: $(basename ${0}) NGINX_PORT PROXY_URL"
  exit 1
fi

# run user script if one exists
USER_MODULES="${XDG_CONFIG_HOME:=$HOME/.config}/rstudio_on_nesi/prelude.bash"

if [[ -f "${USER_MODULES}" ]]; then
  echo "Using user modules from ${USER_MODULES}"
  . "${USER_MODULES}"
fi

# ensure R interpreter is available
if ! command -v R &>/dev/null; then
  echo "No R interpreter found, loading default R module"
  module load R
fi

NGINX_PORT="${1}"
PROXY_URL="${2#/}"

# trick to find a free port (see https://unix.stackexchange.com/a/132524 and jupyter-server-proxy source code)
# If RSTUDIO_PORT is already set, check if it is valid. THROW ERROR IF NOT, errors are relatively descriptive.
RSTUDIO_PORT="$(python -c "import socket; s=socket.socket(); s.bind(('', ${RSTUDIO_PORT:-0})); print(s.getsockname()[1]); s.close()")"

# create an Nginx configuration file for rstudio reverse proxy
NGINX_CONFIG_FILE="/var/lib/rstudio-server/nginx.conf"

cat <<EOF >"$NGINX_CONFIG_FILE"
pid /tmp/nginx.pid;
worker_processes 1;
$([[ $LOGLEVEL = "DEBUG" ]] && echo "error_log /dev/stdout debug;")
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
      proxy_redirect ~^http://localhost:$RSTUDIO_PORT/auth-sign-in(.+)\$ https://\$http_host/$PROXY_URL/auth-sign-in?username=$USER&password=\$http_rstudio_password;
      proxy_redirect ~^https://localhost:$RSTUDIO_PORT/auth-sign-in(.+)\$ https://\$http_host/$PROXY_URL/auth-sign-in?username=$USER&password=\$http_rstudio_password;
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

# use R to find the path to libraries, including R_LIBS_USER
R_LIBS_USER=$(Rscript -e "cat(unique(c(Sys.getenv('R_LIBS_USER'), .libPaths())), sep=':')")

RSESSION_CONFIG_FILE="/var/lib/rstudio-server/rsession.conf"
echo "r-libs-user=$R_LIBS_USER" >"$RSESSION_CONFIG_FILE"

rserver_cmd="/usr/lib/rstudio-server/bin/rserver \
--server-user ${USER} \
--www-port ${RSTUDIO_PORT} \
--auth-none 0 \
--auth-pam-helper-path /usr/bin/pam-helper \
--server-data-dir /tmp \
--rsession-which-r=$(which R) \
--rsession-config-file=$RSESSION_CONFIG_FILE"

nginx_cmd="nginx -c ${NGINX_CONFIG_FILE} \
-p /tmp \
-e /dev/nginx_error.log"

# Print, then run commands.
echo "rserver cmd: ${rserver_cmd}"
echo "nginx cmd: ${nginx_cmd}"
${rserver_cmd} &
${nginx_cmd}
