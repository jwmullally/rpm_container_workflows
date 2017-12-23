#!/bin/sh -ex

function test_response {
    RESPONSE=`curl -vsS "http://$ENDPOINT/"`
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
