#!/bin/bash
#
#   @name: getsizeaccounts.sh
#   @author: luiz nascimento
#   @description: generate list of accounts with used size
#   @version: 0.2

date_now=$(/bin/date +%F)
file="/tmp/soap_getquota_${date_now}.txt"
result="/tmp/getquota${date_now}.txt"
get_quota_request=$( /opt/zimbra/bin/zmsoap -z GetQuotaUsageRequest > $file ) 2> /dev/null 
get_account_list=$( /usr/bin/awk -F"\" name=\"" '{ print $2 }' $file | awk -F"\" id=\"" '{ print $1 }' | egrep -v "^$")

for account_name in $get_account_list;
	do
		size_account=$(/bin/egrep "\"$account_name\"" $file | /usr/bin/awk -F"used=\"" '{ print $2 }' | /usr/bin/awk -F "\"/>" '{ print $1 }')
		size_MB=$(/bin/echo $size_account | /usr/bin/awk '{ calc = $1 / 1024 / 1024 ; print calc "MB" }')
		echo "$account_name - ${size_MB}"
	done > $result

echo "Soap Output: $file"
echo "Result: $result"
