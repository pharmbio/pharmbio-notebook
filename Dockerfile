## https://docs.nvidia.com/deeplearning/frameworks/tensorflow-release-notes/rel_19.09.html#rel_19.09
FROM nvcr.io/nvidia/tensorflow:19.09-py3

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

ARG NB_USER="jovyan"
ARG NB_UID="1000"

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
