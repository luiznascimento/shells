#!/bin/bash
#


teste=$(echo $1 | egrep '@')

Valida(){

	if [[ ! -n $teste ]]
	then 
		echo " "
		echo "Executar assim: ./envia_shell.sh email@recipientto.tld"
		echo " "
		exit
	fi
}

Envia(){
cat <<EOF | nc mx1.server.tld 25
HELO inova.net
MAIL FROM: <myemail@tld>
RCPT TO: <$teste>
DATA
From: Owner <myemail@mydomain.tld>
To: $teste <$teste>
Subject: Teste de envio - $(hostname)
Content-Type: text/plain; charset=UTF-8
                                                                                                                                                                                               
Olá ${teste};
 
Este é apenas um teste de envio e entrega a partir do servidor $(hostname).

Por favor, o ignore!
 
Atenciosamente!
 
.
QUIT
EOF
}

Valida
Envia
