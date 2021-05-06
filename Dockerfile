\
# This is the Default image to be built, It will be overridden with --build-args in
# our CICD process
# https://hub.docker.com/r/tensorflow/tensorflow
ARG BASE_IMAGE=tensorflow/tensorflow:2.1.0-py3-jupyter

FROM $BASE_IMAGE

ENV SHELL=/bin/bash

# add timezone info
ENV TZ=Europe/Stockholm
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

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
    vim \
    wget \
    curl \
    sqlite \
    sqlite3 \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-generic-recommended \
    libsqlite3-dev \
    less \
    bc \
    unzip \
    default-jre \
    csvkit \
    graphviz


# Go installation
RUN cd /usr/local/bin &&\
    wget https://golang.org/dl/go1.15.6.linux-amd64.tar.gz \
    && tar -zxf go1.15.6.linux-amd64.tar.gz
    #&& echo 'export GOROOT=~/go' >> ~/.bashrc \
    #&& echo 'export GOPATH=~/proj/go' >> ~/.bashrc \
    #&& echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bashrc \

ENV GOROOT="/usr/local/bin/go"
ENV GOPATH="/usr/local/bin/proj/go"
ENV PATH="$GOPATH/bin:$GOROOT/bin:$PATH"

# SciPipe installation
RUN go get github.com/scipipe/scipipe/...@v0.9.14

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
RUN pip install --no-cache-dir -r requirements.txt


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

# python 3.6 might be changed in future, keep an eye in this
ENV JUPYTER_PATH='$JUPYTER_PATH:/home/jovyan/.local/lib/python3.6/site-packages'


#
# The entrypoint will first copy /pharmbio/ files to user home
# This is because /home/jovyan will be mountpoint for persistent volume
# and all contents that is there already in this image will be masqued with
# persistent volume contents
# Then the entrypoint will start jupyter notebook server
#
CMD /entrypoint.sh
