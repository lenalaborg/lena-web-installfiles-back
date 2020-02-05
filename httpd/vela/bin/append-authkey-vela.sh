#!/bin/sh
SCRIPTPATH=`cd $(dirname $0) ; pwd -P`
SCRIPT=${SCRIPTPATH}/$(basename $0)

. ${SCRIPTPATH}/env-vela.sh

VELA_AUTHORIZED_KEYS_DIR=`dirname ${VELA_AUTHORIZED_KEYS_PATH}`
if [ ! -d ${VELA_AUTHORIZED_KEYS_DIR} ]; then
   mkdir -p ${VELA_AUTHORIZED_KEYS_DIR}
fi

while true; do
	echo "Input client public key. ( q: quit )"
	read client_public_key
	if [ "$client_public_key" = "q" -o "$client_public_key" = "Q" ] ; then
	  exit 1;
	fi
	
	if [ "$client_public_key" != "" ]; then
		echo ${client_public_key} >> ${VELA_AUTHORIZED_KEYS_PATH}
		exit 0;
	fi
	
done

exit 0;