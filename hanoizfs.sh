#!/bin/bash

#Implement modular and infinite hanoi rotation backup in zfs
#http://en.wikipedia.org/wiki/Backup_rotation_scheme#Towers_of_Hanoi
#http://lists.debian.org/debian-bsd/2011/12/msg00045.html

#use cron or systemd.timer to call this file periodically

#first argument is the duration of a 'day' in seconds
#if you want to take daily backups then 86400
#second argument is the pool name
#third argument is the filesystem name: pool/fs

#control the duration of a 'day'
PERIOD=$1

#calculate the tape number,

#if tapes are finite (n):
#tape 1 contains day = 2*i+1
#tape 2 contains day = 4*i+2
#tape n-1 contains day = 2^(n-1)*i+ 2^(n-2)
#tape n contains day = 2^(n-1)*i

#if there are infinite number of tapes,
#tape n contains day = 2^(n-1)*i+2^(n-2)
#so day = 2^tape*(2i+1)

#Thus, find the maximum power of 2 that divides the number
#this is the tape that will be used for this period
findtape ()
{
local mytime=$(( $1 / $PERIOD ))
local i=0
#echo $mytime
until [ $(( $mytime % 2 )) -eq 1 ];
do
  (( i++ ))
  (( mytime >>=1 ))
done

return $i

}

#skip snapshot if scrub  is ongoing
zpool status -v $2 | grep scrub | grep -q -v progress

if [ $? -ne 0 ]
  then
    echo Scrub is running
    exit 0
fi

current_second=$(date +%s)
findtape $current_second
tape=$?
#echo $current_second $tape

#create a temporary snapshot
zfs snapshot $3"@hanoisnaptemp"

#delete old snapshots of the current tape
delete_snapshots=$(zfs list -r -t snapshot $3 | grep hanoisnap_"$tape"_ | awk '{print $1}')
#echo $delete_snapshots
for snapshot in $delete_snapshots; do
  echo Deleting $snapshot
  zfs destroy $snapshot
done

#rename the temporary to the calculated tape
zfs rename $3@hanoisnaptemp $3"@hanoisnap_"$tape"_"$(date +%F-%H%M)
