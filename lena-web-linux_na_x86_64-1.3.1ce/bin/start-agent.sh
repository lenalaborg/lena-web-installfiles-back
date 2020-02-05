#!/bin/sh
# ---------------------------------------------------------------------------
# Start script for the LENA Agent Server
# ---------------------------------------------------------------------------

RUNDIR=`dirname "$0"`
LENA_HOME=`cd "$RUNDIR/.." ; pwd -P`
LENA_LOG_HOME=${LENA_HOME}/logs
LOG_HOME=${LENA_LOG_HOME}/lena-agent
PATCH_LOG_HOME=${LENA_LOG_HOME}/lena-patcher
DEFAULT_PORT=16800
RUNNER=`whoami`

# check install type
if [ -d "${LENA_HOME}/depot/lena-web" ] && [ ! -d "${LENA_HOME}/depot/lena-se" ]; then
 DEFAULT_PORT=16900
fi

ARG_AGENT_PORT=
ARG_JAVA_HOME=
ARG_REGIST_INFO=
ARG_REGIST_LEVEL=
ARG_REGIST_OPT=
ARG_NODE_NM=
ARG_NODE_GROUP_NM=
ARG_CLUSTER_NM=
ARG_MASTER_NODE_NM=
ARG_DELETE_SERVER_FILES=
ARG_RETRY_TIMEOUT=
ARG_LICENSE=
ARG_DEAMON=background
ARG_SERVER_NM=
ARG_START_SERVER=
AUTO_REGIST=
ARG_ADDRESS_TYPE=

#check arguments
if echo $* | egrep -q '[.*]?(-p |-j |-r |-rv |-ro |-ng |-nm |-cl |-ms |-rt |-lc |-d |-sn |-ss |-at )' ; then

	while [ "$1" != "" ]; do
	    PARAM=`echo $1`
	    VALUE=`echo $2`
	    case $PARAM in
	        -h | --help)
	            echo "help"
	            exit
	            ;;
	        -r)
	          ARG_REGIST_INFO=$VALUE
	          ;;
	        -rv)
	          ARG_REGIST_LEVEL=$VALUE
	          ;;
	        -ro)
	          ARG_REGIST_OPT=$VALUE
	          ;;
	        -p)
	          ARG_AGENT_PORT=$VALUE
	          ;;
	        -j)
	          ARG_JAVA_HOME=$VALUE
	          ;;
	        -nm)
	          ARG_NODE_NM=$VALUE
	          ;;
	        -ng)
	          ARG_NODE_GROUP_NM=$VALUE
	          ;;
	        -cl)
	          ARG_CLUSTER_NM=$VALUE
	          ;;
	        -ms)
	          ARG_MASTER_NODE_NM=$VALUE
	          ;;
	        -rt)
	          ARG_RETRY_TIMEOUT=$VALUE
	          ;;
	        -lc)
	          ARG_LICENSE=$VALUE
	          ;; 
	        -d)
	          ARG_DEAMON=$VALUE
	          ;; 
	        -sn)
	          ARG_SERVER_NM=$VALUE
	          ;; 
	        -ss)
	          ARG_START_SERVER=$VALUE
	          ;;  
	        -at)
	          ARG_ADDRESS_TYPE=$VALUE
	          ;;   
	            
	        *)
	            echo "ERROR: unknown parameter \"$PARAM\""
	            exit 1
	            ;;   
	    esac
	    shift
	    shift
	done
	
 else
    ARG_JAVA_HOME=$1
    ARG_AGENT_PORT=$2
    ARG_REGIST_INFO=$3
    ARG_NODE_NM=$4
    ARG_NODE_GROUP_NM=$5
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
		echo "JAVA_HOME is invalid. Please check if jdk is installed.";
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
			echo "JAVA_HOME is invalid. Please check if jdk is installed.";
		fi
	done
}

#check javahome path
if [ ! -z "${ARG_JAVA_HOME}" ]; then
        if is_valid_javahome ${ARG_JAVA_HOME} ; then
                export JAVA_HOME=${ARG_JAVA_HOME}
                save_javahome_info ${JAVA_HOME}
        else
                echo "JAVA_HOME is invalid. Please check if jdk is installed.";
                exit 1
        fi
fi

check_javahome

