
#!/usr/bin/expect -f

set timeout -1
set user "ubuntu"
set host "3.95.178.103"
#set password "your-password"  # if SSH password is required, consider using SSH keys instead

spawn ssh $user@$host
# expect "*assword:*"
# send "$password\r"

# expect "*\$*"
# This line tells Expect to wait until it sees the shell prompt ($), which indicates that the SSH session has successfully logged in and the shell is ready to accept commands.

expect "*\$*"
send "sudo certbot register -m rodrigorenteriatx@gmail.com --agree-tos\r"

expect "*Do you agree to the terms?*"
send "n\r"

expect eof

#     Ensuring Command Execution: Without the carriage return, the command might just be typed out without being executed. Adding \r ensures that the command is actually submitted to the system for execution.

# Examples of Carriage Return in Action:

#     Sending a Command via Expect:
#         send "sudo apt update\r"
#         In this line, "sudo apt update" is the command you want to run, and \r tells the terminal to execute the command as if you had typed it and pressed Enter.
