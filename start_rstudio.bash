#!/usr/bin/env bash

if [[ $# -lt 1 ]]; then
    echo "Usage: $(basename $0) NGINX_PORT [BASE_URL]"
    exit 1
fi

NGINX_PORT="$1"
BASE_URL="${2:-user-redirect/proxy/$NGINX_PORT}"

# TODO use image in /opt/nesi/containers
IMAGE="/home/riom/nobackup/tidyverse_nginx_3.6.1.sif"

module load Singularity

export PASSWORD="blabla"

singularity run --contain \
    -B "$HOME","/nesi/project/$SLURM_JOB_ACCOUNT","/nesi/nobackup/$SLURM_JOB_ACCOUNT" \
    "$IMAGE" "$NGINX_PORT" "$BASE_URL"
