
# This is the Default image to be built, It will be overridden with --build-args in
# our CICD process
# https://hub.docker.com/r/tensorflow/tensorflow

ARG BASE_IMAGE="should be specified with --build-arg"
ARG FRAMEWORK="Specify with --build-arg"

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
    screen \
    less \
    rsync \
    zip \
    unzip \
    iputils-ping \
    sqlite \
    sqlite3 \
    libgl1-mesa-glx \
    python3-rdkit \
    librdkit1 \
    rdkit-data \
    openjdk-17-jdk-headless \
    cmake\
    golang

# Rust Installs, disabling unless needed:
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN cargo --help

# add pharmbio templates, examples and misc
WORKDIR /pharmbio/
COPY README.md .
COPY notebooks/* ./notebooks/

# Custom bashrc
COPY bash.bashrc /etc/bash.bashrc

# pip installs
COPY requirements.txt .
RUN python3 -m pip install --no-cache-dir pip --upgrade
RUN python3 -m pip install --no-cache-dir -r requirements.txt


RUN if [ "$FRAMEWORK" = "cuda" ]; then \
      # Do something specific to production environment \
        python3 -m pip install --no-cache-dir \
                       torch==2.2.1 \
                       torchvision \
                       torchaudio \
                       --index-url https://download.pytorch.org/whl/cu121 \
        python3 -m pip install --no-cache-dir pytorch_toolbelt \
        python3 -m pip install --no-cache-dir -f https://data.pyg.org/whl/torch-2.2.0+cu121.html \
               pyg-lib \
               torch-scatter \
               torch-sparse \
               torch-cluster \
               torch-spline-conv \
               torch-geometric \
    elif [ "$FRAMEWORK" = "cpu" ]; then \
        python3 -m pip install --no-cache-dir \
                torch==2.2.1 \
                torchvision \
                torchaudio \
                --index-url https://download.pytorch.org/whl/cpu \
        python3 -m pip install --no-cache-dir pytorch_toolbelt \
        python3 -m pip install --no-cache-dir -f https://data.pyg.org/whl/torch-2.2.0+cpu.html \
                pyg-lib \
                torch-scatter \
                torch-sparse \
                torch-cluster \
                torch-spline-conv \
                torch-geometric \
    elif [ "$FRAMEWORK" = "rocm" ]; then \
        # Insert your ROCm-specific pip install commands here
        echo "not yet implemented: $FRAMEWORK"; \
        exit 1; \
    else \
        echo "Unsupported ENVIRONMENT: $FRAMEWORK"; \
        exit 1; \
    fi

#RUN python3 -m pip install --no-cache-dir \
#                        torch==2.2.1 \
#                        torchvision \
#                        torchaudio \
#                        --index-url https://download.pytorch.org/whl/cu121
#RUN python3 -m pip install --no-cache-dir pytorch_toolbelt

#RUN python3 -m pip install --no-cache-dir -f https://data.pyg.org/whl/torch-2.2.0+cu121.html \
#                pyg-lib \
#                torch-scatter \
#                torch-sparse \
#                torch-cluster \
#                torch-spline-conv \
#                torch-geometric

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
