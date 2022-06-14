#!/bin/bash

echo "params : ${@}"
echo "#params: ${#@}"

while getopts "ab:" OPT
do
	echo "OPT: $OPT | OPTARG: $OPTARG | OPTIND: $OPTIND"
	case "$OPT" in
		
	esac
done
echo shift "$((OPTIND-1))"
shift "$((OPTIND-1))"

echo "params : ${@}"
echo "#params: ${#@}"
