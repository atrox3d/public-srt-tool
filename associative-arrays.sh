#!/bin/bash

declare -A LEVELS=( [debug]=0 [info]=1 [warning]=2 [error]=3 [fatal]=4 )
echo "${!LEVELS[@]}"
echo "${LEVELS[@]}"