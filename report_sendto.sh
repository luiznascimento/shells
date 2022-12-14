#!/bin/bash
remetente=$1

grep -E "from=<($remetente)" /var/log/zimbra.log | awk '{print $6}' |
rev | cut -c2- | rev | sort -u | grep -v 'NOQUEUE'> /tmp/deParaId.log;

funcGrepFromTo () {
    grep "$1" /var/log/zimbra.log | grep -E 'from=<|to=<' | awk -F "$2" '{print$2}' | cut -d\> -f1 | grep -E @
}

funcDateTime () {
    grep "$1" /var/log/zimbra.log | grep -E 'from=<' | awk '{print$1" "$2" "$3}'
}

while IFS= read -r messageId;
do
    from=$(funcGrepFromTo "$messageId" "from=<");
    to=$(funcGrepFromTo "$messageId" "to=<");
    dataHora=$(funcDateTime "$messageId");
    
    echo "$dataHora", E-mail enviado De: "$from" para: "$(echo $to | awk '{for(i=2;i<=NF-1;i++) printf $i", "; print""}') \
    $(echo $to | awk '{print$NF}')";
done < /tmp/deParaId.log
