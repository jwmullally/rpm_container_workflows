#!/bin/bash
set -euxo pipefail
shopt -s extglob

# Set to "y" to enable webhooks when creating the examples
WEBHOOKS_ENABLED="n"

gogs_deploy() {
    gogs_gen_endpoint
    oc new-app -f https://raw.githubusercontent.com/OpenShiftDemos/gogs-openshift-docker/master/openshift/gogs-persistent-template.yaml --param=HOSTNAME="$GOGS_ENDPOINT" -o yaml |
        sed "s/SKIP_TLS_VERIFY = false/SKIP_TLS_VERIFY = true/" |
        oc apply -f-
    oc rollout status -w dc/gogs
    curl "http://$(gogs_endpoint)/user/sign_up" --data 'user_name=developer&password=developer&retype=developer&email=nobody@127.0.0.1'
}

gogs_gen_endpoint() {
    # Gogs needs to know its public hostname on deployment
    if oc get route gogs; then
        GOGS_ENDPOINT="$(oc get route gogs --template={{.spec.host}})"
    else
        # There is no standard way to determine this in advance. 
        # Try allocate a route and parse the domain from there.
        # Same meaning as master-config.yaml:routingConfig.subdomain
        oc new-app nginx --name=test-nginx
        oc expose service test-nginx
        sleep 3
        GOGS_ENDPOINT="$(oc get route test-nginx --template={{.spec.host}} | sed 's/^test-nginx/gogs/')"
        oc delete all -l app=test-nginx
    fi
}

gogs_endpoint() {
    oc get route gogs --template={{.spec.host}}
    # If pods can't reach the router from inside, swap to this instead
    #echo "gogs.rpm-docker-build.svc.cluster.local:3000"
}

gogs_repo_create() {
    REPO="$1"

    rm -rf ../__gitprep;  cp -rv . ../__gitprep; pushd ../__gitprep
    rm -rf .git;  git init;  git add .
    if [ -f .gitmodules ]; then
        git reset .gitmodules
        # git doesn't support importing ".gitmodules" :/
        mv .gitmodules .gitmodules.orig
        git config -f .gitmodules.orig --get-regexp '^submodule\..*\.path$' |
            while read path_key path; do
                url_key="$(echo "$path_key" | sed 's/\.path/.url/')"
                url="$(git config -f .gitmodules.orig --get "$url_key")"
                branch_key="$(echo "$path_key" | sed 's/\.path/.branch/')"
                branch="$(git config -f .gitmodules.orig --get "$branch_key")"
                git submodule add --branch "$branch" "$url" "$path"
            done
    fi
    git commit -m 'initial commit'

    gogs_repo_webhook_delete "$REPO"
    ENDPOINT="$(oc get route gogs --template={{.spec.host}})"
    PROJECT="$(oc project -q)"
    curl "http://developer:developer@$(gogs_endpoint)/api/v1/user/repos" --data "name=$REPO"
    git remote add origin "http://developer:developer@$(gogs_endpoint)/developer/$REPO.git"
    git push -u origin master --force

    popd; rm -rf ../__gitprep
}

gogs_repo_delete() {
    REPO="$1"

    curl "http://developer:developer@$(gogs_endpoint)/api/v1/repos/developer/$REPO" -X DELETE
}

gogs_repo_webhook() {
    REPO="$1"
    BUILDCONFIG="$2"

    if [ "$WEBHOOKS_ENABLED" != "y" ]; then
        return
    fi

    gogs_repo_webhook_delete "$REPO"

    PROJECT="$(oc project -q)"
    WEBHOOK_SECRET="$(oc get buildconfig "$BUILDCONFIG" --template '{{range .spec.triggers}}{{if eq .type "Generic"}}{{.generic.secret}}{{end}}{{end}}')"

    curl "http://developer:developer@$(gogs_endpoint)/api/v1/repos/developer/$REPO/hooks" --header "Content-Type:application/json" --data @- <<EOF
{
    "type": "gogs",
    "config": {
        "url": "https://openshift.default.svc.cluster.local/oapi/v1/namespaces/$PROJECT/buildconfigs/$BUILDCONFIG/webhooks/$WEBHOOK_SECRET/generic",
        "content_type": "json"
    },
    "events": [
        "push"
    ],
    "active": true
}
EOF
    echo
}

gogs_repo_webhook_delete() {
    REPO="$1"

    if [ "$WEBHOOKS_ENABLED" != "y" ]; then
        return
    fi

    HOOK_IDS="$((curl --silent "http://developer:developer@$(gogs_endpoint)/api/v1/repos/developer/$REPO/hooks" | grep -o '"id":[0-9]*' | grep -o '[0-9]*' | tr '\n' ' ') || true)"
    for HOOK_ID in $HOOK_IDS; do
        curl "http://developer:developer@$(gogs_endpoint)/api/v1/repos/developer/$REPO/hooks/$HOOK_ID" -X DELETE
    done
}
