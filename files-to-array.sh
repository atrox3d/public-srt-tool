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
		# __DEBUG ${x[@]}
		# __DEBUG "${x[@]}"
		# __DEBUG ${#x[@]}
		# declare -p x >&2
		echo "$(join_by , "${x[@]}")"
		# echo "${x[@]}"
		# return ${#x[@]}
}

files="$(getfiles . mp4 mkv txt)"
info $files
IFS=',' read -r -a files <<< "$files"
info "${files[@]}"
for file in "${files[@]}"
do
	echo $file
done
