#!/bin/bash

#-----------------------------------------------------------------------------
# boilerplate.sh
#-----------------------------------------------------------------------------

# get current path
HERE="$(dirname ${BASH_SOURCE[0]})"
OK=KO
echo "HERE | ${HERE}"
for here in "${HERE}" .. ../lib .
do
	echo "TRY | . ${here}/logger.include"
	if . "${here}/logger.include"
	then
		OK=OK
		info "OK | sourced ${here}/logger.include"
		break
	fi
done

[ "${OK}" == OK ] || {
	echo "FATAL | cannot find logger.include"
	exit 255
}
exit
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
	local max_depth=${2}	# max possible depth
	local cur_depth=${3}	# max possible depth
	local scope="${4^^}"	# DIRS|FILES|ALL
	local fn="${5}"			# function or script
	local args="${@:6}"		# arguments
	
	debug "traverse() | path      | ${path}"
	debug "traverse() | max_depth | ${max_depth}"
	debug "traverse() | cur_depth | ${cur_depth}"
	debug "traverse() | scope     | ${scope}"
	debug "traverse() | fn        | ${fn}"
	debug "traverse() | args      | ${args[@]}"
	
	# TODO | add max_depth check
	# exit
	
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
			((cur_depth++))
			if [ ${max_depth} != ALL ] && [ ${cur_depth} -gt ${max_depth} ]
			then
				debug "reached max_depth ${max_depth}"
			else
				traverse "${node}" ${max_depth} ${cur_depth} "${scope}" "${fn}" "${args[@]}"
			fi
		fi
		
		# only files
		allowed_scopes=(ALL FILES)
		if [ -f "${node}" ] && grep -q "${scope}" <<< "${allowed_scopes[@]}"
		then
			info "FILE  | ${node}"
			"${fn}" "${node}" "${args[@]}"
		fi
	done
	shopt -u nullglob
}

LOG_LEVEL=debug
logger_setlevel "${LOG_LEVEL}"
# check params
debug "PARAMS | ${@:-no params}"

if [ ${#} -ge 3 ]
then
	# START_DIR="${1}"
	# SCOPE="${2}"
	# FN="${3}"
	# FN_ARGS="${@:4}"
	START_DIR=""
	MAX_DEPTH=ALL
	CUR_DEPTH=0
	SCOPE=""
	FN=""
	FN_ARGS="${@}"
	
	super "LOG_LEVEL| ${LOG_LEVEL}"
	debug "START_DIR| ${START_DIR}"
	debug "MAX_DEPTH| ${MAX_DEPTH}"
	debug "SCOPE    | ${SCOPE}"
	debug "FN       | ${FN}"
	debug "FN_ARGS  | ${FN_ARGS[@]}"
	
	while getopts "w:d:s:r:l:" OPT
	do
		debug "OPT: $OPT | OPTARG: $OPTARG | OPTIND: $OPTIND"
		case "${OPT}" in
			w)
				START_DIR="${OPTARG}"
			;;
			d)
				MAX_DEPTH=${OPTARG^^}
			;;
			s)
				SCOPE="${OPTARG}"
			;;
			r)
				FN="${OPTARG}"
			;;
			l)
				LOG_LEVEL="${OPTARG^^}"
			;;
		esac
	done
	shift "$((OPTIND-1))"
	FN_ARGS="${@}"

	logger_setlevel "${LOG_LEVEL}"
	
	super "LOG_LEVEL| ${LOG_LEVEL}"
	debug "START_DIR| ${START_DIR}"
	debug "MAX_DEPTH| ${MAX_DEPTH}"
	debug "SCOPE    | ${SCOPE}"
	debug "FN       | ${FN}"
	debug "FN_ARGS  | ${FN_ARGS[@]}"
	# debug "ARGS: ${@}"
	debug traverse "${START_DIR}" "${MAX_DEPTH}" "${CUR_DEPTH}" "${SCOPE}" "${FN}" "${FN_ARGS}"
	traverse "${START_DIR}" "${MAX_DEPTH}" "${CUR_DEPTH}" "${SCOPE}" "${FN}" "${FN_ARGS}"
	
else
	fatal "syntax: ${NAME} [OPTIONS] run-args"
	fatal "  -l: log level: debug info warning error fatal"
	fatal "  -w: where    : start directory"
	fatal "[ -d: max_depth: how many levels down: default all]"
	fatal "  -s: scope    : files|dirs|all"
	fatal "  -r: run      : function/script"
	fatal "               : script args..."
fi

