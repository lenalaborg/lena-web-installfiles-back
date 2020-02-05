#!/bin/sh
echo "*******************************"
echo "*        LENA Version         *"
echo "*******************************"

ARGUMENTS="$@"
RUNDIR=`dirname "$0"`
LENA_HOME=`cd "$RUNDIR/.." ; pwd -P`

#check java_home
if [ -r "${LENA_HOME}/etc/info/java-home.info" ]; then
	JAVA_HOME=`cat "${LENA_HOME}/etc/info/java-home.info"`
else
	info "JAVA_HOME is invalid."
	end_fail
fi

# set installer lib path
INSTALLER_LIB_PATH=${LENA_HOME}/modules/lena-installer/lib
list=`ls ${INSTALLER_LIB_PATH}/*.jar`
for i in `echo $list`
do
  INSTALLER_LIB_PATH=$INSTALLER_LIB_PATH:$i
done

${JAVA_HOME}/bin/java -cp ${INSTALLER_LIB_PATH} -Duser_java.home=${JAVA_HOME} -Dlena.home=${LENA_HOME} "argo.install.Version" ${ARGUMENTS}

exit 0