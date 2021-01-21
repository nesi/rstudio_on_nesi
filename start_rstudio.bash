#!/usr/bin/env bash

set -u

module load Singularity

PASSWORD="blabla" singularity run --contain \
    -B "$HOME","/nesi/project/$SLURM_JOB_ACCOUNT","/nesi/nobackup/$SLURM_JOB_ACCOUNT" \
    "/home/riom/nobackup/tidyverse_nginx_3.6.1.sif" "$1" "$2"
