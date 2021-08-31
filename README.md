cypherTrap

Bash script to cyphering WiFi of DOCSIS cable modem. 
Current model support:
 - TC7230
 
Installing

Clone repository to local machine. 
```
cd /usr/src/
git clone https://github.com/Prohighsolutions/cypherTrap.git

cd cypherTrap
cp getTrap.sh /etc/snmp/

chmod +x /etc/snmp/getTrap.sh

echo "traphandle default /etc/snmp/getTrap.sh" >> /etc/snmp/snmptrapd.conf
```

Restart snmptrapd daemon

To customize network name, please change the "wifi" variable
