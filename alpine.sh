#shellcheck shell=bash

run_apk_update() {
    enter_run_cmd

    #shellcheck disable=SC1003
    echo '    ; apk update \'
}

cmd_apk_min_install_impl() {
    #shellcheck disable=SC1003
    echo 'apk add -u -q \'
    echo -n "${INDENT}${INDENT}$*"
}

# Give it as parameters what packages to install. IT will install them, but without any other optional dependencies
cmd_apk_min_install() {
    enter_run_cmd

    echo -n "$INDENT; "
    cmd_apk_min_install_impl "$@"
    #shellcheck disable=SC1003
    echo ' \'
}

run_apk_cleanups() {
    true
}

cmd_apk_purge_packages() {
    enter_run_cmd
    echo "   ; apk del $* \\ "
}
