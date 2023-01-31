#!/bin/bash
#
# @name: last7days.sh
# @author: Victor Bento
# @ date

FROMLISTBYDAY="/tmp/nrpc/byday/FROMLIST-"
NRPCFROMPERDAY="/tmp/nrpc/byday/NRPCBYDAY-"

for FOLDER in byday byhour;
do

if [[ -e /tmp/nrpc/${FOLDER} ]]
then
    mkdir -p /tmp/nrpc/${FOLDER}
fi

done

for D in $(seq 23 30);
  do
    for H in $(seq - 00 23);
      do
      	#Lista de froms por dia
        egrep "May ${d}" /tmp/nrpc-all.txt| egrep "@dominio-cliente>" | awk '{ print $7 }' | sort | uniq ) > ${FROMLISTBYDAY}-${D}
		for FROM in $(cat NRPCFROMPERDAY)
        echo $(egrep "May ${d} ${h}" /tmp/nrpc-all.txt| egrep "${FROM}" | awk '{ print $9 }' | awk -F\= '{ print $2  }' | paste -sd+ | bc -l)
        #  > ${NRPCFROMPERDAY}-${D}-${H}
  done
done
