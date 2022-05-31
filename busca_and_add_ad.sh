#!/bin/bash
# Penso Tecnologia
# By Andre Antonioli e Renato Rainato
# Data: 08/07/2018
# Ultima modificacao: 2018-08-06 17h28
# Versao: 1.3b

export LC_ALL=nb_NO.UTF-8

LDAPHOST="ldap-ad"
ADUSER="email@dominio-do-cliente"
ADPASS="dfq9ZZRd"
BASEDN="AD-Base-DN"
DOMINIO="dominio-do-cliente"
ZMPROV="/opt/zimbra/bin/zmprov"
TIMESTAMP=`date --date "1 hour ago" +"%Y%m%d%H%M%S.0Z"`
LDAPSEARCH="/opt/zimbra/common/bin/ldapsearch"
BASE64="/bin/base64"
PROCESSNAME="busca_ad"

LOCK="/tmp/$PROCESSNAME.lock"

if [ -f $LOCK ]; then
	echo `date +"%Y%m%d%H%M%S"` " - PROCESSO AINDA EM EXECUCAO - $PROCESSNAME"
	exit 2 ;
fi

touch $LOCK

for LOGINS in `$LDAPSEARCH -LLL -o ldif-wrap=no -x -h $LDAPHOST -D "$ADUSER" -w$ADPASS -b $BASEDN -s sub "whenChanged>=$TIMESTAMP" | grep dn: | awk -F"," '{print $1}'  | awk -F"CN=" '{print $2}'` ; do

	$LDAPSEARCH -LLL -o ldif-wrap=no -x -h $LDAPHOST -D "$ADUSER" -w$ADPASS -b $BASEDN -s sub "samAccountName=$LOGINS" >> /tmp/$LOGINS.ldif
	
	TMP="/tmp/$LOGINS.ldif"
	SN=`grep sn: $TMP | sed 's/sn: //g'`
	GN=`grep givenName: $TMP | sed 's/givenName: //g'`
	DN=`grep displayName: $TMP | sed 's/displayName: //g'`
	DE=`grep description: $TMP | sed 's/description:: //g' | $BASE64 -d`
	MAIL=`grep mail: $TMP | sed 's/mail: //g'`
	SENHA=`shuf -i 1-1000 -n 1 | md5sum | cut -c 1-12`
	LOGIN=`echo $LOGINS@$DOMINIO | tr A-Z a-z`
	ZTMP="/tmp/z$LOGINS.ldif"

    # testa se valores estao em base64
    TSN=`grep -c sn:: $TMP`
	if [ $TSN -eq 0 ]; then
		SN=`grep sn: $TMP | sed 's/sn: //g'`
	else
	    SN=`grep sn:: $TMP | sed 's/sn:: //g' | $BASE64 -d`
	fi

	TGN=`grep -c givenName:: $TMP`
	if [ $TGN -eq 0 ]; then
		GN=`grep givenName: $TMP | sed 's/givenName: //g'`
	else
		GN=`grep givenName:: $TMP | sed 's/givenName:: //g' | $BASE64 -d`
	fi

	TDN=`grep -c displayName:: $TMP`
	if [ $TDN -eq 0 ]; then
		DN=`grep displayName: $TMP | sed 's/displayName: //g'`
	else
		DN=`grep displayName:: $TMP | sed 's/displayName:: //g' | $BASE64 -d`
	fi

	$ZMPROV -l ga $LOGIN 1> $ZTMP 2>/dev/null
	
	CHKACCOUNT=`grep "# name " $ZTMP | awk '{print $3}' | grep -v ^$ | wc -l`
	ZCHKACCTSTATUS=`grep zimbraAccountStatus $ZTMP | awk '{print $2}' | grep -v ^$ `
	
	echo "#----------------------------------------------------------------------------------------------------#"
	echo `date +"%Y%m%d%H%M%S"` - PROCESSANDO MODIFICACOES: $LOGIN

	# 2 teste se a conta possui o atributo email com @dominio-do-cliente
	if [ `echo $MAIL | grep -c $DOMINIO` -eq 1 ]; then
	
		echo `date +"%Y%m%d%H%M%S"` "2.1 - TEM EMAIL: $MAIL"

		# 3 checa se a conta existe no zimbra
		if [ $CHKACCOUNT -eq 0 ]; then
			echo `date +"%Y%m%d%H%M%S"` "3.2 Conta tem email $DOMINIO e nao existe no Zimbra"
		    $ZMPROV ca $LOGIN S$SENHA displayName "$DN" givenName "$GN" sn "$SN"
			$ZMPROV aaa $LOGIN $MAIL
			$ZMPROV ma $LOGIN zimbraPrefFromAddress $MAIL
			$ZMPROV ma $LOGIN zimbraPrefFromAddressType sendAs
	
		else

			# 6 altera atributos e verifica se os atributos as diferentes
			echo `date +"%Y%m%d%H%M%S"` "6 - Verificando se login: $LOGIN tem atributos para alteracao"
			ZSN=`grep sn: $ZTMP | sed 's/sn: //g'`
			ZGN=`grep givenName: $ZTMP | sed 's/givenName: //g'`
			ZDN=`grep displayName: $ZTMP | sed 's/displayName: //g'`
			ZDE=`grep description: $ZTMP | sed 's/description: //g'`
			ZALIAS=`grep zimbraMailAlias: $ZTMP | sed 's/zimbraMailAlias: //g'`

			if [ ! "$ZSN" == "$SN" ]; then
				echo `date +"%Y%m%d%H%M%S"` "6.1 - Alterar atributos da conta $LOGIN: Zimbra \"$ZSN\" diferente do AD \"$SN\""
				$ZMPROV ma $LOGIN sn "$SN"
			fi
				
			if [ ! "$ZGN" == "$GN" ]; then
				echo `date +"%Y%m%d%H%M%S"` "6.1 - Alterar atributos da conta $LOGIN: Zimbra \"$ZGN\" diferente do AD \"$GN\""
				$ZMPROV ma $LOGIN givenName "$GN"
			fi
				
			if [ ! "$ZDN" == "$DN" ]; then
				echo `date +"%Y%m%d%H%M%S"` "6.1 - Alterar atributos da conta $LOGIN: Zimbra \"$ZDN\" diferente do AD \"$DN\""
				$ZMPROV ma $LOGIN displayName "$DN"
			fi
	
			if [ ! "$ZDE" == "$DE" ]; then
				echo `date +"%Y%m%d%H%M%S"` "6.1 - Alterar atributos da conta $LOGIN: Zimbra \"$ZDE\" diferente do AD \"$DE\""
				$ZMPROV ma $LOGIN description "$DE"
			fi

			if [ ! "$ZALIAS" == "$MAIL" ]; then
				echo `date +"%Y%m%d%H%M%S"` "6.1 - Alias da conta e na conta $LOGIN: Zimbra \"$ZALIAS\" diferente do AD \"$MAIL\""
				$ZMPROV raa $LOGIN $ZALIAS
				$ZMPROV aaa $LOGIN $MAIL
				$ZMPROV ma $LOGIN zimbraPrefFromAddress $MAIL
				$ZMPROV ma $LOGIN zimbraPrefFromAddressType sendAs
			fi

			# testa se a conta existe no zimbra e está closed para reativar
			if [ "$ZCHKACCTSTATUS" == "closed" ]; then
				echo `date +"%Y%m%d%H%M%S"` "6.1 - Reativando conta $LOGIN: no Zimbra"
				$ZMPROV ma $LOGIN zimbraAccountStatus active
				$ZMPROV aaa $LOGIN $MAIL
				$ZMPROV ma $LOGIN zimbraPrefFromAddress $MAIL
				$ZMPROV ma $LOGIN zimbraPrefFromAddressType sendAs
			fi
		fi

	else
	
		# 5 teste de se conta existe no zimbra mesmo
		if [ $CHKACCOUNT -eq 1 ]; then

			ZSN=`grep sn: $ZTMP | sed 's/sn: //g'`
	        ZGN=`grep givenName: $ZTMP | sed 's/givenName: //g'`
	        ZDN=`grep displayName: $ZTMP | sed 's/displayName: //g'`
	        ZDE=`grep description: $ZTMP | sed 's/description: //g'`
	        ZALIAS=`grep zimbraMailAlias: $ZTMP | sed 's/zimbraMailAlias: //g'`

			if [ ! "$ZCHKACCTSTATUS" == "closed" ]; then
				echo `date +"%Y%m%d%H%M%S"` "5.1 - Bloqueando conta que exite no zimbra mais nao tem email $DOMINIO"
				$ZMPROV raa $LOGIN $ZALIAS
				$ZMPROV ma $LOGIN zimbraAccountStatus closed
			else
				echo `date +"%Y%m%d%H%M%S"` "5.2 - NADA A SER FEITO NO LOGIN: $LOGIN"
			fi 

		else 
			echo `date +"%Y%m%d%H%M%S"` "5.2 - NADA A SER FEITO NO LOGIN: $LOGIN"
		fi
	fi 
	
	# remove arquivos temporarios
	rm -f /tmp/$LOGINS.ldif
	rm -f $ZTMP

done

sleep 1
rm -f $LOCK
