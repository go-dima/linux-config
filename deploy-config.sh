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

echo '########## Update & Install Tools ##########'
sudo apt-get update
packages_to_install=`cat packages | awk '{printf("%s ",$0)}'`
sudo apt-get -y install ${PACKAGES_TO_INSTALL}

if [[ "${SKIP_CLONE}" -eq "false" ]]; then
  # Clone repo
  git clone https://github.com/go-dima/linux-config.git
  cd linux-config
fi

echo '########## Configure bash-git-prompt ##########'
BASH_GIT_PROMPT_URL=https://github.com/magicmonty/bash-git-prompt.git
BASH_GIT_PROMPT_FOLDER=~/.bash-git-prompt

if [[ ! -d "$BASH_GIT_PROMPT_FOLDER" ]] ; then
    git clone $BASH_GIT_PROMPT_URL $BASH_GIT_PROMPT_FOLDER --depth=1
else
    cd "$BASH_GIT_PROMPT_FOLDER"
    git pull $BASH_GIT_PROMPT_URL
    cd -
fi

echo '########## Configure bashrc ##########'
cat profile/my_bashrc > ~/.bashrc.extra
PATTERN='source ~/.bashrc.extra'
BASHRC_FILE=~/.bashrc
grep -qxF -- "$PATTERN" "$BASHRC_FILE" || echo "$PATTERN" >> "$BASHRC_FILE"

echo '########## Configure git ##########'
cat profile/my_gitconfig > ~/.gitconfig
mkdir -p ~/bin
cp git-commands/* ~/bin/

echo '########## Configure vim ##########'
cat profile/my_vimrc > ~/.vimrc

# Cleanup
if [[ -z "$1" ]]; then
  echo 
  cd ..
  rm -rf linux-config
fi

echo '########## Apply Changes ##########'
source ~/.bashrc

echo '########## Configuration Complete ##########'
