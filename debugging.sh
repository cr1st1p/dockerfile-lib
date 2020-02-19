#shellcheck shell=bash

run_debugging_tool_install() {
    assert_os_detected

    enter_run_cmd
    if is_debian_like; then
        cat << 'EOS'
    ; echo "Installing debugging tools" \
EOS
        cmd_apt_min_install strace curl wget netcat nano
    elif is_alpine; then
        cmd_apk_min_install strace curl wget netcat-openbsd nano
    else
        bail "debugging tools: unhandled OS"
    fi
}

