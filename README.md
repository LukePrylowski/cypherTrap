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

Make sure /etc/default/snmptrapd contains the following lines

```
# This file controls the activity of snmptrapd

# snmptrapd control (yes means start daemon).  As of net-snmp version
# 5.0, master agentx support must be enabled in snmpd before snmptrapd
# can be run.  See snmpd.conf(5) for how to do this.
TRAPDRUN=yes

# snmptrapd options (use syslog).
TRAPDOPTS='-One -p /run/snmptrapd.pid -c /etc/snmp/snmptrapd.conf'
```

Restart snmptrapd daemon

To customize network name, please change "wifi" variable.
To customize community string, please change "comm" variable. Keep in mind it must be read-write community.
 
