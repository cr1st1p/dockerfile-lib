#shellcheck shell=bash


run_supervisor_add_repo() {
    return 0
}


# Requires pip3 to be installed (check python.sh)
#
run_supervisor_install() {
    enter_run_cmd
    cat <<'EOS'
    ; echo "Installing 'supervisor'" \
    ; pip3 install supervisor \
EOS
}
