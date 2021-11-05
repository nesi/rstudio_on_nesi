#!/bin/bash -e

# TODO remove dead code / variables
# TODO fix version of environment modules loaded
# TODO remove hardcoded path to container, make it a script input
# TODO document script inputs (explicit and implicit via environment variables, e.g. $LOGLEVEL)
# TODO make the script display message if wrong number of inputs or missing environment variables
# TODO rename .bash as it's a bash script
# TODO run shellcheck on the file
# TODO use robust option of bash to limit bugs (set -euo pipefail)

initialize(){

    #export LOGLEVEL="DEBUG"
    export ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
    #export SIFPATH="/opt/nesi/containers/rstudio-server/r_nesi_centos7.sif"
    export SIFPATH="/nesi/project/nesi99999/Callum/dev_rstudio_on_nesi_centos/conf/nesi_base.sif"

    #TMPROOT will be root mount point for all writable files in container.
    # export TMPROOT="$(mktemp -d -t rstudio-jupyter-XXXX)"

    module purge
    module unload XALT/full
    module load Singularity
}

parse_input(){ 
    debug "$@"
    :
}

set_env(){

    export SINGULARITYENV_LOGLEVEL="$LOGLEVEL"

    # Apps that dont need a special install.
    BIND_PATH_APPS="$BIND_PATH_APPS,\
/usr/bin/file,\
/usr/bin/htop,\
/usr/bin/less,\
/usr/bin/man,\
/usr/bin/nano,\
/usr/bin/unzip,\
/usr/bin/vim,\
/usr/bin/which"

    BIND_PATH_REQUIRED="$BIND_PATH_REQUIRED,\
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

#     BIND_PATH_CUDA="$BIND_PATH_CUDA,\
# /cm/local/apps/cuda,\
# $EB_ROOT_CUDA"
#/var/lib/dcv-gl/lib64,\

    # folder used as a place where rstudio can write
    RSTUDIO_VAR_FOLDER="/home/$USER/.rstudio_on_nesi"
    mkdir -p "$RSTUDIO_VAR_FOLDER"

    BIND_PATH_FS="$BIND_PATH_FS,\
/opt/nesi,\
/nesi/project,\
/nesi/nobackup,\
$HOME:/home/$USER,\
$RSTUDIO_VAR_FOLDER:/var/lib/rstudio-server,\
$VDT_ROOT"
#Binding home to self, but also /home/user
#     BIND_PATH_R="$BIND_PATH_R,\
# $TMPROOT/var/:/var,\
# $TMPROOT/tmp/:/tmp"
#    BIND_PATH_R="$BIND_PATH_R,\
#    /var/lib/rstudio-server:/home/$USER/.rstudio_on_nesi"

    export SINGULARITY_BINDPATH="$SINGULARITY_BINDPATH,$BIND_PATH_R,$BIND_PATH_REQUIRED,$BIND_PATH_FS,$BIND_PATH_APPS"
    debug "Singularity bindpath is $(echo "${SINGULARITY_BINDPATH}" | tr , '\n')"
}

start_rserver(){   
    # Using 'exec'
    cmd="singularity $([[ $LOGLEVEL = "DEBUG" ]] && echo "--debug shell" || echo "exec") --contain --writable-tmpfs $SIFPATH $*"
    debug "$cmd"
    ${cmd}
}

debug(){
    if [[ $LOGLEVEL = "DEBUG" ]];then
        echo "DEBUG: ${FUNCNAME[1]}::${BASH_LINENO[-1]} ${BASH_LINENO[-1]} $*"
    fi
}

export () {
    debug "$@"
    command export "$@"
}

main(){
    initialize
    parse_input "$@"
    set_env
    start_rserver "$@"
    
    return 0
}

trap cleanup INT ERR SIGINT SIGTERM

main "$@"