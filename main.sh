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


. countfiles.include

info "START"
# __DEBUG_ENABLE

video_files=($(countfiles ./movie mp4 mkv))
echo "${video_files[@]}"
echo "${#video_files[@]}"
exit
total_videos=$?
info "total video files: $total_videos"
for file in "${video_files[@]}"
do
	info "video file       :  $file"
done
[ $total_videos -eq 0 ] && { fatal "no video files"; exit; }
[ $total_videos -gt 1 ] && { fatal "too many video files: $total_videos"; exit; }





# total_videos=${#videos[@]}
# info "total videos: $total_videos"
# if [ $total_videos -gt 1 ]
# then
	# fatal "too much video files"
	# exit
# fi

