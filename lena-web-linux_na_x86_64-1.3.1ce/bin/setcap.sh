#!/bin/bash


RUNDIR=`dirname "$0"`
LENA_HOME=`cd "$RUNDIR/.." ; pwd -P`
HTTPD_FILE=$LENA_HOME/modules/lena-web-pe/bin/httpd
LENA_USER=`cat $LENA_HOME/conf/agent.conf | grep "agent.server.user" | awk -F= '{print $2}'`

check_run_user() {
        RUN_USER=`whoami`
        if [ "$RUN_USER" != "root" ]; then
                echo "ERROR : This script must be run by the root user because of system operation."
                exit
        fi
}


check_setcap_enabled() {
        RET=`getcap $HTTPD_FILE`
        if [ -n "$RET" ]; then
                echo "Error: setcap httpd is already enabled"
                exit
        fi
}

check_setcap_disabled() {
        RET=`getcap $HTTPD_FILE`
        if [ ! -n "$RET" ]; then
                echo "Error: setcap httpd is already disabled"
                exit
        fi
}

create_setcap() {
        setcap 'cap_net_bind_service=+ep' $HTTPD_FILE
}

delete_setcap() {
        setcap -r $HTTPD_FILE
}

create_ld_config() {
		if `uname -r | grep -q amzn2`; then
        	echo $LENA_HOME/modules/lena-web-pe/lib/amzn2 > /etc/ld.so.conf.d/lena-x86_64.conf
		else
        	echo $LENA_HOME/modules/lena-web-pe/lib > /etc/ld.so.conf.d/lena-x86_64.conf
		fi		
        ldconfig > /dev/null 2>&1
}

delete_ld_config() {
        rm -f /etc/ld.so.conf.d/lena-x86_64.conf
        ldconfig
}


check_run_user
case $1 in
        enable)
                check_setcap_enabled
                create_setcap
                create_ld_config
                echo "setcap httpd is successfully enabled"
                ;;
        disable)
                check_setcap_disabled
                delete_setcap
                delete_ld_config
                echo "setcap httpd is successfully disabled"
                ;;
        *)
                echo "Usage: $0 {enable|disable}"
esac
