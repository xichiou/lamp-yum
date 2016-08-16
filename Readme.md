## 简介
* 1. LAMP 指的是 Linux + Apache + MySQL + PHP 运行环境
* 2. LAMP 一键安装是用 Linux Shell 语言编写的，用于在 CentOS/Redhat 系统上一键安装 LAMP 环境的脚本。



## 如何安装
### 第一步，下载、解压、赋予权限：

    yum install -y unzip wget
    wget --no-check-certificate https://github.com/xichiou/lamp-yum/archive/master.zip -O lamp-yum.zip
    unzip lamp-yum.zip
    cd lamp-yum-master/
    chmod +x *.sh

### 第二步，安装LAMP
终端中输入以下命令：

    ./lamp.sh 2>&1 | tee lamp.log


##命令一览：
* MySQL 或 MariaDB 命令: 

        systemctl (start|stop|restart|reload|status) mariadb

* Apache 命令: 

        systemctl (start|stop|restart|reload|status) httpd

