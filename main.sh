#!/bin/bash
. logger.include

info "START"
#log wrong x


function count_files()
{
	extensions=($@)
	total=0
	for ext in ${extensions[@]}
	do
		_total=$(ls *.${ext} 2>/dev/null | wc -l)
		total=$((total + _total))
	done
	return $total
}

count_files mp4 mkv
total_videos=$?
[ $total_videos -eq 0 ] && { fatal "no video files"; exit; }
[ $total_videos -gt 1 ] && { fatal "too many video files: $total_videos"; exit; }



# total_videos=${#videos[@]}
# info "total videos: $total_videos"
# if [ $total_videos -gt 1 ]
# then
	# fatal "too much video files"
	# exit
# fi

