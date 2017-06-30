#!/bin/sh -ex

function create {
    oc project rpm-example
    oc create -f demo-container.yaml
}

function create_repos {
    ENDPOINT=`oc get route gogs --template={{.spec.host}}`
    pushd repos
    for pkg in *; do
        curl "http://developer:developer@$ENDPOINT/api/v1/user/repos" --data "name=$pkg"
        pushd $pkg
        rm -rf .git
        git init && git add . && git commit -m 'initial commit'
        git remote add origin "http://developer:developer@$ENDPOINT/developer/$pkg.git"
        git push -u origin master --force
        popd
    done
    popd
}

function start_build {
    oc start-build demo-container-pipeline
}

function delete {
    oc delete all -l app=demo-container
}

case $1 in
    create)
        create
        ;;
    create-repos)
        create_repos
        ;;
    start-build)
        start_build
        ;;
    delete)
        delete
        ;;
    --help|*)
        echo "$0 create|create-repos|start-build|delete"
        ;;
esac
