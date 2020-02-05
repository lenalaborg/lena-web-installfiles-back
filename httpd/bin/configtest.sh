#!/bin/sh

SCRIPTPATH=`cd $(dirname $0) ; pwd -P`
SCRIPT=$SCRIPTPATH/$(basename $0)

. ${SCRIPTPATH}/../env.sh

#echo "Test Configuration [lenaw] ... ${SERVER_ID}"

RUNNER=`whoami`

if [ ${RUNNER} = ${RUN_USER} ] || [ ${RUNNER} = root ]; then
  # Test Configuration
  ${ENGN_HOME}/bin/apachectl -t -f ${INSTALL_PATH}/conf/httpd.conf -D${MPM_TYPE} ${EXT_MODULE_DEFINES}
else
   echo "Deny Access : [ ${RUNNER} ]. Not ${RUN_USER}" ;
   exit 0 ;
fi
