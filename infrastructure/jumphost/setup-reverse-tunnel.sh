#!/bin/bash

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: ./setup-reverse-tunnel.sh <vps-ip> <local-port-on-vps>"
  echo ""
  echo "Examples:"
  echo "  Control Plane:  ./setup-reverse-tunnel.sh vps.example.com 2201"
  echo "  Worker 1:       ./setup-reverse-tunnel.sh vps.example.com 2202"
  echo "  Worker 2:       ./setup-reverse-tunnel.sh vps.example.com 2203"
  exit 1
fi

VPS_HOST="$1"
VPS_PORT="$2"
HOSTNAME=$(hostname)

echo "Настройка reverse SSH tunnel для $HOSTNAME"
echo "VPS: $VPS_HOST"
echo "Порт на VPS: $VPS_PORT"

echo "Генерация SSH ключа для туннеля"

if [ ! -f ~/.ssh/id_ed25519_tunnel ]; then
  ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_tunnel -N "" -C "tunnel-$HOSTNAME"
fi

echo ""
echo "Публичный ключ для добавления на VPS:"
cat ~/.ssh/id_ed25519_tunnel.pub
echo ""
read -p "Добавь этот ключ на VPS и нажми Enter для продолжения..."

echo "Создание systemd service для автозапуска туннеля"

sudo bash -c "cat > /etc/systemd/system/reverse-tunnel.service" << EOF
[Unit]
Description=Reverse SSH Tunnel to Jump Host
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/ssh -N -T -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=accept-new -i /root/.ssh/id_ed25519_tunnel -R $VPS_PORT:localhost:22 tunneluser@$VPS_HOST
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "Запуск туннеля"

sudo systemctl daemon-reload
sudo systemctl enable reverse-tunnel
sudo systemctl start reverse-tunnel

echo ""
echo "Проверка статуса туннеля"
sudo systemctl status reverse-tunnel

echo ""
echo "Туннель настроен"
echo ""
echo "Теперь с VPS можешь подключиться:"
echo "  ssh root@localhost -p $VPS_PORT"
echo ""
