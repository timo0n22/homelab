#!/bin/bash
# setup-worker.sh - Setup k3s agent on worker nodes

set -e

NODE_NAME=${1:-orangepi-worker}
SERVER_IP=${2}
NODE_TOKEN=${3}

if [ -z "$SERVER_IP" ] || [ -z "$NODE_TOKEN" ]; then
  echo "Usage: $0 <node-name> <server-ip> <node-token>"
  exit 1
fi

echo "Setting up k3s worker: $NODE_NAME"

# Run base setup
bash base-setup.sh

# Set hostname
hostnamectl set-hostname $NODE_NAME

# Install k3s agent
curl -sfL https://get.k3s.io | K3S_URL=https://$SERVER_IP:6443 \
  K3S_TOKEN=$NODE_TOKEN \
  sh -s - agent \
  --node-name $NODE_NAME

echo "Worker node $NODE_NAME joined the cluster!"
