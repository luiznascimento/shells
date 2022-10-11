#!/bin/bash

#ZIMBRA VARS

LOCALCONFIG="/opt/zimbra/conf/localconfig.xml"
LDAPURL=$(egrep ldap_url ${LOCALCONFIG} -A1 | egrep value | awk -F">" '{ print $2 }' | cut -d\< -f1)
LDAPDN=$(egrep zimbra_ldap_userdn ${LOCALCONFIG} -A1 | egrep value | awk -F">" '{ print $2 }' | cut -d\< -f1)
LDAPPWD=$(egrep zimbra_ldap_password ${LOCALCONFIG} -A1 | egrep value | awk -F">" '{ print $2 }' | cut -d\< -f1)

#DOMAIN VALIDATION

DOM=${1}
VALIDADOM=$(echo ${DOM} | wc -c)

if [[ "$(echo ${VALIDADOM})" -gt "6" ]]
then

echo "ID od COS,Nome do COS,Conta"

for cosname in $(/opt/zimbra/bin/zmprov gac ); 
	do 
	cn=$(/opt/zimbra/common/bin/ldapsearch -H ${LDAPURL} -D "uid=zimbra,cn=admins,cn=zimbra" -w ${LDAPPWD} "(&(objectClass=zimbraCos)(cn=${cosname}))" | egrep '^cn:' | awk '{ print $2 }');
	cosid=$(/opt/zimbra/common/bin/ldapsearch -H ${LDAPURL} -D "uid=zimbra,cn=admins,cn=zimbra" -w ${LDAPPWD} "(&(objectClass=zimbraCos)(cn=${cosname}))" zimbraId | egrep "^zimbraId" | awk '{ print $2 }');
        #echo ${cn} - ${cosid} ; sleep 5 
        for acct in $(/opt/zimbra/common/bin/ldapsearch -H ${LDAPURL} -D "uid=zimbra,cn=admins,cn=zimbra" -w ${LDAPPWD} "(&(objectClass=zimbraAccount)(zimbraCosId=${cosid})(zimbraMailDeliveryAddress=*${DOM}))" zimbraMailDeliveryAddress | egrep zimbraMailDeliveryAddress | awk '{ print $2 }' | egrep @); 
	do 
			echo ${cosid},${cosname},${acct} 
done
done

COSDEFAULTID=$(zmprov gd ${DOM} zimbraDomainDefaultCOSId | awk '{ print $2 }'| egrep -v "name|^$")
COSDEFAULTNAME=$(/opt/zimbra/common/bin/ldapsearch -H ${LDAPURL} -D "uid=zimbra,cn=admins,cn=zimbra" -w ${LDAPPWD} "(&(objectClass=zimbraCos)(zimbraId=${COSDEFAULTID}))" cn | egrep "^cn" | awk '{ print $2 }')
for ACCTCOSDFAULT in $(/opt/zimbra/common/bin/ldapsearch -H ${LDAPURL} -D "uid=zimbra,cn=admins,cn=zimbra" -w ${LDAPPWD} "(&(objectClass=zimbraAccount)(zimbraMailDeliveryAddress=*${DOM})(!(zimbraCosId=*)))" zimbraMailDeliveryAddress | egrep zimbraMailDeliveryAddress | awk '{ print $2 }' | egrep @); 
do 
			echo ${COSDEFAULTID},${COSDEFAULTNAME},${ACCTCOSDFAULT} 
done  

else
	echo ""
	echo "Informe o dominio como parametro."
	echo ""
fi
