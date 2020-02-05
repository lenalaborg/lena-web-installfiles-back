#!/bin/sh

############ Start of default variable definition ############
SCRIPTPATH=`cd $(dirname $0) ; pwd -P`
ROOT_PROJECT_PATH=`cd ${SCRIPTPATH}/.. ; pwd -P`
PROJECT_NAME=`basename ${ROOT_PROJECT_PATH}`
############  End of default variable definition  ############


############ Start of loading common script ############
. ${ROOT_PROJECT_PATH}/bin/web-common.sh ${ROOT_PROJECT_PATH}
############  End of loading common script  ############

install_default_package ${1}

exit 0;
