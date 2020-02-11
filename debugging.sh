#shellcheck shell=bash

run_debugging_tool_install() {
    enter_run_cmd
    cat << 'EOS'
    ; echo "Installing debugging tools" \
    ; export DEBIAN_FRONTEND=noninteractive \
    ; apt-get install --no-install-recommends --no-install-suggests -yqq strace curl wget netcat nano \
EOS
}

