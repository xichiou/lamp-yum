#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS / RedHat / Fedora
#   Description:  Yum Install LAMP(Linux + Apache + MySQL/MariaDB + PHP )
#   Author: Teddysun <i@teddysun.com>
#   Intro:  https://teddysun.com/lamp-yum
#           https://github.com/teddysun/lamp-yum
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

# Install LAMP Script
function install_lamp(){
    rootness
    disable_selinux
    pre_installation_settings
    install_apache
    #install_database
    install_mariadb
    install_php
    install_phpmyadmin
    cp -f $cur_dir/lamp.sh /usr/bin/lamp
    chmod +x /usr/bin/lamp
    clear
    echo ""
    echo 'Congratulations, Yum install LAMP completed!'
    echo "Your Default Website: http://${IP}"
    echo "MySQL root password:$dbrootpwd"
    echo ""
    echo "Enjoy it! "
    echo ""
}

# Make sure only root can run our script
function rootness(){
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi
}

# Disable selinux
function disable_selinux(){
if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi
}

# Pre-installation settings
function pre_installation_settings(){
    echo ""
    echo "#############################################################"
    echo "# LAMP Auto yum Install Script for CentOS / RedHat / Fedora #"
    echo "# Intro: https://teddysun.com/lamp-yum                      #"
    echo "# Author: Teddysun <i@teddysun.com>                         #"
    echo "#############################################################"
    echo ""

    # Display Public IP
    echo "Getting Public IP address..."
    getIP
    echo -e "Your main public IP is\t\033[32m$IP\033[0m"
    echo ""
    
    # Set MySQL root password
    echo "Please input the root password of MySQL or MariaDB:"
    read -p "(Default password: root):" dbrootpwd
    if [ -z $dbrootpwd ]; then
        dbrootpwd="root"
    fi
    echo ""
    echo "---------------------------"
    echo "Password = $dbrootpwd"
    echo "---------------------------"
    echo ""
     # Choose PHP version
    while true
    do
    echo "Please choose a version of the PHP:"
    echo -e "\t\033[32m1\033[0m. Install PHP-5.6"
    echo -e "\t\033[32m2\033[0m. Install PHP-7.0"
    read -p "Please input a number:(Default 1) " PHP_version
    [ -z "$PHP_version" ] && PHP_version=1
    case $PHP_version in
        1|2)
        echo ""
        echo "---------------------------"
        echo "You choose = $PHP_version"
        echo "---------------------------"
        echo ""
        break
        ;;
        *)
        echo "Input error! Please only input number 1,2"
    esac
    done
    get_char(){
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
    }
    echo ""
    echo "Press any key to start...or Press Ctrl+C to cancel"
    char=`get_char`

    yum -y install unzip wget
    yum -y install epel-release
    wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
    rpm -Uvh remi-release-7*.rpm
    
    #yum -y update
    
    yum -y install ntp
    ntpdate -d tick.stdtime.gov.tw
}

# Install Apache
function install_apache(){
    # Install Apache
    echo "Start Installing Apache..."
    yum -y install httpd
    systemctl enable httpd
    systemctl start httpd
    echo "Apache Install completed!"
}

# Install database
function install_database(){
    if [ $DB_version -eq 1 ]; then
        install_mysql
    elif [ $DB_version -eq 2 ]; then
        install_mariadb
    fi
}

# Install MariaDB
function install_mariadb(){
    # Install MariaDB
    echo "Start Installing MariaDB..."
    yum -y install mariadb mariadb-server
    systemctl enable mariadb
    systemctl start mariadb
    /usr/bin/mysqladmin password $dbrootpwd
    /usr/bin/mysql -uroot -p$dbrootpwd <<EOF
drop database if exists test;
delete from mysql.user where user='';
update mysql.user set password=password('$dbrootpwd') where user='root';
delete from mysql.user where not (user='root') ;
flush privileges;
exit
EOF
    echo "MariaDB Install completed!"
}

# Install PHP
function install_php(){
    echo "Start Installing PHP..."
    
    if [ $PHP_version -eq 1 ]; then
     remi-php70.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php70.repo
        sed -i '/php56]/,/gpgkey/s/enabled=0/enabled=1/g' /etc/yum.repos.d/remi.repo
    fi
    
    if [ $PHP_version -eq 2 ]; then
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi.repo
        sed -i '/php70]/,/gpgkey/s/enabled=0/enabled=1/g' /etc/yum.repos.d/remi-php70.repo
    fi
    
    yum -y install php php-gd php-mysql php-mcrypt
    
    sed -i 's/^.*date\.timezone.*=.*/date\.timezone = "Asia\/Taipei"/g' /etc/php.ini
    sed -i 's/^.*display_errors.*=.*/display_errors = On/g' /etc/php.ini
    sed -i 's/^.*max_execution_time.*=.*/max_execution_time = 150/g' /etc/php.ini
    sed -i 's/^.*max_file_uploads.*=.*/max_file_uploads = 300/g' /etc/php.ini
    sed -i 's/^.*max_input_time.*=.*/max_input_time = 120/g' /etc/php.ini
    sed -i 's/^.*max_input_vars.*=.*/max_input_vars = 5000/g' /etc/php.ini
    sed -i 's/^.*memory_limit.*=.*/memory_limit = 240M/g' /etc/php.ini
    sed -i 's/^.*post_max_size.*=.*/post_max_size = 220M/g' /etc/php.ini
    sed -i 's/^.*upload_max_filesize.*=.*/upload_max_filesize = 200M/g' /etc/php.ini
    
    systemctl reload httpd
    
    echo "PHP install completed!"
}
# Install phpmyadmin.
function install_phpmyadmin(){
    yum -y install phpMyAdmin
    #vi /etc/httpd/conf.d/phpMyAdmin.conf
    #line 17: 127.0.0.1 => 127.0.0.1 192 172

    #Start httpd service
    systemctl restart httpd
}

