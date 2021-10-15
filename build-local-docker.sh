#!/bin/bash

git_branch="$(git branch --show-current)"
tag=$git_branch
tensorflow_version="${git_branch#tf-}" # remove prefix
tensorflow_version="${tensorflow_version%-*}" # remove suffix 
image="pharmbio-notebook"
echo "tensorflow_version=$tensorflow_version"
echo "tag=$tag"
echo "image=$image"

# Build CPU and GPU version of this tensorflow docker
docker build -t pharmbio/$image:$tag . --build-arg BASE_IMAGE=tensorflow/tensorflow:${tensorflow_version}-jupyter
docker build -t pharmbio/$image:${tag}-gpu . --build-arg BASE_IMAGE=tensorflow/tensorflow:${tensorflow_version}-gpu-jupyter
