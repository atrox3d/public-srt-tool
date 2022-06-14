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
logger_setlevel info
# logger_setlevel debug
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
		SUBSDIR=( "${MOVIEDIR}"/*subs/ )	# glob subs directory into array
		# if [ -d "${MOVIEDIR}"/subs ]
		# then
			# SUBDIR="${MOVIEDIR}"/subs
		# elif
			# [ -d "${MOVIEDIR}"/subs ]
		# fi
		debug "SUBSDIR    | ${SUBSDIR}"
		debug "SUBSDIR[@] | ${SUBSDIR[@]}"
		debug "SUBSDIR#   | ${#SUBSDIR[@]}"
		# exit
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
		SUBSDIR="${SUBSDIR[0]}"	# save it using IFS
	IFS="$OIFS"
	info "found '${SUBSDIR}'"

	debug "subtitles pattern: ${SUBSDIR}/*english*.srt"
	subtitles=( "${SUBSDIR}"/*english*.srt )	# capture srt files in array
	debug "subtitles pattern: ${SUBSDIR}/*subs*.srt"
	subtitles+=( "${SUBSDIR}"/*subs*.srt )	# capture srt files in array
	debug "subtitles: ${subtitles[@]}"
	debug "#subtitles: ${#subtitles[@]}"
	filename=""
	filesize=0
	[ ${#subtitles[@]} -gt 0 ] || {
		warn "no subtitles found in '${SUBSDIR}'"
		warn "exiting"
		exit
	}
	for _filename in "${subtitles[@]}"
	do
		debug "filename : ${filename}"
		debug "filesize : ${filesize}"
		
		debug "_filename: ${_filename}"
		debug "_filesize=\$(stat -c %s \"${_filename}\")"	# get current file size
		_filesize=$(stat -c %s "${_filename}")	# get current file size
		[ $? -eq 0 ] || {
			fatal "cannot stat '${filename}'"
			exit 255
		}
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
	info "srtfile | '${srtfile}'"					# 2_English.srt
	
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
	
	diff "${srtfile}" "${MOVIEDIR}/${filename}" &>/dev/null
	diff_exitcode=$?
	debug "diff exit code: ${diff_exitcode}"
	if [ ${diff_exitcode} -eq 0 ]
	then
		warn "subtitle already exist: ${MOVIEDIR}/${filename}"
		warn "no op"
	else
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
	fi
	shopt -u nullglob		# OFF | expand no match to null string
	shopt -u nocaseglob		# OFF | expand case insensitive
else
	fatal "syntax | ${NAME} movie-path [run]"
fi

