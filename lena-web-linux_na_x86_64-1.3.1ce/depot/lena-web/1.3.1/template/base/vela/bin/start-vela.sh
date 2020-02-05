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

if [ "${VELA_ENABLED}" != "true" ]; then
	echo_silent "Vela is not enabled"
	exit 0;
fi

if [ -r ${VELA_PID_FILE} ]; then
   VELA_PID=`cat ${VELA_PID_FILE}`
   PROCESS_ALIVE=`ps -p ${VELA_PID} | grep "${VELA_PID}" | wc -l`
   
   if [ ${PROCESS_ALIVE} -eq 0 ]; then
      echo_silent "Removing PID File."
      rm ${VELA_PID_FILE}
   else
	    echo_silent "Vela server (pid ${VELA_PID}) already running."
	    exit 1;
   fi
fi

${VELA_ENGINE_HOME}/sbin/sshd \
  -E ${VELA_LOG_FILE_PATH} \
  -f ${VELA_CONFIG_PATH} \
  -o "Port=${VELA_PORT}" \
  -o "PidFile=${VELA_PID_FILE}" \
  -o "Protocol=2" \
  -o "AuthorizedKeysFile=${VELA_AUTHORIZED_KEYS_PATH}" \
  -o "StrictModes=no" \
  -o "NoneEnabled=yes"

EXIT_CODE=$?
if [ ${EXIT_CODE} -eq 0 ]; then
	echo_silent "Vela server started.(Port:${VELA_PORT})"
else
	echo_silent "Can't start Vela server. Check the log file( ${VELA_LOG_FILE_PATH} )"
fi
exit ${EXIT_CODE};