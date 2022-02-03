#!/bin/bash
#
#  @name: blockinternacionalips.sh
#  @author: luiz.nascimento
#

#tmpfile
ATKFILE='/tmp/ip-attackers.txt'

#blockedips
/usr/sbin/iptables -L -n  | egrep DROP | awk '{ print $4 }' > ${ATKFILE}

for ATTACKER in $(for x in $(egrep "SASL LOGIN" /var/log/zimbra.log | cut -d\[ -f3 | cut -d\] -f1 | sort | uniq | awk '{ print $1 }' );
    do 
        echo $x - $(/usr/bin/geoiplookup $x)
done | egrep -v BR | awk '{ print $1 }' ) 
        do 
			if [[ $(egrep -q "^${ATTACKER}$" ${ATKFILE} ; echo $?) -eq '0' ]];
			then
				echo "${ATTACKER} - IP found"
			else
				echo "${ATTACKER} - IP not found"
				/usr/sbin/iptables -A INPUT -p tcp -s ${ATTACKER} -j DROP
			fi
done
