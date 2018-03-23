#!/bin/bash 
set -euxo pipefail

source ../../../common/common.sh

function create {
    pushd repos/myapp
    make dependencies
    gogs_repo_create myapp
    popd
    oc new-app http://$(gogs_endpoint)/developer/myapp.git --name=myapp -o yaml | oc apply -f-
    oc expose service myapp --dry-run=true -o yaml | oc apply -f-
    oc set probe dc/myapp --liveness --get-url=http://:8000
    gogs_repo_webhook myapp myapp
}

function build {
    oc start-build myapp
}

function delete {
    oc delete all -l app=myapp
    gogs_repo_delete myapp
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
