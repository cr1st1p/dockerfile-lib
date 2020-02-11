#shellcheck shell=bash
set -e

# IMPORTANT:
# a) if using non quoted 'EOS' here-doc delimiter:
#   - then you can use shell's variables
#   - need to backquote the $ signs if you want them into output and not interpolated.
#   - you need to backquote any \ - like the ones from the line's ending
# b) NO empty lines inside the output from run_* functions
# 


DEV_MODE=
IN_RUN_CMD=
RUN_WITH_DEBUG=
SHELL_COMMAND_GENERATED=
DOCKERFILE_LIB="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

INDENT="    "

#shellcheck disable=SC1090
source "${DOCKERFILE_LIB}/os-detect.sh"


terminate_run_cmd() {
    if [ -n "$IN_RUN_CMD" ]; then
        echo "$INDENT; true"
        echo
    fi
}

# to be called just before generating RUN commands.
# it MUST do at least a 'set -e'
#
enter_run_cmd() {
    if [ -z "$IN_RUN_CMD" ] || [ -n "$DEV_MODE" ]; then
        terminate_run_cmd

        # we want to use bash and not sh.
        # if you really want 'sh', then, in your main program, set SHELL_COMMAND_GENERATED=1
        # but be aware that some code might want Bash
        if [ -z "$SHELL_COMMAND_GENERATED" ]; then
            echo 'SHELL ["/bin/bash", "-c"] '
            SHELL_COMMAND_GENERATED=1
        fi

        if [ -n "$RUN_WITH_DEBUG" ]; then
            echo 'RUN set -ex \'
        else
            echo 'RUN set -e \'
        fi
        IN_RUN_CMD=1
    fi
}

# to be called when you want to force a RUN command to end.
# For example, when you want to output other Dockerfile commands
# Or simply when you want to force a new layer, regardless of the 'mode'
exit_run_cmd() {
    terminate_run_cmd
    IN_RUN_CMD=
}


# In case you need to force something to run
run_current_timestamp() {
    enter_run_cmd
    date +"$INDENT; echo '%s' >/dev/null \\"
}

bail() {
    echo "$*"
    exit 1
}


