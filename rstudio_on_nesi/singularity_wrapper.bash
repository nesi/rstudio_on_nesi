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

initialize() {
    if [ -z "${SIFPATH}" ]; then
        echo "SIFPATH must be set."
        exit 1
    fi

    ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"

    module purge
    module unload XALT/full
    module load Singularity/3.9.4
}

set_env() {
    export SINGULARITYENV_LOGLEVEL="${LOGLEVEL}"

    #BIND_PATH_REQUIRED="\
    # /run,\
    # /dev/tty0,\
    # /dev/dri/card0,\
    # /usr/include,\
    # /usr/lib64/libGL.so.1.2.0,\
    # /usr/lib64/libmunge.so,\
    # /lib/libjpeg.so.62"

    # folder used as a place where rstudio can write
    RSTUDIO_VAR_FOLDER="${XDG_DATA_HOME:=$HOME/.local/share}/rstudio_on_nesi"
    mkdir -p "${RSTUDIO_VAR_FOLDER}"

    BIND_PATH_FS="\
    /opt/nesi,\
    /nesi/project,\
    /nesi/nobackup,\
    /scale_wlg_persistent,\
    /scale_wlg_nobackup,\
    ${HOME}:/home/${USER},\
    ${RSTUDIO_VAR_FOLDER}:/var/lib/rstudio-server,\
    ${ROOT}"

    # export modulepath and additional environment variable to use modules inside rsession
    MODULEPATH_PROFILE="${RSTUDIO_VAR_FOLDER}/01-modulepath_nesi.sh"
    echo "export MODULEPATH=${MODULEPATH}" > "${MODULEPATH_PROFILE}"
    echo "export SYSTEM_STRING=${SYSTEM_STRING}" >> "${MODULEPATH_PROFILE}"
    echo "export OS_ARCH_STRING=${OS_ARCH_STRING}" >> "${MODULEPATH_PROFILE}"
    echo "export CPUARCH_STRING=${CPUARCH_STRING}" >> "${MODULEPATH_PROFILE}"

    MODULEDEFAULT_PROFILE="${RSTUDIO_VAR_FOLDER}/z01-modules.sh"
    echo "module load NeSI" > "${MODULEDEFAULT_PROFILE}"

    BIND_MODULEPATH_PROFILE="\
    ${MODULEPATH_PROFILE}:/etc/profile.d/01-modulepath_nesi.sh,\
    ${MODULEDEFAULT_PROFILE}:/etc/profile.d/z01-modules.sh,"

    # ensure Slurm commands will run in a terminal inside rsession
    BIND_PATH_SLURM="\
    /etc/hosts,\
    /etc/opt/slurm,\
    /opt/slurm,\
    /var/run/munge,\
    /lib64/libjson-c.so.5"
    # /usr/share/lmod/lmod

    export SINGULARITY_BINDPATH="\
    ${SINGULARITY_BINDPATH},\
    ${BIND_PATH_FS},\
    ${BIND_MODULEPATH_PROFILE},\
    ${BIND_PATH_SLURM}"

    if [[ ${LOGLEVEL} = "DEBUG" ]]; then
        echo "Singularity bindpath is $(echo "${SINGULARITY_BINDPATH}" | tr , '\n')"
    fi
}

main() {
    initialize
    set_env
    singularity $(if [[ "${LOGLEVEL}" = "DEBUG" ]]; then echo "--debug shell"; else echo "exec"; fi) --contain --writable-tmpfs "${SIFPATH}" ${*}
    return 0
}

main "${@}"
