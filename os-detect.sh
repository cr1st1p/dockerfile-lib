# shellcheck shell=bash

# OS detection - it is *staticaly* determined from your last docker 'FROM'
# command, *IF* you use our 'GEN_FROM' bash function
# 
# I'd recommend using the GEN_FROM instead of just echoing 'FROM something'
# because you could automatically infer some things about the OS
# and automatically do some setups instead of calling by yourself
# the OS specific version.
# 



DOCKERFILE_FROM=

declare -A FROM_TO_OS
# id, id_like, code_name, joined by ':'
# the matching is done based on prefix
FROM_TO_OS['ubuntu:focal']="ubuntu:debian:focal"
FROM_TO_OS['ubuntu:20.04']="ubuntu:debian:focal"
FROM_TO_OS['ubuntu:eoan']="ubuntu:debian:eoan"
FROM_TO_OS['ubuntu:19.10']="ubuntu:debian:eoan"
FROM_TO_OS['ubuntu:bionic']="ubuntu:debian:bionic"
FROM_TO_OS['ubuntu:18.04']="ubuntu:debian:bionic"
FROM_TO_OS['ubuntu:xenial']="ubuntu:debian:xenial"
FROM_TO_OS['ubuntu:16.04']="ubuntu:debian:xenial"
FROM_TO_OS['alpine:']="alpine:alpine:alpine"


assert_os_detected() {
    if [ -z "$os_id" ] || [ -z "$os_id_like" ]; then
        bail "Could not 'detect' the OS"
    fi
}

assert_os_code_name_detected() {
    [ -n "$os_code_name" ] || bail "Could not 'detect' the OS code name"
}

is_arch_like() {
    assert_os_detected
    test "$os_id" = "arch" -o "$os_id_like" = "arch" 
}

is_debian_like() {
    assert_os_detected
    [ "$os_id_like" = "debian" ]
}

is_ubuntu() {
    assert_os_detected
    [ "$os_id" = "ubuntu" ]
}

is_alpine() {
    assert_os_detected
    [ "$os_id" = "alpine" ]
}

GEN_FROM() {
    DOCKERFILE_FROM="$1"

    exit_run_cmd
    echo "FROM ${DOCKERFILE_FROM}"

    # let's determine OS
    for f in "${!FROM_TO_OS[@]}"; do
        if [[ "$DOCKERFILE_FROM" == ${f}* ]]; then
            IFS=: read -r os_id os_id_like os_code_name <<<"${FROM_TO_OS[$f]}" 
            break
        fi
    done
}

os_detect_dynamic()
{
    os_id=$(grep -P '^ID=' /etc/os-release | sed -e 's/ID=//')
    os_id_like=$(grep -P '^ID_LIKE=' /etc/os-release | sed -e 's/ID_LIKE=//')
    os_code_name=$(grep -P '^VERSION_CODENAME=' /etc/os-release | sed -e 's/VERSION_CODENAME=//')
}
