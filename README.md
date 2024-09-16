[![Build Status](https://travis-ci.com/pharmbio/pharmbio-notebook.svg?branch=master)](https://travis-ci.com/pharmbio/pharmbio-notebook)

# pharmbio-notebook-playground
Docker containers for interactive notebook environments for rancher cluster. Different branches are used to build notebooks for different tasks, like tensorflow, cpsign etc.

Built dockers published to [pharmbio docker repo](https://cloud.docker.com/u/pharmbio/repository/docker/pharmbio/pharmbio-notebook), updates to this repo builds automatically with travis

# Current Branch Notes:
Pharmbio/pharmbio:tf-2.17.0-pytorch-gpu is built using the tensorflow 2.17.0 base image published by tensorflow. It emulates Ubuntu22.04, and natively runs python 3.11 now. CUDA12.3 is installed and paired with PyTorch 2.x.x.

# Branch versioning
Current branch for latest is "nightly"<br>
This repo is based on using branch names matching the tensorflow [docker image versions](https://hub.docker.com/r/tensorflow/tensorflow/tags), i.e. 1.14.0, 1.15.0, 2.1.0 etc. The branch name is used by travis and GitHub Actions to build docker images based on the tensorflow docker images, and both CPU and GPU version is built from every version.

**Example tags:**
* nightly, 2.4.0-pytorch-r
* 1.12.0 and 1.12.0
* 1.14.0
* tf-2.1.0 (old versioning with prefix indicating this is based upon tensorflow)

## Tensorflow notebooks
Tensorflow notebook runs jupyter and versions exist for both GPU enabled and non-GPU enabled tensorflow. Branches indicate which version of Tensorflow is installed. Both CPU and GPU version is built from same branch as of 1.14.0. Python packages are listed in the requirements.txt file, and are installed on build through pip. Changes to package versions and additions of new packages is easily managed by modifying the requirements.txt file.
