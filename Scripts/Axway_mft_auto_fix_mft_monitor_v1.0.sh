#!/bin/bash
Start_time=$(date "+%Y%m%d%H%M")
echo "++++++++++++++++++++++++start time is +++++++++++++++++++++++++++++"+"${Start_time}"
#Move q_se_time.csv which generated 2 hours before to /tmp/mft_log/bak/ and tag by timestamp
echo "--------Begin to move the old file--------"
tem_time=$(date "+%Y%m%d%H%M")
if [ -a /tmp/mft_log/q_se_time.csv ]; then
   mv /tmp/mft_log/q_se_time.csv /tmp/mft_log/bak/$tem_time.csv
fi
echo "Completed the remove"
#Connect Axway-combined mysql and select error records by filter accountname 'xxxxxxxxx' and 'xxxxxxx' then output to /tmp/mft_log/q_se_time.csv
echo "Begin to scan the DB log"
cd /opt/MFT/Axway/SecureTransport/mysql/bin/
./mysql --defaults-file=/opt/MFT/Axway/SecureTransport/conf/mysql.conf -uroot -pxxxxxxxxx -D st <<EOF
SELECT FROM_UNIXTIME(a.starttime/1000,'%Y-%m-%d %H:%i:%s') as starttime,a.accountname,a.clientdir AS 'Subscriptionfolder',a.filename,a.remotedir,b.data AS 'Failedreason' FROM TransferStatus a LEFT JOIN TransferData b ON a.id=b.transferstatusid WHERE a.accountname in ('Ex_iCoastline_P','EX_MMI_P') and a.starttime/1000 > (unix_timestamp(now()) - 60*60*2) and (a.STATUS='2' or a.STATUS='12') ORDER BY a.starttime DESC into outfile '/tmp/mft_log/q_se_time.csv';
exit
EOF
echo "Completed the scanning"
echo "-----------check and move file-------------"
#file=q_se_time.csv new generated file
IFS='	'
while read f_time f_username f_v_dir f_filename f_p_name f_code;
do
	#Account is Ex_iCoastline_P and ErrorCode is Exit Code -64
	if [[ "$f_username" = "zzzzzzzzz" ]] && [[ "$f_code" = "Exit Code -64" ]];then
		mv "$f_p_name/Archive/tmp/$f_filename" "$f_p_name/$f_filename"
	fi

	#Account is EX_MMI_P and ErrorCode is Exit Code -64
	if [[ "$f_username" = "xxxxxxxxx" ]] && [[ "$f_code" = "Exit Code -64" ]];then
		#filename match "xxxxxxxx*.txt"
		if [[ $f_filename == xxxxxxx*.txt ]];then
			mv "$f_p_name/tmp/$f_filename" "$f_p_name/$f_filename"
		fi
		
		#filename match "a*.txt"
		if [[ $f_filename == a*.txt ]];then
			mv "$f_p_name/tmp/$f_filename" "$f_p_name/$f_filename"
		fi
		
		#filename match xxxxx*.xml
		if [[ $f_filename == xxxxxx*.xml ]];then
			mv "$f_p_name/tmp/$f_filename" "$f_p_name/$f_filename"
		fi
	fi
done < "/tmp/mft_log/q_se_time.csv"
echo "Completed the remove business file"
End_time=$(date "+%Y%m%d%H%M")
echo "+++++++++++++++++++++++++++++End time is ++++++++++++++++++++++++++"+"${End_time}"
