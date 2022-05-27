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
	local scope="${2^^}"
	local fn="${3}"
	local args="${@:4}"
	
	info "traverse() | path    | ${path}"
	info "traverse() | scope   | ${scope}"
	info "traverse() | fn      | ${fn}"
	info "traverse() | args    | ${args[@]}"
	# exit
	
	shopt -s nullglob
	for node in "${path}"/*
	do
		allowed_scopes=(ALL DIRS)
		if [ -d "${node}" ] && grep -q "${scope}" <<< "${allowed_scopes[@]}"
		then
			info "DIR   | ${node}"
			"${fn}" "${node}" "${args[@]}"
			traverse "${node}" "${scope}" "${fn}" "${args[@]}"
		fi
		
		allowed_scopes=(ALL FILES)
		if [ -f "${node}" ] && grep -q "${scope}" <<< "${allowed_scopes[@]}"
		then
			info "DIR   | ${node}"
			"${fn}" "${node}" "${args[@]}"
			traverse "${node}" "${scope}" "${fn}" "${args[@]}"
		fi
	done
	shopt -u nullglob
}

# check params
info "PARAMS | ${@:-no params}"
if [ ${#} -ge 3 ]
then
	START_DIR="${1}"
	SCOPE="${2}"
	FN="${3}"
	FN_ARGS="${@:4}"
	
	info "START_DIR| ${START_DIR}"
	info "SCOPE    | ${SCOPE}"
	info "FN       | ${FN}"
	info "FN_ARGS  | ${FN_ARGS[@]}"
	
	info traverse "${START_DIR}" "${SCOPE}" "${FN}" "${FN_ARGS[@]}"
	traverse "${START_DIR}" "${SCOPE}" "${FN}" "${FN_ARGS[@]}"
	
else
	fatal "syntax: ${NAME} start-directory files|dirs|all function/script args..."
fi

