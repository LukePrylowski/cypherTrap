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

function getDate()
{
    now=`date +"%Y-%m-%d %H:%M:%S"`
    echo ${now}
}

function setWiFi()
{
    local i=$1
    local n=$2
    local nt=$3
    local p=$4
    local t=$5

    if [[ $t == "TC7230" ]]; then

	snmpset -v2c -c ${comm} ${i} .1.3.6.1.4.1.2863.205.30.1.1.2.1.1.2.${n} i: 1
	snmpset -v2c -c ${comm} ${i} .1.3.6.1.4.1.2863.205.30.1.1.2.1.1.3.${n} s: "${nt}"
        snmpset -v2c -c ${comm} ${i} .1.3.6.1.4.1.2863.205.30.1.1.2.1.1.4.${n} i:7
	snmpset -v2c -c ${comm} ${i} .1.3.6.1.4.1.2863.205.30.1.1.2.3.4.1.2.${n} s: "${p}"
        snmpset -v2c -c ${comm} ${i} .1.3.6.1.4.1.2863.205.10.1.30.100 i: 1
    fi;
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

    if [[ ${oid} == ".1.3.6.1.4.1.20858.10.22.2.1.1.1."* ]]; then

        state=`echo ${val} | xargs` 
    fi;
    
done

if [ ${state} -eq 8 ] && [[ ${ip} != "0.0.0.0" ]] && [[ ${mac} != "000000000000" ]]; then
    type=`snmpget -v2c -c ${comm} -Onqv $ip .1.3.6.1.2.1.1.1.0 | awk -F 'MODEL: ' '{print($2)}' | sed 's/>>\"//g'`


    if [[ ${type} != "" ]]; then

	if [[ ${type} == "TC7230" ]]; then

	    net24=`snmpget -Onqv -v2c -c ${comm} $ip .1.3.6.1.4.1.2863.205.30.1.1.2.1.1.3.32 | sed 's/\"//g'`
	    net50=`snmpget -Onqv -v2c -c ${comm} $ip .1.3.6.1.4.1.2863.205.30.1.1.2.1.1.3.112 | sed 's/\"//g'`
	else
	    
	    net24=""
	    net50=""
	fi;
    
	if [[ ${net24} != "" ]]; then

	    if [[ ${net24} != ${wifi}_${mac: -4} ]]; then

		now=$(getDate)
    		echo "${now}: CM ${ip} ${mac} ${type} wrong WiFi 2.4GHz ${net24}" >> ${log}
        	echo "${now}: CM ${ip} ${mac} ${type} getting SN..." >> ${log}
		getSn ${ip}
    		echo "${now}: CM ${ip} ${mac} ${type} Wifi 2.4GHz is being updated" >> ${log}
    		setWiFi ${ip} 32 "${wifi}_${mac: -4}" "${sn}" "${type}"
	    else

    		echo "${now}: CM ${ip} ${mac} ${type} WiFi 2.4GHz is OK" >> ${log}
	    fi;
	fi;
	
	if [[ ${net50} != "" ]]; then

	    if [[ ${net50} != ${wifi}_5G_${mac: -4} ]]; then

		now=$(getDate)
    		echo "${now}: CM ${ip} ${mac} ${type} wrong WiFi 5GHz ${net50}" >> ${log}
    		echo "${now}: CM ${ip} ${mac} ${type} getting SN..." >> ${log}
    		getSn ${ip}
    		echo "${now}: CM ${ip} ${mac} ${type} Wifi 5GHz is being updated" >> ${log}
    		setWiFi ${ip} 112 "${wifi}_5G_${mac: -4}" "${sn}" "${type}"
	    else

    		echo "${now}: CM ${ip} ${mac} ${type} WiFi 5GHz is OK" >> ${log}
	    fi;
	fi;
	
	if [[ ${net24} == "" ]] && [[ ${net50} == "" ]]; then

	    now=$(getDate)
	    echo "${now}: CM ${ip} ${mac} ${type} not checking..." >> ${log}
	fi;
    fi;
fi;


