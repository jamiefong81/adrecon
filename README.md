My Active Directory inital enumeration script
Runs nmap scan for ldap
Then lists shares with smbclient
Then runs enum4linux
It then checks for ZeroLogon, if it is vulnerable to it
Then just asks you if you want to run kerbrute or not

You may need to edit some of this for it to work
For example my kerbrute is in my /opt so you will see that in the script for your kerbrute directory
