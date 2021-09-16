#!/bin/bash

echo "Update cypherTrap..."

cp getTrap.sh /etc/snmp/
chmod +x /etc/snmp/getTrap.sh

if -f /etc/snmp/getTrap.sh; then
echo "Update is done..,"
else
echo "Something went wrong. Please run update script once again..."
fi;
