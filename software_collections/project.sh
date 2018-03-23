#!/bin/bash 
set -euxo pipefail

source ../common/common.sh

create() {
    oc login -u developer
    oc get project rpm-scl || oc new-project rpm-scl

    #oc apply -f kubeobjs
    gogs_deploy
}

delete() {
    oc delete project rpm-scl
}

case ${1:-} in
    create)
        create
        ;;
    delete)
        delete
        ;;
    *)
        echo "$0 create|delete"
        ;;
esac
