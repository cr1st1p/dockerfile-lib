#shellcheck shell=bash

run_apk_update() {
    enter_run_cmd

    cat <<'EOS'
    ; apk update \
EOS
}

cmd_apk_min_install_impl()  {
    echo 'apk add -u -q \'
    echo -n "${INDENT}${INDENT}$*"
}

# Give it as parameters what packages to install. IT will install them, but without any other optional dependencies
cmd_apk_min_install()  {
    enter_run_cmd

    echo -n "$INDENT; "
    cmd_apk_min_install_impl "$@"
    echo ' \'
}