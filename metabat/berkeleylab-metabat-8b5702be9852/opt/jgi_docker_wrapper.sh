#!/bin/bash

USAGE="Proper Usage: $0 image cmd [...]"

if [ $# -lt 2 ]
then
  echo "$USAGE" 1>&2
  echo "ERROR - please specify an image and command to execute" 1>&2
  exit 1
fi

image=$1
shift
cmd=$2

shifter=$(which shifter 2>/dev/null || true)
docker=$(which docker 2>/dev/null || true)
cmd2=$(which cmd 2>/dev/null || true)

set -e
set -o pipefail

RUN_PREFIX=
if [ -x "${cmd2}" ]
then
  # no need for shifter or docker
  RUN_PREFIX=time
elif [ -x "${shifter}" ]
then
  img=$(${shifter}img lookup $image 1>&2 || true)
  [ -z "$img" ] && ${shifter}img pull $image 1>&2 && img=$(${shifter}img lookup $image)
  if [ -z "$img" ]
  then
    echo "$USAGE" 1>&2
    echo "ERROR - shifter could not pull $image" 1>&2
    exit 1
  fi
  RUN_PREFIX="shifter --image=id:${img}"
elif [ -x "${docker}" ]
then
  if ! docker pull $image 1>&2
  then
    echo "$USAGE" 1>&2
    echo "ERROR - docker could not pull $image" 1>&2
    exit 1
  fi
  img=$image
  volumes="--volume=$(pwd):$(pwd) --workdir=$(pwd)"
  if [ -n "$VOLUMES" ]
  then
    for v in $VOLUMES
    do
      volumes="$volumes --volume=$v:$v"
    done
  fi
  RUN_PREFIX="docker run -i --tty=false -a STDIN -a STDOUT -a STDERR --user $(id -u):$(id -g) $volumes ${img}"
else
  echo "$USAGE" 1>&2
  echo "Could not find '$cmd' or shifter or docker for image=$image.  Please update your PATH" 1>&2
  exit 1
fi

echo "Executing '$RUN_PREFIX $@' at $(date) on $(uname -n)" 1>&2

ret=0
$RUN_PREFIX $@ || ret=$?

if [ $ret -ne 0 ]
then
  echo "ERROR exit $ret for command '$RUN_PREFIX $@' at $(date)" 1>&2
  exit $ret
else
  echo "Finished at $(date) with $SECONDS s runtime" 1>&2
fi

