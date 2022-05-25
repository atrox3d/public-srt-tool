#!/bin/bash
. logger.include
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

