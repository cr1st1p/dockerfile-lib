#!/usr/bin/env bash


# run_* functions are to be run with Dockerfile 'RUN'. For the moment, just a nomenclature, not
# a requirement
set -e

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LIB_PATH="${SCRIPT_PATH}/.."

for n in main.sh apt.sh nginx.sh debugging.sh; do
    # shellcheck disable=SC1090
    source "${LIB_PATH}/$n"
done


DEV_MODE=
FORCE_GIT_CLONE=



# =========
run_cleanup() {
    enter_run_cmd

    run_apt_remove_initial_packages
    run_apt_cleanups
}



# =======
copy_files() {
    exit_run_cmd

    cat << 'EOS'
COPY files/www/ /var/www/html/

EOS
}

run_nginx_change_port() {
    enter_run_cmd
    # since we're running nginx as 'nginx', we need to change port
    # in real use you'd probably write the whole config file from 0...

    cat << 'EOS'
    ; sed -i -E -e 's@listen +80@listen 8080@' /etc/nginx/conf.d/default.conf \
    ; sed -i -E -e 's@root +/usr/share/nginx/html *;@root /var/www/html;@' /etc/nginx/conf.d/default.conf \
EOS
}

run_fix_files() {
    return 0

    # below, some example of what you could/should do:
    enter_run_cmd

    cat << 'EOS'
    ; chmod +x /start.sh \
EOS
}


start_stuff() {
    exit_run_cmd


    GEN_FROM "ubuntu:bionic-20200112"

    cat <<'EOS'

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
EXPOSE 8080
EOS

}


end_stuff() {
    exit_run_cmd

    cat <<'EOS'
USER nginx    
CMD ["nginx", "-g", "daemon off;"]
#CMD [ "bash", "-c", "sleep 1h"]
EOS
}


# ==== command line parsing
checkArg () {
    if [ -z "$2" ] || [[ "$2" == "-"* ]]; then
        echo "Expected argument for option: $1. None received"
        exit 1
    fi
}

arguments=()
while [[ $# -gt 0 ]]
do
    # split --x=y to have them separated
    [[ $1 == --*=* ]] && set -- "${1%%=*}" "${1#*=}" "${@:2}"

    case "$1" in
        --dev)
            DEV_MODE=1
            shift
            ;;
        --force-git-clone)
            FORCE_GIT_CLONE=1
            shift
            ;;
        --) # end argument parsing
            shift
            break
            ;;
        -*) # unsupported flags
            echo "Error: Unsupported flag $1" >&2
            exit 1
            ;;
        *) # preserve positional arguments
            arguments+=("$1")
            shift
            ;;
    esac    
done

# ==== and now, generate output:

start_stuff

[ -z "$DEV_MODE" ] && copy_files


run_apt_initial_minimal_installs

run_nginx_add_repo
# here: add other repos if needed
run_apt_update # call it only once

run_nginx_install

# you should normally comment this:
run_debugging_tool_install

run_nginx_as_nginx_user
run_nginx_change_port


[ -n "$DEV_MODE" ] && copy_files

run_fix_files

[ -z "$DEV_MODE" ] && run_cleanup

end_stuff
