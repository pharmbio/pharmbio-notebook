#!/bin/bash
#set -xv

git_branch="$(git branch --show-current)"
tag=$git_branch
tensorflow_version="${git_branch#tf-}" # remove prefix
tensorflow_version="${tensorflow_version%-*}" # remove suffix
image="pharmbio-notebook"
echo "tensorflow_version=$tensorflow_version"
echo "tag=$tag"
echo "image=$image"
#switch to buildx build
# Build docker image for this container.
# docker buildx build --no-cache -t ghcr.io/pharmbio/$image:$tag \
#              --build-arg BASE_IMAGE=tensorflow/tensorflow:${tensorflow_version}-jupyter \
#              --build-arg FRAMEWORK=cpu \
#              -f ./docker/env.Dockerfile . || exit 1
docker buildx build --no-cache -t ghcr.io/pharmbio/$image:${tag}-gpu \
             --build-arg BASE_IMAGE=tensorflow/tensorflow:${tensorflow_version}-gpu-jupyter \
             --build-arg FRAMEWORK=cuda \
             -f docker/env.Dockerfile . || exit 1

#docker push "ghcr.io/pharmbio/$image:$tag-devel"
