# This Dockerfile is used to build THE ASGS RabbitMQ message handler python image
FROM python:3.6.5-slim

# get some credit
LABEL maintainer="RENCI"

# update the base image
RUN apt-get update

# update pip
RUN pip install --upgrade pip

# clear out the apt cache
RUN apt-get clean

# create a new non-root user and switch to it
RUN useradd --create-home -u 1000 nru
USER nru

# Create the directory for the code and cd to it
WORKDIR /repo/asgs-monitor-ui

# install requirements
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# copy over the django manager
COPY manage.py manage.py

# copy over the rest of the website files
COPY ASGS_Mon ASGS_Mon
COPY ASGS_Web ASGS_Web

# expose the website container port
EXPOSE 8000

# start the services
ENTRYPOINT ["python", "manage.py", "runserver", "0.0.0.0:8000"]
