#!/bin/sh
set -ex
cd /var/www
/usr/bin/python -m CGIHTTPServer 8000
