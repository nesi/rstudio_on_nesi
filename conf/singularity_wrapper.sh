#!/bin/bash -e

initialize(){
    export ROOT="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)")"
    export LOGLEVEL="DEBUG"
    module purge
    module unload XALT/full
    module load Singularity
}

parse_input(){ 
    :
    # if [ $# -ne 5 ]; then
    #     echo "Usage: $(basename $0) <image> <command> NGINX_PORT PROXY_URL"
    #     exit 1
    # fi
    # VDT_NGINX_PORT="$1"
    # VDT_PROXY_URL="$2"
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
/usr/bin/vim"

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
$HOME:/home/$USER,\
$VDT_ROOT"


    BIND_PATH_R="$BIND_PATH_FS,\
/opt/nesi,\
/nesi/project,\
/nesi/nobackup,\
$HOME:/home/$USER,\
$VDT_ROOT"

    export SINGULARITY_BINDPATH="$SINGULARITY_BINDPATH,$BIND_PATH_REQUIRED,$BIND_PATH_FS,$BIND_PATH_APPS,$BIND_PATH_CUDA"
    debug "Singularity bindpath is $(echo "${SINGULARITY_BINDPATH}" | tr , '\n')"

    # If environment setup for desktop flavor.
    if [[ -f "${VDT_TEMPLATES}/${VDT_BASE}/pre.sh" ]];then
        source "${VDT_TEMPLATES}/${VDT_BASE}/pre.sh" 
    fi

    # Set websockify options.
    VDT_WEBSOCKOPTS=" --log-file=$VDT_LOGFILE --heartbeat=30 $VDT_WEBSOCKOPTS"

    # # Additional verboseness for remoteness.
    # if [[ -n $persistent || -n $remote ]];then
    #     VDT_WEBSOCKOPTS=" --verbose ${VDT_WEBSOCKOPTS}"
    # fi    

    # Export all variables starting with 'VDT' to singularity.
    for ev in $(compgen -A variable | grep ^VDT );do
        export "SINGULARITYENV_$ev"="${!ev}"
        debug "SINGULARITYENV_$ev"="${!ev}"
    done
    
    # # Murder any ports that were missed.
    # while [[ "$(fuser "$VDT_SOCKET_PORT"/tcp 2>/dev/null | wc -w)" -gt 0 ]];do
    #     warning "Port '$VDT_SOCKET_PORT' in use. Killing $VDT_SOCKET_PORT"
    #     kill -9 $(fuser "$VDT_SOCKET_PORT"/tcp 2>/dev/null | awk '{ print $1 }')
    # done
    
    # lockfile="${VDT_HOME}/${remote:-$(hostname)}:${VDT_SOCKET_PORT}@${SLURM_JOB_ID}"

}

create_vnc(){   
    # Set instance name
    #if [[ ! -x  "$(readlink -f "$VDT_TEMPLATES/$VDT_BASE/image")" ]];then echo "'$VDT_TEMPLATES/$VDT_BASE/image' doesn't exist!";exit 1;fi
    cmd="singularity --debug "
    
    VDT_OVERLAY=${VDT_OVERLAY:-"$VDT_HOME/overlay.img"}

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

    # if [[ -n ${VDT_TUNNEL_HOST} ]];then 
    #     lennut
    # fi
    #"${timeout}" s
    cmd="$cmd $*"
    debug "$cmd"
    ${cmd}
    # echo $$ > ${lockfile} 
}

# set_display (){
#     # Finds a free display port. If passed an argument, will test that then return.
#     max_i=4;
#     for (( i=0; i<max_i; i++ )); do
#         VDT_DISPLAY_PORT=${1:-$(shuf -i 1100-2000 -n 1)}
#         debug "Testing display port ${VDT_DISPLAY_PORT}"
#         if [[ ! -e "/tmp/.X11-unix/X{$VDT_DISPLAY_PORT}" ]];then return 0;fi
#         if [[ $# -gt 0 ]];then echo "Selected display port ${1} not suitable."; return 2;fi
#     done
#     error "Could not find a suitable display port after $max_i attempts."
# }

# cleanup() {
#     #vncserver
#     #singularity $verbose exec "$img_path" "vncserver -kill ":$VDT_DISPLAY_PORT"" 1> ${VDT_LOGFILE} 2>&1 || true
#     #rm -f $verbose /tmp/.X11-unix/.X*
#     #rm -f $verbose "$HOME"/.vnc/*"${VDT_INSTANCE_NAME}".pid
#     echo "Trapped $?"
#     turbo_kill $lockfile &
#     #if [[ -n "${VDT_LOGFILE}" ]]; then rm -f $verbose "${VDT_LOGFILE}";fi
#     #if [[ -n "${lockfile}" ]]; then rm -f $verbose "${lockfile}";fi
#     # Unset all VDT variables.
#     for ev in $(compgen -A variable | grep ^VDT );do
#         unset "$ev"
#     done
        
#     rm -fvr "/tmp/.X$display_port-lock"
#     rm -fvr "/tmp/.ICE$display_port-lock"

#     while [[ "$(fuser $VDT_SOCKET_PORT/tcp 2>/dev/null | wc -w)" -gt 0 ]];do
#         kill -9 "$(fuser $VDT_SOCKET_PORT/tcp 2>/dev/null | awk '{ print $1 }')"
#     done
#     pkill --signal 9 -P $$ > /dev/null 2>&1 
#     exit 0

# }
# cleanup_nice() {
#     cleanup || return 0
# }

# lennut(){
#     # Todo: Allow multiple attempts.
#     echo "Opening reverse tunnel to '${VDT_TUNNEL_HOST}'"
#     ssh -vfNT -o ExitOnForwardFailure=yes -R ${VDT_SOCKET_PORT}:localhost:${VDT_SOCKET_PORT} ${VDT_TUNNEL_HOST}
#     tunnel_pid="$!"
#     sleep 5
#     # if [[ "$(ps -o s -h -p $tunnel_pid)"! = [SR] ]];then
#     #     echo "Failed to open tunnel from $(hostname)"
#     #     exit 1
#     # fi   
# }

debug(){
    if [[ -n ${verbose} || $LOGLEVEL = "DEBUG" ]];then
        echo "DEBUG: ${FUNCNAME[1]}::${BASH_LINENO[-1]} ${BASH_LINENO[-1]} $*"
    fi
}
main(){
    initialize
    parse_input "$@"
    set_env
    create_vnc "$@"
    
    return 0
}

trap cleanup INT ERR SIGINT SIGTERM

main "$@"