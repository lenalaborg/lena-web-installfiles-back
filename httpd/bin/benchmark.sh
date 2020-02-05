#!/bin/sh

SCRIPTPATH=`cd $(dirname $0) ; pwd -P`
SCRIPT=$SCRIPTPATH/$(basename $0)

. ${SCRIPTPATH}/../env.sh

echo "Benchmakr LENA [web] ... ${SERVER_ID}"
echo "**************************************************"
echo "* Caution : This script can make lots of request *"
echo "**************************************************"

CONCURRENCY=100
if [ ! -z "${1}" ]; then
	CONCURRENCY=${1}
else
	read -p "CONCURRENCY( q: quit, Default: ${CONCURRENCY} ) : " user_input
	CONCURRENCY=${user_input:-${CONCURRENCY}}
	if [ "${user_input}" = "q" -o "${user_input}" = "Q" ] ; then
		exit 2;
	fi
fi

REQUESTS=10000
if [ ! -z "${2}" ]; then
	REQUESTS=${2}
else
	read -p "REQUESTS( q: quit, Default: ${REQUESTS} ) : " user_input
	REQUESTS=${user_input:-${REQUESTS}}
	if [ "${user_input}" = "q" -o "${user_input}" = "Q" ] ; then
		exit 2;
	fi
fi

REQUEST_PATH=index.html
if [ ! -z "${3}" ]; then
	REQUEST_PATH=${3}
else
	read -p "REQUEST_PATH( q: quit, Default: ${REQUEST_PATH} ) : " user_input
	REQUEST_PATH=${user_input:-${REQUEST_PATH}}
	if [ "${user_input}" = "q" -o "${user_input}" = "Q" ] ; then
		exit 2;
	fi
fi

REQUEST_URL=http://127.0.0.1:${SERVICE_PORT}/${REQUEST_PATH}

#echo ${ENGN_HOME}/bin/ab -c ${CONCURRENCY} -n ${REQUESTS} ${REQUEST_URL}
${ENGN_HOME}/bin/ab -c ${CONCURRENCY} -n ${REQUESTS} ${REQUEST_URL}

exit 0;