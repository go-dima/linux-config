# ============================================================
# Stage: linux
# Tests the apt/Linux code path of deploy-config.sh
# ============================================================
FROM debian:bookworm-slim AS linux

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo curl bash git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install git-delta from GitHub releases (not in Debian bookworm apt)
RUN ARCH=$(dpkg --print-architecture) && \
    curl -fsSL "https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_${ARCH}.deb" \
        -o /tmp/delta.deb && \
    dpkg -i /tmp/delta.deb && \
    rm /tmp/delta.deb

RUN useradd -m -s /bin/bash user \
    && echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER user
WORKDIR /home/user

# Note: zsh is in apps.json (brew:false) and installed by deploy-config.sh
# before the OMZ curl install runs — ordering is safe.
COPY --chown=user:user . /home/user/setup
WORKDIR /home/user/setup

RUN bash deploy-config.sh -local
RUN bash test/verify.sh linux

# ============================================================
# Stage: macos
# Tests the brew/macOS code path via Linuxbrew + uname shim
# ============================================================
FROM debian:bookworm-slim AS macos

# Linuxbrew needs build tools, procps (ps), and file
# zsh is pre-installed on real macOS; install it here to simulate that
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo curl bash git build-essential procps file ca-certificates zsh \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash user \
    && echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER user
WORKDIR /home/user

# Install Linuxbrew (non-interactive)
RUN NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Copy repo first — the uname shim lives in test/mock-uname.sh
COPY --chown=user:user . /home/user/setup

# Install uname shim into ~/bin so it shadows /usr/bin/uname
RUN mkdir -p /home/user/bin \
    && cp /home/user/setup/test/mock-uname.sh /home/user/bin/uname \
    && chmod +x /home/user/bin/uname

# ~/bin first so the shim wins; then Linuxbrew
# Docker applies ENV to all subsequent RUN instructions, so deploy-config.sh
# sees `command -v brew` succeed and skips the brew install step.
ENV PATH="/home/user/bin:/home/linuxbrew/.linuxbrew/bin:$PATH"

WORKDIR /home/user/setup

RUN bash deploy-config.sh -local
RUN bash test/verify.sh macos
