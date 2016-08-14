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

wget 'http://120.115.2.90/modules/tad_uploader/index.php?op=dlfile&cfsn=108&cat_sn=16&name=xoopscore25-2.5.8_tw_20160529.zip' -O xoops.zip
unzip xoops.zip

wget --no-check-certificate https://github.com/tad0616/tadtools/archive/master.zip -O tadtools.zip
unzip tadtools.zip

wget --no-check-certificate https://github.com/tad0616/tad_adm/archive/master.zip -O tad_adm.zip
unzip tad_adm.zip

wget --no-check-certificate https://github.com/tad0616/tad_themes/archive/master.zip -O tad_themes.zip
unzip tad_themes.zip

cd XoopsCore25-2.5.8
chown -R apache.apache htdocs
mv /var/www/html /var/www/html_org
mv htdocs /var/www/html
cd ..

chown -R apache.apache tadtools-master
mv tadtools-master /var/www/html/modules/tadtools

chown -R apache.apache tad_adm-master
mv tad_adm-master /var/www/html/modules/tad_adm

chown -R apache.apache tad_themes-master
mv tad_themes-master /var/www/html/modules/tad_themes



cd /var/www/html
mv xoops_* /var/www



