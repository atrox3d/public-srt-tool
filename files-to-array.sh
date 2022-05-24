#!/bin/bash

# get current path
HERE="$(dirname ${BASH_SOURCE[0]})"

# save parameters and reset them
ARGS=( "${@}" )
PARAM="${1}"
set --

# source logger
. "${HERE}/logger.include"

# save this script name
NAME="$(basename ${BASH_SOURCE[0]})"


function join_by { local IFS="${1}"; shift; echo "$*"; }

function getfileslist()
{
	local path="${1}"
	shift
	local sep="${1}"
	shift
	
	info "path: ${path}"
	info "sep : ${sep}"
	
	pushd "${path}" &> /dev/null || { echo fatal "path ${path} does not exist"; exit; }
		local patterns=""
		local ext
		for ext
		do
			patterns="${patterns} *.$ext"
		done

		info "patterns: ${patterns}"

		shopt -s nullglob
		local files=(${patterns})
		info "files: (${files[@]})"
		shopt -u nullglob

		list="$(join_by "${sep}" "${files[@]}")"
		info "${list}"
		echo "${list}"
	popd &> /dev/null
}

#
# source or run
#
if [ "${BASH_SOURCE[0]}" != "${0}" ]
then
	info "SOURCE | ${NAME} | ignoring params: ${ARGS[@]} | ok"
else
	sep="," 
	list="$(getfileslist . "${sep}" "${ARGS[@]}")"
	info "list : ${list}"
	# exit
	IFS="$sep" read -r -a files <<< "${list}"
	info "files: (${files[@]})"
	for file in "${files[@]}"
	do
		info "file : ${file}"
	done
	info ${#files[@]}
fi
