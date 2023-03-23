#!/bin/bash
#
#  @name: sshtunnel.sh
#  @author: Luiz Nascimento
#  @date: 23/03/2023
#  @email: anotaai
#
#

PATH=${pwd}

echo ${PATH}

# Define a expressão regular para o formato de endereço IP
IPREGEX='^([0-9]{1,3}\.){3}[0-9]{1,3}$'

  # Verifica se o argumento corresponde ao formato do IP
  if [[[ $HOSTA =~ $IPREGEX ]] AND [[ $HOSTB =~ $IPREGEX ]] AND [[ $HOSTC =~ $IPREGEX ]]]
  then
     ssh fw -L 2222:0.0.0.0:2222 'bash -s' < sshtunnel-include.sh
  fi