#!/bin/bash

# get current path
HERE="$(dirname ${BASH_SOURCE[0]})"

# save parameters and reset them
ARGS=( "${@}" )
param="$1"
set --

# source logger
. "${HERE}/logger.include"

# save this script name
NAME="$(basename ${BASH_SOURCE[0]})"


function join_by { local IFS="$1"; shift; echo "$*"; }

function getfiles()
{
	local path="$1"
	shift
	local sep="$1"
	shift
	pushd "$path" &> /dev/null || { echo fatal "path $path does not exist"; exit; }
		local pattern=""
		local ext
		for ext
		do
			pattern="$pattern *.$ext"
		done

		shopt -s nullglob
		local files=($pattern)
		shopt -u nullglob

		echo "$(join_by "$sep" "${files[@]}")"
	popd
}

if [ "${param,,}" == main ]
then
	sep="," 
	IFS="$sep" read -r -a files <<< "$(getfiles . "$sep" mp4 mkv txt)"
	info "${files[@]}"
	for file in "${files[@]}"
	do
		info $file
	done
	info ${#files[@]}
fi
