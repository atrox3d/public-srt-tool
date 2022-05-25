#!/bin/bash

# get current path
HERE="$(dirname ${BASH_SOURCE[0]})"

# save parameters and reset them
# ARGS=( "${@}" )
# set --

# source logger
. "${HERE}/logger.include"

# save this script name
NAME="$(basename ${BASH_SOURCE[0]})"

# check params
info "PARAMS | ${@:-no params}"
if [ ${#} -gt 1 ]
then
	BASE_DIR="${1}"
	shift
	
	CUR_DIR="${BASE_DIR}"
	VIDEO_COUNT=0
	while [ ${VIDEO_COUNT} -eq 0 ]
	do
		info ./countfiles.include "${CUR_DIR}" "${@}"
		./countfiles.include "${CUR_DIR}" "${@}"
	done
else
	fatal "syntax: ${NAME} start-directory"
fi

