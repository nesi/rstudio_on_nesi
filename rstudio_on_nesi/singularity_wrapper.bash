#!/bin/bash

set -eo pipefail

#######################################
# Wrapper script, excecutes arguments in singularity image with some standard
# NeSI bind paths.
#
# Arguments:
#   Commands to be run within the singularity container
#
# Env Variables Required:
#   SIFPATH: absolute path to a singularity image file, built of a .def file
#            contained in the 'conf' directory
#
# Env Variables Optional:
#   LOGLEVEL: [DEBUG]
#   SINGULARITY_BINDPATH: Singularity bind path
#######################################

initialize(){
    if [ -z "${SIFPATH}" ]; then
        echo "SIFPATH must be set."
        exit 1
    fi

    ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"

    module purge
    module unload XALT/full
    module load Singularity/3.8.5
}

set_env(){
    export SINGULARITYENV_LOGLEVEL="${LOGLEVEL}"

    # Apps that don't need a special install.
    BIND_PATH_APPS="\
    /usr/bin/file,\
    /usr/bin/htop,\
    /usr/bin/less,\
    /usr/bin/man,\
    /usr/bin/nano,\
    /usr/bin/unzip,\
    /usr/bin/vim,\
    /usr/bin/which"

    BIND_PATH_REQUIRED="\
    /run,\
    /dev/tty0,\
    /etc/machine-id,\
    /dev/dri/card0,\
    /usr/bin/ssh-agent,\
    /usr/bin/gpg-agent,\
    /usr/bin/lsb_release,\
    /usr/share/fonts,\
    /usr/share/X11/fonts,\
    /usr/share/lmod/lmod,\
    /usr/include,\
    /etc/opt/slurm,\
    /etc/X11/,\
    /opt/slurm,\
    /usr/lib64/libGL.so.1.2.0,\
    /usr/lib64/libmunge.so,\
    /usr/lib64/libmunge.so.2,\
    /usr/lib64/libmunge.so.2.0.0,\
    /usr/lib64/libgbm.so.1.0.0,\
    /lib/libjpeg.so.62,\
    /lib64/libjpeg.so"

    # folder used as a place where rstudio can write
    RSTUDIO_VAR_FOLDER="${XDG_DATA_HOME:=$HOME/.local/share}/rstudio_on_nesi"
    mkdir -p "${RSTUDIO_VAR_FOLDER}"

    BIND_PATH_FS="\
    /opt/nesi,\
    /nesi/project,\
    /nesi/nobackup,\
    ${HOME}:/home/${USER},\
    ${RSTUDIO_VAR_FOLDER}:/var/lib/rstudio-server,\
    ${ROOT}"

    export SINGULARITY_BINDPATH="${SINGULARITY_BINDPATH},${BIND_PATH_REQUIRED},${BIND_PATH_FS},${BIND_PATH_APPS}"
    if [[ ${LOGLEVEL} = "DEBUG" ]]; then
        echo "Singularity bindpath is $(echo "${SINGULARITY_BINDPATH}" | tr , '\n')"
    fi
}

main(){
    initialize
    set_env
    singularity $(if [[ "${LOGLEVEL}" = "DEBUG" ]]; then echo "--debug shell"; else echo "exec"; fi) --contain --writable-tmpfs "${SIFPATH}" ${*}
    return 0
}

main "${@}"
