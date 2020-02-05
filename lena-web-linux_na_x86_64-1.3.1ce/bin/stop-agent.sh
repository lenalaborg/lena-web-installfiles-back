#!/bin/sh
# ---------------------------------------------------------------------------
# Stop script for the LENA Agent Server
# ---------------------------------------------------------------------------

RUNDIR=`dirname "$0"`
LENA_HOME=`cd "$RUNDIR/.." ; pwd -P`
LENA_LOG_HOME=${LENA_HOME}/logs
LOG_HOME=${LENA_LOG_HOME}/lena-agent
PATCH_LOG_HOME=${LENA_LOG_HOME}/lena-patcher

AUTO_UNREGIST=

#check arguments
if echo $* | egrep -q '[.*]?(-ur |-rt )' ; then

	while [ "$1" != "" ]; do
	    PARAM=`echo $1`
	    VALUE=`echo $2`
	    case $PARAM in
	        -h | --help)
	            echo "help"
	            exit
	            ;;
	        -ur)
	          #-ur option means that unregist node from manager 
	          AUTO_UNREGIST="-unReg $VALUE"
	          shift
	          shift
	          ;;
	        -f)
	          #-f option means that unregist regardless having clustered servers or servers
	          AUTO_UNREGIST="${AUTO_UNREGIST} -force"
	          shift
	          ;;
	        -rt)
	          #-rt option means Retry Timeout when call Manager Open API
	          AUTO_UNREGIST="${AUTO_UNREGIST} -retryTimout $VALUE"
	          shift
	          shift
	          ;;
	        -df)
	          #-df option means that Delete server Files on scaling-in.
			  AUTO_UNREGIST="${AUTO_UNREGIST} -deleteFiles"
			  shift
	          ;;
	        -ss)
	          #-ss option means that Stop Servers on scaling-in.
			  AUTO_UNREGIST="${AUTO_UNREGIST} -stopServer"
			  shift
	          ;;
	            
	        *)
	            echo "ERROR: unknown parameter \"$PARAM\""
	            exit 1
	            ;;   
	    esac
	done
fi


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

#check agent.conf
if [ ! -r "${LENA_HOME}/conf/agent.conf" ]; then
	while true; do
		echo "Input Agent port for LENA Agent. ( q: quit )"
		echo "Agent port (Default : 16800): "
		read agent_port
		if [ "${agent_port}" = "q" -o "${agent_port}" = "Q" ] ; then
			exit 1;
		fi
		AGENT_PORT=${agent_port}
		break;
	done
fi

#LOG_HOME
if [ ! -d "${LOG_HOME}"  ]; then
    mkdir -p ${LOG_HOME}
fi
#Log File
if [ ! -r "${LOG_HOME}/node-agent.log"  ]; then
    touch ${LOG_HOME}/node-agent.log
fi

export JAVA_HOME
export PATH=${PATH}:.

list=`ls ${LENA_HOME}/modules/lena-agent/lib/*.jar`
for i in `echo $list`
do
  AGENT_CLASS_PATH=$AGENT_CLASS_PATH:$i
done

CLASSPATH=${AGENT_CLASS_PATH}:${LENA_HOME}/modules/lena-agent/lib:${JAVA_HOME}/lib/tools.jar

JAVA_OPTS="-Xms64m -Xmx256m -Dlena.home=${LENA_HOME} -Dlog.home=${LOG_HOME} -Dpatch.log.home=${PATCH_LOG_HOME} -Djava.library.path=${LD_LIBRARY_PATH}:${LENA_HOME}/modules/lena-agent/lib/sigar"

${JAVA_HOME}/bin/java ${JAVA_OPTS} -cp .:${CLASSPATH} argo.node.agent.server.NodeAgentServer -config ${AGENT_PORT}

if [ $? = 0 ]; then
    ${JAVA_HOME}/bin/java ${JAVA_OPTS} -cp .:${CLASSPATH} argo.node.agent.server.NodeAgentServer -stop ${AGENT_PORT} ${AUTO_UNREGIST} 2>>${LOG_HOME}/node-agent.log
fi