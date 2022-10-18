# This Dockerfile is used to build THE ASGS RabbitMQ message handler python image
FROM python:3.6.5-slim

# get some credit
LABEL maintainer="RENCI"

# install basic tools
RUN apt-get update
RUN apt-get install -yq vim procps

# update pip
RUN pip install --upgrade pip

# clear out the apt cache
RUN apt-get clean

# make a directory for the repo
RUN mkdir -p -m777 /srv/django/ASGS_Web/messages/
RUN mkdir -p -m777 /repo/message/logs

# go to the directory where we are going to upload the repo
WORKDIR /repo/message

# install requirements
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# get all queue message handler files into this image
COPY ./messages/*.py ./
COPY ./messages/*.sh ./
COPY ./messages/*.template ./
COPY ./messages/logging.conf /srv/django/ASGS_Web/messages

# make sure the file has execute permissions
RUN chmod 755 ./messages/startup.sh

# create a new non-root user and switch to it
RUN useradd --create-home -u 1000 nru
USER nru

# start the services
ENTRYPOINT ["bash", "startup.sh", "30"]
