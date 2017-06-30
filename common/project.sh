#!/bin/sh -ex

function create {
    oc login -u system:admin
    # rpmbuilder needs to run as a privileged container 
    # for mock to do chroot and mounts
    oc adm policy add-scc-to-user privileged system:serviceaccount:rpm-example:jenkins
    oc login -u developer
    oc new-project rpm-example

    oc create -f rpmbuilder.yaml
    oc new-app jenkins-persistent # or jenkins-ephemeral
    # Equivilant to:
    #oc process openshift//jenkins-persistent -l app=jenkins -o yaml | oc create -f -
    # Sometimes we get OOM on Jenkins with default 512Mi limit
    #oc patch deploymentconfig jenkins -p '{"spec":{"template":{"spec":{"containers":[{"name":"jenkins","resources":{"limits":{"memory":"1Gi"}}}]}}}}'

    oc new-app -f https://raw.githubusercontent.com/OpenShiftDemos/gogs-openshift-docker/master/openshift/gogs-persistent-template.yaml --param=HOSTNAME=gogs.172.17.0.1.nip.io
}

function create_gogs_user {
    ENDPOINT=`oc get route gogs --template={{.spec.host}}`
    curl "http://$ENDPOINT/user/sign_up" --data 'user_name=developer&password=developer&retype=developer&email=nobody@127.0.0.1'
}

function delete {
    oc delete project rpm-example
}

case $1 in
    create)
        create
        ;;
    create-gogs-user)
        create_gogs_user
        ;;
    delete)
        delete
        ;;
    --help|*)
        echo "$0 create|create-gogs-user|delete"
        ;;
esac
