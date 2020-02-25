#shellcheck shell=bash

NODE_MAJOR_VERSION=11

run_nodejs_add_repo() {
    if is_debian_like; then
        run_apt_gpg_key_from_url https://deb.nodesource.com/gpgkey/nodesource.gpg.key
        run_apt_add_repo nodesource "https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x" main
    else
        bail "nodejs: unhandled OS"
    fi
}

run_nodejs_install() {
    if is_debian_like; then
        cmd_apt_min_install nodejs
    else
        bail "nodejs: unhandled OS"
    fi
}
