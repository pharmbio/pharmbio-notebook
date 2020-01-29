## https://hub.docker.com/r/tensorflow/tensorflow

ARG BASE_IMAGE=tensorflow/tensorflow:2.1.0-py3-jupyter

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
    vim \
    wget \
    curl \
    sqlite \
    sqlite3 \
    libxrender1 \
    libxext6

# add pharmbio templates, examples and misc
WORKDIR /pharmbio/
COPY README.md .
COPY notebooks/* ./notebooks/
#COPY secrets_manager.py .
#COPY source_minio_credentials.rc .

# pip installs
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

#
# Conda installation
#
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh
RUN find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete
RUN /opt/conda/bin/conda clean -afy
RUN /opt/conda/bin/conda init
RUN /opt/conda/bin/conda config --set auto_activate_base false
RUN /opt/conda/bin/conda create --name pbseq_2020 python=3.7

# Make RUN commands use the new environment:
SHELL ["/opt/conda/bin/conda", "run", "-n", "pbseq_2020", "/bin/bash", "-c"]

RUN conda install -c rdkit rdkit

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir sklearn

RUN conda install ipykernel
RUN ipython kernel install --name=Python_3.7_Conda_RDKit
#
# End conda
#

SHELL ["/bin/bash", "-c"]

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
