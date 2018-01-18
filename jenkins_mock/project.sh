#!/bin/bash 
set -euxo pipefail

source ../common/common.sh

create() {
    echo "WARNING: jenkins-slave-rpmbuilder-centos7 needs to run as a privileged"
    echo "container (CAP_SYS_ADMIN) for mock to do chroot and mounts."
    echo "==> This script will add scc privilege to project jenkins user."
    read -p "Press enter to continue, or CTRL+C to abort"
    oc login -u system:admin
    oc adm policy add-scc-to-user privileged system:serviceaccount:rpm-jenkins-mock:jenkins

    oc login -u developer
    oc get project rpm-jenkins-mock || oc new-project rpm-jenkins-mock

    oc apply -f kubeobjs

    oc new-app jenkins-persistent -o yaml | oc apply -f- # or jenkins-ephemeral
    # Sometimes we get OOM on Jenkins with default 512Mi limit
    #oc patch deploymentconfig jenkins -p '{"spec":{"template":{"spec":{"containers":[{"name":"jenkins","resources":{"limits":{"memory":"1Gi"}}}]}}}}'

    gogs_deploy
}

delete() {
    oc delete project rpm-jenkins-mock
}

case "${1:-}" in
    create)
        create
        ;;
    delete)
        delete
        ;;
    *)
        echo "Usage: $0 create|delete"
        exit 1
        ;;
esac
