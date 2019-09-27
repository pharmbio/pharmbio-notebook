ARG tf_base=1.14.0-gpu-py3

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
    libsm6 \
    libxext6 \
    libxrender-dev \
    nano \
    mysql-client \
    default-jdk \
    git \
    curl

# pip installs
RUN pip install --no-cache-dir \
    pymysql \
    awscli \
    opencv-python \
    numpy \
    scipy \
    scikit-learn \
    matplotlib \
    pandas \
    keras \
    pillow

## User and permission setup

ARG NB_USER="jovyan"
ARG NB_UID="1000"

#RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER
RUN adduser --disabled-password --gecos '' --uid $NB_UID $NB_USER
RUN adduser $NB_USER sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER $NB_USER
WORKDIR /home/$NB_USER


COPY README.md .
COPY notebooks/* ./notebooks/
COPY secrets_manager.py .
COPY source_minio_credentials.rc .
