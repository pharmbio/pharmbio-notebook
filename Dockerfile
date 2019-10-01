## https://hub.docker.com/r/tensorflow/tensorflow

ARG BASE_IMAGE=tensorflow/tensorflow:1.14.0-py3-jupyter

FROM $BASE_IMAGE

ENV SHELL=/bin/bash

# apt installs
RUN apt update && apt install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    gnupg \
    tmux \
    sudo \
    ssh \
    nano \
    mysql-client \
    libpq-dev \
    git \
    curl

## SEPARATED FOR CACHING

# pip installs
WORKDIR /home/$NB_USER
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

## User and permission setup

# there must always be a jovyan
ENV NB_USER="jovyan"
ENV NB_UID="1000"

#RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER
RUN adduser --disabled-password --gecos '' --uid $NB_UID $NB_USER && adduser $NB_USER sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER $NB_USER

WORKDIR /pharmbio/

COPY README.md .
COPY notebooks/* ./notebooks/
COPY secrets_manager.py .
COPY source_minio_credentials.rc .
COPY entrypoint.sh /

WORKDIR /home/$NB_USER

CMD /entrypoint.sh
