#!/bin/bash
#
#  @name: sshtunnel.sh
#  @author: Luiz Nascimento
#  @date: 23/03/2023
#  @email: luiz.nascimento at penso.com.br
#
#

HOSTA=${1}
HOSTB=${2}

# Define a expressão regular para o formato de endereço IP
IPREGEX='^([0-9]{1,3}\.){3}[0-9]{1,3}$'


  # Verifica se o argumento corresponde ao formato do IP
  if [[[ $HOSTA =~ $IPREGEX ]] AND [[ $HOSTB =~ $IPREGEX ]]]
  then
     
  fi


ssh fw -L 2222:10.30.8.21:3333




 ssh fw -L 2222:0.0.0.0:2222