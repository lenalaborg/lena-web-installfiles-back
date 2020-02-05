#!/bin/sh

SCRIPTPATH=`cd $(dirname $0) ; pwd -P`
SCRIPT=$SCRIPTPATH/$(basename $0)

. ${SCRIPTPATH}/env.sh

echo "Start LENA [web] ... ${SERVER_ID}"

RUNNER=`whoami`

COMMAND=${1}

# set command
case ${COMMAND} in
	graceful)
		COMMAND=graceful
	;;
	*)
		COMMAND=restart
	;;
esac

if [ ${RUNNER} = ${RUN_USER} ] || [ ${RUNNER} = root ]; then
  # Start Apache
  if [ ! -z "${MONITORING_SERVICE_PORT}" ];then
    echo "Listen \${MONITORING_SERVICE_PORT}" > ${INSTALL_PATH}/conf/extra/httpd-monitoring-service-port.conf
  else
    echo "" > ${INSTALL_PATH}/conf/extra/httpd-monitoring-service-port.conf
  fi
  ${ENGN_HOME}/bin/apachectl -f ${INSTALL_PATH}/conf/httpd.conf -k ${COMMAND} -D${MPM_TYPE} ${EXT_MODULE_DEFINES}
else
   echo "Deny Access : [ ${RUNNER} ]. Not ${RUN_USER}" ;
   exit 0 ;
fi