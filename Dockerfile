
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
    nodejs \
    screen \
    less \
    rsync \
    unzip \
    iputils-ping \
    sqlite \
    sqlite3 \
    libgl1-mesa-glx \
    texlive-base \
    texlive-xetex \
    texlive-fonts-recommended \
    python3-rdkit \
    librdkit1 \
    rdkit-data \
    openjdk-17-jdk-headless \
    golang

# Rust Installs:

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN cargo --help

# OPTIONAL: CPP bidnings. Use local only, crashes REPO
#RUN wget https://download.pytorch.org/libtorch/cu111/libtorch-cxx11-abi-shared-with-deps-1.9.0%2Bcu111.zip
#RUN unzip libtorch-cxx11-abi-shared-with-deps-1.9.0+cu111.zip
#RUN rm libtorch-cxx11-abi-shared-with-deps-1.9.0+cu111.zip


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
RUN python3 -m pip install --no-cache-dir pip --upgrade
RUN python3 -m pip install --no-cache-dir -r requirements.txt

RUN python3 -m pip install --no-cache-dir -f https://download.pytorch.org/whl/torch_stable.html \
			   torch==1.9.0+cu111 \
			   torchvision==0.10.0+cu111 \
			   torchaudio==0.9.0

RUN python3 -m pip install --no-cache-dir pytorch_toolbelt
RUN python3 -m pip install --no-cache-dir --no-deps cellpose \
				omnipose

RUN python3 -m pip install --no-cache-dir -f https://data.pyg.org/whl/torch-1.9.0+cu111.html \
                pyg-lib \
                torch-scatter \
                torch-sparse \
                torch-cluster \
                torch-spline-conv \
                torch-geometric
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
