#!/bin/bash -e

REPO_URL=https://github.com/go-dima/linux-config.git
REPO_DIR=~/.linux-config
SKIP_CLONE=false

step() { echo ""; echo "########## $1 ##########"; }

# --- Args ---
if [[ ! -z "$1" ]]; then
  if [[ "$1" == "-local" ]] || [[ "$1" == "-l" ]]; then
    echo "Running from local folder"
    SKIP_CLONE=true
    REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
  else
    echo "Invalid option: $1"; exit 1
  fi
fi

# --- Detect OS ---
OS=$(uname)
[[ "$OS" == "Darwin" ]] && IS_MAC=true || IS_MAC=false

# --- Clone repo ---
if [[ "${SKIP_CLONE}" == "false" ]]; then
  step "Cloning repo"
  git clone "$REPO_URL" "$REPO_DIR"
  cd "$REPO_DIR"
fi

# --- Bootstrap: ensure jq + package manager are ready ---
step "Bootstrap"
if [[ "$IS_MAC" == "true" ]]; then
  if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  command -v jq &>/dev/null || brew install jq
else
  sudo apt-get update
  sudo apt-get -y install git curl jq
fi

# --- Install packages ---
step "Installing packages"
if [[ "$IS_MAC" == "true" ]]; then
  formulae=$(jq -r '.packages[] | select(.brew != false and .brew != "cask") | .name' "$REPO_DIR/apps.json" | tr '\n' ' ')
  [[ -n "$formulae" ]] && brew install $formulae

  casks=$(jq -r '.packages[] | select(.brew == "cask") | .name' "$REPO_DIR/apps.json" | tr '\n' ' ')
  [[ -n "$casks" ]] && brew install --cask $casks
else
  apt_packages=$(jq -r '.packages[] | select(.apt != false) | if (.apt | type) == "string" then .apt else .name end' "$REPO_DIR/apps.json" | tr '\n' ' ')
  [[ -n "$apt_packages" ]] && sudo apt-get -y install $apt_packages
fi

# --- Script installs (OMZ, p10k, zsh plugins) ---
step "Script installs"
count=$(jq '.curl | length' "$REPO_DIR/apps.json")
for i in $(seq 0 $((count - 1))); do
  name=$(jq -r ".curl[$i].name" "$REPO_DIR/apps.json")
  cmd=$(jq -r ".curl[$i].cmd" "$REPO_DIR/apps.json")

  # Skip if already installed
  if [[ "$name" == "omz" ]]; then
    [[ -d ~/.oh-my-zsh ]] && echo "OMZ already installed, skipping" && continue
  elif [[ "$name" == "p10k" ]]; then
    [[ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k" ]] && echo "p10k already installed, skipping" && continue
  else
    [[ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$name" ]] && echo "$name already installed, skipping" && continue
  fi

  echo "Installing $name..."
  eval "$cmd"
done

# --- Configure zsh ---
step "Configuring zsh"
if [[ -f ~/.zshrc ]]; then
  sed -i.bak 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
  sed -i.bak 's/^plugins=(git)$/plugins=(git docker zsh-autosuggestions zsh-syntax-highlighting you-should-use)/' ~/.zshrc
  rm -f ~/.zshrc.bak
fi
ZSHRC_PATTERN="source $REPO_DIR/profile/my_zshrc"
grep -qxF "$ZSHRC_PATTERN" ~/.zshrc 2>/dev/null || echo "$ZSHRC_PATTERN" >> ~/.zshrc
P10K_PRESET="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/config/p10k-lean.zsh"
cp "$P10K_PRESET" ~/.p10k.zsh
# Wizard answers: compatible (ascii), 1 line (no newline element), compact
sed -i.bak "s/typeset -g POWERLEVEL9K_MODE=.*/typeset -g POWERLEVEL9K_MODE=ascii/" ~/.p10k.zsh
sed -i.bak "s/typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=.*/typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false/" ~/.p10k.zsh
sed -i.bak "/[[:space:]]*newline[[:space:]]*/d" ~/.p10k.zsh
rm -f ~/.p10k.zsh.bak
P10K_PATTERN='[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh'
grep -qxF "$P10K_PATTERN" ~/.zshrc 2>/dev/null || echo "$P10K_PATTERN" >> ~/.zshrc

# --- Configure bash (fallback) ---
step "Configuring bash"
BASHRC_PATTERN="source $REPO_DIR/profile/my_bashrc"
grep -qxF "$BASHRC_PATTERN" ~/.bashrc 2>/dev/null || echo "$BASHRC_PATTERN" >> ~/.bashrc

# --- Configure git ---
step "Configuring git"
cp "$REPO_DIR/profile/my_gitconfig" ~/.gitconfig
mkdir -p ~/bin
cp "$REPO_DIR/git-commands/"* ~/bin/
chmod +x ~/bin/git-adds ~/bin/git-commit-push ~/bin/git-flush ~/bin/git-graph ~/bin/git-plant ~/bin/git-trim

# --- Configure vim ---
step "Configuring vim"
cp "$REPO_DIR/profile/my_vimrc" ~/.vimrc

step "Configuration Complete"
echo "Restart your shell or run: exec zsh"
