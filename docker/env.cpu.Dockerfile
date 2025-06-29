# Base image should be specified with --build-arg during build
ARG BASE_IMAGE="tensorflow/tensorflow:latest"  # Example default

FROM $BASE_IMAGE
ARG FRAMEWORK="cuda"
# ARG FRAMEWORK need to be after the build stage FROM (since it is used in another build process)
ARG FRAMEWORK

# Set shell
ENV SHELL=/bin/bash

# Set timezone
ENV TZ=Europe/Stockholm
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install base dependencies
ENV DEBIAN_FRONTEND=noninteractive
# >apt_installs.txt to save instead of executing
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    libegl1-mesa-dev \
    libgles2-mesa-dev \
    gnupg \
    tmux \
    sudo \
    ssh \
    openssh-server \
    mysql-client \
    libpq-dev \
    git \
    vim \
    wget \
    curl \
    ncdu \
    less \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-latex-recommended \
    libsqlite3-dev \
    bc \
    rsync \
    zip \
    unzip \
    iputils-ping \
    sqlite \
    sqlite3 \
    libgl1-mesa-glx \
    csvkit \
    graphviz \
    rdkit-data \
    openjdk-17-jdk-headless \
    golang-go


# Upgrade pip and install base Python packages
COPY requirements.txt .
RUN python3 --version
RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    python3 -m pip install --no-cache-dir -r requirements.txt

# Conditional install based on FRAMEWORK argument


# Add pharmbio templates, examples and misc
#WORKDIR /pharmbio/
#COPY README.md .
#COPY notebooks/* ./notebooks/

# Custom bashrc
COPY bash.bashrc /etc/bash.bashrc

# Set up user
RUN useradd -m -s /bin/bash -N -u 1000 jovyan && \
    echo "jovyan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set ownership for directories jovyan might need to modify
RUN chown jovyan /opt/

# Ensure SSH daemon directory exists & generate host keys
RUN mkdir -p /var/run/sshd && ssh-keygen -A

# Final user and work directory setup
USER jovyan
WORKDIR /home/jovyan

#
# The entrypoint will first copy /pharmbio/ files to user home
# This is because /home/jovyan will be mountpoint for persistent volume
# and all contents that is there already in this image will be masqued with
# persistent volume contents
# Then the entrypoint will start jupyter notebook server
#
COPY entrypoint.sh /
CMD /entrypoint.sh
