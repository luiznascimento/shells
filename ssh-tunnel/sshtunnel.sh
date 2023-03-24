#!/bin/bash
#
#  @name: sshtunnel.sh
#  @author: Luiz Nascimento
#  @date: 23/03/2023
#  @email: anotaai
#
#

DIR=$(dirname $0)

# Define a expressão regular para o formato de endereço IP
IPREGEX='^([0-9]{1,3}\.){3}[0-9]{1,3}$'

  # Verifica se o argumento corresponde ao formato do IP
     ps aux | egrep "L 2222" | awk '{ print $2 }' | xargs kill > /dev/null
     sleep 10;
     ssh fw -tt -L 2222:0.0.0.0:2222 'bash -s' <(${DIR}/sshtunnel-include.sh; sleep 3600000)
     #sleep 10
     
