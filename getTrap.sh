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

    type=`snmpget -v2c -c ${comm} -Onqv $ip .1.3.6.1.2.1.1.1.0 | awk -F 'MODEL: ' '{print($2)}' | sed 's/>>\"//g'`

    path=`pwd`

    if [[ ${type} != "" ]] && [ -f ${path}/conf.d/${type} ]; then

	. ${path}/conf.d/${type}

	if [ ${#setMibs[@]} -gt 0 ]; then

    	    echo "${now}: CM ${ip} ${mac} ${type} setting online MIBs" >> ${log}
	    
	    for i in "${!onlineMibs[@]}"; do
	        snmpset -v2c -c ${comm} $ip "${onlineMibs[i]}" "${onlineType[i]}": "${onlineVals[i]}"
	    done
	fi;

	if [ ${#checkMibs[@]} -gt 0 ]; then
	    
	    for i in "${!checkMibs[@]}"; do
		
	        tmp=`snmpget -Onqv -v2c -c ${comm} $ip ${checkMibs[i]} | sed 's/\"//g'`

		if [[ ${tmp} != "" ]] && [[ ${tmp} != ${checkVals[i]} ]]; then

		    IFS="|"

		    mibs=${checkMibs[i]}
		    types=${checkType[i]}
		    values=${checkVals[i]}

		    now=$(getDate)
    		    echo "${now}: CM ${ip} ${mac} ${type} wrong ${checkMibs[i]}, current: ${tmp}, expected: ${checkVals[i]}" >> ${log}
        	    echo "${now}: CM ${ip} ${mac} ${type} getting SN..." >> ${log}
		    getSn ${ip}
    		    echo "${now}: CM ${ip} ${mac} ${type} ${checkMibs[i]} is being updated" >> ${log}

		    
		    for mib in "${!mibss[@]}"; do
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
