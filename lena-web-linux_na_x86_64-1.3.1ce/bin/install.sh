#!/bin/sh

echo "*******************************"
echo "*  LENA Server Install !      *"
echo "*******************************"

RUNDIR=`dirname "$0"`
LENA_HOME=`cd "$RUNDIR/.." ; pwd -P`
RUN_USER=`whoami`
HOSTNAME=`hostname`
COMMAND="$1"
SERVER_TYPE="$2"
IS_DEBUG_ENABLED="false"
LENA_LOG_HOME=${LENA_HOME}/logs
LOG_HOME=${LENA_LOG_HOME}/lena-installer

debug ( ) {
	if [ "${IS_DEBUG_ENABLED}" = "true" ]; then
		echo "$*"
	fi
}

info ( ) {
	echo "$*"
}

end_success ( ) {
	info "Execution is completed.!!"
	exit 0
}

end_fail ( ) {
	info "Execution is failed.!!"
	exit 1
}

end_abort ( ) {
	info "Execution is aborted.!!"
	exit 2
}

check_process() {
	if [ "`uname -s`" = "HP-UX" ]; then
		local is_alive=`ps -efx | grep "lena.home=${LENA_HOME}" | grep "argo.install" | wc -l`
	else
		local is_alive=`ps -ef | grep "lena.home=${LENA_HOME}" | grep "argo.install" | wc -l`
	fi
	
  if [ ${is_alive} -ne 0 ]; then
	    info "Another install process is already running."
	    end_fail
   fi
}

is_valid_javahome() {
	local _javahome=$1
	
	if [ -z "${_javahome}" ]; then
		return 1
	fi
	
	if [ ! -r "${_javahome}/bin/java" ]; then
		return 1
	fi
	
	if [ ! -r "${_javahome}/lib/tools.jar" ]; then
		return 1
	fi
	
	return 0
}

save_javahome_info(){
	local _javahome=$1
	if is_valid_javahome ${_javahome}; then
		echo ${_javahome} > ${LENA_HOME}/etc/info/java-home.info
	else
		echo "JAVA_HOME is invalid. Please check if jdk is installed.";
		end_fail
	fi
}

check_javahome() {
	if [ -r "${LENA_HOME}/etc/info/java-home.info" ]; then
		info_java_path=`cat "${LENA_HOME}/etc/info/java-home.info"`
		if is_valid_javahome ${info_java_path}; then
			export JAVA_HOME=${info_java_path}
			return
		fi
	fi
	
	while true; do
		echo "Input JAVA_HOME path for LENA. ( q: quit )"
		echo "JAVA_HOME PATH : "
		read input_java_path
		if [ "${input_java_path}" = "q" -o "${input_java_path}" = "Q" ] ; then
			end_abort
		fi
		if is_valid_javahome ${input_java_path}; then
			export JAVA_HOME=${input_java_path} 
			save_javahome_info ${JAVA_HOME}
			return
		else
			echo "JAVA_HOME is invalid. Please check if jdk is installed.";
		fi
	done
}

RESULT_FORMAT=text
#check arguments
for current_argument in $@; do
	if is_valid_javahome ${current_argument}; then
		save_javahome_info ${current_argument}
	elif [ "${current_argument}" = "--json" ]; then
		RESULT_FORMAT=json
	else
		ARGUMENTS="$ARGUMENTS $current_argument"
	fi
done

#check javahome path
check_javahome


# set installer lib path
INSTALLER_LIB_PATH=${LENA_HOME}/modules/lena-installer/lib
list=`ls ${INSTALLER_LIB_PATH}/*.jar`
for i in `echo $list`
do
  INSTALLER_LIB_PATH=$INSTALLER_LIB_PATH:$i
done

debug "RUNDIR : ${RUNDIR}"
debug "LENA_HOME : ${LENA_HOME}"
debug "COMMAND : ${COMMAND}"
debug "SERVER_TYPE : ${SERVER_TYPE}"
debug "JAVA_HOME : ${JAVA_HOME}"
debug "INSTALLER_LIB_PATH : ${INSTALLER_LIB_PATH}"
debug "ARGUMENTS : ${ARGUMENTS}"

_CLASSPATH="-cp ${INSTALLER_LIB_PATH}"
_JAVA_OPTS="-d64 -Duser_java.home=${JAVA_HOME} -Dlena.home=${LENA_HOME} -Dhostname=${HOSTNAME} -Drun_user=${RUN_USER} -Dis_debug_enabled=${IS_DEBUG_ENABLED} -Dlog.home=${LOG_HOME} -Dresult.format=${RESULT_FORMAT}"

case ${COMMAND} in
	compile)
		if [ "${SERVER_TYPE}" = "apache-server" ] || [ "${SERVER_TYPE}" = "lena-web" ]; then
			${LENA_HOME}/bin/web-compile.sh ${ARGUMENTS}
		else
			${JAVA_HOME}/bin/java ${_CLASSPATH} ${_JAVA_OPTS} "argo.install.Main"
			end_fail
		fi
  	;;
	modify)
		debug ${JAVA_HOME}/bin/java ${_CLASSPATH} ${_JAVA_OPTS} "argo.install.Modify" ${ARGUMENTS}
		check_process
		${JAVA_HOME}/bin/java ${_CLASSPATH} ${_JAVA_OPTS} "argo.install.Modify" ${ARGUMENTS}
	;;
	*)
		debug ${JAVA_HOME}/bin/java ${_CLASSPATH} ${_JAVA_OPTS} "argo.install.Main" ${ARGUMENTS}
		check_process
		${JAVA_HOME}/bin/java ${_CLASSPATH} ${_JAVA_OPTS} "argo.install.Main" ${ARGUMENTS}
	;;
esac

EXIT_CODE=$?
if [ ${EXIT_CODE} -eq 0 ]; then
	end_success
elif [ ${EXIT_CODE} -eq 2 ]; then
	end_abort
else
	end_fail
fi

exit 0