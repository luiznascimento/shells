#!/bin/bash
#
#  @name: sshtunnel.sh
#  @author: Luiz Nascimento
#  @date: 23/03/2023
#  @email: luiz.nascimento at me.com
#
#
 
ssh -tt 10.30.0.243 -L 2222:10.30.8.21:22
sleep 2678400
