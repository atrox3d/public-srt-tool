#!/bin/bash
# for movie_folder in /e/VIDEO/film\ ENG/*/;do ./template-movie.sh "${movie_folder}" run;[ $? -eq 0 ] || break;done

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
#	syntax check
#
if [ $# -lt 1 ]
then
	fatal "SYNTAX | ${NAME} {WORKDIR} [RUN]"
	fatal "SYNTAX | WORKDIR: work directory"
	fatal "SYNTAX | RUN    : \"RUN\" or nothing"
	exit 255
else
	#
	#	process params
	#
	WORKDIR="${1}"
	RUN="${2^^}"
	#
	#	check params
	#
	[ -d "${WORKDIR}" ] || {
		fatal "WORKDIR DOES NOT EXIST | ${WORKDIR}"
		echo
		echo
		echo
		exit 255
	}
fi
#
#	dump variables
#
info "HERE   | ${HERE}"
info "NAME   | ${NAME}"
info "WORKDIR| ${WORKDIR}"
info "RUN    | ${RUN}"
#
#	loop through subdirectories of work directory
#
for movie_folder in "${WORKDIR}"/*/
do
	#
	#	run script for current movie subfolder
	#
	info "${HERE}"/template-movie.sh "${movie_folder}" "${RUN}"
	"${HERE}"/template-movie.sh "${movie_folder}" "${RUN}"
	#
	#	save and process exit code
	#
	EXITCODE=$?
	info "template-movie.sh | EXITCODE | ${EXITCODE}"
	echo
	echo
	echo
	[ $? -eq 0 ] || {
		info read -p "continue (S/N)?" CONTINUE
		read -p "continue (S/N)?" CONTINUE
		[ "${CONTINUE^^}" == "S" ] || break 
	}
done
