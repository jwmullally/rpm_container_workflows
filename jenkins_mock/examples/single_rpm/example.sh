#!/bin/bash 
set -euxo pipefail

source ../../../common/common.sh

function create {
    oc apply -f repos/hello/kubeobjs
    (cd repos/hello && gogs_repo_create hello)
    gogs_repo_webhook hello single-rpm-pipeline
}

function build {
    oc start-build single-rpm-pipeline
}

function delete {
    oc delete all -l app=single-rpm
    gogs_repo_delete hello
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
