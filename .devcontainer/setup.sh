#!/bin/bash

set -e

echo "Настройка DevContainer окружения..."

nix-env -iA nixpkgs.fzf \
             nixpkgs.ripgrep \
             nixpkgs.k9s \
             nixpkgs.kubectl \
             nixpkgs.kubectx \
             nixpkgs.neovim \
             nixpkgs.zsh \
             nixpkgs.git \
             nixpkgs.lazygit \
             nixpkgs.go \
             nixpkgs.gopls \
             nixpkgs.yaml-language-server \
             nixpkgs.marksman

mkdir -p /tmp/.ssh
cp -r ~/.ssh/* /tmp/.ssh/ 2>/dev/null || true
chmod 700 /tmp/.ssh
chmod 600 /tmp/.ssh/* 2>/dev/null || true

grep -v -i "usekeychain\|addkeystoagent" ~/.ssh/config > /tmp/.ssh/config 2>/dev/null || cp ~/.ssh/config /tmp/.ssh/config

ssh-keyscan github.com >> /tmp/.ssh/known_hosts 2>/dev/null

if [ ! -d ~/.dotfiles ]; then
  GIT_SSH_COMMAND="ssh -F /tmp/.ssh/config" \
    git clone --depth 1 git@github.com:timo0n22/devcontainer-dotfiles.git ~/.dotfiles
fi

cd ~/.dotfiles
chmod +x install.sh
./install.sh
