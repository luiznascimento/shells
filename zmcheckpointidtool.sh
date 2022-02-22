#!/bin/bash
#
#  @original source: https://github.com/tylerfontaine/zmcheckpointidtool/blob/master/zmidcheckpointtool.sh
#  @name:  tylerfontaine
#

function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

FIX="false"


#getopts

while getopts 'm:f' flag; do
	case "${flag}" in
		m) MAILBOX="${OPTARG}" ;;
		f) FIX="true" ;;
		*) error "Unexpected option ${flag}";;
	esac
done

#WARN ON FIX
if [ "$FIX" = "true" ]; then
	if [[ "no" == $(ask_yes_or_no "This will make changes to the mySQL databse. Are you sure you want to") ]] ; then
      echo "No changes have been made."
      exit 0
	fi
fi

if [ $MAILBOX ] ; then
	#get account specified with -m
	mysql -N -e "select concat_ws(',', id, comment, item_id_checkpoint,group_id) from mailbox WHERE comment='$MAILBOX'" zimbra > /tmp/all_checkpoints.txt

else

#generate csv of accounts on mailstore
mysql -N -e "select concat_ws(',', id, comment, item_id_checkpoint,group_id) from mailbox" zimbra > /tmp/all_checkpoints.txt

fi

#Loop through csv line by line\
OLDIFS=$IFS
IFS=","

#touch zmprov command files
touch /tmp/affectedaccounts.txt 2>&1
touch /tmp/maintenanceaccounts.txt 2>&1
touch /tmp/reactivateaccounts.txt 2>&1

#read file line by line, assigning values from csv
while read MID ACCOUNT CHECKPOINT GROUP

do
#first loop to ID accounts and create zmprov commands if necessary
BIGGESTID=`mysql -N -e "SELECT MAX(id) FROM mail_item WHERE mailbox_id=$MID" mboxgroup$GROUP`
    if [ $BIGGESTID -gt $CHECKPOINT ] ; then
    	echo "$ACCOUNT"
        echo "$MID,$ACCOUNT,$CHECKPOINT,$GROUP,$BIGGESTID" >> /tmp/affectedaccounts.txt
        
        if [ "$FIX" = "true" ] ; then
            echo "ma $ACCOUNT zimbraAccountStatus maintenance" >> /tmp/maintenanceaccounts.txt
            
        
        fi
	fi
done < /tmp/all_checkpoints.txt

#second loop if fixing accounts, using zmprov commands
if [ "$FIX" = "true" ] ; then
    cat /tmp/maintenanceaccounts.txt |sed "s/maintenance/active/" >> /tmp/reactivateaccounts.txt
    echo "Putting affected accounts in maintenance mode"
    zmprov < /tmp/maintenanceaccounts.txt
    echo "Done."
    echo "Fixing affected accounts"
    while read MID1 ACCOUNT1 CHECKPOINT1 GROUP1 BIGGESTID1

    do
            NEWCHECKPOINT=`expr $BIGGESTID1 + 100`
            mysql -e "UPDATE zimbra.mailbox SET item_id_checkpoint=$NEWCHECKPOINT WHERE id='$MID1' AND comment='$ACCOUNT1'"
            echo "$ACCOUNT item_id_checkpoint updated. Old value: $CHECKPOINT1 | New value: $NEWCHECKPOINT"
            echo "Reloading $ACCOUNT1 . . ."
            #echo "ACCOUNT 1: $ACCOUNT1"
            zmsoap -A -z UnloadMailboxRequest/account @name="$ACCOUNT1"
    done < /tmp/affectedaccounts.txt
    echo "Reactivating Affected accounts"
    zmprov < /tmp/reactivateaccounts.txt
    echo "done"
fi
echo "cleaning up tempoary files"
rm -f /tmp/all_checkpoints.txt 2>&1
rm -f /tmp/maintenanceaccounts.txt 2>&1
rm -f /tmp/reactivateaccounts.txt 2>&1
echo "Done."
