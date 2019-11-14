[![Build Status](https://travis-ci.com/pharmbio/pharmbio-notebook.svg?branch=1.14.0)](https://travis-ci.com/pharmbio/pharmbio-notebook)

# pharmbio-notebook-playground
Docker containers for interactive notebook environments for rancher cluster. Different branches are used to build notebooks for different tasks, like tensorflow, cpsign etc.

Built dockers published to [pharmbio docker repo](https://cloud.docker.com/u/pharmbio/repository/docker/pharmbio/pharmbio-notebook), updates to this repo builds automatically with travis

## Tensorflow notebooks
Tensorflow notebook runs jupyter and versions exist for both GPU enabled and non-GPU enabled tensorflow. Branches indicate which version of Tensorflow is installed. Both CPU and GPU version is built from same branch as of 1.14.0. Python packages are listed in the requirements.txt file, and are installed on build through pip. Changes to package versions and additions of new packages is easily managed by modifying the requirements.txt file.
