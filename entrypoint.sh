#!/bin/bash

# create symlink to pharmbio template dir
ln -s /pharmbio /home/jovyan

# Start jupyter service
source /etc/bash.bashrc && jupyter notebook --notebook-dir=/tf --ip 0.0.0.0 --no-browser --allow-root
