#!/bin/bash

# get current path
HERE="$(dirname ${BASH_SOURCE[0]})"

# save parameters and reset them
# ARGS=( "${@}" )
# set --

# source logger
{
	. "${HERE}/logger.include" || {
		. "${HERE}/../logger.include" || {
			echo "FATAL | cannot find logger.include"
			exit 255
		}
	}
} 2> /dev/null

# save this script name
NAME="$(basename ${BASH_SOURCE[0]})"

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
fi

