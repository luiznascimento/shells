#!/bin/bash
#
#  @name: Luiz Nascimento
#  @script: Gera rotas
#

tmpfile="/tmp/temp-routes.log"
transportfile="/etc/transports"
echo -n > ${tmpfile}

for mxh in mxcorp mxlite mxhero ; 
do 
      mysql -N -h 192.168.75.110 -D rotas -u rotas -pXXXXXXXX -e "SELECT * FROM ${mxh}" >> ${tmpfile}
      doms=$(awk '{ print $1}' ${tmpfile} | sort | uniq )
      #awk '{ print $1}' ${tmpfile} | wc -l
      for dom in ${doms} ;
      do
          rota=$( egrep "^${dom}" ${tmpfile} | head -1 | awk '{ print $2 }' | cut -d'\' -f1)
          for alias in $(mysql -N -h 192.168.75.110 -D rotas -u rotas -pXXXXXXXX -e "SELECT alias FROM ${mxh} WHERE dominio='${dom}'")
          do
	  			echo ${alias}  smtp:${rota}
	  	  done
	  	  echo ${alias}  smtp:${rota}
      done
done > ${transportfile}

echo "*  smtp:192.168.80.90" >> ${transportfile}
sed 's/ORIGINAL-IP01/192.168.55.55/g' -i ${transportfile}
sed 's/ORIGINAL-IP02/192.168.55.65/g' -i ${transportfile}
sed 's/ORIGINAL-IP03/192.168.55.66/g' -i ${transportfile}

postmap ${transportfile} 2> /dev/null
