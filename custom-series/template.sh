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
				#	OR
				#
				#		get the biggest
				#
				shopt -s nullglob			# ON | expand no match to null string
				shopt -s nocaseglob			# ON | expand case insensitive
				subtitles=( *english*.srt )	# capture srt files in array
				filename=""
				filesize=0
				debug "subtitles: ${subtitles[@]}"
				for _filename in "${subtitles[@]}"
				do
					_filesize=$(stat -c %s "${filename}")	# get current file size
					debug "filename : ${filename}"
					debug "filesize : ${filesize}"
					debug "_filename: ${_filename}"
					debug "_filesize: ${_filesize}"
					[ ${_filesize} -gt ${filesize} ] && {	# if bigger
						filename="${_filename}"				# update filename
						filesize=${filesize}				# update filesize
					}
				done
				
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
				shopt -u nullglob		# OFF | expand no match to null string
				shopt -u nocaseglob		# OFF | expand case insensitive
			done
		# cd back
		info popd
		popd  &> /dev/null
	done
else
	fatal "syntax | ${NAME} path [run]"
fi

