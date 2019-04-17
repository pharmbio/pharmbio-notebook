ARG tf_base=1.12.0-gpu-py3

FROM tensorflow/tensorflow:${tf_base}

# Set pachctl version to match desired pachd version

ENV SHELL=/bin/bash

ARG pachctl_version=1.7.10
RUN apt update && apt install -y --no-install-recommends \
    # apt installs
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
    curl && \
    # custom installs
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt update && apt install -y --no-install-recommends kubectl  && \
    curl -o /tmp/pachctl.deb -L https://github.com/pachyderm/pachyderm/releases/download/v${pachctl_version}/pachctl_${pachctl_version}_amd64.deb && dpkg -i /tmp/pachctl.deb && \
    # pip installs
    pip install --no-cache-dir \
    pymysql \
    python-pachyderm \
    awscli \
    opencv-python \
    numpy \
    scipy \
    scikit-learn \
    matplotlib \
    pandas \
    keras \
    pillow && \
    # cleanup
    rm /tmp/pachctl.deb

COPY README.md /home/
COPY notebooks/* /notebooks/
COPY secrets_manager.py /home
COPY source_minio_credentials.rc /home/

WORKDIR /home
