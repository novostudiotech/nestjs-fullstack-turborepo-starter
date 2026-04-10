#!/usr/bin/env bash

COMMAND=$1
FILTER_APPS=$(awk -F',' '{ for( i=1; i<=NF; i++ ) printf "--filter="$i" " }' <<<"$2")

echo -e "> npx turbo run $COMMAND $FILTER_APPS\n"

npx turbo run $COMMAND $FILTER_APPS
