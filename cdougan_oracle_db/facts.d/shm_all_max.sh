#!/bin/bash
#===============================================================================
#
#          FILE: shmall.sh
# 
#         USAGE: ./shmall.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 06/15/2017 11:50
#      REVISION:  ---
#===============================================================================
mem="$(free -b | grep Mem | awk '{print $2}')"
echo "total_mem=$mem"
shmmax="$((mem/2))"
echo "shmmax=$shmmax"
shmall="$((mem/8192))"
echo "shmall=$shmall"
