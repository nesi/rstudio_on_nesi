#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename $0) NGINX_PORT"
    exit 1
fi

NGINX_PORT="$1"

RSTUDIO_PORT="21200"  # TODO autodetect a free port
IMAGE="/home/riom/nobackup/tidyverse_nginx_3.6.1.sif"  # TODO use image in /opt/nesi/containers

module load Singularity

export PASSWORD="blabla"

singularity run --contain \
    -B "$HOME","/nesi/project/$SLURM_JOB_ACCOUNT","/nesi/nobackup/$SLURM_JOB_ACCOUNT" \
    "$IMAGE" "$RSTUDIO_PORT" "$NGINX_PORT"
