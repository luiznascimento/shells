#!/bin/bash

domain=$1

validation=$(echo ${domain} | egrep '[a-zA-Z]' | wc -l)

if [[ ${validation} == 1 ]]; then
    
echo '***Checando se o domínio existe e em qual tabela do banco'
echo ''
for t in $(for x in $(mysql -N -h xxxxxxxxxx -D rotas -u rotas -pXXXXXXXX -e "SHOW TABLES" | egrep -v alias) ; do echo $x ;done); do echo $t ;  mysql -N -h XXXXXXXXX -D rotas -u rotas -pXXXXXXXXX -e "SELECT * FROM ${t} WHERE dominio='${domain}'" ; done
echo ''
echo '***Checando se o domínio existe no arquivo de rotas (/etc/inova/transport) e no binários de rotas (/etc/inova/transport.db)'
echo ''
echo 'Arquivo:'
echo ''
egrep "${domain}" /etc/inova/transports
echo ''
echo 'Binario:'
echo ''
strings /etc/inova/transports.db | egrep "${domain}" -A1

else
    echo "Execute:"
    echo ""
    echo "$0 domain.com.br"
    echo ""
    echo ""
fi
