#!/bin/bash
. logger.include

info "START"
#log wrong x

extensions=(mp4 mkv)
for ext in ${extensions[@]}
do
	_videos=(*.${ext})
	videos=(${videos[@]} ${_videos[@]})
	info ${videos[@]}
done

total_videos=${#videos[@]}
info "total videos: $total_videos"
if [ $total_videos -gt 1 ]
then
	fatal "too much video files"
	exit
fi

