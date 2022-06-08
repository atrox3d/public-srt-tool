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
logger_setlevel debug
#
# check params
#
info "PARAMS | ${@}"
if [ ${#} -gt 0 ]
then
	MOVIEDIR="${1}"
	[ -d "${MOVIEDIR}" ] || {
		fatal "movie directory does not exist: '${MOVIEDIR}'"
		exit 255
	}
	info "movie directory exists: '${MOVIEDIR}'"

	shopt -s nullglob					# ON | expand no match to null string
	shopt -s nocaseglob					# ON | expand case insensitive

	SUBSDIR=( "${1}"/subs/ )			# glob subs directory into array
	
	debug "SUBSDIR  | ${SUBSDIR}"
	debug "SUBSDIR  | ${SUBSDIR[@]}"
	debug "SUBSDIR# | ${#SUBSDIR[@]}"
	
	[ ${#SUBSDIR[@]} -gt 0 ] || {		# check if exists
		fatal "cannot find ${1}/subs/"
		exit 255
	}
	SUBSDIR="${SUBSDIR[0]}"				# save it
	info "found ${SUBSDIR}"
	#
	# loop through srt files
	# ${SUBSDIR} : /path/to/tv-serie-folder/01/season-1/episode01
	# */         : 2_English.srt
	#
	# TODO: stop at first or add counter 
	#
	#	OR
	#
	#		get the biggest
	#
	subtitles=( "${SUBSDIR}"/*english*.srt )	# capture srt files in array
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
	info "srtfile | ${srtfile}"					# 2_English.srt
	
	movies=( "${MOVIEDIR}"/*.m* )
	[ ${#movies[@]} -eq 1 ] || {
		fatal "no movies or too many movies:"
		for movie in "${movies[@]}"
		do
			fatal "movie file | ${movie}"
		done
		exit 255
	}
	movie="${movies[0]}"
	info "MOVIE | ${movie}"
	
	filename="${movie%.*}.srt"	# episode01.srt
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
else
	fatal "syntax | ${NAME} movie-path [run]"
fi

