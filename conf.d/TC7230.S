##################################
# Configuration file for CM TC7230
##################################

####
# MIBs to set everytime CM is online
####

onlineMibs=()
onlineVals=()
onlineType=()

####
# MIBs to check and set when CM is online
####

# check MIBs
checkMibs=( ".1.3.6.1.4.1.2863.205.30.1.1.2.1.1.3.32" ".1.3.6.1.4.1.2863.205.30.1.1.2.1.1.3.112" )
checkVals=( ${wifi}_${mac: -4} ${wifi}_5G_${mac: -4} )

# set MIBs
setMibs=( ".1.3.6.1.4.1.2863.205.30.1.1.2.1.1.2.32|.1.3.6.1.4.1.2863.205.30.1.1.2.1.1.3.32|.1.3.6.1.4.1.2863.205.30.1.1.2.1.1.4.32|.1.3.6.1.4.1.2863.205.30.1.1.2.3.4.1.2.32|.1.3.6.1.4.1.2863.205.30.1.1.1.1.0" ".1.3.6.1.4.1.2863.205.30.1.1.2.1.1.2.112|.1.3.6.1.4.1.2863.205.30.1.1.2.1.1.3.112|.1.3.6.1.4.1.2863.205.30.1.1.2.1.1.4.112|.1.3.6.1.4.1.2863.205.30.1.1.2.3.4.1.2.112|.1.3.6.1.4.1.2863.205.30.1.1.1.1.0" )
setVals=( "1|${wifi}_5G_${mac: -4}|7|${sn}|1" "1|${wifi}_5G_${mac: -4}|7|${sn}|1" )
setType=( "i|s|i|s|i" "i|s|i|s|i" )
