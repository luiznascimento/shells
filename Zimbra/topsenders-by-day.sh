#!/bin/bash

froms=$(egrep nrcpt /var/log/zimbra.log | awk '{ print $7 }' | sort | uniq )
for from in ${froms}; do
    echo $(echo $(egrep "${from}" /var/log/zimbra.log | awk -F"nrcpt=" '{ print $2 }' | awk '{ print $1 }' | tr '\n' '+'  | sed "s/+$//" ) | bc -l) - ${from} 
done | sort -n > topsenders.txt
