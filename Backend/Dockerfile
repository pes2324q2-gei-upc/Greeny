# pull official base image
FROM python:3.12-bookworm

# set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DJANGO_SETTINGS_MODULE=greeny.settings

# set work directory
WORKDIR /code

# install dependencies
COPY requirements.txt /code/
RUN apt-get update && \
    apt-get install -y libgdal-dev && \
    pip install -r requirements.txt
# copy project
COPY . /code/