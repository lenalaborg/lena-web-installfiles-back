#!/bin/sh

# crontab example
# */10 * * * * /engn001/lena/1.3.1/etc/sync/sync-storage.sh 127.0.0.1 lena
# 0 50 2 * * * /engn001/lena/1.3.1/etc/sync/sync-storage.sh 127.0.0.1 lena
# 0 50 2 * * * /engn001/lena/1.3.1/etc/sync/sync-storage.sh  127.0.0.1 lena > /engn001/lena/1.3.1/logs/lena-manager/sync-storage.log 2>&1

RUNDIR=`dirname "$0"`
LENA_HOME=`cd "$RUNDIR/../.." ; pwd -P`
MASTER_LENA_MANAGER_IP=
USER=

if [ "$#" -ne 2 ]; then

    echo "check parameter!(MASTER_LENA_MANAGER_IP, USER)";
    echo "ex) sync-storage.sh 127.0.0.2 user01"
    exit 1

else

    MASTER_LENA_MANAGER_IP="$1"
    USER="$2"

    echo "============================"
    echo "execute stop-manager"
    echo "============================"
    ${LENA_HOME}/bin/stop-manager.sh

    echo "============================"
    echo "execute manager storage sync"
    echo "============================"
    rsync -avPz --delete --stats -l -t -e ssh ${USER}@${MASTER_LENA_MANAGER_IP}:${LENA_HOME}/modules/lena-manager/storage ${LENA_HOME}/modules/lena-manager

    echo "============================"
    echo "execute start-manager"
    echo "============================"
    ${LENA_HOME}/bin/start-manager.sh

    echo "complete manager storage sync"
fi
