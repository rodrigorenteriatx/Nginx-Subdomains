
#!/usr/bin/expect -f

set timeout -1
set user "ubuntu"
set host "54.81.169.112"
#set password "your-password"  # if SSH password is required, consider using SSH keys instead

spawn ssh $user@$host
# expect "*assword:*"
# send "$password\r"

expect "*\$*"
send "sudo certbot register -m rodrigorenteriatx@gmail.com --agree-tos\r"

expect "*Do you agree to the terms?*"
send "n\r"

expect eof
