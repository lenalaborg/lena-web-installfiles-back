#!/bin/sh
# ---------------------------------------------------------------------------
# Stop script for the Reset JVM Route Value
# ---------------------------------------------------------------------------

RUNDIR=`dirname "$0"`
LENA_HOME=`cd "$RUNDIR/../.." ; pwd -P`
LENA_LOG_HOME=${LENA_HOME}/logs
LOG_HOME=${LENA_LOG_HOME}/lena-agent

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
		echo "JAVA_HOME is invalid. $JAVA_HOME";
		exit 1
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
			exit 2
		fi
		if is_valid_javahome ${input_java_path}; then
			export JAVA_HOME=${input_java_path} 
			save_javahome_info ${JAVA_HOME}
			return
		else
			echo "JAVA_HOME is invalid. ${input_java_path}";
		fi
	done
}

#check javahome path
check_javahome

export JAVA_HOME
export PATH=${PATH}:.

list=`ls ${LENA_HOME}/modules/lena-agent/lib/*.jar`
for i in `echo $list`
do
  AGENT_CLASS_PATH=$AGENT_CLASS_PATH:$i
done

JAVA_OPTS="-Dlena.home=${LENA_HOME} -Dlog.home=${LOG_HOME}"

CLASSPATH=${AGENT_CLASS_PATH}:${LENA_HOME}/modules/lena-agent/lib:${JAVA_HOME}/lib/tools.jar

${JAVA_HOME}/bin/java ${JAVA_OPTS} -cp .:${CLASSPATH} argo.node.agent.server.util.ResetJvmRoute $@
