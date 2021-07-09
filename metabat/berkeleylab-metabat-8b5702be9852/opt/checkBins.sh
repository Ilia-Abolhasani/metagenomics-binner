#!/bin/bash

USAGE="$0 BinDir"

if [ $# -lt 1 ]
then
  echo "$USAGE" 1>&2
  exit 1
fi

bindir=$1

# Resolve the base path and bootstrap the environment
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

echo "Starting $0 $@ at $(date)"

set -e
onerr()
{
  echo "uh oh something went wrong with '$0 $@' at $(date)" 1>&2
  trap "" 0
  exit 1
}
trap onerr 0 1 2 3 15

if [ ! -f $bindir/CheckM.txt ]
then
  echo "Running checkm $(date)"
  $DIR/jgi_docker_wrapper.sh sstevens/checkm checkm lineage_wf -f $bindir/CheckM.txt.tmp -t 8 -x fa $bindir/ $bindir/SCG
  mv $bindir/CheckM.txt.tmp $bindir/CheckM.txt 
  echo "Completed checkm at $(date)"
fi

if [ ! -f $bindir/CheckM-perf.txt ]
then
  echo "Running R performance check $(date)"
  Rscript $DIR/benchmark.R $bindir > $bindir/CheckM-perf.txt.tmp
  mv $bindir/CheckM-perf.txt.tmp $bindir/CheckM-perf.txt
  echo "Completed benchmark.R at $(date)"
fi

trap "" 0
echo "Completed $0 $@ at $(date)"
