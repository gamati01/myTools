#!/bin/bash
#
USER=$1
#
if [ -z "$USER" ]; then
    echo "user not defined "
    echo "Usage: $0 <user>"
    exit 1
fi
#
# export START=2025-01-01
#
START=$2
if [ -z "$START" ]; then
    export START=now-7days
fi
#
END=$3
if [ -z "$END" ]; then
    export END=now
fi
#
echo "#-----------------"
echo "#Info about user "$1
echo "#from            "$START
echo "#to              "$END
echo "#-----------------"
# 
#
sacct -u $1 -X  -S $START -E $END --format=jobid,user,elapsedraw,state,partition,alloctres -P  | sed s'/|/,/g'  | sed s'/=/,/g'
#
# 
[gamati01@login07 bin]$  vi jobInfo.sh 
[gamati01@login07 bin]$ cat jobInfo.sh 
#!/bin/bash
#
JOB=$1
OPT=$2
#
if [ -z "$JOB" ]; then
    echo "jobid not defined "
    echo "Usage: $0 <jobid>"
    exit 1
fi
#
if [ -z "$OPT" ]; then
# do nothing
    echo "-----------------"
    echo "Info about job "$1
    echo "-----------------"
else
    echo "-----------------"
    echo "Info about job "$1
    echo "Looking for energy (only leonardo, in 2026) "
    echo "-----------------"
fi
#
# 
sacct -j $1 -X  --format=jobid,user,elapsedraw,state,partition,start,end,submit,alloctres -P  | sed s'/|/,/g' | grep -v ElapsedRaw > $1.temp
#
export USER=`awk -F"," '{print $2}'  $1.temp`
export TIME=`awk -F"," '{print $3}'  $1.temp`
export STAT=`awk -F"," '{print $4}'  $1.temp`
export PART=`awk -F"," '{print $5}'  $1.temp`
export START=`awk -F"," '{print $6}' $1.temp`
export END=`awk -F"," '{print $7}' $1.temp`
export SUBM=`awk -F"," '{print $8}' $1.temp`
export NODE=`awk -F"=" '{print $NF}' $1.temp`
echo "user="$USER
echo "time="$TIME
echo "status="$STAT
echo "partition="$PART
echo "nodes used="$NODE
echo "submit="$SUBM
echo "start="$START
echo "end="$END
awk -F"," '{print $10}'  $1.temp
awk -F"," '{print $11}'  $1.temp
# 
if [ -z "$OPT" ]; then
    echo "-----------------"
else
    export FILE="/leonardo_work/cin_emon/BEO-en_measurements/beo--2026*--noheader.csv"
#
    export ETS=`grep slurm$1 $FILE | awk -F"," '{print $(NF-2)}'`
    export POW=`echo $ETS $TIME $NODE  | awk '{print $1/($2*$3)}'`
    echo "tot. energy (j)="$ETS
    echo "mean power per node (W)="$POW
    echo "-----------------"
fi
#
rm -rf $1.temp
