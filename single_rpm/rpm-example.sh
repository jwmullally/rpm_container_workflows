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
    oc new-app -f https://raw.githubusercontent.com/OpenShiftDemos/gogs-openshift-docker/master/openshift/gogs-persistent-template.yaml

    oc create -f hello.yaml
}

function create_repos {
    ENDPOINT=`oc get route gogs --template={{.spec.host}}`
    curl "http://$ENDPOINT/user/sign_up" --data 'user_name=developer&password=developer&retype=developer&email=nobody@127.0.0.1'
    curl "http://developer:developer@$ENDPOINT/api/v1/user/repos" --data "name=hello"
    push_repos
}

function push_repos {
    ENDPOINT=`oc get route gogs --template={{.spec.host}}`
    pushd examples/hello
    if [ ! -d ".git" ]; then
        git init && git add * && git commit -m 'initial commit'
    fi
    git push --set-upstream "http://developer:developer@$ENDPOINT/developer/hello.git" master
    popd
}

function start_build {
    oc start-build hello-container-pipeline
}

function delete {
    oc delete project rpm-example
}

case $1 in
    create)
        create
        ;;
    create_repos)
        create_repos
        ;;
    push_repos)
        push_repos
        ;;
    start_build)
        start_build
        ;;
    delete)
        delete
        ;;
    --help)
        echo "$0 admin|create|create_repos|push_repos|delete"
        ;;
    *)
        ;;
esac
