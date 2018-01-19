#!/bin/bash 
set -euxo pipefail

source ../../../common/common.sh

function create {
    (cd repos/hello && gogs_repo_create hello)
    oc apply -f repos/hello/kubeobjs
    #oc new-app http://$(gogs_endpoint)/developer/hello.git --name=single-rpm -o yaml | oc apply -f-
    #oc expose service single-rpm --dry-run=true -o yaml | oc apply -f-
    #oc set probe dc/single-rpm --liveness --get-url=http://:8000
    gogs_repo_webhook hello single-rpm
}

function build {
    oc start-build single-rpm
}

function delete {
    oc delete all -l app=single-rpm
    gogs_repo_delete single-rpm
}

case "${1:-}" in
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
