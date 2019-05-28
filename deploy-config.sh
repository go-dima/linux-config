#!/bin/bash -e

# clone repo
if [ ! -z $1 ]; then
  if [ "$1" == "-remote" ] || [ "$1" == "-r" ]; then
    git clone https://github.com/go-dima/linux-config.git
    cd linux-config
  else
    echo Invalid option: $1
    exit 1
  fi
fi

# clone bash-git-prompt
BASH_GIT_PROMPT_URL=https://github.com/magicmonty/bash-git-prompt.git
BASH_GIT_PROMPT_FOLDER=~/.bash-git-prompt

if [ ! -d "$BASH_GIT_PROMPT_FOLDER" ] ; then
    git clone $BASH_GIT_PROMPT_URL $BASH_GIT_PROMPT_FOLDER --depth=1
else
    cd "$BASH_GIT_PROMPT_FOLDER"
    git pull $BASH_GIT_PROMPT_URL
    cd -
fi

# configure bashrc
cat profile/my_bashrc > ~/.bashrc.extra
PATTERN='source ~/.bashrc.extra'
BASHRC_FILE=~/.bashrc
grep -qxF -- "$PATTERN" "$BASHRC_FILE" || echo "$PATTERN" >> "$BASHRC_FILE"

# configure git
cat profile/my_gitconfig > ~/.gitconfig
mkdir -p ~/bin
cp git-commands/* ~/bin/

# configure vim
cat profile/my_vimrc > ~/.vimrc

# cleanup
if [ ! -z $1 ]; then
  cd ..
  rm -rf linux-config
fi

# apply changes
source ~/.bashrc
