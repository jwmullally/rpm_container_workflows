#!/bin/sh -ex

function create {
    oc create -f kubeobjs
    create_repos
}

function create_repos {
    ENDPOINT="$(oc get route gogs --template={{.spec.host}})"
    PROJECT="$(oc project -q)"
    WEBHOOK_SECRET="$(oc get buildconfig demo-container-pipeline --template '{{(index .spec.triggers 0).generic.secret}}')"
    pushd repos
    for pkg in *; do
        curl "http://developer:developer@$ENDPOINT/api/v1/user/repos" --data "name=$pkg"
        pushd $pkg
        rm -rf .git
        git init && git add . && git commit -m 'initial commit'
        git remote add origin "http://developer:developer@$ENDPOINT/developer/$pkg.git"
        git push -u origin master --force

        curl "http://developer:developer@$ENDPOINT/api/v1/repos/developer/$pkg/hooks" --header "Content-Type:application/json" --data @- <<EOF
{
    "type": "gogs",
    "config": {
        "url": "https://openshift.default.svc.cluster.local/oapi/v1/namespaces/$PROJECT/buildconfigs/demo-container-pipeline/webhooks/$WEBHOOK_SECRET/generic",
        "content_type": "json"
    },
    "events": [
        "push"
    ],
    "active": true
}
EOF
        popd
    done
    popd
}

function delete_repos {
    ENDPOINT=`oc get route gogs --template={{.spec.host}}`
    pushd repos
    for pkg in *; do
        curl "http://developer:developer@$ENDPOINT/api/v1/repos/developer/$pkg" -X DELETE
    done
    popd
}

function start_build {
    oc start-build demo-container-pipeline
}

function delete {
    oc delete all -l app=demo-container
    delete_repos
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
