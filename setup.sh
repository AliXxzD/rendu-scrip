#!/usr/bin/env bash
#
# Script d’hébergement (IaaS Simulation) pour Ubuntu
# --------------------------------------------------
# Objectifs :
# 1. Mettre à jour le système
# 2. Installer Node.js (et éventuellement Nginx, UFW)
# 3. Déployer une app Node.js (ou un site HTML) dans /var/www/monapp
# 4. (Optionnel) Configurer un service systemd pour lancer l'app au démarrage
# --------------------------------------------------

set -e  # Stoppe le script si une commande échoue

echo "=== [1/5] Mise à jour du système ==="
sudo apt-get update -y
sudo apt-get upgrade -y

echo "=== [2/5] Installation de Node.js, npm, Git ==="
sudo apt-get install -y nodejs npm git

# (Optionnel) Installation de Nginx
# echo "Installation de Nginx..."
# sudo apt-get install -y nginx
# sudo systemctl enable nginx
# sudo systemctl start nginx

# (Optionnel) Pare-feu avec UFW
# echo "Installation de UFW..."
# sudo apt-get install -y ufw
# sudo ufw allow OpenSSH
# sudo ufw allow 80
# sudo ufw allow 443
# sudo ufw allow 3000
# sudo ufw --force enable || true

echo "=== [3/5] Création ou clonage de l'application ==="
APP_DIR="/var/www/monapp"
sudo mkdir -p "$APP_DIR"

# Exemple d’un server.js minimaliste
sudo bash -c "cat > $APP_DIR/server.js" << 'EOF'
const http = require('http');

const PORT = process.env.PORT || 3000;
const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/html; charset=utf-8'});
  res.end('<h1>Bonjour, ceci est mon serveur Node.js sur un VPS IaaS !</h1>');
});

server.listen(PORT, () => {
  console.log(`Serveur démarré sur http://localhost:${PORT}`);
});
EOF

# (Pour un projet réel, on remplacerait par un git clone de votre repo)
# sudo git clone https://github.com/votre-user/votre-projet.git /var/www/monapp
# cd /var/www/monapp
# npm install

echo "=== [4/5] (Optionnel) Configuration d’un service systemd pour Node.js ==="
SERVICE_FILE="/etc/systemd/system/monapp.service"
sudo bash -c "cat > $SERVICE_FILE" << EOF
[Unit]
Description=Mon application Node
After=network.target

[Service]
ExecStart=/usr/bin/node $APP_DIR/server.js
Restart=always
User=nobody
Group=nogroup
Environment=PATH=/usr/bin:/usr/local/bin
WorkingDirectory=$APP_DIR

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable monapp
sudo systemctl start monapp

echo "=== [5/5] Fin du déploiement ==="
echo "Vérifiez l'état du service: sudo systemctl status monapp"
echo "Accédez à l'app via http://[IP-de-votre-serveur]:3000"
