#!/bin/bash

# get current path
HERE="$(dirname ${BASH_SOURCE[0]})"

# save parameters and reset them
# ARGS=( "${@}" )
# set --

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

NAME="$(basename ${BASH_SOURCE[0]})"	# save this script name

#
# check params
#
info "PARAMS | ${@}"
if [ ${#} -gt 0 ]
then
	#
	# loop through seasons:
	#
	# example: /path/to/tv-serie-folder/01/season-1/
	#
	# ${1}/ : /path/to/tv-series/
	# */    : 01/
	# */    : season-1/
	#
	for season in "${1}"/*/*/
	do
		info "pushd season | ${season}"
		pushd "${season}" &> /dev/null
			#
			# loop through subtitles subdirs
			# ${season}/ : /path/to/tv-serie-folder/01/season-1/
			# Subs/      : Subs/
			# */         : episode01/
			#
			for subsdir in "${season}"/[Ss]ubs/*/
			do
				info "subsdir | ${subsdir}"
				#
				# loop through srt files
				# ${subsdir} : /path/to/tv-serie-folder/01/season-1/episode01
				# */         : 2_English.srt
				#
				# TODO: stop at first or add counter
				#
				for srtfile in "${subsdir}"/*.srt
				do
					info "srtfile | ${srtfile}"				# 2_English.srt
					filename="$(basename "${subsdir}").srt"	# episode01.srt
					info "filename | ${filename}"
					#
					# copy srt files at video files level or just print
					#
					if [ "${2^^}" == RUN ]
					then
						info "RUN | cp ${srtfile} ${season}/${filename}"
						cp "${srtfile}" "${season}/${filename}" || {
							fatal "error copying"
							exit 255
						}
					else
						info "PRINT | cp ${srtfile} ${season}/${filename}"
					fi
				done
			done
		# cd back
		info popd
		popd  &> /dev/null
	done
else
	fatal "syntax | ${NAME} path [run]"
fi

