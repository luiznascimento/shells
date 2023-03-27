#!/bin/bash
#
#  @name: checkSpamFlow.sh
#  @data: 21/10/2021
#  @author: Luiz Nascimento
#  @objective: check mail flow from last 5 minutes, disable Zimbra mail account and notify admins.
#

#variaveis

dir="/tmp/countrecipients/"
counterlog=${dir}onelog
totalcount=${dir}totalcount
#domspipefile=${dir}domspipefile

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

doms=$( su -l zimbra -c "zmprov -l gad" | egrep -v "qualmbox01.a.inova.com.br|qualmbox01.aws.inova.com.br" )
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
		echo Bloqueia "${mail}" $(egrep "${mail}$" ${totalcount}| awk '{ print $1 }')
	  else
		echo menor: "${mail}" $(egrep "${mail}$" ${totalcount} | awk '{ print $1 }')
	  fi
done
