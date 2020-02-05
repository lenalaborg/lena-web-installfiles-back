#!/bin/sh

SCRIPTPATH=`cd $(dirname $0) ; pwd -P`

export ENGN_HOME=`cd ${SCRIPTPATH}/../..; pwd -P`
export SERVER_ID=webd-lenaw
export SERVICE_PORT=8580
export RUN_USER=`whoami`
export HTTPS_SERVICE_PORT=`expr ${SERVICE_PORT} + 43`
export INSTALL_PATH=${SCRIPTPATH}
export DOC_ROOT=${INSTALL_PATH}/htdocs
export LOG_HOME=${INSTALL_PATH}/logs
export VELA_ENABLED=false
#export MONITORING_SERVICE_PORT=`expr ${SERVICE_PORT} + 10001`
export STAGING_SERVICE_PORT=`expr ${SERVICE_PORT} + 10000`
export STAGING_HTTPS_SERVICE_PORT=`expr ${HTTPS_SERVICE_PORT} + 10000`
export MPM_TYPE=MPM_EVENT
export GRACEFUL_SHUTDOWN_TIMEOUT=0
export LENA_NAME=${SERVER_ID}
export INST_NAME=${LENA_NAME}_`hostname`
export TRACE_DTM=5000000
export EXT_MODULE_NAMES=
export EXT_MODULE_DEFINES=

if [ ! -r ${ENGN_HOME}/modules/mod_mpm_event.so ]; then
	export MPM_TYPE=MPM_WORKER
fi

if [ -r ${ENGN_HOME}/modules/mod_pagespeed_ap24.so ]; then
	EXT_MODULE_NAMES="MOD_PAGESPEED $EXT_MODULE_NAMES"
	EXT_MODULE_DEFINES="-DMOD_PAGESPEED $EXT_MODULE_DEFINES"
fi

if [ -r ${ENGN_HOME}/modules/mod_lsc.so ]; then
	EXT_MODULE_NAMES="MOD_LSC $EXT_MODULE_NAMES"
	EXT_MODULE_DEFINES="-DMOD_LSC $EXT_MODULE_DEFINES"
fi

if [ -r ${ENGN_HOME}/modules/mod_usertrack.so ]; then
	EXT_MODULE_NAMES="MOD_USERTRACK $EXT_MODULE_NAMES"
	EXT_MODULE_DEFINES="-DMOD_USERTRACK $EXT_MODULE_DEFINES"
fi

if [ -r ${ENGN_HOME}/modules/mod_eum.so ]; then
	EXT_MODULE_NAMES="MOD_EUM $EXT_MODULE_NAMES"
	EXT_MODULE_DEFINES="-DMOD_EUM $EXT_MODULE_DEFINES"
fi

## LIBPATH
_OS_NAME=`uname -s`
if [ "${_OS_NAME}" = "AIX" ]; then
	export LIBPATH="${ENGN_HOME}/lib:/opt/freeware/lib64:/opt/freeware/lib:/usr/linux/lib64:${LIBPATH}"
elif `uname -r | grep -q amzn2`; then
    export LD_LIBRARY_PATH="${ENGN_HOME}/lib/amzn2:${LD_LIBRARY_PATH}"
else
    export LD_LIBRARY_PATH="${ENGN_HOME}/lib:${LD_LIBRARY_PATH}"
fi