#!/bin/bash

set -e

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

git clone --depth 1 https://github.com/timo0n22/devcontainers-dotfiles.git /tmp/dotfiles
cp -r /tmp/dotfiles ~/.dotfiles
rm -rf /tmp/dotfiles

cd ~/.dotfiles
chmod +x install.sh
./install.sh

mkdir -p ~/.kube

cat >> ~/.zshrc << 'EOF'

alias k="kubectl"
source <(kubectl completion zsh)
complete -F __start_kubectl k
EOF

mkdir -p ~/.config/k9s

cat > ~/.config/k9s/config.yaml << 'EOF'
k9s:
  refreshRate: 2
  maxConnRetry: 5
  enableMouse: true
  ui:
    skin: dark
    logoless: false
EOF
