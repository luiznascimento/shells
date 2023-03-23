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

ssh fw -L 2222:10.30.8.21:3333



 ssh fw -L 2222:0.0.0.0:2222