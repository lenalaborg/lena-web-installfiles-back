#!/bin/bash

RUNDIR=`dirname "$0"`
LENA_HOME=`cd "$RUNDIR/.." ; pwd -P`
LENA_USER=`grep 'agent.server.user' $LENA_HOME/conf/agent.conf | awk -F= '{print $2}'`


check_invalid_value() {
        case $2 in (-*|"")
                echo "Error: Invalid value for option: $1"
                exit
                ;;
        esac
}



usage() {
        echo "Usage: $0 --prepath [OPTIONS]"
        echo "OPTIONS"
        echo "--prepath         Required. Absolute Path Only. Example) /logs001/lena/1.3/servers"
        echo "--postpath        Choice.   Relative Path Only. Example) logs"
        echo "--symlink         Choice.   No value requied"
}


PREPATH=
POSTPATH=
SYMLINK="N"

if [ $# -eq 0 ]; then
        usage
        exit
fi


while true
do

        if [ $# -eq 0 ]; then
                break
        fi

        case $1 in
                --prepath)
                        check_invalid_value $1 $2
                        shift

                        PREPATH=$1
                        if [ "${PREPATH:0:1}" != "/" ]; then
                                echo "ERROR: Prepath must be begined with absolute path: $PREPATH"
                                exit
                        fi
                        if [ "${PREPATH: -1}" = "/" ]; then
                                PREPATH=${PREPATH:0:-1}
                        fi

                        ;;
                --postpath)
                        check_invalid_value $1 $2
                        shift

                        POSTPATH=$1
                        if [ "${POSTPATH:0:1}" = "/" ]; then
                                echo "ERROR: Postpath must be begined with relative path: $POSTPATH"
                                exit
                        fi
                        if [ "${POSTPATH: -1}" = "/" ]; then
                                POSTPATH=${POSTPATH:0:-1}
                        fi

                        ;;
                --symlink)
                        SYMLINK="Y"
                        ;;
                *)
                        echo "ERROR: Invalid option: $1"
                        usage
                        exit
                        ;;
        esac
        shift
done

if [ -z $PREPATH ]; then
        echo "ERROR: --prepath option must be required."
        exit
fi


for SERVER_PATH in $LENA_HOME/servers/*
do
        if [ "$SERVER_PATH" = "$LENA_HOME/servers/*" ]; then
                echo "ERROR: There is no Server Instance"
                exit
        fi

        SERVER_NAME=`echo $SERVER_PATH | awk -F'/' '{print $NF}'`

        LOG_DIR=$PREPATH/$SERVER_NAME
        if [ ! -z $POSTPATH ]; then
                LOG_DIR=$LOG_DIR/$POSTPATH
        fi

        sudo -u $LENA_USER mkdir -p $LOG_DIR
        if [ $? -eq 0 ]; then
                echo "[$SERVER_NAME] Log directory is successfully created ->  `ls -ld $LOG_DIR`"
                if [ "$SYMLINK" = "Y" ]; then
                        sudo -u $LENA_USER rm -rf $SERVER_PATH/logs
                        sudo -u $LENA_USER ln -s $LOG_DIR $SERVER_PATH/logs
                        echo "[$SERVER_NAME] Symbolic link is successfully created ->  `ls -l $SERVER_PATH/logs`"
                fi
        fi


        echo

done
