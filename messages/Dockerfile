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

# make a directory for the repo
RUN mkdir -p -m777 /message/logs
RUN mkdir -p -m777 /srv/django/ASGS_Web/messages/

# go to the directory where we are going to upload the repo
WORKDIR /message

# get the latest code
#RUN git clone https://github.com/RENCI/ASGS_Web.git

# get all queue message handler files into this image
COPY . .
COPY ./msg_settings.ini /srv/django/ASGS_Web/messages
COPY ./logging.conf /srv/django/ASGS_Web/messages

RUN chmod 777 -R .

# install requirements
RUN pip install -r requirements.txt

# change to the new user
USER nru

# start the service entry point
#ENTRYPOINT ["python", "receive_msg_service_pg.py", "&", "python", "receive_cfg_msg_service_pg.py", "&"]