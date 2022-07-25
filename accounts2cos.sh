#!/bin/bash
#
#  @name: list Zimbra Accounts with COS Name and COS Id
#  @author: lnascimento
#  @date: 07/25/2022
#

ldap_url=""
ldap_password=""

echo "ID od COS,Nome do COS,Conta"

for cosname in $(/opt/zimbra/bin/zmprov gac ) 
	do 
	cn=$(/opt/zimbra/common/bin/ldapsearch -H ldap://${ldap_url}:389 -D "uid=zimbra,cn=admins,cn=zimbra" -w "${ldap_password}" "(&(objectClass=zimbraCos)(cn=${cosname}))" | egrep '^cn:' | awk '{ print $2 }');
	cosid=$(/opt/zimbra/common/bin/ldapsearch -H ldap://${ldap_url}:389 -D "uid=zimbra,cn=admins,cn=zimbra" -w "${ldap_password}" "(&(objectClass=zimbraCos)(cn=${cosname}))" zimbraId | egrep "^zimbraId" | awk '{ print $2 }');
        #echo ${cn} - ${cosid} ; sleep 5 
        for acct in $(/opt/zimbra/common/bin/ldapsearch -H ldap://${ldap_url}:389 -D "uid=zimbra,cn=admins,cn=zimbra" -w "${ldap_password}" "(&(objectClass=zimbraAccount)(zimbraCosId=${cosid})(zimbraMailDeliveryAddress=*))" zimbraMailDeliveryAddress | egrep zimbraMailDeliveryAddress | awk '{ print $2 }' | egrep @); 
	      do 
			      echo ${cosid},${cosname},${acct} 
	      done  
done
