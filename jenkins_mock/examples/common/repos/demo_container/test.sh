#!/bin/bash 
set -euxo pipefail

function test_response {
    RESPONSE=`curl -vsS --connect-timeout 10 --retry 3 "http://$ENDPOINT/"`
    if [ "$RESPONSE" != "Hello, World!" ]; then
        echo "Test fail" 1>&2
        exit 1
    fi
}

function run_tests {
    ENDPOINT=$1
    test_response
    echo "Test pass"
}

run_tests "$@"
