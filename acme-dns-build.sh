#/usr/bin/env bash

#IP IN CONDIG FILE NOT FILLED YET
#
#INSTALL ACME-DNS (SERVER)
#

USER="ubuntu"
HOST="placeholderip"

ssh $USER@$HOST << EOF

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


sudo systemctl enable acme-dns.service
sudo systemctl start acme-dns.service
EOF

#
#INSTALL ACME-DNS-CLIENT (ON SAME MACHINE), AND INSTALL CERTBOT AND PREREQS
#
ssh $USER@$HOST << EOF
git clone https://github.com/acme-dns/acme-dns-client
cd acme-dns-client
go get
go build
mv acme-dns-client /usr/local/bin/acme-dns-client

sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo snap set certbot trust-plugin-with-root=ok
EOF
#REGISTER BUT RUN EXPECT SCRIPT

ssh $USER@$HOST "sudo acme-dns-client register -d rodrigonginx.com -s http://localhost:8080"

#POSSIBLY MAKE A BOTO3 PYTHON SCRIPT THAT REACHES OUT OT DNS PROVIDES(ROUTE 53) FROM MASTER SERVER TO ADD CNAME RECORDS _acme-challenge.yourdomain.tld
# We will need to read output from above command for the record and CNAME value.
#Then we can continue with script

#./expect_certbot.sh

expect << "EOF"
set timeout -1
#set password "your-password"  # if SSH password is required, consider using SSH keys instead

spawn ssh $USER@$HOST
# expect "*assword:*"
# send "$password\r"

# expect "*\$*"
# This line tells Expect to wait until it sees the shell prompt ($), which indicates that the SSH session has successfully logged in and the shell is ready to accept commands.

expect "*\$*"
send "sudo certbot register -m rodrigorenteriatx@gmail.com --agree-tos\r"

expect "*Do you agree to the terms?*"
send "n\r"

expect eof
EOF

#     Ensuring Command Execution: Without the carriage return, the command might just be typed out without being executed. Adding \r ensures that the command is actually submitted to the system for execution.

# Examples of Carriage Return in Action:

#     Sending a Command via Expect:
#         send "sudo apt update\r"
#         In this line, "sudo apt update" is the command you want to run, and \r tells the terminal to execute the command as if you had typed it and pressed Enter.

#MANUAL REGISTRATION
#sudo certbot certonly --manual --preferred-challenges dns --manual-auth-hook 'acme-dns-client' -d *.rodrigonginx.com

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
