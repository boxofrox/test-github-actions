#!/bin/bash

err() {
  echo "$@" >&2
}

usage() {
  err "Usage: release-draft.sh FIRST_COMMIT LAST_COMMIT"
}

FIRST_COMMIT=$1
LAST_COMMIT=$2

shift
shift

if [[ -z "$FIRST_COMMIT" ]]; then
  err "Missing argument FIRST_COMMIT"
  exit 1
fi

if [[ -z "$LAST_COMMIT" ]]; then
  err "Missing argument LAST_COMMIT"
  exit 1
fi

HEADER_MSG=$(cat <<EOF
hello world
EOF
)

git log $FIRST_COMMIT^1..$LAST_COMMIT --format="%s" --reverse --no-merges \
  | sed 's/\(^.*$\)/- \1/' \
  | (echo $HEADER_MSG; cat -;) \
  | sed 's/$/\\n/' \
  | tr -d '\n' \
  | (echo -n '{ "text": "'; cat -; echo '" }';) \
  | curl -X POST -H 'Content-Type: application/json; charset=utf-8' --data-binary @- http://httpbin.org/anything
