#!/usr/bin/env bash
set -euo pipefail

############################
# 0. Xcode Command-Line Tools
############################
if ! xcode-select -p >/dev/null; then
  echo "Installing Xcode Command-Line Tools…"
  # The '|| true' prevents the script from exiting if the command fails
  # (e.g., user cancels the GUI prompt, or if tools are already installed
  # but xcode-select -p initially reported them as missing).
  xcode-select --install || true
else
  echo "Xcode CLI already installed."
fi

############################
# 1. Dotfiles update (optional)
############################
DOTFILES_DIR="$HOME/.cfg"
if [ -d "$DOTFILES_DIR" ]; then
  read -p "Dotfiles repo found at $DOTFILES_DIR. Pull latest changes? [y/N] " update_dotfiles
  if [[ "$update_dotfiles" =~ ^[Yy]$ ]]; then
    /usr/bin/git --git-dir="$DOTFILES_DIR/" --work-tree="$HOME" pull
  else
    echo "Skipping dotfiles update."
  fi
fi

############################
# 2. Symlink dotfiles
############################
echo "Setting up dotfiles symlinks..."

# Symlink .zshrc
if [ -f "$DOTFILES_DIR/.zsh/.zshrc" ]; then
  ln -sf "$DOTFILES_DIR/.zsh/.zshrc" "$HOME/.zshrc"
  echo "Linked .zshrc"
fi

# Symlink .gitconfig
if [ -f "$DOTFILES_DIR/.gitconfig.d/.gitconfig" ]; then
  ln -sf "$DOTFILES_DIR/.gitconfig.d/.gitconfig" "$HOME/.gitconfig"
  echo "Linked .gitconfig"
fi

# Symlink .gitignore_global
if [ -f "$DOTFILES_DIR/.gitignore_global" ]; then
  ln -sf "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
  echo "Linked .gitignore_global"
fi

############################
# 3. Homebrew
############################
if ! command -v brew >/dev/null; then
  echo "Installing Homebrew…"
  /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # The Homebrew environment will be configured below, after this block.
else
  echo "Homebrew already installed."
fi

# Ensure Homebrew is available in the current shell and its environment is set up.
# This runs whether Homebrew was just installed or already present.
if [ -d "/opt/homebrew" ]; then # Apple Silicon Macs
  eval "$('/opt/homebrew/bin/brew' shellenv)"
elif [ -d "/usr/local/Homebrew" ]; then # Intel Macs (Homebrew prefix)
  eval "$('/usr/local/bin/brew' shellenv)" # Path to brew executable
fi

echo "Updating Homebrew…"
brew update

############################
# 4. Brew packages & casks
############################
BREW_PKGS=(
  git
  zsh
  rbenv
  nvm
  wget
  jq
  gh
  tree
  pnpm
)

BREW_CASKS=(
  iterm2
  firefox
  emacs
)

echo "Installing brew packages…"
for pkg in "${BREW_PKGS[@]}"; do
  brew list "$pkg" >/dev/null 2>&1 || brew install "$pkg"
done

echo "Installing brew casks…"
for cask in "${BREW_CASKS[@]}"; do
  brew list --cask "$cask" >/dev/null 2>&1 || brew install --cask "$cask"
done

############################
# 5. Emacs config setup (with update prompt)
############################
EMACS_DIR="$HOME/.emacs.d"
EMACS_REPO="git@github.com:Robdel12/.emacs.d.git"
if [ -d "$EMACS_DIR/.git" ]; then
  read -p "Emacs config repo found at $EMACS_DIR. Pull latest changes? [y/N] " update_emacs
  if [[ "$update_emacs" =~ ^[Yy]$ ]]; then
    git -C "$EMACS_DIR" pull
  else
    echo "Skipping Emacs config update."
  fi
elif [ -d "$EMACS_DIR" ]; then
  echo "$EMACS_DIR exists but is not a git repo. Skipping clone."
else
  echo "Cloning Emacs config…"
  git clone "$EMACS_REPO" "$EMACS_DIR"
fi

############################
# 6. Oh My Zsh (unattended)
############################
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh…"
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh already present."
fi

############################
# 7. macOS tweaks
############################
echo "Setting some macOS defaults…"
# faster key repeat
defaults write NSGlobalDomain KeyRepeat -int 1

############################
# 8. Git email setup (prompt if not set)
############################
GIT_EMAIL=$(git config --global user.email || true)
if [ -z "$GIT_EMAIL" ]; then
  read -p "Enter your Git email address: " input_email
  if [ -n "$input_email" ]; then
    git config --global user.email "$input_email"
    echo "Git email set to $input_email"
  else
    echo "No email entered. Skipping Git email setup."
  fi
else
  echo "Git email already set to $GIT_EMAIL"
fi

echo "Bootstrap complete! 🎉"
echo "You may need to restart your terminal (or run 'exec zsh')."
