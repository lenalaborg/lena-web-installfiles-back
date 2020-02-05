#!/bin/bash

RUNDIR=`dirname "$0"`
LENA_HOME=`cd "$RUNDIR/.." ; pwd -P`
INSTALL_INFO=$LENA_HOME/etc/info/install-info.xml



print_kv() {
        printf "| %-23s | %s\n" "$1" "$2"
}
print_skv() {
        printf "| %-23s |   - %s\n" "$1" "$2"
}
print_sskv() {
        printf "| %-23s |     - %s\n" "$1" "$2"
}
print_ssskv() {
        printf "| %-23s |       - %s\n" "$1" "$2"
}
print_sssskv() {
        printf "| %-23s |         - %s\n" "$1" "$2"
}
print_ssssskv() {
        printf "| %-23s |           - %s\n" "$1" "$2"
}
print_tl() {
        printf "+-------------------------+-------------------------------------------------------------------\n"
}
print_bl() {
        printf "+-------------------------+-------------------------------------------------------------------\n\n"
}
print_dl() {
        printf "**********************************************************************************************\n\n"
}
print_h() {
        printf "[ %s Information ]\n" "$1"
}


print_host_server_info() {
        print_h "Host Server"
        print_tl
        print_kv 'Hostname' `hostname`
        print_kv 'CPU Count' `cat /proc/cpuinfo | grep "physical id" | wc -l`
        print_kv 'HyperThreading' `chk_ht`
        print_kv 'Memory Total' "`free -m | grep Mem | awk '{print $2}'` MB"
        print_kv 'OS' "`uname -sr`"
        print_bl
}

chk_ht() {
        COND=`lscpu | grep "Thread(s) per core:" | awk -F: '{print $2}'`
        if [ $COND -eq 2 ]; then
                echo "Enabled"
        else
                echo "Disabled"
        fi
}

print_lena_manager_info() {
        MGR_ENV_FILE=$LENA_HOME/bin/env-manager.sh
        MGR_CONF_FILE=$LENA_HOME/conf/manager.conf
        if [ ! -e $MGR_ENV_FILE ]; then
                return
        fi
        source $MGR_ENV_FILE
        print_h "LENA Manager"
        print_tl
        print_kv 'LENA Version' `$LENA_HOME/bin/version.sh | grep ' - Version' | awk -F: '{print $2}'`
        print_kv 'LENA Home' $LENA_HOME
        print_kv 'Start Script' $LENA_HOME/bin/start-manager.sh
        print_kv 'Stop Script' $LENA_HOME/bin/stop-manager.sh
        print_kv 'Log Home' $LOG_HOME
        print_kv 'Java Version' `$JAVA_HOME/bin/java -version 2>&1 | grep version | awk -F\" '{print $2}'`
        print_kv 'Java Home' $JAVA_HOME
        print_kv 'Service Port' "TCP $SERVICE_PORT"
        print_kv 'Advertiser Port' "UDP `cat $MGR_CONF_FILE | grep dataudp.port | awk -F= '{print $2}'`"
        print_kv 'Run User' $WAS_USER
        print_bl
}

print_lena_agent_info() {
        RELEASE_FILE=$LENA_HOME/etc/info/release-info.xml
        LENA_TYPE=`cat $RELEASE_FILE | grep type | awk -F'>|<' '{print $3}'`
        if [ "$LENA_TYPE" = "lena-enterprise" ] || [ "$LENA_TYPE" = "lena-standard" ] || [ "$LENA_TYPE" = "lena-exclusive" ]
        then
                print_h "LENA WAS Agent"
        elif [ "$LENA_TYPE" = "lena-web" ]; then
                print_h "LENA WEB Agent"
        else
                return
        fi
        AGENT_CONF_FILE=$LENA_HOME/conf/agent.conf
        INFO_PATH=$LENA_HOME/etc/info

        eval "LENA_LOG_HOME=`cat $LENA_HOME/bin/start-agent.sh | grep LENA_LOG_HOME= | awk -F= '{print $2}'`"
        eval "LOG_HOME=`cat $LENA_HOME/bin/start-agent.sh | grep LOG_HOME= | egrep -v 'LENA_LOG_HOME=|PATCH_LOG_HOME=' | awk -F= '{print $2}'`"
        JAVA_HOME=`cat $LENA_HOME/etc/info/java-home.info`

        print_tl
        print_kv 'Node Type' $LENA_TYPE
        print_kv 'Node Version' `cat $RELEASE_FILE | grep -1a type | grep version | awk -F'<|>' '{print $3}'`
        print_kv 'Node Home' $LENA_HOME
        print_kv 'Start Script' $LENA_HOME/bin/start-agent.sh
        print_kv 'Stop Script' $LENA_HOME/bin/stop-agent.sh
        print_kv 'Log Home' $LOG_HOME
        print_kv 'Java Version' `$JAVA_HOME/bin/java -version 2>&1 | grep version | awk -F\" '{print $2}'`
        print_kv 'Java Home' $JAVA_HOME
        print_kv 'Agent Port' `cat $AGENT_CONF_FILE | grep agent.server.port | awk -F= '{print $2}'`
        print_kv 'Run User' `cat $AGENT_CONF_FILE | grep agent.server.user | awk -F= '{print $2}'`
        print_bl
}

