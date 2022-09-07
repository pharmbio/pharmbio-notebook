
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
    texlive-fonts-recommended

# pip installs
COPY requirements.txt .
RUN python3 -m pip install --no-cache-dir pip --upgrade
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# Install conda
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2022.05-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh

# cleanup some stuff from conda
RUN find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete
RUN /opt/conda/bin/conda clean -afy

# init conda
RUN /opt/conda/bin/conda init bash
RUN /opt/conda/bin/conda config --set auto_activate_base false

# install ReinventCommunity conda environment
RUN git clone --depth 1 https://github.com/MolecularAI/ReinventCommunity.git
RUN /opt/conda/bin/conda env create -f ReinventCommunity/environment.yml

# RUN commands in use the new environment (can not use activate in Dockerfile):
SHELL ["/opt/conda/bin/conda", "run", "-n", "ReinventCommunity", "/bin/bash", "-c"]

# install ipykernel to this conda env and add it to notebook
RUN conda install -c anaconda ipykernel
RUN ipython kernel install --name=ReinventCommunity_Python3.7 --display-name "ReinventCommunity_Python3.7"

# install Reinvent conda environment
RUN git clone --depth 1 https://github.com/MolecularAI/Reinvent.git
RUN /opt/conda/bin/conda env create -f Reinvent/reinvent.yml

# RUN commands in use the new environment (can not use activate in Dockerfile):
SHELL ["/opt/conda/bin/conda", "run", "-n", "reinvent.v3.2", "/bin/bash", "-c"]

# install ipykernel to this conda env and add it to notebook
RUN conda install -c anaconda ipykernel
RUN ipython kernel install --name=Reinvent --display-name "Reinvent"


SHELL ["/bin/bash", "-c"]

#
# End conda
#

# add pharmbio templates, examples and misc
WORKDIR /pharmbio/
COPY README.md .
COPY notebooks/* ./notebooks/

# Custom bashrc
COPY bash.bashrc /etc/bash.bashrc

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

# Add conda to bashrc
RUN echo export PATH="/opt/conda/bin:$PATH" > .bashrc

#
# The entrypoint will first copy /pharmbio/ files to user home
# This is because /home/jovyan will be mountpoint for persistent volume
# and all contents that is there already in this image will be masqued with
# persistent volume contents
# Then the entrypoint will start jupyter notebook server
#
CMD /entrypoint.sh
