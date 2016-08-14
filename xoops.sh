#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS / RedHat / Fedora
#   Description:  
#   Author: 
#   Intro:  https://github.com/xichiou/xoops
#===============================================================================================

clear

# Current folder
cur_dir=`pwd`

# Get public IP
function getIP(){
    IP=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\." | head -n 1`
    if [[ "$IP" = "" ]]; then
        IP=`curl -s -4 icanhazip.com`
    fi
}