# Add apache virtualhost
function vhost_add(){
    #Define domain name
    read -p "(Please input domains such as:www.example.com):" domains
    if [ "$domains" = "" ]; then
        echo "You need input a domain."
        exit 1
    fi
    domain=`echo $domains | awk '{print $1}'`
    if [ -f "/etc/httpd/conf.d/$domain.conf" ]; then
        echo "$domain is exist!"
        exit 1
    fi
    #Create database or not    
    while true
    do
    read -p "(Do you want to create database?[y/N]):" create
    case $create in
    y|Y|YES|yes|Yes)
    read -p "(Please input the user root password of MySQL or MariaDB):" mysqlroot_passwd
    /usr/bin/mysql -uroot -p$mysqlroot_passwd <<EOF
exit
EOF
    if [ $? -eq 0 ]; then
        echo "MySQL or MariaDB root password is correct.";
    else
        echo "MySQL or MariaDB root password incorrect! Please check it and try again!"
        exit 1
    fi
    read -p "(Please input the database name):" dbname
    read -p "(Please set the password for mysql user $dbname):" mysqlpwd
    create=y
    break
    ;;
    n|N|no|NO|No)
    echo "Not create database, you entered $create"
    create=n
    break
    ;;
    *) echo Please input only y or n
    esac
    done

    #Create database
    if [ "$create" == "y" ];then
        /usr/bin/mysql -uroot -p$mysqlroot_passwd  <<EOF
CREATE DATABASE IF NOT EXISTS \`$dbname\`;
GRANT ALL PRIVILEGES ON \`$dbname\` . * TO '$dbname'@'localhost' IDENTIFIED BY '$mysqlpwd';
GRANT ALL PRIVILEGES ON \`$dbname\` . * TO '$dbname'@'127.0.0.1' IDENTIFIED BY '$mysqlpwd';
FLUSH PRIVILEGES;
EOF
    fi
    #Define website dir
    webdir="/data/www/$domain"
    DocumentRoot="$webdir/web"
    logsdir="$webdir/logs"
    mkdir -p $DocumentRoot $logsdir
    chown -R apache:apache $webdir
    #Create vhost configuration file
    cat >/etc/httpd/conf.d/$domain.conf<<EOF
<virtualhost *:80>
ServerName  $domain
ServerAlias  $domains 
DocumentRoot  $DocumentRoot
CustomLog $logsdir/access.log combined
DirectoryIndex index.php index.html
<Directory $DocumentRoot>
Options +Includes -Indexes
AllowOverride All
Order Deny,Allow
Allow from All
php_admin_value open_basedir $DocumentRoot:/tmp
</Directory>
</virtualhost>
EOF
    service httpd restart > /dev/null 2>&1
    echo "Successfully create $domain vhost"
    echo "######################### information about your website ############################"
    echo "The DocumentRoot:$DocumentRoot"
    echo "The Logsdir:$logsdir"
    [ "$create" == "y" ] && echo "database name and user:$dbname and password:$mysqlpwd"
}

# Remove apache virtualhost
function vhost_del(){
    read -p "(Please input a domain you want to delete):" vhost_domain
    if [ "$vhost_domain" = "" ]; then
        echo "You need input a domain."
        exit 1
    fi
    echo "---------------------------"
    echo "vhost account = $vhost_domain"
    echo "---------------------------"
    echo ""
    get_char(){
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
    }
    echo "Press any key to start delete vhost...or Press Ctrl+c to cancel"
    echo ""
    char=`get_char`

    if [ -f "/etc/httpd/conf.d/$vhost_domain.conf" ]; then
        rm -f /etc/httpd/conf.d/$vhost_domain.conf
        rm -rf /data/www/$vhost_domain
    else
        echo "Error:No such domain file, Please check your input domain and try again."
        exit 1
    fi

    service httpd reload > /dev/null 2>&1
    echo "Successfully delete $vhost_domain vhost"
}

# List apache virtualhost
function vhost_list(){
    ls /etc/httpd/conf.d/ | grep -v "php.conf" | grep -v "none.conf" | grep -v "welcome.conf" | grep -iv "README" | awk -F".conf" '{print $1}'
}

# Initialization step
action=$1
[ -z $1 ] && action=install
case "$action" in
install)
    install_lamp
    ;;
add)
   vhost_add
    ;;
del)
   vhost_del
    ;;
list)
   vhost_list
    ;;
*)
    echo "Usage: `basename $0` [install|uninstall|add|del|list]"
    ;;
esac
