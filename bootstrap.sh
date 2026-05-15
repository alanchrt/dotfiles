#!/bin/bash -i

set -e

OS="$(uname -s)"

# collect user info
echo -n "Your name: "
read NAME
echo -n "Your email: "
read EMAIL
echo -n "Your rbw (Bitwarden) email: "
read RBW_EMAIL

PANEL_COLOR=""
CHEZMOI_DATA="name = \"$NAME\"\nemail = \"$EMAIL\"\nrbw_email = \"$RBW_EMAIL\""

echo -n "[sudo] password for $USER: "
read -s PASSWORD
echo

if [[ "$OS" == "Linux" ]]; then
    echo -n "Top bar color override (leave blank for Dracula default, e.g. rgba(20, 20, 30, 0.98)): "
    # a nice alternative: rgba(118, 0, 100, 0.95)
    read PANEL_COLOR
fi

CHEZMOI_DATA="$CHEZMOI_DATA\npanel_color = \"$PANEL_COLOR\""

# install base deps
if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew &>/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    brew install ansible chezmoi
elif [[ "$OS" == "Linux" ]]; then
    echo "$PASSWORD" | sudo -S dnf install -y ansible python3-psutil
    mkdir -p "$HOME/.local/bin"

    # install chezmoi (latest release; `chezmoi upgrade` can refresh later)
    if ! command -v chezmoi >/dev/null 2>&1; then
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    fi
fi

# init and apply chezmoi
# Layout matches the wst workstream convention: ~/Projects/<project>/<canonical>/
# Here the canonical dir is `master` (matches the default branch).
DOTFILES_DIR="$HOME/Projects/dotfiles/master"
mkdir -p "$HOME/Projects/dotfiles"
if [[ ! -d "$DOTFILES_DIR" ]]; then
    git clone https://github.com/alanchrt/dotfiles.git "$DOTFILES_DIR"
fi
printf "$CHEZMOI_DATA\n" > "$DOTFILES_DIR/.chezmoidata.toml"
chezmoi apply --source "$DOTFILES_DIR"

# run ansible playbook
if [[ "$OS" == "Darwin" ]]; then
    ANSIBLE_FORCE_COLOR=true ansible-playbook -v -c local \
        "$DOTFILES_DIR/macos.yml" \
        -i "$DOTFILES_DIR/hosts" \
        --extra-vars "ansible_become_password=$PASSWORD"
elif [[ "$OS" == "Linux" ]]; then
    ANSIBLE_FORCE_COLOR=true ansible-pull -v --checkout master \
        --url https://github.com/alanchrt/dotfiles.git \
        -i hosts --extra-vars "ansible_become_password=$PASSWORD"
fi

if [[ "$OS" == "Darwin" ]]; then
    echo ""
    echo "Manual steps:"
    echo "  1. Install Karabiner-Elements: brew install --cask karabiner-elements"
    echo "  2. Open Karabiner-Elements and grant Accessibility/Input Monitoring permissions"
    echo "  3. Open Rectangle and grant Accessibility permissions"
fi

echo "Please restart this machine to make sure all groups, extensions, and services reload properly."
