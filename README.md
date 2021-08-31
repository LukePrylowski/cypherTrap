cypherTrap

Bash script to cyphering WiFi of DOCSIS cable modem based on traps sent by CMTS/CCAP
 
Current model support:
 - TC7230
 
Installing
 
```
cd /usr/src/
git clone https://github.com/Prohighsolutions/cypherTrap.git

cd cypherTrap
cp getTrap.sh /etc/snmp/

chmod +x /etc/snmp/getTrap.sh

echo "traphandle default /etc/snmp/getTrap.sh" >> /etc/snmp/snmptrapd.conf

echo "TRAPDRUN=yes" > /etc/default/snmptrapd
echo "TRAPDOPTS='-One -t -n -p /run/snmptrapd.pid -c /etc/snmp/snmptrapd.conf'" >> /etc/default/snmptrapd

systemctl restart snmptrapd

```

To customize network name, please change "wifi" variable.

To customize community string, please change "comm" variable. Keep in mind it must be read-write community.
 
