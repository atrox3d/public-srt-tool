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
	local context="${2^^}"
	local fn="${3}"
	local args="${@:4}"
	
	info "traverse() | path    | ${path}"
	info "traverse() | context | ${context}"
	info "traverse() | fn      | ${fn}"
	info "traverse() | args    | ${args[@]}"
	# exit
	
	shopt -s nullglob
	for node in "${path}"/*
	do
		contexts=(ALL DIRS)
		if [ -d "${node}" ] && grep -q "${context}" <<< "${contexts[@]}"
		then
			info "DIR   | ${node}"
			${fn} "${node}" "${args[@]}"
			traverse "${node}" "${context}" "${fn}" "${args[@]}"
		fi
		
		contexts=(ALL FILES)
		if [ -f "${node}" ] && grep -q "${context}" <<< "${contexts[@]}"
		then
			info "DIR   | ${node}"
			${fn} "${node}" "${args[@]}"
			traverse "${node}" "${context}" "${fn}" "${args[@]}"
		fi
	done
	shopt -u nullglob
}

# check params
info "PARAMS | ${@:-no params}"
if [ ${#} -ge 3 ]
then
	START_DIR="${1}"
	CONTEXT="${2}"
	FN="${3}"
	FN_ARGS="${@:4}"
	
	info "START_DIR| ${START_DIR}"
	info "CONTEXT  | ${CONTEXT}"
	info "FN       | ${FN}"
	info "FN_ARGS  | ${FN_ARGS[@]}"
	
	info traverse "${START_DIR}" "${CONTEXT}" "${FN}" "${FN_ARGS[@]}"
	traverse "${START_DIR}" "${CONTEXT}" "${FN}" "${FN_ARGS[@]}"
	
else
	fatal "syntax: ${NAME} start-directory files|dirs|all function/script args..."
fi

