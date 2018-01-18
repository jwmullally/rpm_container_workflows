#!/bin/bash
set -euxo pipefail

source ../../../common/common.sh

function create {
    oc apply -f repos/app-multi-rpm-imagesource/kubeobjs
    pushd repos
    for pkg in *; do
        (cd $pkg; gogs_repo_create $pkg)
        gogs_repo_webhook $pkg multi-rpm-imagesource-pipeline
    done
}

function build {
    oc start-build multi-rpm-imagesource-pipeline
}

function delete {
    oc delete all -l app=multi-rpm-imagesource
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
