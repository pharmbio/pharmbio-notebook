#!/bin/bash

# create symlink to pharmbio template dir
if [ ! -e /home/jovyan/pharmbio ]; then
  ln -s /pharmbio /home/jovyan/
fi

# Start jupyter service
source /etc/bash.bashrc && jupyter notebook --notebook-dir=/tf --ip 0.0.0.0 --no-browser --allow-root
