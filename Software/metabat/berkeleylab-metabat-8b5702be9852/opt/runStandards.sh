#!/bin/bash

USAGE="$0 /path/to/metabat2 [ binPrefix ]"
mb2=$(realpath $1)
if [ ! -x "$mb2" ]
then
  echo "$USAGE" 1>&2
  echo "Could not execute '$mb2'" 1>&2
  exit 1
fi

git=$(which git 2>/dev/null || true)
gitver=
if [ -x "$git" ]
then
  gitver=$(${git} describe --tags --dirty 2>/dev/null || true)
  [ -z "$gitver" ] || gitver="-$gitver"
fi

binPrefix=$2
[ -n "$binPrefix" ] || binPrefix=standard$gitver
invokedas="'$0 $@'"

# Resolve the base path and bootstrap the environment
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

echo "Starting $invokedas at $(date)"

set -e
set -o pipefail

onerr()
{
  echo "uh oh something went wrong with '$invokedas' at $(date)" 1>&2
  trap "" 0
  exit 1
}
trap onerr 0 1 2 3 15

if [ -n "$SCRATCH" ] && [ -w "$SCRATCH" ]
then
  WORKDIR=/$SCRATCH/$USER-metabat-standards
else
  WORKDIR=/tmp/$USER-metabat-standards
fi

mkdir -p $WORKDIR
cd $WORKDIR
echo "Saving files to $(pwd) and using binPrefix=$binPrefix"


for case in CASE1 CASE2 CASE3
do
  if [ ! -d $case ] 
  then
    mkdir $case.tmp
    cd $case.tmp
    wget https://portal.nersc.gov/dna/RD/Metagenome_RD/MetaBAT/Files/BestPractices/V2/$case/assembly.fa.gz
    wget https://portal.nersc.gov/dna/RD/Metagenome_RD/MetaBAT/Files/BestPractices/V2/$case/depth.txt
    cd ..
    mv $case.tmp $case
  fi

  # default, minus abundance table
  bins_noa=$binPrefix-$case-noabd
  if [ ! -d $bins_noa ]
  then
    rm -rf $bins_noa.tmp
    $mb2 -i $case/assembly.fa.gz -o $bins_noa.tmp/bin -v --seed 1 2>$bins_noa.err | tee $bins_noa.log
    mv $bins_noa.tmp $bins_noa
  fi
  $DIR/checkBins.sh $bins_noa 2>&1 | tee $bins_noa-checkBins.log
  cat $bins_noa/CheckM-perf.txt

  
  # default
  bins=$binPrefix-$case
  if [ ! -d $bins ]
  then
    rm -rf $bins.tmp
    $mb2 -i $case/assembly.fa.gz -a $case/depth.txt -o $bins.tmp/bin -v --seed 1 2>$bins.err | tee $bins.log
    mv $bins.tmp $bins
  fi
  $DIR/checkBins.sh $bins 2>&1 | tee $bins-checkBins.log
  cat $bins/CheckM-perf.txt

  Rscript $DIR/benchmark.R $bins_noa $bins > CheckM-diffperf.txt.tmp
  mv CheckM-diffperf.txt.tmp CheckM-diffperf-noabd.txt
  echo "Completed diffperf between $bins_noa and $bins at $(date)"
  cat CheckM-diffperf-noabd.txt


  # default with minContig 2000
  bins2=$binPrefix-$case-m2000
  if [ ! -d $bins2 ]
  then
    rm -rf $bins2.tmp
    $mb2 -i $case/assembly.fa.gz -a $case/depth.txt -o $bins2.tmp/bin -v -m 2000 --seed 1 2>$bin2.err | tee $bins2.log
    mv $bins2.tmp $bins2
  fi
  $DIR/checkBins.sh $bins2 2>&1 | tee $bins2-checkBins.log
  cat $bins2/CheckM-perf.txt

  Rscript $DIR/benchmark.R $bins $bins2 > CheckM-diffperf.txt.tmp 
  mv CheckM-diffperf.txt.tmp CheckM-diffperf.txt
  echo "Completed diffperf between $bins and $bins2 at $(date)"

done


trap "" 0
echo "Done with $invokedas at $(date)"
