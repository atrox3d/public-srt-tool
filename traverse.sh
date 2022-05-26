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
	local node
	local path="${1}"
	local fn="${2}"
	local args="${@:3}"
	
	shopt -s nullglob
	for node in "${1}"/*
	do
		if [ -d "${node}" ]
		then
			info "DIR   | ${node}"
			${fn} "${node}" "${args[@]}"
			traverse "${node}" "${fn}" "${args[@]}"
		elif [ -f "${node}" ]
		then
			# ${fn} "${node}" "${args[@]}"
			:
		# else
			# echo "OTHER | ${node}"
		fi
	done
	shopt -u nullglob
}

# check params
info "PARAMS | ${@:-no params}"
if [ ${#} -gt 0 ]
then
	START_DIR="${1}"
	FN="${2}"
	FN_ARGS="${@:3}"
	info "FN_ARGS | ${FN_ARGS[@]}"
	# shift
	traverse "${START_DIR}" "${FN}" "${FN_ARGS[@]}"
	
else
	fatal "syntax: ${NAME} start-directory"
fi

