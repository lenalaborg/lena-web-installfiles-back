#!/bin/sh
SCRIPTPATH=`cd $(dirname $0) ; pwd -P`
SCRIPT=${SCRIPTPATH}/$(basename $0)

. ${SCRIPTPATH}/env-vela.sh

if [ "`uname -s`" = "HP-UX" ]; then
	ps -efx | grep ${VELA_CONFIG_PATH} | grep sshd
else
	ps -ef | grep ${VELA_CONFIG_PATH} | grep sshd
fi

exit 0;
