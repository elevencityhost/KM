#!/bin/bash
account=`whoami`
source=/home/$account/splunkforwarder-7.3.2-c60db69f8e32-Linux-x86_64.tgz
target=/usr/local/software/splunk
if [ -d "/usr/local/software/" ];then
	if [ ! -d "/usr/local/software/splunk" ];then
         	  sudo mkdir /usr/local/software/splunk
	fi
else
	 sudo mkdir /usr/local/software
	 sudo mkdir /usr/local/software/splunk
fi
downloadMedia()
{
sudo yum -y install ftp
sudo yum -y install lftp
ip=************
port=22
user=***********
password=***********
localDir=/home/$account
remoteDir=/splunkfiles
targetFile=splunkforwarder-7.3.2-c60db69f8e32-Linux-x86_64.tgz
lftp -u ${user},${password} sftp://${ip}:${port}<<EOF
cd ${remoteDir}
lcd ${localDir}
get ${targetFile}
bye
EOF
}
downloadMedia
sudo cp $source $target
rm -rf $source
sudo tar -zxvf $target/splunkforwarder-7.3.2-c60db69f8e32-Linux-x86_64.tgz -C $target
sudo rm -rf $target/splunkforwarder-7.3.2-c60db69f8e32-Linux-x86_64.tgz
sudo bash -c "cat > $target/splunkforwarder/etc/system/local/user-seed.conf"<<eof
[user_info]
USERNAME =
HASHED_PASSWORD =
eof
sudo bash -c "cat > $target/splunkforwarder/etc/system/local/limits.conf"<<eof
[thruput]
maxKBps = 4096
eof
check_process=`sudo ps -ef|grep splunk`
check_port=`sudo netstat -an|grep 8089`
if [[ $check_result =~ "pid=" ]];then
	echo "splunk process already running !!!"
	exit
elif [[ $check_port =~ "LISTEN" ]];then
	echo "port 8089 has been used !!!"
	exit
else
	echo "starting splunk....."
	# sudo $target/splunkforwarder/bin/splunk start --accept-license
fi
check_process_again=`sudo ps -ef|grep splunk`
echo check_process_again
if [[ $check_process_again =~ "pid=" ]];then
	echo "You have successfully installed splunk uniforwarder !!!"
else
	echo "Splunk uniforwarder installation encountered exception, please check !!!"
fi
