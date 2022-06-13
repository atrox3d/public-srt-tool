#!/bin/bash
# for d in /e/VIDEO/film\ ENG/*/;do ./template-movie.sh "${d}" run;[ $? -eq 0 ] || break;done

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
HERE="$(dirname ${BASH_SOURCE[0]})"
NAME="$(basename ${BASH_SOURCE[0]})"	# save this script name
logger_setlevel info

WORKDIR="${1}"
RUN="${2^^}"

info "HERE   | ${HERE}"
info "NAME   | ${NAME}"
info "WORKDIR| ${WORKDIR}"
info "RUN    | ${RUN}"

[ $# -gt 0 ] || {
	fatal "SYNTAX | ${NAME} {WORKDIR} [RUN]"
	fatal "SYNTAX | WORKDIR: work directory"
	fatal "SYNTAX | RUN    : \"RUN\" or nothing"
	exit 255
}

for d in "${WORKDIR}"/*/
do
	info "${HERE}"/template-movie.sh "${d}" "${RUN}"
	"${HERE}"/template-movie.sh "${d}" "${RUN}"
	EXITCODE=$?
	info "EXITCODE | ${EXITCODE}"
	[ $? -eq 0 ] || {
		info read -p "continue (S/N)?" CONTINUE
		read -p "continue (S/N)?" CONTINUE
		[ "${CONTINUE^^}" == "S" ] || break 
	}
done
