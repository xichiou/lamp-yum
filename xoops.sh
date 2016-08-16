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
unzip -q xoops.zip

wget --no-check-certificate https://github.com/tad0616/tadtools/archive/master.zip -O tadtools.zip
unzip -q tadtools.zip
chown -R apache.apache tadtools-master

wget --no-check-certificate https://github.com/tad0616/tad_adm/archive/master.zip -O tad_adm.zip
unzip -q tad_adm.zip
chown -R apache.apache tad_adm-master

#wget --no-check-certificate https://github.com/tad0616/tad_themes/archive/master.zip -O tad_themes.zip
#unzip -q tad_themes.zip
#chown -R apache.apache tad_themes-master


cd XoopsCore25-2.5.8
chown -R apache.apache htdocs

# Choose XOOPS site location type
while true
do
	echo "Please choose your XOOPS URL type:"
	echo -e "\t\e[32m1\e[0m. http://${IP}/"
	echo -e "\t\e[32m2\e[0m. http://${IP}/XOOPS/"
	read -p "Please input a number:(Default 1) " SITE_root_type
	[ -z "$SITE_root_type" ] && SITE_root_type=1
	case $SITE_root_type in
		1|2)
		echo ""
		echo "---------------------------"
		echo "You choose = $SITE_root_type"
		echo "---------------------------"
		echo ""
		break
		;;
		*)
		echo "Input error! Please only input number 1,2"
	esac
done	

if [ $SITE_root_type -eq 1 ]; then
	mv /var/www/html /var/www/html_org
	mv htdocs /var/www/html
	
	cd ..
	mv tadtools-master /var/www/html/modules/tadtools
	mv tad_adm-master /var/www/html/modules/tad_adm
	
	cd /var/www/html
	mv xoops_* /var/www
	
	echo ""
	echo 'Congratulations, setup XOOPS folder completed!'
	echo ""
	echo -e "Open your XOOPS site => http://${IP} to finish installation"
	echo ""
	echo "Enjoy it! "
	echo ""
	echo ""
fi


if [ $SITE_root_type -eq 2 ]; then
	# Set your XOOPS site location
	echo "Please input your XOOPS site location:"
	echo -e "your XOOPS site http://${IP}/\e[31mXOOPS\e[0m/"
	read -p "change XOOPS or Default:XOOPS ==>" SITE_root
	if [ -z $SITE_root ]; then
		SITE_root="XOOPS"
	fi
	
	mv htdocs /var/www/html/${SITE_root}
	mkdir /var/www/${SITE_root}

	cd ..
	mv tadtools-master /var/www/html/${SITE_root}/modules/tadtools
	mv tad_adm-master /var/www/html/${SITE_root}/modules/tad_adm

	cd /var/www/html/${SITE_root}
	mv xoops_* /var/www/${SITE_root}

	echo ""
	echo 'Congratulations, setup XOOPS folder completed!'
	echo ""
	echo -e "Open your XOOPS site => http://${IP}/\e[31m${SITE_root}\e[0m/ to finish installation"
	echo "Install step 4/14"
	echo -e "xoops_data directory:\e[31m/var/www/${SITE_root}/xoops_data\e[0m"
	echo -e "xoops_lib  directory:\e[31m/var/www/${SITE_root}/xoops_lib\e[0m"
	echo ""
	echo "Enjoy it! "
	echo ""
	echo ""
fi
