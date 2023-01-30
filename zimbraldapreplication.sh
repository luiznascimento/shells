#!/bin/bash
#
#  @name: zimbraldapreplication.sh
#  #version: 1.0
#  @date: 30/01/2023
#  @author: Luiz Nascimento
#  @contact: anotaai at me.com
#

#Variables:

lsearch="/opt/zimbra/common/bin/ldapsearch"
lsrvs=$(egrep ldap_master_url /opt/zimbra/conf/localconfig.xml -A1 | awk -F"<value>" '{ print $2 }' | awk -F'</value>' '{ print $1 }' | egrep -v '^$' | sed 's/ldap\:\/\///' | sed 's/ldap\:\/\///' | sed 's/:389//g')
userdn=$(grep zimbra_ldap_userdn /opt/zimbra/conf/localconfig.xml -A1 | awk -F"<value>" '{ print $2 }' | awk -F'</value>' '{ print $1 }' | egrep -v '^$' )
lpwd=$(egrep zimbra_ldap_password /opt/zimbra/conf/localconfig.xml -A1 | awk -F"<value>" '{ print $2 }' | awk -F'</value>' '{ print $1 }' | egrep -v '^$')
nsrv=$( echo ${lsrvs} | wc -w)

#Classes

GetObjects() {

i=1

for lsrv in ${lsrvs};
do   
    eval srv${i}=$(${lsearch} -H ldap://${lsrv}:389 -D cn=config -w B5_Wo8f6o '(&(objectClass=zimbraAccount)(zimbraMailDeliveryAddress=*))' zimbraMailDeliveryAddress | egrep "^zimbraMailDeliveryAddress" | awk '{ print $2 }' | wc -l)
    let i++ 
done
}

CountSrvs(){

case ${nsrv} in
     1) echo "Ambiente sem replica cadastrada." ;;
     2) 
        CheckReplication
     ;;    
esac

}

CheckReplication(){

#srv1=$(echo ${srv1}+1 | bc -l )
#echo srv2 ${srv2}

case ${nsrv} in
     2) 
         if [[ "${srv1}" == "${srv2}" ]]
         then
             echo "Replication is OK"
         else
             echo "Replication is Fail"
	 fi
     ;;
     3) 
         if [[ "${srv1}" == "${srv2}" ]] && [[ "${srv2}" == "${srv3}" ]]
         then
             echo "Zimbra Ldap Replication is OK"
             exit 0
         else
             echo "Zimbra Ldap Replication is Fail"
             exit 2
	 fi
     ;;
     4) 
         if [[ "${srv1}" == "${srv2}" ]] && [[ "${srv2}" == "${srv3}" ]] && [[ "${srv1}" == "${srv4}" ]]
         then
             echo "Replication is OK"
         else
             echo "Replication is Fail"
	 fi
     ;;
esac

}

#Run

GetObjects
CountSrvs
