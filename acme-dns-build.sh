#/usr/bin/env bash

#IP IN CONDIG FILE NOT FILLED YET
#
#INSTALL ACME-DNS (SERVER)
#

git clone https://github.com/joohoi/acme-dns
cd acme-dns
export GOPATH=/tmp/acme-dns
go build

sudo mv acme-dns /usr/local/bin
sudo mkdir /etc/acme-dns/
sudo mv ~/config.cfg /etc/acme-dns/config.cfg
mv ~/go/bin/acme-dns /usr/local/bin/acme-dns

#Create systemd system account for acme-dns, gecos is basically comments
sudo adduser --system --gecos "acme-dns Service" --disabled-password --group --home /var/lib/acme-dns acme-dns
sudo mv acme-dns.service /etc/systemd/system/acme-dns.service

# sudo restorecon -Rv /etc/systemd/system/
# chown acme-dns:acme-dns /etc/systemd/system/acme-dns.service

sudo systemctl enable acme-dns.service
sudo systemctl start acme-dns.service

cd ~

#
#INSTALL ACME-DNS-CLIENT (ON SAME MACHINE)
#
git clone https://github.com/acme-dns/acme-dns-client
cd acme-dns-client
go get
go build
mv acme-dns-client /usr/local/bin/acme-dns-client
cd ~

#RUN THE CLIENT
sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo snap set certbot trust-plugin-with-root=ok

#REGISTER BUT RUN EXPECT SCRIPT


#Guided creaton but we will try to script
sudo acme-dns-client register -d rodrigonginx.com -s http://localhost:8080

sudo certbot certonly --manual --preferred-challenges dns --manual-auth-hook 'acme-dns-client' -d *.rodrigonginx.com

#Crontaab for renewal via dns-01 challenge
echo "0 */12 * * *  certbot renew --manual --test-cert --preferred-challenges dns --manual-auth-hook 'acme-dns-client'" | tee -a certcron
crontab certcron

# * * * * * /path/to/command
# - - - - -
# | | | | |
# | | | | +---- Day of the week (0 - 7) (Sunday is both 0 and 7)
# | | | +------ Month (1 - 12)
# | | +-------- Day of the month (1 - 31)
# | +---------- Hour (0 - 23)
# +------------ Minute (0 - 59)
