#!/bin/bash
#
#  @version: 0.1
#  @date: 04/13/2019
#  @author: Luiz Nascimento
#  Generate message path from Mailbox ID and Message or Item ID
#


idaccount=$1
idmessage=$2
group_idz=$(/opt/zimbra/bin/mysql -N -e "SELECT group_id FROM zimbra.mailbox WHERE id="${idaccount}"" -N)
partial_path=$(/opt/zimbra/bin/mysql -e "select locator from mboxgroup${group_idz}.mail_item where id=\"${idmessage}\" and mailbox_id=\"${idaccount}\" limit 1" -N)
#partial_path=$(perl -le 'print $ARGV[1] >> $ARGV[0]' 12 ${id-account})
homepath=$(/opt/zimbra/bin/mysql -e "select path from zimbra.volume WHERE id="${partial_path}"" -N)
path_message=$(/opt/zimbra/bin/mysql -e "select id, concat('${homepath}/', (mailbox_id >> 12), '/', mailbox_id, '/msg/', (id >> 12), '/', id, '-', mod_content, '.msg') as file from mboxgroup${group_idz}.mail_item where mailbox_id="${idaccount}" and id="${idmessage}" limit 1")

echo $path_message
