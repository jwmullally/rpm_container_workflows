#!/bin/sh -eux

export DJANGO_SETTINGS_MODULE=myapp.settings
python -m django migrate
exec gunicorn myapp.wsgi -b 0.0.0.0:8000
