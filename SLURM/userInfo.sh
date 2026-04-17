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
