#!/bin/bash

#migrations
python manage.py makemigrations
python manage.py migrate

#ini db
python manage.py fetchstations

#runserver
python manage.py runserver 0.0.0.0:8000