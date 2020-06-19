#shellcheck shell=bash

# TODO:
# Look at
# https://github.com/docker-library/cassandra/blob/master/Dockerfile.template
# and
# https://raw.githubusercontent.com/nginxinc/docker-nginx/5971de30c487356d5d2a2e1a79e02b2612f9a72f/mainline/buster/Dockerfile
#
# They do seem to have a few things in common (related to 'apt' handling) which would be good to refactor and reuse ...
#

run_apt_update() {
    enter_run_cmd
    cat <<'EOS'
    ; apt-get update -qq \
EOS
}

cmd_apt_min_install_impl() {
    #shellcheck disable=SC1003
    echo 'DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -yqq -o Dpkg::Options::=--force-unsafe-io \'
    echo -n "${INDENT}${INDENT}$*"
}

# Give it as parameters what packages to install. IT will install them, but without any other optional dependencies
cmd_apt_min_install() {
    enter_run_cmd

    echo -n "$INDENT; "
    cmd_apt_min_install_impl "$@"
    #shellcheck disable=SC1003
    echo ' \'
}

cmd_apt_purge_packages_function() {
    [ -z "$_cmd_apt_purge_packages_function_printed" ] || return 0
    [ -n "$DEV_MODE" ] || _cmd_apt_purge_packages_function_printed=1

    cat <<'EOS'
    ; function apt_purge_packages() { \
        local pkgToRemoveList="" \
    ;   for pkgToRemove in "$@"; do \
          if dpkg --status "$pkgToRemove" &> /dev/null; then \
            pkgToRemoveList="$pkgToRemoveList $pkgToRemove" ; \
          fi ; \
        done  \
    ;   if [ -n "$pkgToRemoveList" ]; then \
          DEBIAN_FRONTEND=noninteractive apt-get purge -y -o Dpkg::Options::=--force-unsafe-io \
            $pkgToRemoveList \
        ; fi \
    ; } \
EOS
}

cmd_apt_purge_packages() {
    enter_run_cmd

    cmd_apt_purge_packages_function

    cat <<EOS
    ; apt_purge_packages $* \\
EOS
}

run_apt_initial_minimal_installs() {
    run_apt_update
    cmd_apt_min_install gnupg2 apt-transport-https ca-certificates
}

# remove the packages installed by run_apt_initial_minimal_installs.
# Take care though, some of them might actually be needed
run_apt_remove_initial_packages() {
    cmd_apt_purge_packages gnupg2 apt-transport-https ca-certificates
}

run_apt_cleanups() {
    cmd_apt_purge_packages command-not-found command-not-found-data man-db manpages python3-commandnotfound python3-update-manager update-manager-core
    # bash parsers are having a problem with ending \
    head -n -1 <<'EOS'
    ; apt-get purge -y --auto-remove \
    ; apt-get clean -q \
    ; rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup || true \
    ; rm -rf /var/lib/apt/lists/* \

EOS

    # TODO: more things can be removed, for sure...
}

run_ensure_curl_is_installed() {
    enter_run_cmd
    echo -n "$INDENT; [ command -v curl >/dev/null 2>/dev/null ] || "
    cmd_apt_min_install_impl curl
    #shellcheck disable=SC1003
    echo ' \'
}

run_apt_gpg_key_from_url() {
    local url="$1"

    run_ensure_curl_is_installed
    enter_run_cmd
    echo "$INDENT; curl -s '$url' | apt-key add - \\"

}

run_apt_add_repo() {
    local name="$1"
    local repo_url="$2"
    local components="$3"
    local suite="$4"
    local repo_type="${5:-deb}"

    if [ -z "$suite" ]; then
        assert_os_code_name_detected
        declare -g os_code_name
        suite="$os_code_name"
    fi

    enter_run_cmd
    echo "$INDENT; echo '$repo_type $repo_url $suite $components' > /etc/apt/sources.list.d/$name.list \\"
}
