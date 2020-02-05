#!/bin/sh

# ---------------------------------------------------------------------------
# web-server compile script
# ---------------------------------------------------------------------------

SCRIPTPATH=`cd $(dirname $0) ; pwd -P`
LENA_HOME=`cd ${SCRIPTPATH}/.. ; pwd -P`

. ${LENA_HOME}/bin/web-common.sh ${LENA_HOME}

setup_environment() {
	if [ -z "${WEB_ENGINE_TARGET_PATH}" ]; then
		if [ "${SERVER_TYPE}" = "apache-server" ]; then
			WEB_ENGINE_TARGET_PATH=${LENA_HOME}/modules/${HTTPD_22_DEPOT_NAME}
		else
			WEB_ENGINE_TARGET_PATH=${LENA_HOME}/modules/${WEB_SERVER_DEPOT_NAME}
		fi
	fi
	
	if [ -r "${LENA_HOME}/etc/info/web-server-engine-path.info" ]; then
		WEB_ENGINE_TARGET_PATH=`cat ${LENA_HOME}/etc/info/web-server-engine-path.info`
		info "web-server engine is already compiled!!"
		end_fail
	else
		info "Input Web Server engine install path. ( q: quit )"
		info "Default install path : $WEB_ENGINE_TARGET_PATH "
		read input_web_server_engine_path
		if [ "$input_web_server_engine_path" = "q" -o "$input_web_server_engine_path" = "Q" ] ; then
			end_abort
		fi
		if [ "$input_web_server_engine_path" != "" ] ; then
			WEB_ENGINE_TARGET_PATH=$input_web_server_engine_path
		fi
	fi
}

compile_lena_web_server_all() {
	if [ "${_OS_NAME}" = "AIX" ]; then
		load_environment_vairable_for_aix xlc
		compile_web_engine ${WEB_SERVER_DEPOT_PATH}/module/web-engine/src ${WEB_ENGINE_TARGET_PATH}
		check_exit_code $?
		
		compile_web_connectors ${WEB_SERVER_DEPOT_PATH}/module/web-connectors/src ${WEB_ENGINE_TARGET_PATH}
		check_exit_code $?
		
		#setup_security ${WEB_ENGINE_TARGET_PATH}
		#check_exit_code $?
	else
		install_default_package ${SERVER_TYPE}
		
		compile_web_engine ${WEB_SERVER_DEPOT_PATH}/module/web-engine/src ${WEB_ENGINE_TARGET_PATH}
		check_exit_code $?
		
		compile_web_vela_server ${WEB_SERVER_DEPOT_PATH}/module/web-vela-server/src ${WEB_ENGINE_TARGET_PATH}/vela-server/engine
		check_exit_code $?
		
		compile_web_connectors ${WEB_SERVER_DEPOT_PATH}/module/web-connectors/src ${WEB_ENGINE_TARGET_PATH}
		check_exit_code $?
		
		#setup_security ${WEB_ENGINE_TARGET_PATH}
		#check_exit_code $?
	fi
	
	if [ -f "${LENA_HOME}/modules/lena-web-pe/modules/mod_cmx.so" ]; then
		cp -f ${LENA_HOME}/modules/lena-web-pe/modules/mod_cmx.so ${WEB_ENGINE_TARGET_PATH}/modules
	fi
	if [ -f "${LENA_HOME}/modules/lena-web-pe/modules/mod_fox.so" ]; then
		cp -f ${LENA_HOME}/modules/lena-web-pe/modules/mod_fox.so ${WEB_ENGINE_TARGET_PATH}/modules
	fi
	if [ -f "${LENA_HOME}/modules/lena-web-pe/modules/mod_lsc.so" ]; then
		cp -f ${LENA_HOME}/modules/lena-web-pe/modules/mod_lsc.so ${WEB_ENGINE_TARGET_PATH}/modules
	fi
}

compile_apache_web_server_all() {
	install_default_package ${SERVER_TYPE}

	compile_apache_server ${WEB_SERVER_DEPOT_PATH}/module ${WEB_ENGINE_TARGET_PATH}
	check_exit_code $?
	
	compile_tomcat_connectors ${CONNECTOR_DEPOT_PATH}/module/src ${WEB_ENGINE_TARGET_PATH}
	check_exit_code $?
}


COMMAND=${1}
SERVER_TYPE=${2}
WEB_ENGINE_TARGET_PATH=${3}
if [ -z "${COMMAND}" ]; then
	COMMAND="compile"
fi

if [ -z "${SERVER_TYPE}" ]; then
	SERVER_TYPE="lena-web"
fi
setup_environment
if [ "${SERVER_TYPE}" = "apache-server" ]; then
	WEB_SERVER_DEPOT_PATH=${LENA_HOME}/depot/${HTTPD_22_DEPOT_NAME}/${HTTPD_22_VERSION}
	CONNECTOR_DEPOT_PATH=${LENA_HOME}/depot/${TOMCAT_CONNECTORS_DEPOT_NAME}/${TOMCAT_CONNECTORS_VERSION}
	chmod -R 755 ${WEB_SERVER_DEPOT_PATH}
	compile_apache_web_server_all
else
	WEB_SERVER_DEPOT_PATH=${LENA_HOME}/depot/${WEB_SERVER_DEPOT_NAME}/${WEB_SERVER_VERSION}
	chmod -R 755 ${WEB_SERVER_DEPOT_PATH}
	compile_lena_web_server_all
fi

echo ${WEB_ENGINE_TARGET_PATH} > ${LENA_HOME}/etc/info/web-server-engine-path.info

info_emphasized "Compile is completed."
exit 0;
