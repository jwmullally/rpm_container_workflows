#!/bin/bash 
set -euxo pipefail

create() {
    # rpmbuilder needs to run as a privileged container 
    # for mock to do chroot and mounts
    oc login -u system:admin
    oc adm policy add-scc-to-user privileged system:serviceaccount:ex-jenkins-mock:jenkins

    oc login -u developer
    oc new-project ex-jenkins-mock

    oc apply -f kubeobjs

    oc new-app jenkins-persistent # or jenkins-ephemeral
    # Sometimes we get OOM on Jenkins with default 512Mi limit
    #oc patch deploymentconfig jenkins -p '{"spec":{"template":{"spec":{"containers":[{"name":"jenkins","resources":{"limits":{"memory":"1Gi"}}}]}}}}'
}

create_gogs() {
    SUBDOMAIN="$(oc get route jenkins --template={{.spec.host}} | sed 's/^[^.]*\.//')"
    oc new-app -f https://raw.githubusercontent.com/OpenShiftDemos/gogs-openshift-docker/master/openshift/gogs-persistent-template.yaml --param=HOSTNAME="gogs.$SUBDOMAIN" -o yaml | oc apply -f-
    sleep 3
    oc export configmap gogs-config | sed "s/SKIP_TLS_VERIFY = false/SKIP_TLS_VERIFY = true/" | oc apply -f-
    oc rollout cancel dc/gogs
    sleep 3
    oc rollout latest dc/gogs
    oc rollout status -w dc/gogs
    ENDPOINT=`oc get route gogs --template={{.spec.host}}`
    curl "http://$ENDPOINT/user/sign_up" --data 'user_name=developer&password=developer&retype=developer&email=nobody@127.0.0.1'
}

delete() {
    oc delete project ex-jenkins-mock
}

case $1 in
    create)
        create
        ;;
    create-gogs)
        create_gogs
        ;;
    delete)
        delete
        ;;
    *)
        echo "$0 create|create-gogs|delete"
        ;;
esac
