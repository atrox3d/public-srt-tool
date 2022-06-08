#!/bin/bash
# for d in /e/VIDEO/film\ ENG/*/;do ./template-movie.sh "${d}" run;[ $? -eq 0 ] || break;done
# for d in /e/VIDEO/film\ ENG/*/;do ./template-movie.sh "${d}";[ $? -eq 0 ] || break;done


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
	OIFS="$IFS"							# save IFS
	IFS=$'\n'							# set IFS to newline
		SUBSDIR=( "${1}"/[Ss]ubs/* )	# glob subs directory into array
		
		debug "SUBSDIR    | ${SUBSDIR}"
		debug "SUBSDIR[@] | ${SUBSDIR[@]}"
		debug "SUBSDIR#   | ${#SUBSDIR[@]}"
		for sd in "${SUBSDIR[@]}"		# loop through directories
		do
			debug "SUBSDIR[] | ${sd}"
			debug "DIRNAME   | $(dirname "${sd}")"
		done
		
		[ ${#SUBSDIR[@]} -gt 0 ] || {	# check if at least one exists
			warn "cannot find ${1}/[Ss]ubs/"
			warn "exiting"
			exit
		}

		[ ${#SUBSDIR[@]} -gt 1 ] && {	# check only one exists
			warn "too many directories ${1}/[Ss]ubs/"
			warn "exiting"
			exit
		}
		SUBSDIR="$(dirname ${SUBSDIR[0]})"	# save it using IFS
	IFS="$OIFS"
	info "found '${SUBSDIR}'"
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
	subtitles=( "${SUBSDIR}"/{*english*,subs}.srt )	# capture srt files in array
	filename=""
	filesize=0
	debug "subtitles: ${subtitles[@]}"
	debug "#subtitles: ${#subtitles[@]}"
	[ ${#subtitles[@]} -gt 0 ] || {
		warn "no subtitles found in '${SUBSDIR}'"
		warn "exiting"
		exit
	}
	for _filename in "${subtitles[@]}"
	do
		_filesize=$(stat -c %s "${_filename}")	# get current file size
		debug "filename : ${filename}"
		debug "filesize : ${filesize}"
		debug "_filename: ${_filename}"
		debug "_filesize: ${_filesize}"
		[ ${_filesize} -gt ${filesize} ] && {	# if bigger
			filename="${_filename}"				# update filename
			filesize=${_filesize}				# update filesize
		}
	done
	
	debug "filename : ${filename}"
	debug "filesize : ${filesize}"
	debug "notfound : ${filename:-NOTFOUND}"
	[ "${filename:-NOTFOUND}" == NOTFOUND ] && {
		warn "no subtitles found"
		exit
	}
	
	srtfile="${filename}"
	info "srtfile | ''${srtfile}'"					# 2_English.srt
	
	movies=( "${MOVIEDIR}"/*.{mp4,mp5,avi,mkv} )
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
	
	filename="$(basename "${movie%.*}.srt")"	# episode01.srt
	info "srtfile  | ${srtfile}"
	info "filename | ${filename}"
	#
	# copy srt files at video files level or just print
	#
	if [ "${2^^}" == RUN ]
	then
		info "RUN command | cp "
		info "RUN src     | ${srtfile}"
		info "RUN dst     | ${MOVIEDIR}/${filename}"
		cp "${srtfile}" "${MOVIEDIR}/${filename}" || {
			fatal "error copying"
			exit 255
		}
	else
		info "PRINT command | cp "
		info "PRINT src     | ${srtfile}"
		info "PRINT dst     | ${MOVIEDIR}/${filename}"
	fi
	shopt -u nullglob		# OFF | expand no match to null string
	shopt -u nocaseglob		# OFF | expand case insensitive
else
	fatal "syntax | ${NAME} movie-path [run]"
fi

