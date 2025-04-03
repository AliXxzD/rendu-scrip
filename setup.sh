# rendu-scrip#!/usr/bin/env bash

# Script d’hébergement IaaS pour Ubuntu (exemple)
# -----------------------------------------------
# Automatisation du setup : Mise à jour, Node.js, App, Pare-feu, Service systemd

set -e  # Stoppe le script si une commande échoue

echo "=== 1. Mise à jour du système ==="
sudo apt-get update -y
sudo apt-get upgrade -y

echo "=== 2. Installation de Node.js, npm, Git (et éventuellement Nginx, UFW) ==="
sudo apt-get install -y nodejs npm git

# (Optionnel) Installer Nginx si besoin
# sudo apt-get install -y nginx
# sudo systemctl enable nginx
# sudo systemctl start nginx

# (Optionnel) Installer et configurer UFW (pare-feu)
# sudo apt-get install -y ufw
# sudo ufw allow 22       # SSH
# sudo ufw allow 80       # HTTP
# sudo ufw allow 443      # HTTPS
# sudo ufw allow 3000     # Port Node.js
# sudo ufw --force enable || true

echo "=== 3. Création ou clonage de l'application (Node.js) ==="
APP_DIR="/var/www/monapp"
sudo mkdir -p "$APP_DIR"

# Exemple minimal : un server.js qui renvoie un message HTML
sudo bash -c "cat > $APP_DIR/server.js" << 'EOF'
const http = require('http');

const PORT = process.env.PORT || 3000;
const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/html; charset=utf-8'});
  res.end('<h1>Bonjour, ceci est mon serveur Node.js sur un VPS IaaS !</h1>');
});

server.listen(PORT, () => {
  console.log(`Serveur en écoute sur http://localhost:${PORT}`);
});
EOF

# (Si vous avez un vrai projet Git, vous feriez plutôt un git clone)
# sudo git clone https://github.com/utilisateur/monprojet.git /var/www/monapp
# cd /var/www/monapp && npm install

echo "=== 4. Configuration systemd pour lancer l'application au démarrage ==="
SERVICE_FILE="/etc/systemd/system/monapp.service"

sudo bash -c "cat > $SERVICE_FILE" << EOF
[Unit]
Description=Application Node.js (MonApp)
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

echo "=== 5. Activation du service ==="
sudo systemctl daemon-reload
sudo systemctl enable monapp
sudo systemctl start monapp

echo "=== Installation terminée ! ==="
echo "Vérifiez l’état du service : sudo systemctl status monapp"
echo "Votre application écoute sur le port 3000 (IP_du_serveur:3000)."
