#!/bin/sh
SCRIPTPATH=`cd $(dirname $0) ; pwd -P`
SCRIPT=${SCRIPTPATH}/$(basename $0)

. ${SCRIPTPATH}/env-vela.sh

SILENT_MODE="false"
if [ "$1" = "--silent" ]; then
		SILENT_MODE="true"
fi
	
echo_silent () {
	if [ "${SILENT_MODE}" != "true" ]; then
    echo "$*"
	fi
}

if [ ! -r ${VELA_PID_FILE} ]; then
   echo_silent "Vela server (no pid file) not running."
   exit 1;
fi

#pkill -15 -P `cat ${VELA_PID_FILE}`
kill -15 `cat ${VELA_PID_FILE}`

echo_silent "Vela server stopped."
exit 0;
