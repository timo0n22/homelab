#!/bin/bash

set -e

echo "Настройка VPS как jump host"

sudo apt update
sudo apt install -y openssh-server fail2ban

echo "Настройка SSH"

sudo bash -c 'cat >> /etc/ssh/sshd_config' << 'EOF'

# Разрешить TCP forwarding для туннелей
AllowTcpForwarding yes
GatewayPorts yes

# Разрешить держать туннели открытыми
ClientAliveInterval 60
ClientAliveCountMax 3

# Увеличить количество одновременных сессий
MaxSessions 20
MaxStartups 20:30:100

EOF

sudo systemctl restart sshd

echo "Настройка fail2ban"

sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "Создание пользователя для туннелей"

sudo useradd -m -s /bin/bash tunneluser
sudo mkdir -p /home/tunneluser/.ssh
sudo chmod 700 /home/tunneluser/.ssh

echo ""
echo "VPS настроен"
echo ""
echo "Следующие шаги:"
echo "1. Добавь свой публичный SSH ключ в /home/tunneluser/.ssh/authorized_keys"
echo "2. Настрой firewall если нужно"
echo ""
