# This Dockerfile is used to build THE ASGS RabbitMQ message handler python image
FROM python:3.6.5

# get some credit
LABEL maintainer="RENCI"

# install basic tools
RUN apt-get update
RUN apt-get install -yq vim

# update pip
RUN pip install --upgrade pip

# create a new non-root user
RUN useradd -M -u 1000 nru

# make a directory for the repo code
RUN mkdir -p -m777 /code

# go to the directory where we are going to upload the repo
WORKDIR /code

# get all queue message handler files into this image
COPY ./manage.py .
COPY ./requirements.txt .

# copy over the django files
COPY ASGS_Mon/ ASGS_Mon/
COPY ASGS_Web/ ASGS_Web/

RUN chmod 777 -R .

# install requirements
RUN pip install -r requirements.txt

# change to the new user
USER nru

EXPOSE 8000

# start the services
ENTRYPOINT ["python", "manage.py", "runserver", "0.0.0.0:8000"]
