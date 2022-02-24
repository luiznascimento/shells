#!/bin/bash
#
# @name: check_primarymessage
# @author: luiz.nascimento
# @date: 19.05.2021.1020.0030
# @details: check used space from primary disk of zimbra.
#
#

Usage(){

cat << EOF

check_primarymessage - Monitoring free space from active primary message.

Usage:

$0 warning_percent critical_percent

Example:

$0 70 80

EOF

}

warn=$1
crit=$2

if [[ -z ${warn} ]] || [[ -z ${crit} ]]
then
   Usage
   exit 2
fi

primaryMessage=$(/opt/zimbra/bin/zmvolume -l | egrep primaryMessage -C3 | egrep "current: true" -B5 | egrep "path:" | awk '{ print $2 }')
perCentUsed=$(df -h ${primaryMessage} | awk '{ print $5}' | egrep '[0-9]' | cut -d\% -f1)

#echo pm $primaryMessage
#echo pu $perCentUsed

if [[ ${perCentUsed} > ${warn} ]] && [[ ${perCentUsed} > ${crit}  ]]
then
    echo "CRITICAL - Zimbra Primary Message: ${primaryMessage} is ${perCentUsed}%"
    exit 2
else
    if [[ ${perCentUsed} > ${warn} ]] && [[ ${perCentUsed} < ${crit}  ]]
    then 
        echo "WARNING - Zimbra Primary Message: ${primaryMessage} is ${perCentUsed}%"
	exit 1
    else
	echo "OK - Zimbra Primary Message: ${primaryMessage} is ${perCentUsed}%"
	exit 0
    fi
fi
