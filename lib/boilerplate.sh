#!/bin/bash

#-----------------------------------------------------------------------------
# boilerplate.sh
#-----------------------------------------------------------------------------

# get current path
HERE="$(dirname ${BASH_SOURCE[0]})"
echo "HERE | ${HERE}"
#
# source logger
#
{
	. "${HERE}/logger.include" || {
		. "${HERE}/../logger.include" || {
			echo "FATAL | cannot find logger.include"
			exit 255
		}
	}
} 2> /dev/null
#
#	setup variables and log level
#
HERE="$(dirname ${BASH_SOURCE[0]})"
NAME="$(basename ${BASH_SOURCE[0]})"	# save this script name
logger_setlevel info

#-----------------------------------------------------------------------------
# boilerplate.sh
#-----------------------------------------------------------------------------

