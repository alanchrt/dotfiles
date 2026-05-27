# wst-dev — one mega image for all wst stream containers.
#
# Bakes in the user's full toolchain (gh, claude, gt, mise, chezmoi, bun,
# node, jdk, Android SDK), Playwright + Chromium, and the union of system
# deps the user's projects need. wst-container-up swaps project devcontainer
# `image`/`build`/`features` for this image while preserving mounts, ports,
# env, runArgs, and postCreateCommand.
#
# Refresh: ansible-playbook -c local -i ~/Projects/dotfiles/master/hosts ~/Projects/dotfiles/master/local.yml --tags devcontainer -e wst_dev_force_rebuild=true

FROM mcr.microsoft.com/devcontainers/base:bookworm

ARG GH_VERSION=2.62.0
ARG BUN_VERSION=1.3.5
ARG ANDROID_CMDLINE_TOOLS=11076708
ARG NODE_MAJOR=22
ENV DEBIAN_FRONTEND=noninteractive

# Use bash for RUN steps so herestrings / process subs / etc. work.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# 1. apt — gh repo + Adoptium repo + all the system deps we ever need
RUN set -eux; \
    install -d -m 0755 /etc/apt/keyrings; \
    apt-get update; \
    apt-get install -y --no-install-recommends curl ca-certificates gnupg; \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /etc/apt/keyrings/githubcli-archive-keyring.gpg; \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list; \
    curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public \
      | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bookworm main" \
      > /etc/apt/sources.list.d/adoptium.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      gh temurin-17-jdk \
      unzip zip xz-utils tar \
      jq ripgrep fd-find fzf less man-db build-essential pkg-config \
      sqlite3 postgresql-client inotify-tools \
      tmux zsh vim htop ncdu lsd bat age ipython3 diceware \
      libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
      libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
      libgbm1 libpango-1.0-0 libcairo2 libasound2 libatspi2.0-0 \
      libgtk-3-0 \
      libwayland-client0 libwayland-cursor0 libwayland-egl1 \
      libx11-xcb1 libxcb-dri3-0 \
      wl-clipboard xdg-utils; \
    ln -sf /usr/bin/batcat /usr/local/bin/bat; \
    ln -sf /usr/bin/fdfind /usr/local/bin/fd; \
    ln -sf /usr/lib/jvm/temurin-17-jdk-amd64 /usr/lib/jvm/java-17-openjdk; \
    rm -rf /var/lib/apt/lists/*

# 2. Node 22 from NodeSource
RUN set -eux; \
    curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash -; \
    apt-get install -y --no-install-recommends nodejs; \
    rm -rf /var/lib/apt/lists/*; \
    npm config set fund false; \
    npm config set update-notifier false

# 3. mise + chezmoi (system-wide)
RUN set -eux; \
    curl -fsSL https://mise.run | sh; \
    install -m 0755 /root/.local/bin/mise /usr/local/bin/mise; \
    rm -rf /root/.local; \
    curl -fsSL https://get.chezmoi.io | sh -s -- -b /usr/local/bin

# 4. Bun (pinned)
RUN set -eux; \
    curl -fsSL https://bun.sh/install \
      | BUN_INSTALL=/opt/bun bash -s "bun-v${BUN_VERSION}"; \
    ln -s /opt/bun/bin/bun /usr/local/bin/bun; \
    ln -s /opt/bun/bin/bunx /usr/local/bin/bunx

# 4b. Terminal extras from GitHub releases (the bits of roles/terminal/linux.yml
# that aren't in Debian apt). Static binaries → /usr/local/bin. Tarball
# layouts vary (flat / inside a versioned subdir) — find by name to be safe.
ARG LF_VERSION=r33
ARG DOGGO_VERSION=1.0.5
ARG DUST_VERSION=1.1.1
ARG DIFFTASTIC_VERSION=0.61.0
ARG DELTA_VERSION=0.19.2
ARG LAZYGIT_VERSION=0.62.0
RUN set -eux; \
    tmp=$(mktemp -d); \
    # format: <install-name>|<binary-name-inside-tarball>|<url>
    for spec in \
      "lf|lf|https://github.com/gokcehan/lf/releases/download/${LF_VERSION}/lf-linux-amd64.tar.gz" \
      "doggo|doggo|https://github.com/mr-karan/doggo/releases/download/v${DOGGO_VERSION}/doggo_${DOGGO_VERSION}_Linux_x86_64.tar.gz" \
      "dust|dust|https://github.com/bootandy/dust/releases/download/v${DUST_VERSION}/dust-v${DUST_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
      "difft|difft|https://github.com/Wilfred/difftastic/releases/download/${DIFFTASTIC_VERSION}/difft-x86_64-unknown-linux-gnu.tar.gz" \
      "delta|delta|https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
      "lazygit|lazygit|https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
    ; do \
      IFS='|' read -r name bin url <<< "$spec"; \
      d="$tmp/$name"; mkdir -p "$d"; \
      curl -fsSL "$url" | tar -xz -C "$d"; \
      found=$(find "$d" -name "$bin" -type f 2>/dev/null | head -1); \
      [ -n "$found" ] || { echo "$name: binary not found in tarball" >&2; exit 1; }; \
      install -m 0755 "$found" "/usr/local/bin/$name"; \
    done; \
    rm -rf "$tmp"

# 5. Android SDK (matches duramata's pinned cmdline-tools).
# `yes | sdkmanager --licenses` triggers SIGPIPE when sdkmanager exits early;
# with `set -o pipefail` enabled globally that becomes a build failure. Turn
# pipefail off just for this step.
ENV ANDROID_HOME=/opt/android-sdk ANDROID_SDK_ROOT=/opt/android-sdk
RUN set -eux; \
    set +o pipefail; \
    mkdir -p $ANDROID_HOME/cmdline-tools; \
    cd $ANDROID_HOME/cmdline-tools; \
    curl -fsSL "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS}_latest.zip" -o tools.zip; \
    unzip -q tools.zip; \
    mv cmdline-tools latest; \
    rm tools.zip; \
    yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses >/dev/null; \
    $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
      "platform-tools" "platforms;android-34" "build-tools;34.0.0" "emulator"; \
    chown -R vscode:vscode $ANDROID_HOME

# 6. Global npm tools
RUN npm install -g --no-fund --no-audit \
      @withgraphite/graphite-cli \
      @playwright/mcp \
      @devcontainers/cli

# 7. Playwright Chromium (system-wide; readable by any container user)
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/playwright-browsers
RUN set -eux; \
    npx -y playwright install chromium; \
    chmod -R a+rx /opt/playwright-browsers

# 8. Claude Code — install as the runtime user (vscode), mirroring the host
# ansible role. Installer puts the launcher at ~/.local/bin/claude and the
# versioned files at ~/.local/share/claude/. NOTE: ~/.claude is bind-mounted
# at runtime, so installing INTO that path would be hidden by the mount.
# ~/.local/share/claude is NOT bind-mounted, so the install survives.
USER vscode
RUN curl -fsSL https://claude.ai/install.sh | bash
USER root
RUN ln -sf /home/vscode/.local/bin/claude /usr/local/bin/claude \
 && test -x /usr/local/bin/claude

# 8b. Shell environment — powerlevel10k, zsh plugins, tmux tpm.
# devcontainers/base ships oh-my-zsh already at ~/.oh-my-zsh — only add the
# custom theme + plugins + tpm. Each clone is idempotent so the layer is
# safe to re-run on top of an image that already has any of these.
USER vscode
RUN set -eux; \
    OMZ_CUSTOM="$HOME/.oh-my-zsh/custom"; \
    [ -d "$OMZ_CUSTOM/themes/powerlevel10k" ] || \
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "$OMZ_CUSTOM/themes/powerlevel10k"; \
    for plugin in zsh-completions zsh-syntax-highlighting zsh-history-substring-search; do \
      [ -d "$OMZ_CUSTOM/plugins/$plugin" ] || \
        git clone --depth=1 "https://github.com/zsh-users/${plugin}.git" \
          "$OMZ_CUSTOM/plugins/${plugin}"; \
    done; \
    mkdir -p "$HOME/.tmux/plugins"; \
    [ -d "$HOME/.tmux/plugins/tpm" ] || \
      git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"; \
    mkdir -p "$HOME/.vim/pack/themes/start"; \
    [ -d "$HOME/.vim/pack/themes/start/dracula" ] || \
      git clone --depth=1 https://github.com/dracula/vim.git \
        "$HOME/.vim/pack/themes/start/dracula"
USER root

# 9. Boot setup script + metadata
# wst-container-up wires this into the project's devcontainer.json as the
# `postStartCommand` — runs after devcontainer-cli's docker-init.sh on every
# container boot. Don't set ENTRYPOINT here; the base image's init script is
# required for correct uid mapping, ssh-init, etc.
COPY wst-dev-entrypoint.sh /usr/local/bin/wst-dev-entrypoint
RUN set -eux; \
    chmod +x /usr/local/bin/wst-dev-entrypoint; \
    mkdir -p /etc/wst; \
    printf '{"built_at":"%s","node":"%s","gh":"%s","bun":"%s","jdk":"17"}\n' \
      "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$(node -v)" "$GH_VERSION" "$BUN_VERSION" \
      > /etc/wst/wst-dev.json

LABEL org.wst.dev.version="1"
