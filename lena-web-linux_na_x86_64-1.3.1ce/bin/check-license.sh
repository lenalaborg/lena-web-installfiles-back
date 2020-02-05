#!/bin/sh
# ---------------------------------------------------------------------------
# Start script for the LENA License Check
# ---------------------------------------------------------------------------

RUNDIR=`dirname "$0"`
LENA_HOME=`cd "$RUNDIR/.." ; pwd -P`
CPUFILE=/proc/cpuinfo
HYPER_THREADING_ENABLED=false

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
		if [ -d ${LENA_HOME}/etc/info ]; then
			echo ${_javahome} > ${LENA_HOME}/etc/info/java-home.info
		fi
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

check_hyperthreading_enabled() {
	if [ "`uname -s`" = "Linux" ]; then
    	_thread_per_core=`lscpu | grep "Thread(s) per core:" | awk '{print $4}'`
    	
		if [ ${_thread_per_core} -eq 2 ] ; then
		    HYPER_THREADING_ENABLED=true
		else
		    HYPER_THREADING_ENABLED=false
		fi
	fi
}

#check javahome path
check_javahome
check_hyperthreading_enabled

if [ -d ${LENA_HOME}/modules/lena-agent/lib ]; then
	list=`ls ${LENA_HOME}/modules/lena-agent/lib/*.jar`
else
	list=`ls ${LENA_HOME}/lib/*.jar`
fi

for i in `echo $list`
do
	LICENSE_LIB_PATH=$LICENSE_LIB_PATH:$i
done

_CLASSPATH="-cp ${LICENSE_LIB_PATH}"

_JAVA_OPTS="-Dlicense.file=${LENA_HOME}/license/license.xml"
_JAVA_OPTS="${_JAVA_OPTS} -Dlena.home=${LENA_HOME}"
_JAVA_OPTS="${_JAVA_OPTS} -Dlicense.debug-enabled=false"
_JAVA_OPTS="${_JAVA_OPTS} -Djava.net.preferIPv4Stack=true"
_JAVA_OPTS="${_JAVA_OPTS} -Dlicense.check-hyperthreading-enabled=${HYPER_THREADING_ENABLED}"
_JAVA_OPTS="${_JAVA_OPTS} -Dlicense.showHostAddress=true"
#_JAVA_OPTS="${_JAVA_OPTS} -Dlicense.check-type=hostname"

${JAVA_HOME}/bin/java ${_CLASSPATH} ${_JAVA_OPTS} "lena.license.LicenseCheck"

exit 0