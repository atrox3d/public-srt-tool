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
	if . "${here}/logger.include"
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
exit
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

# check params
info "PARAMS | ${@:-no params}"
if [ ${#} -gt 1 ]
then
	BASE_DIR="${1}"
	shift
	
	CUR_DIR="${BASE_DIR}"
	info ./countfiles.include "${CUR_DIR}" "${@}"
	./countfiles.include "${CUR_DIR}" "${@}"
	VIDEO_COUNT=$?
	while [ ${VIDEO_COUNT} -eq 0 ]
	do
		shopt -s nullglob
		# get dirs list
		SUBDIRS=("${CUR_DIR}"/*/)
		# reset
		shopt -u nullglob
		info "subdirs: ${SUBDIRS[@]}"
		
		for CUR_DIR in "${SUBDIRS[@]}"
		do
			info "CUR_DIR: ${CUR_DIR}"
			info ./countfiles.include "${CUR_DIR}" "${@}"
			./countfiles.include "${CUR_DIR}" "${@}"
			VIDEO_COUNT=$?
		done
	done
else
	fatal "syntax: ${NAME} start-directory"
fi

