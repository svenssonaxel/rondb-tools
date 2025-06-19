#!/usr/bin/env bash

source ./scripts/include.sh

proclist() {
  for proc in $possible_procs; do
    for pid in $(pgrep -x "${proc:0:15}"); do
    echo "$proc"
    done
  done |
  uniq -c |
  sed -r 's/^ +//;s/^1 //;s/^([0-9]+) /\1x /;1!s/^/, /;' |
  tr -d '\n'
}

plist="$(proclist)"
if [ -z "$plist" ];
then echo NOTHING running
else echo Running $plist
fi
