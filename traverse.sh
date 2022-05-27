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

#
#	traverse path function/script args
#
#	recursively traverse directories starting from path
#	executing fn "current node" args
#	where node is a file, a directory or both
#	depending on scope
#
function traverse()
{
	local node				# current object
	local path="${1}"		# start path
	local scope="${2^^}"	# DIRS|FILES|ALL
	local fn="${3}"			# function or script
	local args="${@:4}"		# arguments
	
	info "traverse() | path    | ${path}"
	info "traverse() | scope   | ${scope}"
	info "traverse() | fn      | ${fn}"
	info "traverse() | args    | ${args[@]}"
	
	shopt -s nullglob			# expand only available files
	for node in "${path}"/*
	do
		# only dirs
		allowed_scopes=(ALL DIRS)
		if [ -d "${node}" ]
		then
			# run fn if in scope
			if  grep -q "${scope}" <<< "${allowed_scopes[@]}"
			then
				info "DIR   | ${node}"
				"${fn}" "${node}" "${args[@]}"
			fi
			# recurse anyway
			traverse "${node}" "${scope}" "${fn}" "${args[@]}"
		fi
		
		# only files
		allowed_scopes=(ALL FILES)
		if [ -f "${node}" ] && grep -q "${scope}" <<< "${allowed_scopes[@]}"
		then
			info "DIR   | ${node}"
			"${fn}" "${node}" "${args[@]}"
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

