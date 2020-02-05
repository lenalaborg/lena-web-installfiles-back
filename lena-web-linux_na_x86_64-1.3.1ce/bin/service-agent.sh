#!/bin/bash


RUNDIR=`dirname "$0"`
LENA_HOME=`cd "$RUNDIR/.." ; pwd -P`
LENA_CONF_DIR=$LENA_HOME/conf


check_run_user() {
        RUN_USER=`whoami`
        if [ "$RUN_USER" != "root" ]; then
                echo "ERROR : This script must be run by the root user because of SYSTEMD registration."
                exit
        fi
}

check_os_version() {
        uname -r | egrep -q "amzn2|el7"
        if [ $? -ne 0 ]; then
                echo "ERROR : This script must be run on Redhat_Based_Linux Verion 7."
                exit
        fi
}

check_agent_conf() {
        if [ ! -e $CONF_FILE ]; then
                echo "ERROR : agent.conf does not exist."
                exit
        fi
}

define_agent_info() {
        CONF_FILE=$LENA_CONF_DIR/agent.conf
        check_agent_conf
        while read LINE; do
                KEY=`echo $LINE | awk -F= '{print $1}'`
                VALUE=`echo $LINE | awk -F= '{print $2}'`
                if [ "$KEY" = "agent.server.user" ]; then
                        LENA_USER=$VALUE
                elif [ "$KEY" = "agent.server.port" ]; then
                        AGENT_PORT=$VALUE
                fi
        done < $CONF_FILE
	SERVICE_NAME="lena-agent-$AGENT_PORT"
}

check_service_template() {
        if [ ! -e $TEMP_FILE ]; then
                echo "ERROR : lena-service.template does not exist."
                exit
        fi
}

create_agent_service() {
        TEMP_FILE=$LENA_HOME/etc/script/lena-service.template
        NEW_FILE=$LENA_HOME/etc/script/$SERVICE_NAME.service
        check_service_template

        DESCRIPTION=$SERVICE_NAME
        EXECSTART=$LENA_HOME/bin/start-agent.sh
        EXECSTOP=$LENA_HOME/bin/stop-agent.sh
        WORKINGDIRECTORY=$LENA_HOME/bin

        cp $TEMP_FILE $NEW_FILE

        sed -i "s:DSCRTEMPLATE:$DESCRIPTION:g" $NEW_FILE
        sed -i "s:USERTEMPLATE:$LENA_USER:g" $NEW_FILE
        sed -i "s:EXECSTARTTEMPLATE:$EXECSTART:g" $NEW_FILE
        sed -i "s:EXECSTOPTEMPLATE:$EXECSTOP:g" $NEW_FILE
        sed -i "s:WORKDIRTEMPLATE:$WORKINGDIRECTORY:g" $NEW_FILE
}

check_service_running() {
	systemctl status $SERVICE_NAME > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "ERROR : $SERVICE_NAME.service is already registered and activated. You need to stop $SERVICE_NAME.service first."
		exit
	fi
}

register_service() {
	check_service_running
	
        mv $NEW_FILE /usr/lib/systemd/system/$SERVICE_NAME.service
        systemctl daemon-reload
        systemctl enable $SERVICE_NAME > /dev/null 2>&1
        echo "Service is Successfully registered : $SERVICE_NAME"
}

deregister_service() {
	check_service_running

	systemctl disable $SERVICE_NAME > /dev/null 2>&1
	rm -f /usr/lib/systemd/system/$SERVICE_NAME.service
	rm -f /etc/systemd/system/multi-user.target.wants/$SERVICE_NAME.service
	systemctl daemon-reload
	systemctl reset-failed
	echo "Service is Successfully deregistered : $SERVICE_NAME"
}


check_run_user
check_os_version
case $1 in
        register)
                define_agent_info
                create_agent_service
                register_service
                ;;
        deregister)
                define_agent_info
		deregister_service
                ;;
        *)
                echo "Usage: $0 {register|deregister}"

esac