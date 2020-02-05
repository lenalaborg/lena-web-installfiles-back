#!/bin/sh
# setup install configuration
setup_environment() {
  SCRIPT="$0"
  RUNDIR=`dirname "$SCRIPT"`
  LENA_HOME=`cd "$RUNDIR/.." ; pwd -P`
  LENA_CONF_FILE=${LENA_HOME}/conf/manager.conf

	list=`find ${LENA_HOME}/depot -name lena-core*.jar`
  for i in `echo $list`
  do
    LIB_CLASSPATH=$LIB_CLASSPATH:$i
    break;
  done
  CLASSPATH=${LIB_CLASSPATH}
}


is_valid_javahome() {
	local _javahome=$1
	
	if [ -z "${_javahome}" ]; then
		return 1
	fi
	
	if [ -r "${_javahome}/bin/java" ]; then
		return 0
	fi
	
	return 1
}

save_javahome_info(){
	local _javahome=$1
	if is_valid_javahome ${_javahome}; then
		echo ${_javahome} > ${LENA_HOME}/etc/info/java-home.info
	else
		info "JAVA_HOME is invalid. $JAVA_HOME";
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
			info "JAVA_HOME is invalid. ${input_java_path}";
		fi
	done
}

#function that prints out usage syntax
syntax () {
    echo "Usage :"
    echo "./crypt.sh [value to be encrypted]"
    echo " "
}

# Main Script Execution
setup_environment
check_javahome

if [ ! $# -eq 1 ] ; then
 syntax
else
  ${JAVA_HOME}/bin/java -Dlena.config=${LENA_CONF_FILE} -cp ${CLASSPATH} argo.server.security.CryptoManager e datasouce $1
fi