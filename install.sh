#!/usr/bin/env bash
set -euo pipefail

# 1. Clone dotfiles as a bare repo if not already present
DOTFILES_DIR="$HOME/.cfg"
GIT_URI="git@github.com:robdel12/dotfiles.git"

if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Cloning dotfiles bare repo into $DOTFILES_DIR…"
  git clone --bare "$GIT_URI" "$DOTFILES_DIR"
fi

alias config="/usr/bin/git --git-dir=$DOTFILES_DIR/ --work-tree=$HOME"

# avoid showing untracked files
config config --local status.showUntrackedFiles no

echo "Checking out dotfiles…"
config checkout || {
  echo "Backing up pre-existing dotfiles in ~ to ~/.cfg-backup"
  mkdir -p ~/.cfg-backup
  config checkout 2>&1 \
    | grep -E "\\s+\\." \
    | awk '{print $1}' \
    | xargs -I{} mv "$HOME/{}" ~/.cfg-backup/{}
  config checkout
}

# 2. Run the bootstrap script from the checked-out dotfiles
if [ -f "$HOME/bootstrap.sh" ]; then
  echo "Running bootstrap.sh…"
  bash "$HOME/bootstrap.sh"
else
  echo "Error: bootstrap.sh not found in home directory after checkout."
  exit 1
fi
