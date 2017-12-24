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

    # Deploy a GOGs instance for hosting example git repositories
    PROJDOMAIN="$(oc get route jenkins --template={{.spec.host}} | sed 's/^[^-]*\-//')"
    oc new-app -f https://raw.githubusercontent.com/OpenShiftDemos/gogs-openshift-docker/master/openshift/gogs-persistent-template.yaml --param=HOSTNAME="gogs-$PROJDOMAIN" -o yaml |
        sed "s/SKIP_TLS_VERIFY = false/SKIP_TLS_VERIFY = true/" |
        oc apply -f-
    oc rollout status -w dc/gogs
    GOGS_ENDPOINT=`oc get route gogs --template={{.spec.host}}`
    curl "http://$GOGS_ENDPOINT/user/sign_up" --data 'user_name=developer&password=developer&retype=developer&email=nobody@127.0.0.1'
}

delete() {
    oc delete project ex-jenkins-mock
}

case $1 in
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
