#!/bin/bash
#
#  @nome: checkSpam.sh
#  @data: 21/10/2021
#  @autor: Luiz Nascimento
#  @objetivo: gerar um contador de recipientes separados por from por minuto no Zimbra.
#
#variaveis

dir="/tmp/countrecipients/"
counterlog=${dir}onelog
totalcount=${dir}totalcount
report=${dir}report.txt

mkdir -p ${dir} 2> /dev/null

oneago=$(date "+%R" -d "1 min ago")
twoago=$(date "+%R" -d "2 min ago")
threeago=$(date "+%R" -d "3 min ago")
fourago=$(date "+%R" -d "4 min ago")
fiveago=$(date "+%R" -d "5 min ago")

oneminute=$(echo ${oneago} | cut -d\: -f2)
twominute=$(echo ${twoago} | cut -d\: -f2)
threeminute=$(echo ${threeago} | cut -d\: -f2)
fourminute=$(echo ${fourago} | cut -d\: -f2)
fiveminute=$(echo ${fiveago} | cut -d\: -f2)

onehour=$(echo ${oneago} | cut -d\: -f1)
twohour=$(echo ${twoago} | cut -d\: -f1)
threehour=$(echo ${threeago} | cut -d\: -f1)
fourhour=$(echo ${fourago} | cut -d\: -f1)
fivehour=$(echo ${fiveago} | cut -d\: -f1)

echo -n > ${counterlog} > ${totalcount}

doms=$( su -l zimbra -c "zmprov -l gad" | egrep -v "domínios locais para excluir" )
domspipe=$(for dom in ${doms}
do
    let i=$i+1 ;
    count_doms=$(echo ${doms} | wc -w)
    if [[ ${i} -eq ${count_doms} ]]
    then 
        echo -n "$dom"
    else 
        echo -n "$dom|"
    fi
done)

for dom in ${doms}
do

for d in one two three four five
do
	eval egrep " \${${d}hour}:\${${d}minute}" /var/log/zimbra.log | egrep "from=<" | egrep "${domspipe}" | awk -F'from=<' '{ print $2 }'  | awk '{ print $1" "$3}' | egrep ESMTP -v | egrep "nrcpt=" | sed 's/>, nrcpt=/ /' 
done
done >> ${counterlog}


for count in $(awk '{ print $1 }' ${counterlog} | sort | uniq ); do echo $( egrep "^${count}" ${counterlog} | awk '{ print $2 }' | paste -sd+ | bc -l) - $count ; done | sort -n > ${totalcount} 

for mail in $(awk '{ print $3}' ${totalcount} )
       do 
          if [[ "$(egrep "${mail}$" ${totalcount} | awk '{ print $1 }')" -gt "100" ]]
          then
		echo "Conta bloqueada: ${mail} - Quantidade de envios em 5 minutos: $(egrep "${mail}$" ${totalcount} | awk '{ print $1 }')"
	#	su -l zimbra -s "/bin/bash" -s "zmprov ma ${mail} zimbraAcccountStatus locked zimbraPasswordMustChange TRUE zimbraEnforceHistory 10"
#	  else
#		echo menor: "${mail}" $(egrep "${mail}$" ${totalcount} | awk '{ print $1 }')
	  fi
done > ${report} 

reportdata=$(cat ${report} | wc -l )

if [[ ${reportdata} > '0' ]]
then
	echo Enviando report.
	mail -a /tmp/countrecipients/report.txt -s "Aviso de abuso e bloqueio" luiz.nascimento@penso.com.br <<< "Em anexo segue a lista de contas desativadas por envio abusivo"
fi
#mail -a /tmp/countrecipients/report.txt -s "Aviso de abuso e bloqueio" luiz.nascimento@penso.com.br <<< "Em anexo segue a lista de contas desativadas por envio abusivo"
