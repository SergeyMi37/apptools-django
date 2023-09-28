#!/bin/bash
python manage.py migrate
python manage.py loaddata db-test.json
python manage.py createsuperuser --noinput --username adm --email adm@localhost.com
python manage.py runserver 0.0.0.0:8000