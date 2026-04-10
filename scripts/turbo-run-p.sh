#!/usr/bin/env bash

COMMAND=$1
shift

FILTER_ARGS=""
for app in $(echo "$@" | tr ',' ' '); do
  for dir in apps packages; do
    pkg="$dir/$app/package.json"
    if [ -f "$pkg" ]; then
      name=$(node -p "require('./$pkg').name")
      FILTER_ARGS="$FILTER_ARGS --filter=$name"
      break
    fi
  done
done

echo -e "> npx turbo run $COMMAND --parallel $FILTER_ARGS\n"

npx turbo run $COMMAND --parallel $FILTER_ARGS
