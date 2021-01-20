#!/usr/bin/env bash

if [[ $# -lt 1 ]]; then
    echo "Usage: $(basename $0) NGINX_PORT [BASE_URL]"
    exit 1
fi

NGINX_PORT="$1"
BASE_URL="${2:-user-redirect/proxy/$NGINX_PORT}"

# trick to find a free port (see https://unix.stackexchange.com/a/132524 and jupyter-server-proxy source code)
RSTUDIO_PORT="$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')"
IMAGE="/home/riom/nobackup/tidyverse_nginx_3.6.1.sif"  # TODO use image in /opt/nesi/containers

module load Singularity

export PASSWORD="blabla"

singularity run --contain \
    -B "$HOME","/nesi/project/$SLURM_JOB_ACCOUNT","/nesi/nobackup/$SLURM_JOB_ACCOUNT" \
    "$IMAGE" "$RSTUDIO_PORT" "$NGINX_PORT" "$BASE_URL"
