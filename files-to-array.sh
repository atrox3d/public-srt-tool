#!/bin/bash
. logger.include

function join_by { local IFS="$1"; shift; echo "$*"; }

function getfiles()
{
	path="$1"
	pushd "$path" &> /dev/null || { echo fatal "path $path does not exist"; exit; }
		shift
		pattern=""
		for ext
		do
			pattern="$pattern *.$ext"
		done
		
		__DEBUG "pattern: $pattern"
		shopt -s nullglob
		x=($pattern)
		shopt -u nullglob
		echo "$(join_by , "${x[@]}")"
}

IFS=',' read -r -a files <<< "$(getfiles . mp4 mkv txt)"
info "${files[@]}"
for file in "${files[@]}"
do
	info $file
done
info ${#files[@]}