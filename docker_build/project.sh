#!/bin/bash 
set -euxo pipefail

source ../common/common.sh

create() {
    oc login -u developer
    oc get project rpm-docker-build || oc new-project rpm-docker-build

    #oc apply -f kubeobjs
    gogs_deploy
}

delete() {
    oc delete project rpm-docker-build
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
