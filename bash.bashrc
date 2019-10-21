# Copyright 2018 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ==============================================================================

export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@ph-notebook\[\e[m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
export TERM=xterm-256color
alias grep="grep --color=auto"
alias ls="ls --color=auto"

echo -e "\e[1;31m"
cat << "TF"
    ____  __                         __      _
   / __ \/ /_  ____ __________ ___  / /_    (_)___
  / /_/ / __ \/ __ `/ ___/ __ `__ \/ __ \  / / __ \
 / ____/ / / / /_/ / /  / / / / / / /_/ / / / /_/ /
/_/   /_/ /_/\__,_/_/  /_/ /_/ /_/_.___(_)_/\____/
    _   __      __       __                __
   / | / /___  / /____  / /_  ____  ____  / /__
  /  |/ / __ \/ __/ _ \/ __ \/ __ \/ __ \/ //_/
 / /|  / /_/ / /_/  __/ /_/ / /_/ / /_/ / ,<
/_/ |_/\____/\__/\___/_.___/\____/\____/_/|_|


TF
echo -e "\e[0;33m"

if [[ $EUID -eq 0 ]]; then
  cat <<WARN
WARNING: You are running this container as root, which can cause new files in
mounted volumes to be created as the root user on your host machine.

To avoid this, run the container by specifying your user's userid:

$ docker run -u \$(id -u):\$(id -g) args...
WARN
else
  cat <<EXPL
You are running this container as user with ID $(id -u) and group $(id -g),
which should map to the ID and group for your user on the Docker host. Great!
EXPL
fi

# Turn off colors
echo -e "\e[m"
