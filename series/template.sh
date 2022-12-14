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
	if . "${here}/logger.include" &> /dev/null
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
				subtitles=( "${subsdir}"/*english*.srt )	# capture srt files in array
				filename=""
				filesize=0
				debug "subtitles: ${subtitles[@]}"
				for _filename in "${subtitles[@]}"
				do
					_filesize=$(stat -c %s "${_filename}")	# get current file size
					debug "filename : ${filename}"
					debug "filesize : ${filesize}"
					debug "_filename: ${_filename}"
					debug "_filesize: ${_filesize}"
					[ ${_filesize} -gt ${filesize} ] && {	# if bigger
						filename="${_filename}"				# update filename
						filesize=${filesize}				# update filesize
					}
				done
				
				srtfile="${filename}"
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

