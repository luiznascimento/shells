#!/bin/bash
#
#  @name: zacct-less-quota.sh
#  @version: 1.0
#  @date: 03.02.2023
#  @author: Luiz Nascimento
#
#

rm -f /dev/shm/ACCTFROMCOSDEFAULT.txt /dev/shm/ACCT-QUOTA-USED.txt /dev/shm/ACCT-QUOTA-USED.xml /dev/shm/LISTA-DE-MBX.txt

LDAPSEARCH="/opt/zimbra/common/bin/ldapsearch"

LDAPSRV=$(egrep ldap_master_url /opt/zimbra/conf/localconfig.xml -A1 | awk -F"<value>" '{ print $2 }' | awk -F'</value>' '{ print $1 }' | egrep -v '^$' | sed 's/ldap\:\/\///' | sed 's/ldap\:\/\///' | sed 's/:389//g' | head -1)
LDAPPW=$(egrep zimbra_ldap_password /opt/zimbra/conf/localconfig.xml -A1 | awk -F"<value>" '{ print $2 }' | awk -F'</value>' '{ print $1 }' | egrep -v '^$')

GetData(){

COSDEFAULTID=$( ${LDAPSEARCH} -H ldap://${LDAPSRV}:389 -D cn=config -w ${LDAPPW} \"(&(objectClass=zimbraCOS)(name=default))\" zimbraId | egrep zimbraId | egrep -v request | awk '{ print $2 }' )

su -l zimbra -c "zmprov -l gas mailbox" > /dev/shm/LISTA-DE-MBX.txt

${LDAPSEARCH} -H ldap://${LDAPSRV}:389 -D cn=config -w ${LDAPPW} '(&(objectClass=zimbraAccount)(!(zimbraCOSId=*)))' zimbraMailDeliveryAddress | egrep "^zimbraMailDeliveryAddress" | awk '{ print $2 }' > /dev/shm/ACCTWITHOUTCOS.txt 

${LDAPSEARCH} -H ldap://${LDAPSRV}:389 -D cn=config -w ${LDAPPW} \"(&(objectClass=zimbraAccount)(zimbraCOSId=${COSDEFAULTID}))\" zimbraMailDeliveryAddress | egrep "^zimbraMailDeliveryAddress" | awk '{ print $2 }' > /dev/shm/ACCTCOSDEFAULTS.txt

for MBX in $(cat /dev/shm/LISTA-DE-MBX.txt);
do
     # echo "Gerando listas do servidor: ${MBX}"
     su -l zimbra -c "zmsoap -z -A -u "https://${MBX}:7071/service/admin/soap" GetQuotaUsageRequest" >> /dev/shm/ACCT-QUOTA-USED.xml
done

}

SearchQuotaAndUsage(){

echo "Conta,QuotaUsada"

for ACCT in $(cat /dev/shm/ACCTWITHOUTCOS.txt /dev/shm/ACCTCOSDEFAULTS.txt | sort | uniq ); do

  QUOTAUSED=$(echo "scale=2;$(echo $(echo $(egrep "name=\"${ACCT}" /dev/shm/ACCT-QUOTA-USED.xml | awk -F"used=\"" '{ print $2 }' | cut -d\" -f1 )/1024 | bc )/1024 | bc -l)/1024" | bc -l | sed 's/^\./0./')

  QUOTALIMIT=$(echo "scale=2;$(echo $(echo $(egrep "name=\"${ACCT}" /dev/shm/ACCT-QUOTA-USED.xml | awk -F"limit=\"" '{ print $2 }' | cut -d\" -f1 )/1024 | bc )/1024 | bc -l)/1024" | bc -l | sed 's/^\./0./')

if [[ 0 == "${QUOTALIMIT}" ]]
then
     echo "${ACCT},${QUOTAUSED}"
fi

done

}

RNAME=${RANDOM}

GetData  2> /dev/null
SearchQuotaAndUsage 2> /dev/null > /dev/shm/contas-cota-ilimitada.${RNAME}.csv

echo Lista de contas sem cota: /dev/shm/contas-cota-ilimitada.${RNAME}.csv
