#!/bin/bash -e

SKIP_CLONE=false

if [[ ! -z "$1" ]]; then
  if [[ "$1" == "-local" ]] || [[ "$1" == "-l" ]]; then
    echo Running from local folder
    SKIP_CLONE=true
  else
    echo Invalid option: $1
    exit 1
  fi
fi

echo '########## Update & Install Git ##########'
sudo apt-get update
sudo apt-get -y install git

if [[ "${SKIP_CLONE}" -eq "false" ]]; then
  # Clone repo
  git clone https://github.com/go-dima/linux-config.git ~/.linux-config
  cd ~/.linux-config
fi

echo '########## Install Tools ##########'
packages_to_install=`cat packages | awk '{printf("%s ",$0)}'`
sudo apt-get -y install ${PACKAGES_TO_INSTALL}
if [[ ! -d "$HOME/.utils" ]] ; then
  git clone https://github.com/go-dima/Utils.git $HOME/.utils
fi

echo '########## Configure bash-git-prompt ##########'
BASH_GIT_PROMPT_URL=https://github.com/magicmonty/bash-git-prompt.git
BASH_GIT_PROMPT_FOLDER=$HOME/.bash-git-prompt

if [[ ! -d "$BASH_GIT_PROMPT_FOLDER" ]] ; then
    git clone $BASH_GIT_PROMPT_URL $BASH_GIT_PROMPT_FOLDER --depth=1
else
    cd "$BASH_GIT_PROMPT_FOLDER"
    git pull $BASH_GIT_PROMPT_URL
    cd -
fi

echo '########## Configure bashrc ##########'
PATTERN='source ~/.linux-config/profile/my_bashrc'
BASHRC_FILE=~/.bashrc
grep -qxF -- "$PATTERN" "$BASHRC_FILE" || echo "$PATTERN" >> "$BASHRC_FILE"

echo '########## Configure git ##########'
cat profile/my_gitconfig > ~/.gitconfig
mkdir -p ~/bin
cp git-commands/* ~/bin/

echo '########## Configure vim ##########'
cat profile/my_vimrc > ~/.vimrc

echo '########## Apply Changes ##########'
source ~/.bashrc

echo '########## Configuration Complete ##########'
