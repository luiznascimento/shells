#!/bin/bash
#
#  @author: luiz nascimento
#  @name: blockinternacionalips.sh
#

GEOI=/usr/bin/geoiplookup
IPT=/usr/sbin/iptables
ATKFILE='/tmp/ip-attackers.txt'

if [[ -e !${GEOI} ]]
then
	exist=1
else
	echo Por favor instale o pacote do Geo IP
    exit 0
fi


$IPT -L -n  | egrep DROP | awk '{ print $4 }' > ${ATKFILE}


for ATTACKER in $(for x in $(egrep "SASL LOGIN" /var/log/zimbra.log | cut -d\[ -f3 | cut -d\] -f1 | sort | uniq | awk '{ print $1 }'| grep -v '64.251.25.26' );
    do 
        echo $x - $($GEOI $x)
done | egrep -v BR | awk '{ print $1 }' ) 
        do 
                        if [[ $(egrep -q "^${ATTACKER}$" ${ATKFILE} ; echo $?) -eq '0' ]];
                        then
                                echo "${ATTACKER} - IP found"
                        else
                                echo "${ATTACKER} - IP not found"
                                $IPT -A INPUT -p tcp -s ${ATTACKER} -j DROP
                        fi
done