#check agent.conf
if [ ! -r "${LENA_HOME}/conf/agent.conf" ]; then
	#set auto regist info
	if [ ! -z "${ARG_REGIST_INFO}" ]; then
		AUTO_REGIST="-autoReg ${ARG_REGIST_INFO}"
				
		if [ ! -z "${ARG_REGIST_LEVEL}" ]; then
			AUTO_REGIST="${AUTO_REGIST} -registLevel ${ARG_REGIST_LEVEL}"
		fi
		if [ ! -z "${ARG_REGIST_OPT}" ]; then
			AUTO_REGIST="${AUTO_REGIST} -registOption ${ARG_REGIST_OPT}"
		fi
		if [ ! -z "${ARG_NODE_NM}" ]; then
			AUTO_REGIST="${AUTO_REGIST} -nm ${ARG_NODE_NM}"
		fi
		if [ ! -z "${ARG_NODE_GROUP_NM}" ]; then
			AUTO_REGIST="${AUTO_REGIST} -ng ${ARG_NODE_GROUP_NM}"
		fi
		if [ ! -z "${ARG_CLUSTER_NM}" ]; then
			AUTO_REGIST="${AUTO_REGIST} -cluster ${ARG_CLUSTER_NM}"
		fi
		if [ ! -z "${ARG_MASTER_NODE_NM}" ]; then
			AUTO_REGIST="${AUTO_REGIST} -masterServer ${ARG_MASTER_NODE_NM}"
		fi
		if [ ! -z "${ARG_RETRY_TIMEOUT}" ]; then
			AUTO_REGIST="${AUTO_REGIST} -retryTimout ${ARG_RETRY_TIMEOUT}"
		fi
		if [ ! -z "${ARG_LICENSE}" ]; then
			AUTO_REGIST="${AUTO_REGIST} -license ${ARG_LICENSE}"
		fi
		if [ ! -z "${ARG_SERVER_NM}" ]; then
			AUTO_REGIST="${AUTO_REGIST} -serverNm ${ARG_SERVER_NM}"
		fi
		if [ ! -z "${ARG_START_SERVER}" ]; then
			AUTO_REGIST="${AUTO_REGIST} -ss ${ARG_START_SERVER}"
		fi
		if [ ! -z "${ARG_ADDRESS_TYPE}" ]; then
			AUTO_REGIST="${AUTO_REGIST} -addressType ${ARG_ADDRESS_TYPE}"
		fi
	fi
	if [ -z "${ARG_AGENT_PORT}" ]; then
        while true; do
            echo "Input Agent port for LENA Agent. ( q: quit )"
            echo "Agent port (Default : ${DEFAULT_PORT}): "
            read agent_port
            if [ "${agent_port}" = "q" -o "${agent_port}" = "Q" ] ; then
                exit 1;
            fi
            AGENT_PORT=${agent_port}
            break;
        done

        while true; do
            echo "Input Agent user for LENA Agent. ( q: quit )"
            echo "Agent user (Default : ${RUNNER}): "
            read run_user
            if [ "${run_user}" = "q" -o "${run_user}" = "Q" ] ; then
                exit 1;
            fi
                    if [ "${run_user}" = "" ] ; then
                            break;
                    fi
            if [ "${run_user}" != "${RUNNER}" ] ; then
                            echo "Deny Access : [ ${run_user} ]. Not ${RUNNER}"
                exit 1;
            fi
            break;
        done
    else
        AGENT_PORT=${ARG_AGENT_PORT}
    fi
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

#JAVA_OPTS="-Xms64m -Xmx256m -Dlena.home=${LENA_HOME} -Dlog.home=${LOG_HOME} -Dpatch.log.home=${PATCH_LOG_HOME} -Djava.library.path=${LD_LIBRARY_PATH}:${LENA_HOME}/modules/lena-agent/lib/sigar -Djava.net.preferIPv4Stack=true -Dlicense.check-type=hostname"
JAVA_OPTS="-Xms64m -Xmx256m -Dlena.home=${LENA_HOME} -Dlog.home=${LOG_HOME} -Dpatch.log.home=${PATCH_LOG_HOME} -Djava.library.path=${LD_LIBRARY_PATH}:${LENA_HOME}/modules/lena-agent/lib/sigar -Djava.net.preferIPv4Stack=true"

${JAVA_HOME}/bin/java ${JAVA_OPTS} -cp .:${CLASSPATH} argo.node.agent.server.NodeAgentServer -config ${AGENT_PORT}
if [ $? = 0 ]; then
    echo "LENA Agent is started."
    command -v setsid >/dev/null
    if [ $? = 0 ]; then
    	if [ "${ARG_DEAMON}" = "foreground" ]; then
      		setsid ${JAVA_HOME}/bin/java ${JAVA_OPTS} -cp .:${CLASSPATH} argo.node.agent.server.NodeAgentServer -start ${AGENT_PORT} ${AUTO_REGIST} >> ${LOG_HOME}/node-agent.log 2>&1
      	else
      		setsid ${JAVA_HOME}/bin/java ${JAVA_OPTS} -cp .:${CLASSPATH} argo.node.agent.server.NodeAgentServer -start ${AGENT_PORT} ${AUTO_REGIST} >> ${LOG_HOME}/node-agent.log 2>&1 &
      	fi
    else
    	if [ "${ARG_DEAMON}" = "foreground" ]; then
      		${JAVA_HOME}/bin/java ${JAVA_OPTS} -cp .:${CLASSPATH} argo.node.agent.server.NodeAgentServer -start ${AGENT_PORT} ${AUTO_REGIST} >> ${LOG_HOME}/node-agent.log 2>&1
      	else
      		${JAVA_HOME}/bin/java ${JAVA_OPTS} -cp .:${CLASSPATH} argo.node.agent.server.NodeAgentServer -start ${AGENT_PORT} ${AUTO_REGIST} >> ${LOG_HOME}/node-agent.log 2>&1 &
      	fi
    fi
else
    echo "LENA Agent is not started."
fi


