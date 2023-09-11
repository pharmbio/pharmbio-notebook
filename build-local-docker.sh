#!/bin/bash

git_branch="$(git branch --show-current)"
tag=$git_branch
tensorflow_version="${git_branch#tf-}" # remove prefix
tensorflow_version="${tensorflow_version%-*}" # remove suffix
#tensorflow_version="${tensorflow_version%-*}" 
image="pharmbio-notebook"
echo "tensorflow_version=$tensorflow_version"
echo "tag=$tag"
echo "image=$image"

# Build docker image for this container.
#docker build -t pharmbio/pharmbio-notebook:tf-2.8.0-pytorch-gpu . --build-arg #BASE_IMAGE=tensorflow/tensorflow:2.8.0-gpu-jupyter --no-cache

#docker build -t pharmbio/$image:${tag} . --build-arg BASE_IMAGE=tensorflow/tensorflow:${tensorflow_version}-gpu
# Build CPU and GPU version of this tensorflow docker
docker build -t "ghcr.io/pharmbio/$image:$tag-devel" . --build-arg BASE_IMAGE=tensorflow/tensorflow:${tensorflow_version}-jupyter
docker build -t "ghcr.io/pharmbio/$image:${tag}-gpu-devel" . --build-arg BASE_IMAGE=tensorflow/tensorflow:${tensorflow_version}-gpu-jupyter

docker push "ghcr.io/pharmbio/$image:$tag-devel"
