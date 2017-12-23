#!/bin/sh -ex

function create {
    oc create -f hello.yaml
    create_repos
}

function create_repos {
    ENDPOINT=`oc get route gogs --template={{.spec.host}}`
    curl "http://developer:developer@$ENDPOINT/api/v1/user/repos" --data "name=hello"
    pushd repos/hello
    rm -rf .git
    git init && git add . && git commit -m 'initial commit'
    git remote add origin "http://developer:developer@$ENDPOINT/developer/hello.git"
    git push -u origin master --force
    popd
}

function start_build {
    oc start-build hello-container-pipeline
}

function delete {
    oc delete all -l app=hello-container
    ENDPOINT=`oc get route gogs --template={{.spec.host}}`
    curl "http://developer:developer@$ENDPOINT/api/v1/repos/developer/hello" -X DELETE

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
