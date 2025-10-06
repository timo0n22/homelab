#!/bin/bash
# setup-ssh-dotfiles.sh - Setup SSH keys and dotfiles

set -e

GITHUB_USERNAME=${1:-timo0n22}

echo "Setting up SSH and dotfiles..."

# Generate SSH key
if [ ! -f ~/.ssh/id_ed25519 ]; then
  ssh-keygen -t ed25519 -C "$(hostname)" -f ~/.ssh/id_ed25519 -N ""
  echo "SSH key generated. Add this to GitHub:"
  cat ~/.ssh/id_ed25519.pub
  read -p "Press Enter after adding to GitHub..."
fi

# Test GitHub connection
ssh -T git@github.com || true

# Clone dotfiles
if [ ! -d ~/dotfiles ]; then
  git clone git@github.com:$GITHUB_USERNAME/dotfiles.git ~/dotfiles
  cd ~/dotfiles
  
  # Remove interactive parts from install.sh
  sed -i 's/sudo chsh/#sudo chsh/' install.sh
  
  ./install.sh
fi

# Change shell manually
chsh -s /usr/bin/zsh

echo "SSH and dotfiles setup complete!"
echo "Restart shell: exec zsh"
