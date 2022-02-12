#!/bin/bash
. logger.include
. files.include

info "START"

video_file="$(countfiles mp4 mkv)"
total_videos=$?
echo $video_file
[ $total_videos -eq 0 ] && { fatal "no video files"; exit; }
[ $total_videos -gt 1 ] && { fatal "too many video files: $total_videos"; exit; }





# total_videos=${#videos[@]}
# info "total videos: $total_videos"
# if [ $total_videos -gt 1 ]
# then
	# fatal "too much video files"
	# exit
# fi

