# Dotfiles Setup

This repository contains my personal macOS dotfiles and configuration scripts.

## Usage

1. **Bootstrap a new machine:**

```zsh
curl -fsSL https://raw.githubusercontent.com/robdel12/dotfiles/main/install.sh | bash
```

2. **If already cloned:**

```zsh
cd ~/Developer/dotfiles
bash install.sh
```

3. **To update the environment later:**

Just re-run:

```zsh
bash ~/Developer/dotfiles/bootstrap.sh
```

Follow the prompts to update dotfiles, Emacs config, and re-apply system setup.

---

- Zsh configs are in `.zsh/`
- Git configs are in `.gitconfig.d/`
- Emacs config is managed from a separate repo and auto-cloned to `~/.emacs.d`
