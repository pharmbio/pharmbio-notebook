#!/bin/bash

echo Preparing content for user home...

# create symlink to pharmbio template dir
if [ ! -e /home/$NB_USER/pharmbio ]; then
  ln -s /pharmbio /home/$NB_USER/
fi

# create symlink to tensorflow notebook tutorials dir
if [ ! -e /home/$NB_USER/tensorflow-tutorials ]; then
  ln -s /tf/tensorflow-tutorials /home/$NB_USER/tensorflow-tutorials
fi

echo Copied tutorials and templates, starting notebook...

# Start jupyter service
jupyter notebook --notebook-dir=/home/$NB_USER --ip 0.0.0.0 --no-browser --allow-root
