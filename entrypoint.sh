#!/bin/bash

echo Preparing content for user home...

# create symlink to pharmbio template dir
if [ ! -e /home/jovyan/pharmbio ]; then
  ln -s /pharmbio /home/jovyan/
fi

# create symlink to /scratch-shared
if [ ! -e /home/jovyan/scratch-shared ]; then
  ln -s /scratch-shared /home/jovyan/
fi

# create symlink to /mnt
if [ ! -e /home/jovyan/mnt ]; then
  ln -s /mnt /home/jovyan/
fi

# create symlink to /media
if [ ! -e /home/jovyan/media ]; then
  ln -s /media /home/jovyan/
fi

# create symlink to /share
if [ ! -e /home/jovyan/share ]; then
  ln -s /share /home/jovyan/
fi

# create symlink to /course-share
if [ ! -e /home/jovyan/course-share-pvc ]; then
  ln -s /mnt/course-share-pvc /home/jovyan/
fi

# create symlink to tensorflow notebook tutorials dir
if [ ! -e /home/jovyan/tensorflow-tutorials ]; then
  ln -s /tf/tensorflow-tutorials /home/jovyan/tensorflow-tutorials
fi

echo Copied tutorials and templates, starting notebook...

#     docker run -d --rm --name notebook \
#                   --runtime=nvidia --gpus all \
#                   -p 80:8888 \
#                   --network host \
#                   --dns 130.238.164.6 \
#                   --dns 130.238.4.133 \
#                   -e NOTEBOOK_PASSW_SHA1="sha1:2c32ea8566b5:b646acb256d79c65d2c1d2492e58e89a963c8881" \
#                   -v $PWD:/home/jovyan \
#                   -it ghcr.io/pharmbio/pharmbio-notebook:tf-2.12.0rc0-pytorch-gpu

# Start jupyter service
jupyter notebook --notebook-dir=/home/jovyan \
                 --ip 0.0.0.0 \
                 --no-browser \
                 --allow-root \
                 --NotebookApp.password="$NOTEBOOK_PASSW_SHA1" \
                 --NotebookApp.token="$NOTEBOOK_TOKEN" \
                 --NotebookApp.allow_password_change=True \
                 --NotebookApp.default_url="/lab"
