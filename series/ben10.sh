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

# check params
info "PARAMS | ${@}"
if [ ${#} -gt 0 ]
then
	#
	# loop through seasons
	#
	# ${1}/ : /e/VIDEO/serieTV ENG/ben 10/ 
	# */    : 01/ 
	# */    : Ben.10.S01.1080p.WEBRip.x265-RARBG/
	#
	for season in "${1}"/*/*/
	do
		info "pushd season | ${season}"
		pushd "${season}" &> /dev/null
			#
			# loop through subtitles subdirs
			# ${season}/ : /e/VIDEO/serieTV ENG/ben 10/01/Ben.10.S01.1080p.WEBRip.x265-RARBG/
			# Subs/      : Subs/
			# */         : Ben.10.S01E01.1080p.WEBRip.x265-RARBG/
			#
			for subsdir in "${season}"/Subs/*/
			do
				info "subsdir | ${subsdir}"
				#
				# loop through srtfiles
				# ${subsdir} : /e/VIDEO/serieTV ENG/ben 10/01/Ben.10.S01.1080p.WEBRip.x265-RARBG//Subs/Ben.10.S01E01.1080p.WEBRip.x265-RARBG//
				# */         : 2_English.srt
				#
				# TODO: stop at first or add counter
				#
				for srtfile in "${subsdir}"/*
				do
					info "srtfile | ${srtfile}"
					#
					# Ben.10.S01E01.1080p.WEBRip.x265-RARBG.srt
					#
					filename="$(basename "${subsdir}").srt"
					info "filename | ${filename}"
					#
					# copy srt files at video files level
					#
					info "cp ${srtfile} ${season}/${filename}"
					cp "${srtfile}" "${season}/${filename}" || {
						fatal "error copying"
						exit 255
					}
				done
			done
		# cd back
		info popd
		popd  &> /dev/null
	done
else
	fatal "syntax | ${NAME} path"
fi

