#!/usr/bin/env bash
set -euo pipefail

# 1. Clone dotfiles repo if not already present
DOTFILES_DIR="$HOME/.cfg"
GIT_URI="git@github.com:robdel12/dotfiles.git"

if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Cloning dotfiles into $DOTFILES_DIR…"
  git clone "$GIT_URI" "$DOTFILES_DIR"
else
  echo "Dotfiles directory already exists at $DOTFILES_DIR"
fi

# 2. Run the bootstrap script
if [ -f "$DOTFILES_DIR/bootstrap.sh" ]; then
  echo "Running bootstrap.sh…"
  bash "$DOTFILES_DIR/bootstrap.sh"
else
  echo "Error: bootstrap.sh not found in $DOTFILES_DIR"
  exit 1
fi
