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

logger_setlevel debug
# check params
debug "PARAMS | ${@:-no params}"

if [ ${#} -ge 3 ]
then
	# START_DIR="${1}"
	# SCOPE="${2}"
	# FN="${3}"
	# FN_ARGS="${@:4}"
	START_DIR=""
	SCOPE=""
	FN=""
	FN_ARGS=""
	
	debug "START_DIR| ${START_DIR}"
	debug "SCOPE    | ${SCOPE}"
	debug "FN       | ${FN}"
	debug "FN_ARGS  | ${FN_ARGS[@]}"
	
	while getopts "w:d:s:r:" OPT
	do
		debug "OPT: $OPT | OPTARG: $OPTARG | OPTIND: $OPTIND"
	done
	shift "$((OPTIND-1))"
	debug "ARGS: ${@}"
	exit
	debug traverse "${@}"
	traverse "${@}"
	
else
	fatal "syntax: ${NAME} [OPTIONS] run-args"
	fatal "  -w: where: start directory"
	fatal "[ -d: depth: how many levels down: default all]"
	fatal "  -s: scope: files|dirs|all"
	fatal "  -r: run  : function/script"
	fatal "           : script args..."
fi