repeat_lena_was_instances_info() {
        if [ "$LENA_TYPE" != "lena-enterprise" ] && [ "$LENA_TYPE" != "lena-standard" ] && [ "$LENA_TYPE" != "lena-exclusive" ]
        then
                return
        fi

        SERVERS=$LENA_HOME/servers
        for SERVER in $SERVERS/*
        do
                if [ "$SERVER" = "$SERVERS/*" ]; then
                        return
                fi
                print_lena_was_instance_info $SERVER
        done
}

print_lena_was_instance_info() {
        SERVER_HOME=$1
        if [ -e $SERVER_HOME/session.conf ]; then
                return
        fi

        ENV_FILE=$SERVER_HOME/env.sh
        SETENV_FILE=$SERVER_HOME/bin/setenv.sh
        source $ENV_FILE
        source $SETENV_FILE
        SERVER_CONF_DIR=$SERVER_HOME/conf


        print_h "LENA WAS Instance Information"
        print_tl
        print_kv 'Instance ID' $SERVER_ID
        print_kv 'Instance Type' `cat $INSTALL_INFO | grep -2a "$SERVER_ID" | grep type | awk -F'<|>' '{print $3}'`
        print_kv 'Instance Version' `cat $INSTALL_INFO | grep -2a "$SERVER_ID" | grep version | awk -F'<|>' '{print $3}'`
        print_kv 'Instance Home' $SERVER_HOME
        print_kv 'Start Script' $SERVER_HOME/start.sh
        print_kv 'Stop Script' $SERVER_HOME/stop.sh
        print_kv 'Log Home' $LOG_HOME
        print_kv 'Dump Home' $DUMP_HOME
        print_kv 'Java Version' `$JAVA_HOME/bin/java -version 2>&1 | grep version | awk -F\" '{print $2}'`
        print_kv 'Java Home' $JAVA_HOME
        print_kv 'Heap Memory' "`cat $SETENV_FILE | egrep 'Xms|Xmx' | grep -v \# | awk -F'}|\"' '{print $3}' | cut -b2-`"
        print_kv 'JVM Route' `cat $ENV_FILE | grep JVM_ROUTE | awk -F= '{print $2}'`
        print_kv 'Run User' `cat $ENV_FILE | grep WAS_USER | awk -F= '{print $2}'`
        print_connector_info $SERVER_CONF_DIR
        repeat_applications_info $SERVER_CONF_DIR
        repeat_datasources_info $SERVER_CONF_DIR
        print_session_cluster_info $SERVER_CONF_DIR
        print_bl
}

print_connector_info() {
        print_tl
        CONF_DIR=$1
        print_kv 'Connector' '[1] HTTP/1.1'
        print_skv ' - Port' $SERVICE_PORT
        print_skv ' - Max Threads' `cat $CONF_DIR/server.xml | grep "<Connector" | grep "HTTP/1.1" | awk -F'maxThreads=' '{print $2}' | awk -F\" '{print $2}'`
        print_skv ' - URI Encoding' `cat $CONF_DIR/server.xml | grep "<Connector" | grep "HTTP/1.1" | awk -F'URIEncoding=' '{print $2}' | awk -F\" '{print $2}'`
        print_skv ' - Connection Timeout' `cat $CONF_DIR/server.xml | grep "<Connector" | grep "HTTP/1.1" | awk -F'connectionTimeout=' '{print $2}' | awk -F\" '{print $2}'`
        print_kv 'Connector' '[2] AJP/1.3'
        print_skv ' - Port' `expr $SERVICE_PORT - 71`
        print_skv ' - Max Threads' `cat $CONF_DIR/server.xml | grep "<Connector" | grep "AJP/1.3" | awk -F'maxThreads=' '{print $2}' | awk -F\" '{print $2}'`
        print_skv ' - URI Encoding' `cat $CONF_DIR/server.xml | grep "<Connector" | grep "AJP/1.3" | awk -F'URIEncoding=' '{print $2}' | awk -F\" '{print $2}'`
        print_skv ' - Connection Timeout' `cat $CONF_DIR/server.xml | grep "<Connector" | grep "AJP/1.3" | awk -F'connectionTimeout=' '{print $2}' | awk -F\" '{print $2}'`
}

repeat_applications_info() {
        CONF_DIR=$1
        CNT=1
        for APPLICATION in $CONF_DIR/Catalina/localhost/*
        do
                if [ "$APPLICATION" = "$CONF_DIR/Catalina/localhost/*" ]; then
                        return
                fi
                if [ $CNT -eq 1 ]; then
                        print_tl
                fi
                print_application_info $APPLICATION
                CNT=`expr $CNT + 1`
        done
}

print_application_info() {
        CONTEXT_FILE=$1
        print_kv 'Application' "[$CNT] `cat $CONTEXT_FILE | grep '<Context' | awk -Fpath= '{print $2}' | awk -F'\"' '{print $2}'`"
        print_skv ' - DocBase' `cat $CONTEXT_FILE | grep '<Context' | awk -FdocBase= '{print $2}' | awk -F'\"' '{print $2}'`
        SSCOOKIENAME=`cat $CONTEXT_FILE | grep '<Context' | awk -FsessionCookieName= '{print $2}' | awk -F'\"' '{print $2}'`
        if [ -z $SSCOOKIENAME ]; then
                SSCOOKIENAME=JSESSIONID
        fi
        print_skv ' - SessionCookie' $SSCOOKIENAME
}

repeat_datasources_info() {
        CONF_DIR=$1
        CNT=1

        while read LINE
        do
                if [ $CNT -eq 1 ]; then
                        print_tl
                fi
                JNDI=`echo $LINE | awk -Fglobal= '{print $2}' | awk -F'\"' '{print $2}'`
                RESOURCE=`cat $CONF_DIR/server.xml | grep $JNDI`
                SCOPE="Global + ResourceLink(Context)"
                print_datasource_info
                CNT=`expr $CNT + 1`
        done < <(grep '<ResourceLink' $CONF_DIR/context.xml)

        for CONTEXT_FILE in $CONF_DIR/Catalina/localhost/*
        do
                if [ "$APPLICATION" = "$CONF_DIR/Catalina/localhost/*" ]; then
                        break
                fi
                CONTEXT_ROOT=`cat $CONTEXT_FILE | grep '<Context' | awk -Fpath= '{print $2}' | awk -F'\"' '{print $2}'`
                while read LINE
                do
                        JNDI=`echo $LINE | awk -Fglobal= '{print $2}' | awk -F'\"' '{print $2}'`
                        RESOURCE=`cat $CONF_DIR/server.xml | grep $JNDI`
                        if [ -z "$RESOURCE" ]; then
                                continue
                        fi
                        SCOPE="Global + ResourceLink(Application:$CONTEXT_ROOT)"
                        print_datasource_info
                        CNT=`expr $CNT + 1`
                done < <(grep '<ResourceLink' $CONTEXT_FILE)
        done

        while read RESOURCE
        do
                JNDI=`echo $RESOURCE | awk -F' name=' '{print $2}' | awk -F'\"' '{print $2}'`
                SCOPE="Context"
                print_datasource_info
                CNT=`expr $CNT + 1`
        done < <(grep '<Resource ' $CONF_DIR/context.xml)

        for CONTEXT_FILE in $CONF_DIR/Catalina/localhost/*
        do
                if [ "$APPLICATION" = "$CONF_DIR/Catalina/localhost/*" ]; then
                        break
                fi
                CONTEXT_ROOT=`cat $CONTEXT_FILE | grep '<Context' | awk -Fpath= '{print $2}' | awk -F'\"' '{print $2}'`
                while read RESOURCE
                do
                        JNDI=`echo $RESOURCE | awk -F' name=' '{print $2}' | awk -F'\"' '{print $2}'`
                        SCOPE="Application:$CONTEXT_ROOT"
                        print_datasource_info
                        CNT=`expr $CNT + 1`
                done < <(grep '<Resource ' $CONTEXT_FILE)
        done
}

print_datasource_info() {
        print_kv 'DataSource' "[$CNT] $JNDI"
        print_skv ' - Scope' "$SCOPE"
        print_skv ' - URL' "`echo $RESOURCE | awk -Furl= '{print $2}' | awk -F'\"' '{print $2}'`"
        print_skv ' - User' `echo $RESOURCE | awk -Fusername= '{print $2}' | awk -F'\"' '{print $2}'`

        MINIDLE=`echo $RESOURCE | awk -FminIdle= '{print $2}' | awk -F'\"' '{print $2}'`
        MAXIDLE=`echo $RESOURCE | awk -FmaxIdle= '{print $2}' | awk -F'\"' '{print $2}'`
        INITIALSIZE=`echo $RESOURCE | awk -FinitialSize= '{print $2}' | awk -F'\"' '{print $2}'`
        MAXACTIVE=`echo $RESOURCE | awk -FmaxActive= '{print $2}' | awk -F'\"' '{print $2}'`

        print_skv ' - InitSize-MaxActive' "$INITIALSIZE-$MAXACTIVE"
        print_skv ' - MinIdle-MaxIdle' "$MINIDLE-$MAXIDLE"

        TESTONBORROW=`echo $RESOURCE | awk -FtestOnBorrow= '{print $2}' | awk -F'\"' '{print $2}'`
        if [ -z $TESTONBORROW ]; then
                TESTONBORROW=False
        fi
        print_skv ' - TestOnBorrow' $TESTONBORROW

        TESTWHILEIDLE=`echo $RESOURCE | awk -FtestWhileIdle= '{print $2}' | awk -F'\"' '{print $2}'`
        if [ -z $TESTWHILEIDLE ]; then
                TESTWHILEIDLE=False
        fi
        print_skv ' - TestWhileIdle' $TESTWHILEIDLE

        REMOVEABANDONED=`echo $RESOURCE | awk -FremoveAbandoned= '{print $2}' | awk -F'\"' '{print $2}'`
        if [ -z $REMOVEABANDONED ]; then
                REMOVEABANDONED=False
        fi
        print_skv ' - RemoveAbandoned' $REMOVEABANDONED

        LOGABANDONED=`echo $RESOURCE | awk -FlogAbandoned= '{print $2}' | awk -F'\"' '{print $2}'`
        if [ -z $LOGABANDONED ]; then
                LOGABANDONED=False
        fi
        print_skv ' - LogAbandoned' $LOGABANDONED
}


print_session_cluster_info() {
        CONF_DIR=$1
        SESSION_CONF_FILE=$CONF_DIR/session.conf
        if [ ! -e $SESSION_CONF_FILE ]; then
                return
        fi
        print_tl
        EMBEDDED_CHK=`grep server.embedded $SESSION_CONF_FILE | awk -F= '{print$2}'`
        if [ "$EMBEDDED_CHK" = "false" ]; then
                MODE="Standalone Mode"
        else
                MODE="Embedded Mode"
        fi
        print_kv 'Session Cluster' "$MODE"
        print_skv ' - Primary Server' `grep primary.host $SESSION_CONF_FILE | awk -F= '{print $2}'`
        print_skv ' - Primary Port' `grep secondary.host $SESSION_CONF_FILE | awk -F= '{print $2}'`
        print_skv ' - Secondary Server' `grep primary.port $SESSION_CONF_FILE | awk -F= '{print $2}'`
        print_skv ' - Secondary Port' `grep secondary.port $SESSION_CONF_FILE | awk -F= '{print $2}'`

        ESS_CHK=`cat $CONF_DIR/context.xml | grep Manager | grep zodiac | awk -F. '{print $3}' | awk -F'\"' '{print $1}'`
        if [ "$ESS_CHK" = "ZodiacEssManager" ]; then
                ESS_ENABLED=True
        else
                ESS_ENABLED=False
        fi
        print_skv ' - ESS Enabled' $ESS_ENABLED

}

repeat_lena_web_instances_info() {
        if [ "$LENA_TYPE" != "lena-web" ]; then
                return
        fi

        SERVERS=$LENA_HOME/servers
        for SERVER in $SERVERS/*
        do
                if [ "$SERVER" = "$SERVERS/*" ]; then
                        return
                fi
                print_lena_web_instance_info $SERVER
        done
}

print_lena_web_instance_info() {
        SERVER_HOME=$1

        ENV_FILE=$SERVER_HOME/env.sh
        source $ENV_FILE
        SERVER_CONF_DIR=$SERVER_HOME/conf



        print_h "LENA WEB Instance Information"
        print_tl
        print_kv 'Instance ID' $SERVER_ID
        print_kv 'Instance Type' `cat $INSTALL_INFO | grep -2a "$SERVER_ID" | grep type | awk -F'<|>' '{print $3}'`
        print_kv 'Instance Version' `cat $INSTALL_INFO | grep -2a "$SERVER_ID" | grep version | awk -F'<|>' '{print $3}'`
        print_kv 'Instance Home' $SERVER_HOME
        print_kv 'Start Script' $SERVER_HOME/start.sh
        print_kv 'Stop Script' $SERVER_HOME/stop.sh
        print_kv 'Log Home' $LOG_HOME
        print_kv 'Document Root' $DOC_ROOT
        print_kv 'HTTP Port' $SERVICE_PORT
        print_kv 'HTTPS Port' $HTTPS_SERVICE_PORT
        print_kv 'Run User' $RUN_USER

        print_http_engine_info
        print_jk_info
        repeat_vhosts_info

        print_bl

}

print_http_engine_info() {
        print_tl
        print_kv 'HTTP Engine'
        print_kv ' - Timeout' `grep '^Timeout ' $SERVER_CONF_DIR/extra/httpd-default.conf | awk '{print $2}'`
        print_kv ' - KeepAlive' `grep '^KeepAlive ' $SERVER_CONF_DIR/extra/httpd-default.conf | awk '{print $2}'`
        print_kv ' - KeepAliveTimeout' `grep '^KeepAliveTimeout ' $SERVER_CONF_DIR/extra/httpd-default.conf | awk '{print $2}'`
        print_kv ' - ThreadsPerChild' `grep -A 9 mpm_event_module $SERVER_CONF_DIR/extra/httpd-mpm.conf | grep ThreadsPerChild | awk '{print $2}'`
        print_kv ' - MaxRequestWorkers' `grep -A 9 mpm_event_module $SERVER_CONF_DIR/extra/httpd-mpm.conf | grep MaxRequestWorkers | awk '{print $2}'`
}

print_jk_info() {
        print_tl
        print_kv 'Mod_JK Connector'
        print_kv ' - SocketTimeout' `grep socket_timeout $SERVER_CONF_DIR/extra/workers.properties | awk -F= '{print $2}'`
        print_kv ' - SocketKeepalive' `grep socket_keepalive $SERVER_CONF_DIR/extra/workers.properties | awk -F= '{print $2}'`
        print_kv ' - ConnectionPoolTimout' `grep connection_pool_timeout $SERVER_CONF_DIR/extra/workers.properties | awk -F= '{print $2}'`
        print_kv ' - ConnectionPoolSize' `grep connection_pool_size $SERVER_CONF_DIR/extra/workers.properties | awk -F= '{print $2}'`

}

repeat_vhosts_info() {
        print_tl
        CNT=1
        for VHOST_CONF_FILE in $SERVER_CONF_DIR/extra/vhost/*
        do
                VHOST_NAME=`echo $VHOST_CONF_FILE | awk -F/ '{print $NF}' | awk -F. '{print $1}'`
                print_vhost_info
                CNT=`expr $CNT + 1`
        done
}


print_vhost_info() {
        print_kv 'Virtual Host' "[$CNT] $VHOST_NAME"
        print_skv ' - ServerName' `grep ServerName $VHOST_CONF_FILE | uniq | awk '{print $2}'`

        SERVER_ALIAS="None"
        while read LINE
        do
                if [ "$SERVER_ALIAS" = "None" ]; then
                        SERVER_ALIAS=$LINE
                else
                        SERVER_ALIAS="$SERVER_ALIAS, $LINE"
                fi
        done < <(grep ServerAlias $VHOST_CONF_FILE | sort | uniq | awk '{print $2}')
        print_skv ' - ServerAlias' "$SERVER_ALIAS"


        eval "VHOST_DOC_ROOT=`grep DocumentRoot $VHOST_CONF_FILE | uniq | awk '{print $2}'`"
        print_skv ' - DocumentRoot' $VHOST_DOC_ROOT

        grep HTTPS $VHOST_CONF_FILE > /dev/null 2>&1
        if [ $? -eq 0 ]; then
                SSL_ENABLED="Yes"
        else
                SSL_ENABLED="No"
        fi
        print_skv ' - SSL Enabled' $SSL_ENABLED

        grep rewrite $VHOST_CONF_FILE > /dev/null 2>&1
        if [ $? -eq 0 ]; then
                REWRITE_ENABLED="Yes"
        else
                REWRITE_ENABLED="No"
        fi
        print_skv ' - Rewrite Enabled' $REWRITE_ENABLED

        grep proxy_$VHOST_NAME $VHOST_CONF_FILE > /dev/null 2>&1
        if [ $? -eq 0 ]; then
                SLB_ENABLED="Yes"
                print_skv ' - SLB Enabled' $SLB_ENABLED
                print_sskv '    - Address' `grep ProxyPassMatch $SERVER_CONF_DIR/extra/proxy/proxy_$VHOST_NAME.conf | awk '{print $3}'`
                print_sskv '    - Match Expression' `grep ProxyPassMatch $SERVER_CONF_DIR/extra/proxy/proxy_$VHOST_NAME.conf | awk '{print $2}'`
        else
                SLB_ENABLED="No"
                print_skv ' - SLB Enabled' $SLB_ENABLED
                repeat_lbs_info
        fi
}

repeat_lbs_info() {
        CNT2=1

        URI_WORKERMAP_FILE=$SERVER_CONF_DIR/extra/uriworkermap/uriworkermap_$VHOST_NAME.properties
        while read LB_NAME
        do
                URI_MAP="None"
                while read LINE
                do
                        if [ "$URI_MAP" = "None" ]; then
                                URI_MAP=$LINE
                        else
                                URI_MAP="$URI_MAP | $LINE"
                        fi
                done < <(grep " $LB_NAME\$" $URI_WORKERMAP_FILE | awk -F= '{print $1}')

                print_lb_info
                CNT2=`expr $CNT2 + 1`
        done < <(grep -v jkstatus $URI_WORKERMAP_FILE | awk -F= '{print $2}' | sort | uniq)

}

print_lb_info() {
        print_kv ' - Load Balancer' "    <$CNT2> $LB_NAME"
        print_ssskv '    - Sticky Session' `grep "\.$LB_NAME\." $SERVER_CONF_DIR/extra/workers.properties | grep sticky_session | awk -F= '{print $2}'`

        SCOOKIE=`grep "\.$LB_NAME\." $SERVER_CONF_DIR/extra/workers.properties | grep session_cookie | awk -F= '{print $2}'`
        if [ -z $SCOOKIE ]; then
                SCOOKIE="JSESSIONID"
        fi
        print_ssskv '    - Session Cookie' $SCOOKIE

        print_ssskv '    - URI Patterns' "$URI_MAP"

        CNT3=1
        for WORKER in `grep "\.$LB_NAME\." $SERVER_CONF_DIR/extra/workers.properties | grep balance_workers | awk -F'=|,' '{for (i=2; i<=NF; i++) print $i}'`
        do
                print_worker_info
                CNT3=`expr $CNT3 + 1`
        done
}

print_worker_info() {
        print_kv '    - Worker' "        ($CNT3) $WORKER"
        print_ssssskv '       - IP Address' `grep "\.$WORKER\." $SERVER_CONF_DIR/extra/workers.properties | grep host | awk -F= '{print $2}'`
        print_ssssskv '       - Port' `grep "\.$WORKER\." $SERVER_CONF_DIR/extra/workers.properties | grep port | awk -F= '{print $2}'`

        REDIRECT=`grep "\.$WORKER\." $SERVER_CONF_DIR/extra/workers.properties | grep redirect | awk -F= '{print $2}'`
        if [ -z "$REDIRECT" ]; then
                REDIRECT="Round Robin"
        fi
        print_ssssskv '       - Redirect' "$REDIRECT"

}

print_dl
print_host_server_info
print_lena_manager_info
print_lena_agent_info
repeat_lena_was_instances_info
repeat_lena_web_instances_info
