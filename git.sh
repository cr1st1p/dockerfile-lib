#shellcheck shell=bash

run_git_clone() {
    local url="$1"
    local dest="$2"

    enter_run_cmd
    echo "    ; git clone ${url} ${dest} $*\\"
}



run_git_clone_into_existing_dir() {
    local url="$1"
    local dest="$2"
    shift 2
    # rest of parameters are given to git checkout


    enter_run_cmd

    cat <<EOS
    ; ld=\$(pwd) \\
    ; cd "$dest" \\
    ; git clone "$url" "existing-dir.tmp" \\
    ; mv 'existing-dir.tmp/.git' "." \\
    ; rm -rf "existing-dir.tmp/" \\
    ; git reset --hard HEAD \\
    ; git checkout $@ \\
EOS

}
