#!/bin/bash

declare -A LOG_LEVELS=( [debug]=0 [info]=1 [warning]=2 [error]=3 [fatal]=4 )
DEFAULT_LEVEL="debug"
CURRENT_LEVEL="${DEFAULT_LEVEL}"

echo "LEVEL_NAMES  : ${!LOG_LEVELS[@]}"
echo "LEVEL_CODES  : ${LOG_LEVELS[@]}"
echo "DEFAULT_LEVEL: ${DEFAULT_LEVEL}"
echo "CURRENT_LEVEL: ${CURRENT_LEVEL}"

function logger_setlevel()
{
	local level="${1:-UNSET}"

	[ "${LOG_LEVELS[${level}]+EXISTS}" == EXISTS ] || {
		fatal "unknown level ${level}"
		exit 255
	}
	CURRENT_LEVEL="${level}"
}

function logger_getlevelcode()
{
	local level="${1:-UNSET}"

	[ "${LOG_LEVELS[${level}]+EXISTS}" == EXISTS ] || {
		fatal "unknown level ${level}"
		exit 255
	}
	return "${LOG_LEVELS[${level}]}"
}

function logger_islevelenabled()
{
	local level="${1:-UNSET}"

	[ "${LOG_LEVELS[${level}]+EXISTS}" == EXISTS ] || {
		fatal "unknown level ${level}"
		exit 255
	}

	[ "${LOG_LEVELS[${level}]}" -ge "${LOG_LEVELS[${CURRENT_LEVEL}]}" ] && {
		return 0
	} || {
		return 1
	}
}

setlevel $1
getlevelcode $1
echo $?
levelenabled $2
echo $?


