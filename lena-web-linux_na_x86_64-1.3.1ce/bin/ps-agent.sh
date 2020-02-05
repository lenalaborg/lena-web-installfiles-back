#!/bin/sh
# ---------------------------------------------------------------------------
# Start script for the LENA Agent Server
# ---------------------------------------------------------------------------

RUNDIR=`dirname "$0"`
LENA_HOME=`cd "$RUNDIR/.." ; pwd -P`

if [ "`uname -s`" = "HP-UX" ]; then
	ps -efx | grep java | grep "${LENA_HOME}/modules/lena-agent"
else
	ps -ef | grep java | grep "${LENA_HOME}/modules/lena-agent"
fi