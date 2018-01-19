#!/bin/bash 
set -euxo pipefail

source ../../../common/common.sh

function create {
    oc apply -f repos/app-multi-rpm-submodules/kubeobjs
    pushd repos
    for pkg in \
        "app-multi-rpm-submodules" \
        "python-demo_app" \
        "python-hello_lib" \
        "demo_container_submodules"
    do
        (cd $pkg; gogs_repo_create $pkg)
        gogs_repo_webhook $pkg multi-rpm-submodules
    done
}

function build {
    oc start-build multi-rpm-submodules
}

function delete {
    oc delete all -l app=multi-rpm-submodules
    pushd repos
    for pkg in *; do
        gogs_repo_delete $pkg
    done
    popd
}

case ${1:-} in
    create)
        create
        ;;
    build)
        build
        ;;
    delete)
        delete
        ;;
    *)
        echo "Usage: $0 create|build|delete"
        exit 1
        ;;
esac
