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
    mkdir -p /tmp/dotfiles

    # install chezmoi
    if [[ ! -f /tmp/dotfiles/chezmoi.tar.gz ]]; then
        wget --no-clobber https://github.com/twpayne/chezmoi/releases/download/v2.10.0/chezmoi_2.10.0_linux_amd64.tar.gz -O /tmp/dotfiles/chezmoi.tar.gz
        (cd /tmp/dotfiles && tar -xzf chezmoi.tar.gz)
    fi
    mkdir -p "$HOME/.local/bin"
    install /tmp/dotfiles/chezmoi "$HOME/.local/bin"
fi

# init and apply chezmoi
mkdir -p "$HOME/Projects"
if [[ ! -d "$HOME/Projects/dotfiles" ]]; then
    git clone https://github.com/alanchrt/dotfiles.git "$HOME/Projects/dotfiles"
fi
printf "$CHEZMOI_DATA\n" > "$HOME/Projects/dotfiles/.chezmoidata.toml"
chezmoi apply --source "$HOME/Projects/dotfiles"

# run ansible playbook
if [[ "$OS" == "Darwin" ]]; then
    ANSIBLE_FORCE_COLOR=true ansible-playbook -v -c local \
        "$HOME/Projects/dotfiles/macos.yml" \
        -i "$HOME/Projects/dotfiles/hosts" \
        --extra-vars "ansible_become_password=$PASSWORD"
elif [[ "$OS" == "Linux" ]]; then
    # clean up chezmoi temp files
    rm -r /tmp/dotfiles

    ANSIBLE_FORCE_COLOR=true ansible-pull -v --checkout master \
        --url https://github.com/alanchrt/dotfiles.git \
        -i hosts --extra-vars "ansible_become_password=$PASSWORD"
fi

if [[ "$OS" == "Darwin" ]]; then
    echo ""
    echo "Manual steps:"
    echo "  1. Install Karabiner-Elements: brew install --cask karabiner-elements"
    echo "  2. Open Karabiner-Elements and grant Accessibility/Input Monitoring permissions"
    echo "  3. Open AeroSpace and grant Accessibility permissions"
fi

echo "Please restart this machine to make sure all groups, extensions, and services reload properly."
