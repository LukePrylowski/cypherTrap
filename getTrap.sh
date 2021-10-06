#!/bin/bash
 
read host
read ip
comm="public"
vars=
count=1
log="/var/log/cypherTrap"
ip="0.0.0.0"
state=0
mac="0000000000"
type=""
wifi="NetWiFi"
sn=""
net24=""
net50=""
cmtsStateMib=".1.3.6.1.4.1.20858.10.22.2.1.1.1."

function getDate()
{
    now=`date +"%Y-%m-%d %H:%M:%S"`
    echo ${now}
}


function getSn()
{
    sn=`snmpget -Onvq -v2c -c ${comm} $1 1.3.6.1.2.1.69.1.1.4.0 | sed 's/\"//g'`
    echo ${sn}
}

function getType()
{
    type=`snmpget -Oqvn -v2c -c ${comm} $1 .1.3.6.1.2.1.1.1.0 | awk -F 'MODEL: ' '{print($2)}' | sed 's/>>\"//g'`
    echo ${type}
}

while read oid val
do

    count=$[count+1]

    if [[ ${oid} == ".1.3.6.1.2.1.10.127.1.3.3.1.3."* ]]; then

	ip=`echo ${val} | xargs | sed 's/\"//g'`
    fi;

    if [[ ${oid} == ".1.3.6.1.2.1.10.127.1.3.3.1.2."* ]]; then

	mac=`echo ${val} | xargs | awk '{print($1$2$3$4$5$6)}'`
    fi;

    if [[ ${oid} == ${cmtsStatusMib}* ]]; then

        state=`echo ${val} | xargs` 
    fi;
    
done

if [ ${state} -eq 8 ] && [[ ${ip} != "0.0.0.0" ]] && [[ ${mac} != "000000000000" ]]; then

    type=`getType ${ip}`


    if [[ ${type} != "" ]] && [[ -f "/etc/snmp/conf.d/${type}" ]]; then

	now=$(getDate)
        echo "${now}: CM ${ip} ${mac} ${type} getting SN..." >> ${log}	
	sn=`getSn ${ip}`

	. /etc/snmp/conf.d/${type}

	if [ ${#onlineMibs[@]} -gt 0 ]; then

	    now=$(getDate)
    	    echo "${now}: CM ${ip} ${mac} ${type} setting online MIBs" >> ${log}
	    
	    for i in "${!onlineMibs[@]}"; do
	        snmpset -v2c -c ${comm} $ip "${onlineMibs[i]}" "${onlineType[i]}": "${onlineVals[i]}"
	    done
	fi;

	if [ ${#checkMibs[@]} -gt 0 ]; then
	    
	    for i in "${!checkMibs[@]}"; do
		
	        tmp=`snmpget -Onqv -v2c -c ${comm} $ip ${checkMibs[i]} | sed 's/\"//g'`

		if [[ ${tmp} != "" ]] && [[ ${tmp} != ${checkVals[i]} ]]; then

		    now=$(getDate)
    		    echo "${now}: CM ${ip} ${mac} ${type} wrong ${checkMibs[i]}, current: ${tmp}, expected: ${checkVals[i]}" >> ${log}
        	    echo "${now}: CM ${ip} ${mac} ${type} getting SN..." >> ${log}
		    sn=`getSn ${ip}`
    		    echo "${now}: CM ${ip} ${mac} ${type} ${checkMibs[i]} SN: ${sn} is being updated" >> ${log}

		    IFS='|' read -r -a mibs <<< "${setMibs[i]}"
		    IFS='|' read -r -a types <<< "${setType[i]}"
		    IFS='|' read -r -a values <<< "${setVals[i]}"

		    
		    for mib in "${!mibs[@]}"; do
			now=$(getDate)
			echo "${now}: snmpset -v2c -c ${comm} ${ip} ${mibs[mib]} ${types[mib]}: ${values[mib]}" >> ${log}
			snmpset -v2c -c ${comm} ${ip} ${mibs[mib]} ${types[mib]}: ${values[mib]}
		    done;
		else
		    now=$(getDate)
    		    echo "${now}: CM ${ip} ${mac} ${type} ${checkMibs[i]} is OK" >> ${log}
		fi;
	    done;
	fi;	
    else    
        now=$(getDate)
        echo "${now}: CM ${ip} ${mac} ${type} not checking..." >> ${log}
    fi;
fi;

