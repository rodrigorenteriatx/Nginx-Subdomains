#/usr/env/bin bash

USER="centos"
HOST="3.92.68.82"
SRC_DIR="~/nginx-configs"
DEST_DIR="/etc/nginx/sites-available"
ENABLED_DIR="/etc/nginx/sites-enabled"
WEB_ROOT="/var/www"

SITES=("rodrigonginx.com" "test.rodrigonginx.com" "other.rodrigonginx.com")


#Install Nginx and dependencies
# We run "command" to check if the command exists on the remote server, if it doesn't we install it, otherwise we print a message saying it's already installed.

echo "Checking if Nginx is installed on $HOST"
ssh $USER@$HOST << 'ENDSSH'
if ! command -v nginx &> /dev/null
then
    echo "Nginx not found, installing..."
    sudo dnf install -y epel-release
    sudo dnf install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
else
    echo "Nginx is already installed."
fi
ENDSSH

#Create /var/www directory and subdirectories for each site
# We create the /var/www directory and subdirectories for each site using a for loop.
echo "Creating /var/www directory and subdirectories for each site"
ssh $USER@$HOST << 'ENDSSH'
for site in "${SITES[@]}"; do
    sudo mkdir -p $WEB_ROOT/\$site
    sudo chown -R nginx:nginx $WEB_ROOT/\$site
    sudo chmod -R 755 $WEB_ROOT/\$site

    echo "Welcome to $site" | sudo tee /var/www/$site/index.html
done
ENDSSH


#Configure NGINX Server Blocks for each subdomain and the Root domain
# Possibl reaching over the internet to copy conf files

echo "Copying nginx.conf files"
scp $SRC_DIR/*.conf $USER@$HOST:$DEST_DIR

echo Creating symbolic links in the enabled directory

ssh $USER@$HOST << 'ENDSSH'
for file in /etc/nginx/sites-available/*.conf; do
    sudo ln -s $file /etc/nginx/sites-enabled/
done

ceho "Test and Reloading NGINX config"
sudo nginx -t
sudo systemctl reload nginx
ENDSSH



ssh $USER@$HOST << 'ENDSSH'
sudo nginx -t
sudo systemctl reload nginx
ENDSSH