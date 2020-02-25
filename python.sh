#shellcheck shell=bash

# NOTE: for now, assuming a debian/ubuntu distro. This can be improved.

run_python3_install() {
    if is_debian_like; then
        cmd_apt_min_install python3 python3-setuptools python3-pip
    else
        bail "python3_install: unhandled OS"
    fi
}
