#!/bin/sh

SCRIPTPATH=`cd $(dirname $0) ; pwd -P`
SCRIPT=$SCRIPTPATH/$(basename $0)

. ${SCRIPTPATH}/env.sh

RUNNER=`whoami`

COMMAND=${1}

ps_check(){
	if [ "`uname -s`" = "HP-UX" ]; then
		ps -efx | grep ${ENGN_HOME}/bin/httpd|grep ${INSTALL_PATH}/conf/httpd.conf | wc -l
	else
		ps -ef | grep ${ENGN_HOME}/bin/httpd|grep ${INSTALL_PATH}/conf/httpd.conf | wc -l
	fi
}

[ `ps_check` -eq 0 ] && echo "##### ${SERVER_ID} is not running. There is nothing to stop.#######" && exit 1

echo "Stop LENA [web] ... ${SERVER_ID}"

# set command
case ${COMMAND} in
	graceful)
		COMMAND=graceful-stop
	  if [ ! -z "${MONITORING_SERVICE_PORT}" ];then
	  	echo "" > ${INSTALL_PATH}/conf/extra/httpd-monitoring-service-port.conf
	  	${ENGN_HOME}/bin/apachectl -f ${INSTALL_PATH}/conf/httpd.conf -k graceful -D${MPM_TYPE} ${EXT_MODULE_DEFINES}
  		echo "Waiting 10 seconds for stop of monitoring service port"
			sleep 10
			echo "Listen \${MONITORING_SERVICE_PORT}" > ${INSTALL_PATH}/conf/extra/httpd-monitoring-service-port.conf
	  fi
	;;
	*)
		COMMAND=stop
	;;
esac

if [ ${RUNNER} = ${RUN_USER} ] || [ ${RUNNER} = root ]; then
  # Stop Apache
  ${ENGN_HOME}/bin/apachectl -f ${INSTALL_PATH}/conf/httpd.conf -k ${COMMAND} -D${MPM_TYPE} ${EXT_MODULE_DEFINES}
  
  if [ -r ${INSTALL_PATH}/vela.pid ]; then
    ${INSTALL_PATH}/vela/bin/stop-vela.sh --silent
  fi
else
   echo "Deny Access : [ ${RUNNER} ]. Not ${RUN_USER}" ;
   exit 0 ;
fi