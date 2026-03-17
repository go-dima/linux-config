#!/bin/bash
set -e

PLATFORM="${1:?Usage: verify.sh linux|macos}"

pass() { echo "  OK  $1"; }
fail() { echo "FAIL  $1"; exit 1; }

assert_file() {
  [ -e "$1" ] && pass "$1 exists" || fail "$1 missing"
}

assert_cmd() {
  command -v "$1" > /dev/null 2>&1 && pass "command: $1" || fail "command not found: $1"
}

assert_contains() {
  grep -q "$2" "$1" && pass "$1 contains '$2'" || fail "$1 missing '$2'"
}

echo "=== verify.sh: $PLATFORM ==="

# ── Config files ──────────────────────────────────────────────────────────────
assert_file "$HOME/.gitconfig"
assert_contains "$HOME/.gitconfig" "s = status"
assert_file "$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] || [ -f "$HOME/.bash_profile" ] \
  && pass "$HOME/.bashrc or $HOME/.bash_profile exists" \
  || fail "neither $HOME/.bashrc nor $HOME/.bash_profile found"
assert_file "$HOME/.vimrc"

# ── Tools (both platforms) ────────────────────────────────────────────────────
assert_cmd jq
assert_cmd fzf
assert_cmd rg
delta --version > /dev/null 2>&1 && pass "command: delta" || fail "command not found: delta"

# ── Oh My Zsh + plugins ───────────────────────────────────────────────────────
assert_file "$HOME/.oh-my-zsh"
assert_file "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
assert_file "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
assert_file "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
assert_file "$HOME/.oh-my-zsh/custom/plugins/you-should-use"

# ── Custom git commands ───────────────────────────────────────────────────────
[ -x "$HOME/bin/git-trim" ]  && pass "$HOME/bin/git-trim executable"  || fail "$HOME/bin/git-trim missing or not executable"
[ -x "$HOME/bin/git-plant" ] && pass "$HOME/bin/git-plant executable" || fail "$HOME/bin/git-plant missing or not executable"

# ── Platform-specific ─────────────────────────────────────────────────────────
if [ "$PLATFORM" = "linux" ]; then
  batcat --version > /dev/null 2>&1 && pass "command: batcat" || fail "command not found: batcat (bat on Debian)"
  fdfind --version > /dev/null 2>&1 && pass "command: fdfind" || fail "command not found: fdfind (fd on Debian)"

elif [ "$PLATFORM" = "macos" ]; then
  bat --version > /dev/null 2>&1 && pass "command: bat" || fail "command not found: bat"
  assert_cmd tldr
  assert_cmd gh
fi

echo ""
echo "=== All checks passed for $PLATFORM ==="
