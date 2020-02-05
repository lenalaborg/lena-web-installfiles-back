#!/bin/sh

SCRIPTPATH=`cd $(dirname $0) ; pwd -P`
SCRIPT=$SCRIPTPATH/$(basename $0)

. ${SCRIPTPATH}/../env.sh

${ENGN_HOME}/bin/httpd -V -f ${INSTALL_PATH}/conf/httpd.conf -D${MPM_TYPE}

exit 0;