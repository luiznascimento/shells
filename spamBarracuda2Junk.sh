#!/bin/bash
#
# @name: spamBarracuda2Junk.sh 
# @author: Vitor Bento
#

allAccounts=$(ldapsearch -x -H ldap://sepacmbox01.aws.inova.com.br:389 -D uid=zimbra,cn=admins,cn=zimbra -w LK3W3UPw -LLL \
'(&(ObjectClass=zimbraAccount)(zimbraAccountStatus=active))' | grep -i zimbraMailDeliveryAddress | awk '{print$2}');

varNum=0

for conta in $allAccounts
do
   filtros=$(ldapsearch -o ldif-wrap=no -x -H ldap://sepacmbox01.aws.inova.com.br:389 -D uid=zimbra,cn=admins,cn=zimbra -w LK3W3UPw -LLL '(&(ObjectClass=zimbraAccount)(zimbraMailDeliveryAddress='$conta'))' | grep -i zimbraMailSieveScript | awk '{print$2}' | base64 -d | grep '#' | awk '{print$2}')
   for fNomes in $filtros;do
         if [[ $fNomes = "spamTagBarracuda" ]]
            then
               ((varNum+=1))
         fi
   done
   if [[ $varNum -gt 0 ]]
      then
         echo $conta, já possui o filtro de SPAM \do Barracuda ativo
      else
         echo $conta, não possui filtro, criando...
         zmmailbox -z -m $conta afrl "spamTagBarracuda" active any header "subject" contains "[SPAM]" fileinto "Junk"
   fi
   varNum=0
done
