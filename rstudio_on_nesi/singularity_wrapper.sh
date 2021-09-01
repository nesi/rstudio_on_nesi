#!/bin/bash -e

initialize(){

    #export LOGLEVEL="DEBUG"
    export ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
    export SIFPATH="/opt/nesi/containers/rstudio-server/r_nesi_centos7.sif"

    #TMPROOT will be root mount point for all writable files in container.
    export TMPROOT="$(mktemp -d -t rstudio-jupyter-XXXX)"

    module purge
    module unload XALT/full
    module load Singularity
}

parse_input(){ 
    debug "$@"
    :
}

set_env(){
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
    BIND_PATH_FS="$BIND_PATH_FS,\
/opt/nesi,\
/nesi/project,\
/nesi/nobackup,\
$HOME"

#Binding home to self, but also /home/user

    BIND_PATH_R="$BIND_PATH_R,\
$TMPROOT/var/:/var,\
$TMPROOT/tmp/:/tmp"

    mkdir -p $TMPROOT/var/lib/rstudio-server 
    mkdir -p $TMPROOT/var/run/rstudio-server
    mkdir -p $TMPROOT/tmp/

    #chmod 700 $TMPROOT/var/run $TMPROOT/var/lib 

    export SINGULARITY_BINDPATH="$SINGULARITY_BINDPATH,$BIND_PATH_R,$BIND_PATH_REQUIRED,$BIND_PATH_FS,$BIND_PATH_APPS"
    debug "Singularity bindpath is $(echo "${SINGULARITY_BINDPATH}" | tr , '\n')"
}

start_rserver(){   
    # Set instance name
    #if [[ ! -x  "$(readlink -f "$VDT_TEMPLATES/$VDT_BASE/image")" ]];then echo "'$VDT_TEMPLATES/$VDT_BASE/image' doesn't exist!";exit 1;fi
    #VDT_OVERLAY=${VDT_OVERLAY:-"$VDT_HOME/overlay.img"}

    # OVERLAY_SIZE=1000
    # OVERLAY="FALSE"
    
    # if [[ ${OVERLAY} == "TRUE" ]];then
    #     if [[ ! -r ${VDT_OVERLAY} ]];then
    #         # Create overlay
    #         dd if=/dev/zero of=$VDT_OVERLAY bs=1M count=$OVERLAY_SIZE
    #         mkfs.ext3 $VDT_OVERLAY
    #     fi
    #     cmd="$cmd --overlay $VDT_OVERLAY"
    # fi

    # Using 'exec'
    cmd="singularity $([[ $LOGLEVEL = "DEBUG" ]] && echo "--debug shell" || echo "exec") $SIFPATH $*"
    # Using 'run'
    #cmd="singularity $([[ $LOGLEVEL = "DEBUG" ]] && echo "--debug shell" || echo "run") $SIFPATH $*"
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