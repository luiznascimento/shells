#!/bin/bash
#
#  @nome: checkSpamFlow.sh
#  @data: 21/10/2021
#  @autor: Luiz Nascimento
#  @objectiv: gerar um contador de recipientes separados por from por minuto.
#

#variaveis

dir="/tmp/countrecipients/"
quantidadedelog="5"

#limpa antigos

ls -tl | egrep -v total | sed '1,${quantidadedelog}d' | awk '{ print $9 }'  | xargs rm -f 2> /dev/null

data_search=$(echo $(date | awk '{ print $2" "$3" "$4 }') | awk -F: '{ print $1":"$2}')
minute_search=$(echo ${data_search} | awk -F: '{ print $2 }')

egrep "${data_search}" /var/log/zimbra.log | egrep "from=<" | egrep "@specific-domain.com.br" | awk -F'from=<' '{ print $2 }'  | awk '{ print $1" "$3}' | egrep ESMTP -v | sed 's/>, nrcpt=/ /' > ${dir}/${minute_search}

for x in $( awk '{ print $1 }' /tmp/out | sort | uniq ); do echo ${x} $(echo $(egrep $x /tmp/out | awk '{ print $2 }' | paste -sd+ | bc -l )); done
