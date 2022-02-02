
# This is the Default image to be built, It will be overridden with --build-args in
# our CICD process
# https://hub.docker.com/r/tensorflow/tensorflow

ARG BASE_IMAGE="should be specified with --build-arg"

FROM $BASE_IMAGE

ENV SHELL=/bin/bash

# add timezone info
ENV TZ=Europe/Stockholm
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# apt installs
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    gnupg \
    tmux \
    sudo \
    ssh \
    nano \
    mysql-client \
    libpq-dev \
    git \
    vim \
    wget \
    curl \
    ncdu \
    less \
    rsync \
    iputils-ping \
    sqlite \
    sqlite3 \
    libgl1-mesa-glx \
    texlive-base \
    texlive-xetex \
    texlive-fonts-recommended \
    openjdk-17-jre-headless


# add pharmbio templates, examples and misc
WORKDIR /pharmbio/
COPY README.md .
COPY notebooks/* ./notebooks/
#COPY secrets_manager.py .
#COPY source_minio_credentials.rc .

# Custom bashrc
COPY bash.bashrc /etc/bash.bashrc

# pip installs
COPY requirements.txt .
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# there must always be a jovyan - user name is hardcoded to jovyan for compatibility purposes
RUN adduser --disabled-password --gecos '' --uid 1000 jovyan
RUN adduser jovyan sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

## make sure jovyan can install in opt
RUN chown jovyan /opt/

# Fix user
USER jovyan
COPY entrypoint.sh /

WORKDIR /home/jovyan

#
# The entrypoint will first copy /pharmbio/ files to user home
# This is because /home/jovyan will be mountpoint for persistent volume
# and all contents that is there already in this image will be masqued with
# persistent volume contents
# Then the entrypoint will start jupyter notebook server
#
CMD /entrypoint.sh
