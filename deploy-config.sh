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

# setup bash-git-prompt
git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1 
cat profile/my_bashrc >> ~/.bashrc

# configure git
cat profile/my_gitconfig > ~/.gitconfig
mkdir -p ~/bin
cp git-commands/* ~/bin/

# configure vim
cat profile/my_vimrc > ~/.vimrc

# cleanup
if [ ! -z $1 ]; then
  cd ..
  rm -r linux-config
fi
