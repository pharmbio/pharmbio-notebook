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

# Custom bashrc
COPY bash.bashrc /etc/bash.bashrc

# there must always be a jovyan
ENV NB_USER="jovyan"
ENV NB_UID="1000"

RUN adduser --disabled-password --gecos '' --uid $NB_UID $NB_USER
RUN adduser $NB_USER sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER $NB_USER

WORKDIR /pharmbio/

COPY README.md .
COPY notebooks/* ./notebooks/
COPY secrets_manager.py .
COPY source_minio_credentials.rc .
COPY entrypoint.sh /

WORKDIR /home/$NB_USER

#
# The entrypoint will first copy /pharmbio/ files to user home
# This is because /home/jovyan will be mountpoint for persistent volume
# and all contents that is there already in this image will be masqued with
# persistent volume contents
# Then the entrypoint will start jupyter notebook server
#
CMD /entrypoint.sh
