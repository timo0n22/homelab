#!/bin/bash
# base-setup.sh - Base setup for all Orange Pi nodes

set -e

echo "Starting base setup..."

# Update system
apt update && apt upgrade -y

# Install essential packages
apt install -y \
  curl \
  wget \
  git \
  vim \
  htop \
  net-tools \
  software-properties-common \
  apt-transport-https \
  ca-certificates \
  gnupg \
  lsb-release

# Install Docker
if ! command -v docker &> /dev/null; then
  echo "Installing Docker..."
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker
  systemctl start docker
fi

# Disable swap (required for k3s)
swapoff -a
sed -i '/swap/d' /etc/fstab

# Load required kernel modules
cat <<EOF > /etc/modules-load.d/k3s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Set sysctl params
cat <<EOF > /etc/sysctl.d/k3s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# Install zsh and neovim
apt install -y zsh neovim

echo "Base setup complete!"
