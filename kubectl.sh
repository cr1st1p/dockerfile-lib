# shellcheck shell=bash
# installs kubectl by direct download
# https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux
# no checksums verifications are done
#

# version should look like 1.17.0
cmd_kubectl_install() {
    local version="$1"

    enter_run_cmd
    local binary=/usr/bin/kubectl
    echo "    ; curl -f --silent -L 'https://storage.googleapis.com/kubernetes-release/release/v$version/bin/linux/amd64/kubectl' -o '$binary' \\"
    echo "    ; chmod +x $binary \\"
}
