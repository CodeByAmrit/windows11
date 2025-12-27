#!/usr/bin/env bash
set -e

echo "🚀 Secure Ubuntu DevOps Setup Started"

# =============================
# 0. Must be run as sudo
# =============================
if [[ $EUID -ne 0 ]]; then
  echo "❌ Run as root: sudo bash secure-dev-setup.sh"
  exit 1
fi

USERNAME=$(logname)
USER_HOME="/home/$USERNAME"

# =============================
# 1. System Update
# =============================
echo "📦 Updating system..."
apt update && apt upgrade -y

# =============================
# 2. Essential Packages
# =============================
echo "🧰 Installing essentials..."
apt install -y \
  build-essential \
  ca-certificates \
  curl \
  wget \
  unzip \
  git \
  htop \
  nano \
  vim \
  gnupg \
  lsb-release \
  software-properties-common \
  apt-transport-https \
  tree

# =============================
# 3. Firewall (UFW)
# =============================
echo "🔥 Configuring firewall..."
apt install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw --force enable

# =============================
# 4. SSH Hardening
# =============================
echo "🔐 Hardening SSH..."
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
systemctl restart ssh

# =============================
# 5. Fail2Ban
# =============================
echo "🛡 Installing Fail2Ban..."
apt install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# =============================
# 6. Automatic Security Updates
# =============================
echo "🔄 Enabling unattended upgrades..."
apt install -y unattended-upgrades
dpkg-reconfigure -f noninteractive unattended-upgrades

# =============================
# 7. Docker
# =============================
echo "🐳 Installing Docker..."
curl -fsSL https://get.docker.com | sh
usermod -aG docker $USERNAME
systemctl enable docker

# =============================
# 8. Node.js (LTS)
# =============================
echo "🟢 Installing Node.js LTS..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt install -y nodejs
npm install -g npm pm2 yarn

# =============================
# 9. VS Code
# =============================
echo "🧠 Installing VS Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/vscode.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/code stable main" \
  > /etc/apt/sources.list.d/vscode.list
apt update
apt install -y code

# =============================
# 10. Zsh + Oh My Zsh
# =============================
echo "🐚 Installing Zsh..."
apt install -y zsh
chsh -s $(which zsh) $USERNAME

sudo -u $USERNAME bash <<EOF
if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
EOF

# =============================
# 11. Secure .env Handling
# =============================
echo "🔒 Securing .env files..."

cat << 'EOF' > /usr/local/bin/env-lock
#!/bin/bash
find . -name ".env*" -type f -exec chmod 600 {} \;
EOF

chmod +x /usr/local/bin/env-lock

# =============================
# 12. Git Security Defaults
# =============================
echo "🔐 Configuring Git..."
sudo -u $USERNAME git config --global core.autocrlf input
sudo -u $USERNAME git config --global pull.rebase true
sudo -u $USERNAME git config --global init.defaultBranch main

# =============================
# 13. SSH Key Folder Permissions
# =============================
mkdir -p $USER_HOME/.ssh
chmod 700 $USER_HOME/.ssh
chown -R $USERNAME:$USERNAME $USER_HOME/.ssh

# =============================
# 14. Final
# =============================
echo "✅ Setup Complete!"
echo "➡ Logout & login again to apply Docker + Zsh"
echo "➡ Run: env-lock inside projects to protect .env files"
