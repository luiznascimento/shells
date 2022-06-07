#!/bin/bash
#
#  @name: copylogsfromS3.sh
#  @author: Luiz Nascimento
#  @version: 0.1
#
#
S3=$(which s3cmd 2> /dev/null)
SAVELOG="/mnt/dados01/AWS-LOGS-INOVA/"
if [[ ! -e "${S3}" ]]; then echo "Installe o S3Cmd para continuar"; exit 2; fi

echo Lista Paths:
S3PATHS=$(${S3} ls s3://logretention/ | egrep DIR | awk '{ print $2 }')

for S3PATH in ${S3PATHS}; do
   echo PATH: ${S3PATH}
   for FILE in $( ${S3} ls ${S3PATH} | awk '{ print $4 }' ); 
   do
      DATEPATH=$( echo ${FILE} | awk -F"logretention/" '{ print $2 }' | cut -d\/ -f1 )
      FILENAME=$(echo ${FILE} | awk -F"logretention/" '{ print $2 }' | cut -d\/ -f2)
      echo $(date) - Saving log ${FILENAME} to ${SAVELOG}${DATEPATH}
      mkdir -p ${SAVELOG}${DATEPATH}/ 2> /dev/null 
      s3cmd get ${FILE} ${SAVELOG}${DATEPATH}/
      cd ${SAVELOG}${DATEPATH}
      ISGZ=$(file ${FILENAME} | egrep -i "ASCII|text" | wc -l)
      if [[ ${ISGZ} == '0'  ]]
      then
          echo "$(date) - File ${FILENAME} is already GZIP file!"
      else
          echo "$(date) - Compressing ${FILENAME} to GZIP!"
          gzip -9 ${FILENAME}
      fi
      /bin/sleep 10
   done
done
