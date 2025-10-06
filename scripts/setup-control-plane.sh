#!/bin/bash
# setup-control-plane.sh - Setup k3s server on 1GB node

set -e

NODE_NAME=${1:-orangepi-1}
NODE_IP=${2:-$(hostname -I | awk '{print $1}')}

echo "Setting up k3s control plane on $NODE_NAME ($NODE_IP)..."

# Run base setup
bash base-setup.sh

# Set hostname
hostnamectl set-hostname $NODE_NAME

# Install k3s server (lightweight config for 1GB RAM)
curl -sfL https://get.k3s.io | sh -s - server \
  --disable traefik \
  --disable servicelb \
  --disable metrics-server \
  --write-kubeconfig-mode 644 \
  --node-name $NODE_NAME \
  --node-ip $NODE_IP \
  --flannel-backend=vxlan \
  --kube-apiserver-arg="--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname"

# Wait for k3s to be ready
echo "Waiting for k3s to start..."
sleep 10

# Get node token for workers
NODE_TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)

echo "====================================="
echo "Control plane setup complete!"
echo "Node token for workers:"
echo "$NODE_TOKEN"
echo "====================================="
echo "Save this token for worker nodes setup"

# Create namespace for tupochat
kubectl create namespace tupochat || true

echo "To join worker nodes, run:"
echo "bash setup-worker.sh <node-name> $NODE_IP <token>"
