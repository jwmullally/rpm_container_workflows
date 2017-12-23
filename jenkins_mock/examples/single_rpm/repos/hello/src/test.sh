#!/bin/sh -xe

if [ "`$1`" != $'Content-type: text/plain\n\nHello World!' ]; then
    echo "Test fail"
    exit 1
fi
echo "Test pass"
