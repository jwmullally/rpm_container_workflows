#!/bin/bash 
set -euxo pipefail

source ../../../common/common.sh

function create {
    pushd repos
    for pkg in *; do
        (cd $pkg; gogs_repo_create $pkg)
    done
    popd

    oc new-app http://$(gogs_endpoint)/developer/rpm-repo.git --name=rpm-repo -o yaml | oc apply -f-
    oc set probe dc/rpm-repo --liveness --get-url=http://:8000
    oc expose service rpm-repo --dry-run=true -o yaml | oc apply -f-
    gogs_repo_webhook python_hello_lib rpm-repo
    gogs_repo_webhook python_demo_app rpm-repo

    oc new-app http://$(gogs_endpoint)/developer/demo-app.git --name=demo-app -o yaml | oc apply -f-
    oc set probe dc/demo-app --liveness --get-url=http://:8000
    oc expose service demo-app --dry-run=true -o yaml | oc apply -f-
}

function build {
    oc start-build rpm-repo
}

function delete {
    oc delete all -l app=rpm-repo
    oc delete all -l app=demo-app
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
