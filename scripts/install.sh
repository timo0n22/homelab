#!/bin/bash
# install.sh - Main installation script

set -e

echo "Orange Pi Cluster Setup"
echo "======================="
echo ""
echo "Select node type:"
echo "1) Control Plane (1GB node)"
echo "2) Worker Node (4GB node)"
echo "3) SSH & Dotfiles only"
read -p "Enter choice [1-3]: " choice

case $choice in
  1)
    read -p "Enter node name (default: orangepi-1): " NODE_NAME
    NODE_NAME=${NODE_NAME:-orangepi-1}
    bash setup-control-plane.sh $NODE_NAME
    ;;
  2)
    read -p "Enter node name (default: orangepi-worker): " NODE_NAME
    read -p "Enter control plane IP: " SERVER_IP
    read -p "Enter node token: " NODE_TOKEN
    NODE_NAME=${NODE_NAME:-orangepi-worker}
    bash setup-worker.sh $NODE_NAME $SERVER_IP $NODE_TOKEN
    ;;
  3)
    read -p "Enter GitHub username (default: timo0n22): " GITHUB_USER
    GITHUB_USER=${GITHUB_USER:-timo0n22}
    bash setup-ssh-dotfiles.sh $GITHUB_USER
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

echo ""
echo "Setup complete! Reboot recommended."
read -p "Reboot now? (y/n): " REBOOT
if [ "$REBOOT" = "y" ]; then
  reboot
fi
