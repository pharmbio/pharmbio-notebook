#!/bin/bash

# create symlink to pharmbio template dir
if [ ! -e /home/$NB_USER/pharmbio ]; then
  ln -s /pharmbio /home/$NB_USER/
fi

# Start jupyter service
jupyter notebook --notebook-dir=/home/$NB_USER --ip 0.0.0.0 --no-browser --allow-root
