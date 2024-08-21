#!/usr/bin/env bash

USER="ubuntu"  # Adjusted default user for Ubuntu AMI; change as needed
HOST="54.85.250.133"
SRC_DIR="./nginx-configs"
DEST_DIR="/etc/nginx/conf.d"
WEB_ROOT="/var/www"

SITES=("rodrigonginx.com" "test.rodrigonginx.com" "other.rodrigonginx.com")

# First ssh session and add key to agent
# Locally add the created key
ssh -i ~/.ssh/my_keys/id_ed25519 $USER@$HOST 'echo "Key added to agent"'
ssh-add ~/.ssh/my_keys/id_ed25519

# Update package lists and install Nginx and dependencies
echo "Checking if Nginx is installed on $HOST"
ssh $USER@$HOST << 'ENDSSH'
if ! command -v nginx &> /dev/null
then
    echo "Nginx not found, installing..."
    sudo apt update
    sudo apt install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
else
    echo "Nginx is already installed."
fi
ENDSSH

# Create /var/www directory and subdirectories for each site
echo "Creating /var/www directory and subdirectories for each site"
ssh $USER@$HOST << ENDSSH
for site in ${SITES[@]}; do
    sudo mkdir -p $WEB_ROOT/\$site
    sudo chown -R www-data:www-data $WEB_ROOT/\$site  # Adjusted to Ubuntu's default web server user and group
    sudo chmod -R 755 $WEB_ROOT/\$site

    echo "Welcome to \$site" | sudo tee $WEB_ROOT/\$site/index.html
done
ENDSSH

# Copy NGINX Server Blocks configuration files
echo "Copying nginx.conf files"
scp $SRC_DIR/*.conf $USER@$HOST:~
ssh $USER@$HOST << EOF
sudo mv /home/$USER/*.conf $DEST_DIR
sudo nginx -t
sudo systemctl reload nginx
EOF

# Set up for the running of the acme-dns-client script
echo $SRC_DIR/config.cfg
echo $USER@$HOST:~
scp ${SRC_DIR}/config.cfg $USER@$HOST:~
ssh $USER@$HOST << EOF

sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version
EOF

# Uncomment the following line if you have an acme-dns-client script that you want to run
# ssh $USER@$HOST 'chmod +x acme-dns-client.sh && ./acme-dns-client.sh'
