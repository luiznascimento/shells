#
# @author: Luiz Nascimento
# @name: check_smart_scan.sh
# @version: 2.0
# @date: 06/2019 - UPDATED: 14/06/2021
#
#####<variaveis>#####

#diretório de armazenamento do arquivo temporario
dir="/tmp/"
#arquivo temporario com informacoes de backup
bkpinfo="bkpinfo"
#Nessa chave definimos a janela de intervalo p/ checagem de criacao do arquivo. 
expirecache="30"
#Time-out do comando zxsuite
expire="2"
#Time-out do arquivo temporario / Define a janela de consulta do Smartscan
expirecache=30
#variaveis para definir limite de tentativas p/ gerar a informação do ultimo backup
#contador inicial - nao mudar
testfile=0
#quantidade de testes em caso de falha
totaltest=5

#####<\variaveis>#####

checkTmpFile(){

if [[ -f ${dir}${bkpinfo} ]]
then
   find -L ${dir} -name ${bkpinfo} -mmin -${expirecache} | egrep "${bkpinfo}" -q
   if [[ $? == "1" ]]
   then
	createTmpFileInfo
   else
    	checkLastBkpFile
   fi
else
   createTmpFileInfo
fi

}

createTmpFileInfo(){

timeout 30 /bin/su -l zimbra -s /bin/bash -c "zxsuite backup getBackupInfo | egrep lastScan" 2> /dev/null | awk '{ print $2 }' > ${dir}${bkpinfo} 
	if [[ $? == "0" ]]
	then
     		checkLastBkpFile
	else
     		createTmpFileInfo
	fi

}

checkLastBkpFile () {

egrep "20[2][0-9](-[0-1][0-9])(-[0-3][0-9])|1969-12-31" ${dir}${bkpinfo} -q
#echo checklastbkpfile
if [[ $? == "0" ]]
then
  #   echo checkLastBkpFile FileOK
  #   echo cat $(cat ${dir}${bkpinfo})
     splitDate
else
     let testfile=testfile+1
     if [[ ${totaltest} -gt ${testfile} ]]
     then
         createTmpFileInfo
     else
         let testfile=testfile+1
         echo " CRIT -  Generating temporary file error: ${testfile} tentativa(s) de criação de arquivo temporario."
	 exit 2
     fi
     
fi

}

splitDate(){

lastbkp=$(cat ${dir}${bkpinfo})
date_now=$(date  +%Y-%m-%d)
date_oneday_ago=$(date  +%Y-%m-%d --date="1 days ago")
year_now=$(echo $date_now | cut -d\- -f1)
year_lastbkp=$(echo $lastbkp | cut -d\- -f1)

month_now=$(echo $date_now | cut -d\- -f2)
month_oneday_ago=$(echo $date_oneday_ago | cut -d\- -f2)
month_lastbkp=$(echo $lastbkp | cut -d\- -f2)

day_now=$(echo $date_now | cut -d\- -f3)
day_oneday_ago=$(echo $date_oneday_ago | cut -d\- -f3)
day_lastbkp=$(echo $lastbkp | cut -d\- -f3)

if [[ ${month_now} == ${month_oneday_ago} ]]
then
   Normalize
   NormalizeDayAgo
   Validate
else
   NormalizeDayAgo
   Validate
fi

}

Normalize(){
   echo $day_now | egrep -c "^0" -q
   if [[ "$?" == 0 ]]
   then
       day_now_fixed=$(echo ${day_now} | egrep "^0" | cut -d\0 -f2)
       day_now=${day_now_fixed}
   fi
   echo $day_lastbkp | egrep -c "^0" -q
   if [[ "$?" == 0 ]]
   then
       day_lastbkp_fixed=$(echo ${day_lastbkp} | egrep "^0" | cut -d\0 -f2)
       day_lastbkp=${day_lastbkp_fixed}
   fi
}

NormalizeDayAgo(){
   echo $day_oneday_ago | egrep -c "^0" -q
   if [[ "$?" == 0 ]]
   then
       day_oneday_ago_fixed=$(echo ${day_oneday_ago} | egrep "^0" | cut -d\0 -f2)
       day_oneday_ago=${day_oneday_ago_fixed}
   fi
}

Validate(){

if [[ $date_now == $lastbkp ]]
then
     echo "OK - SmartScan is updated - Last Smartscan in $lastbkp"
     exit 0
else
	if [[ $year_now == $year_lastbkp ]]
	then
                if [[ $day_now == $day_lastbkp ]]
                then
                    echo "OK - SmartScan is updated - Last Smartscan in $lastbkp"
                    exit 0
                else
                    if [[ $day_oneday_ago == $day_lastbkp ]]
                    then
                        echo "OK - SmartScan is updated - Last Smartscan in $lastbkp"
                        exit 0
                    else
                        echo "CRITICAL - Last Smartscan is outdated - $lastbkp"
                        exit 2
                    fi
                fi
	else
	    echo "CRITICAL - Last Smartscan is outdated - $lastbkp"
	    exit 2
	fi
fi
}

checkTmpFile
