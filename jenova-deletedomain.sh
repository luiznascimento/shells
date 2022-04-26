#!/bin/bash

unset INPUT
INPUT=${1}
COUNT=$(echo ${INPUT} | egrep '[a-z]' | wc -l)
INJECTBLOCK=$(echo "${INPUT}" | egrep "\*|%" | wc -l)
if [[ ${COUNT} == 1 ]]
then
   if [[ ${INJECTBLOCK} != 1  ]]
   then
       DOM=${INPUT}
       DOMAINFOUND=$(mysql -N -e "SELECT name FROM jenovadb.domain WHERE name=\"${DOM}\"" | wc -l)
           if [[ ${DOMAINFOUND} == 1 ]]
           then
               read -p "Dominio ${DOM} encontrado, deseja prosseguir com a remocao? Todos os dados serao PERDIDOS! (S/n)? " RESPONSE
                   case ${RESPONSE} in
                       [sSyY]) mysql -e "DELETE FROM jenovadb.domain WHERE name=\"${DOM}\""; echo Dominio removido: ${DOM} ;;
                       [nN]) echo "Cancelando processo" ;;
                       [*]) echo "Execute novamente e escolha S ou N!"; exit 2 ;;
                   esac
	   else
	       echo "Dominio nao encontrado ${DOM}"
           fi
   fi
else
    echo "Execute: $0 dominio-que-deseja-remove.com.br"
fi
