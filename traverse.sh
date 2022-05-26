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

function traverse()
{
	shopt -s nullglob
	for node in "${1}"/*
	do
		if [ -d "${node}" ]
		then
			echo "DIR   | ${node}"
			traverse "${node}"
		elif [ -f "${node}" ]
		then
			echo "FILE  | ${node}"
		else
			echo "OTHER | ${node}"
		fi
	done
	shopt -u nullglob
}

# check params
info "PARAMS | ${@:-no params}"
if [ ${#} -gt 0 ]
then
	START_DIR="${1}"
	shift
	traverse "${START_DIR}"
	
else
	fatal "syntax: ${NAME} start-directory"
fi

