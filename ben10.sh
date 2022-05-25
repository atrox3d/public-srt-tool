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

info "PARAMS | ${@}"
if [ ${#} -gt 0 ]
then
	for season in "${1}"/*/*/
	do
		info "pushd ${season}"
		pushd "${season}" &> /dev/null
		
			# ls -l "${season}"/Subs/*/
			for subsdir in "${season}"/Subs/*/
			do
				info "subsdir | ${subsdir}"
				for srtfile in "${subsdir}"/*
				do
					info "srtfile | ${srtfile}"
					filename="$(basename "${subsdir}").srt"
					info "filename | ${filename}"
					info "cp ${srtfile} ${season}/${filename}"
					cp "${srtfile}" "${season}/${filename}" || {
						fatal "error copying"
						exit 255
					}
				done
			done
		info popd
		popd  &> /dev/null
	done
fi

