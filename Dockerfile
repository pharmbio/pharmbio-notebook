ARG tf_base=1.14.0-py3

FROM tensorflow/tensorflow:${tf_base}

ENV SHELL=/bin/bash

# apt installs
RUN apt update && apt install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    gnupg \
    tmux \
    sudo \
    ssh \
    #libsm6 \
    #libxext6 \
    #libxrender-dev \
    nano \
    mysql-client \
    git \
    curl

## SEPARATED FOR CACHING

# pip installs
RUN pip install --no-cache-dir \
    pymysql==0.9.3 \
    awscli==1.16.248 \
    opencv-python-headless==4.1.1.26 \
    numpy==1.16.4 \
    scipy==1.3.1 \
    scikit-learn==0.21.3 \
    matplotlib==3.1.1 \
    pandas==0.25.1 \
    keras==2.3.0 \
    pillow==6.1.0

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

WORKDIR /home/$NB_USER