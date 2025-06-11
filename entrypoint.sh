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

if [ "$SSH_ENABLED" = "true" ]; then
  echo "Starting ssh server"
  sudo /usr/sbin/sshd -E /var/log/sshd.log &
else
  echo "SSH not enabled; skipping sshd startup"
fi

echo "starting notebook..."

# Start jupyter service
jupyter lab --notebook-dir=/home/jovyan \
            --ip 0.0.0.0 \
            --no-browser \
            --allow-root \
            --NotebookApp.password="$NOTEBOOK_PASSW_SHA1"