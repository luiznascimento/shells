#!/bin/bash
# 
# @name: gera_transports.sh 
# @author: Luiz Nascimento
# @date: 02/01/2022
# @version: 0.8

transportfile="/etc/inova/transports"
tmpfile=/tmp/domtmp.txt
echo -n > ${tmpfile}

for mxh in mxcorp mxlite mxhero ; 
do 
      mysql -N -h 192.168.6.140 -D rotas -u rotas -p********* -e "SELECT * FROM ${mxh}dominio" >> ${tmpfile}
      doms=$(awk '{ print $1}' ${tmpfile} | sort | uniq )
      for dom in ${doms} ;
      do
          rota=$( egrep "^${dom}" ${tmpfile} | head -1 | awk '{ print $2 }' | cut -d'\' -f1)
          for alias in $( mysql -N -h 192.168.6.140 -D rotas -u rotas -pGera@Rotas -e "SELECT alias FROM ${mxh}aliases WHERE dominio='${dom}'")
          do
	     echo "${alias}  smtp:${rota}"
	  done
	     echo "${dom}  smtp:${rota}"
      done
done > ${transportfile}

postmap ${transportfile} 2> /dev/null
