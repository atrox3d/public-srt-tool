#!/bin/bash
# for movie_folder in /e/VIDEO/film\ ENG/*/;do ./template-movie.sh "${movie_folder}" run;[ $? -eq 0 ] || break;done

# get current path
HERE="$(dirname ${BASH_SOURCE[0]})"
echo "HERE | ${HERE}"
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
	info "${HERE}"/template-movie.sh "${movie_folder}" "${RUN}"
	"${HERE}"/template-movie.sh "${movie_folder}" "${RUN}"
	EXITCODE=$?
	info "template-movie.sh | EXITCODE | ${EXITCODE}"
	[ $? -eq 0 ] || {
		info read -p "continue (S/N)?" CONTINUE
		read -p "continue (S/N)?" CONTINUE
		[ "${CONTINUE^^}" == "S" ] || break 
	}
done
