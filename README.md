# linux-config
Configure working environment on Linux/macOS with:
- zsh + Oh My Zsh + Powerlevel10k
- gitconfig + custom git commands
- vimrc
- shell aliases
- dev tools (see [apps.json](apps.json))

## Usage

**Local mode:**
```sh
git clone https://github.com/go-dima/linux-config.git
cd linux-config
./deploy-config.sh -local
```

**Remote mode:**
```sh
curl -s https://raw.githubusercontent.com/go-dima/linux-config/master/deploy-config.sh | bash
```

---

## Installed Tools

<details>
<summary>CLI (brew + apt)</summary>

| Tool | Description |
|------|-------------|
| `git` | Version control |
| `tree` | Directory listing |
| `fzf` | Fuzzy finder |
| `ripgrep` | Fast text search — git aware and higher performance |
| `jq` | JSON processor |
| `bat` | `cat` with syntax highlighting and line numbers |
| `watch` | Repeat a command on interval |
| `delta` | Syntax highlighter for git, diff, grep output |

</details>

<details>
<summary>macOS only (brew)</summary>

| Tool | Description |
|------|-------------|
| `tldr` | Simplified community-maintained man pages |
| `gh` | GitHub CLI |
| `docker` | Docker Desktop (cask) |
| `ngrok` | Tunneling service (cask) |

</details>

<details>
<summary>Linux only (apt)</summary>

| Tool | Description |
|------|-------------|
| `zsh` | Zsh shell |
| `curl` | HTTP client |
| `htop` | Interactive process viewer |
| `tmux` | Terminal multiplexer |
| `fd` | `find` replacement — more user-friendly and faster |
| `docker.io` | Docker engine |
| `docker-compose` | Docker Compose |

</details>

<details>
<summary>Script installs (curl)</summary>

| Tool | Description |
|------|-------------|
| Oh My Zsh | Zsh framework |
| Powerlevel10k | Zsh theme |
| zsh-autosuggestions | Fish-like command suggestions |
| zsh-syntax-highlighting | Shell syntax highlighting |
| you-should-use | Reminds you to use your aliases |

</details>

---

## Docker Test

Test the setup script end-to-end inside a container. Assertions run at build time —
a passing build means the full setup completed correctly.

### Linux path (apt)
```bash
docker build --target linux -t linux-config:linux .
```

### macOS path (simulated via Linuxbrew)
```bash
docker build --target macos -t linux-config:macos .
```

### Interactive shell in the tested environment
```bash
docker run --rm -it linux-config:linux zsh
docker run --rm -it linux-config:macos zsh
```

### Manual spot-checks
```bash
# Verify git aliases are in place
docker run --rm linux-config:linux grep "s = status" /home/user/.gitconfig

# Verify zsh plugins were cloned
docker run --rm linux-config:linux ls /home/user/.oh-my-zsh/custom/plugins/

# Verify fzf and ripgrep are on PATH
docker run --rm linux-config:linux sh -c "which fzf && which rg"

# Verify custom git commands are deployed
docker run --rm linux-config:linux ls /home/user/bin/
```

---

## Tools Worth Knowing

<details>
<summary>Not installed — consider adding</summary>

| Tool | Replaces | Description |
|------|----------|-------------|
| `eza` | `ls` | More features — coloring, git-aware |
| `duf` | `df` | Better readability — viewport adjustments, coloring |
| `broot` | `tree` | Better UI, persistent file management and traversal |
| `mcfly` | `ctrl+r` | Smarter shell history search |

</details>
