#!/bin/sh

SCRIPTPATH=`cd $(dirname $0) ; pwd -P`
SCRIPT=$SCRIPTPATH/$(basename $0)

. ${SCRIPTPATH}/env.sh

echo "Start LENA [web] ... ${SERVER_ID}"

RUNNER=`whoami`

COMMAND=${1}

check_vela_process () {
	local exit_code=$1
	
	#if [ ${exit_code} -ne 0 ]; then
	#	echo Vela process start failed.
	#	exit ${exit_code};
	#fi
	
	# wait for 2 seconds
	for loop_cnt in {1..20}
	do
		if [ -r ${INSTALL_PATH}/vela.pid ]; then
			return;
		else
			# Waiting for vela process start.
			sleep 0.1
		fi
		loop_cnt=`expr ${loop_cnt} + 1`
	done

	echo Vela process start failed.
	exit 1;
}

check_web_process () {
	local exit_code=$1
	
	if [ ${exit_code} -ne 0 ]; then
		${INSTALL_PATH}/vela/bin/stop-vela.sh --silent
		exit ${exit_code};
	fi
}

# set command
case ${COMMAND} in
	staging)
		export SERVICE_PORT=${STAGING_SERVICE_PORT}
		export HTTPS_SERVICE_PORT=${STAGING_HTTPS_SERVICE_PORT}
	;;
	*)
		# do nothing
	;;
esac

if [ ${RUNNER} = ${RUN_USER} ] || [ ${RUNNER} = root ]; then
  #_log_dirs="access log"
  _log_dirs="."
  for _dir in `echo $_log_dirs`
  do
    if [ ! -d ${LOG_HOME}/${_dir} ]; then
      mkdir -p ${LOG_HOME}/${_dir}
      if [ $? -ne 0 ]; then
  	  echo >&2 "cannot create log directory '${LOG_HOME}/${_dir}'";
  	  echo >&2 "Startup failed."
  	  exit 1;
      fi
    fi
  done

  if [ "${_OS_NAME}" = "Linux" ] && [ ! -r /lib64/libpcre.so.0 ] && [ ! -r ${ENGN_HOME}/lib/libpcre.so.0 ]; then
    ln -s /lib64/libpcre.so.1 ${ENGN_HOME}/lib/libpcre.so.0
     echo "libpcre.so.0 link generated."
  fi

  if [ ${VELA_ENABLED} = "true" ]; then
    ${INSTALL_PATH}/vela/bin/start-vela.sh --silent
    check_vela_process $?
  fi
  
  # Start Apache
  if [ ! -z "${MONITORING_SERVICE_PORT}" ];then
    echo "Listen \${MONITORING_SERVICE_PORT}" > ${INSTALL_PATH}/conf/extra/httpd-monitoring-service-port.conf
  else
    echo "" > ${INSTALL_PATH}/conf/extra/httpd-monitoring-service-port.conf
  fi
  #${ENGN_HOME}/bin/apachectl -f ${INSTALL_PATH}/conf/httpd.conf -k start -D${MPM_TYPE} ${EXT_MODULE_DEFINES}
  ${ENGN_HOME}/bin/apachectl -f ${INSTALL_PATH}/conf/httpd.conf -k start -D${MPM_TYPE} ${EXT_MODULE_DEFINES} -DFOREGROUND
  check_web_process $?
else
   >&2 echo "Deny Access : [ ${RUNNER} ]. Not ${RUN_USER}" ;
   exit 0 ;
fi
