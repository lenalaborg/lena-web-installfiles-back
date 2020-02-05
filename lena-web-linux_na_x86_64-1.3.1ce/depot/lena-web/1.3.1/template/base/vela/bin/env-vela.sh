#!/bin/sh
SCRIPTPATH=`cd $(dirname $0) ; pwd -P`
SCRIPT=${SCRIPTPATH}/$(basename $0)
export VELA_INSTALL_PATH=`cd ${SCRIPTPATH}/.. ; pwd -P`

. ${VELA_INSTALL_PATH}/../env.sh

export VELA_ID=vela_${SERVER_ID}
export VELA_PORT=`expr ${SERVICE_PORT} + 22`
export VELA_MAPPING_START_PORT=`expr ${SERVICE_PORT} + 50`
export VELA_MAPPING_END_PORT=`expr ${SERVICE_PORT} + 99`
export VELA_RUN_USER=${RUN_USER}
export VELA_LOG_DATE=`date +%Y%m%d`
export VELA_PID_FILE=${INSTALL_PATH}/vela.pid
export VELA_ENGINE_HOME=${ENGN_HOME}/vela-server/engine
export VELA_LOG_FILE_PATH=${LOG_HOME}/${VELA_ID}.log_${VELA_LOG_DATE}
export VELA_CONFIG_PATH=${VELA_INSTALL_PATH}/conf/vela.conf
export VELA_AUTHORIZED_KEYS_PATH=${VELA_INSTALL_PATH}/key/authorized-keys
