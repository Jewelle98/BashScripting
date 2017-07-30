#!/bin/bash

trap '' 2
trap '' SIGTSTP

##########################################################################################

checkforsdb1lvm=`fdisk -l | grep /dev/sdb1 | grep "Linux LVM"`

if [ -z "$checkforsdb1lvm" ]
then
	echo "Please create a /dev/sdb1 partition with at least 8GB and LVM system ID first"

else
	printf "/tmp\n"
	tmpcheck=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab`

	if [ -z "$tmpcheck" ]
	then
		vgcheck=`vgdisplay | grep "VG Name" | grep "MyVG"`

		if [ -z "$vgcheck" ]
		then
			vgcreate MyVG /dev/sdb1 &> /dev/null
		fi
		
		lvcheck=`lvdisplay | grep "LV Name" | grep "TMPLV"`

		if [ -z "$lvcheck" ]
		then 
			lvcreate -L 500M -n TMPLV MyVG &> /dev/null
			mkfs.ext4 /dev/MyVG/TMPLV &> /dev/null
		fi

		echo "/dev/MyVG/TMPLV	/tmp	ext4	defaults 0 0" >> /etc/fstab
		mount -a
		echo "1. /tmp partition - FIXED"
	fi

	nodevcheck1=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nodev`
	nosuidcheck1=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nosuid`
	noexeccheck1=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep noexec`

	if [ -z "$nodevcheck1" ]
	then
		sed -ie 's:\(.*\)\(\s/tmp\s\s*\)\(\w*\s*\)\(\w*\s*\)\(.*\):\1\2\3nodev,\4\5:' /etc/fstab
		echo "2. nodev for /tmp - FIXED (Persistent)"
	fi

	if [ -z "$nosuidcheck1" ]
	then
		sed -ie 's:\(.*\)\(\s/tmp\s\s*\)\(\w*\s*\)\(\w*\s*\)\(.*\):\1\2\3nosuid,\4\5:' /etc/fstab
		echo "3. nosuid for /tmp - FIXED (Persistent)"
	fi

	if [ -z "$noexeccheck1" ]
	then
		sed -ie 's:\(.*\)\(\s/tmp\s\s*\)\(\w*\s*\)\(\w*\s*\)\(.*\):\1\2\3noexec,\4\5:' /etc/fstab
		echo "4. noexec for /tmp - FIXED (Persistent)"
	fi	

	nodevcheck2=`mount | grep "[[:space:]]/tmp[[:space:]]" | grep nodev`

	if [ -z "$nodevcheck2" ]
	then
		mount -o remount,nodev /tmp
		echo "5. nodev for /tmp - FIXED (Non-persistent)"
	fi

	nosuidcheck2=`mount | grep "[[:space:]]/tmp[[:space:]]" | grep nosuid`

	if [ -z "$nosuidcheck2" ]
	then
		mount -o remount,nosuid /tmp
		echo "6. nosuid for /tmp - FIXED (Non-persistent)"
	fi

	noexeccheck2=`mount | grep "[[:space:]]/tmp[[:space:]]" | grep noexec`

	if [ -z "$noexeccheck2" ]
	then
		mount -o remount,noexec /tmp
		echo "7. noexec for /tmp - FIXED (Non-persistent)"
	fi

	printf "\n"
	printf "/var\n"
	
	varcheck=`grep "[[:space:]]/var[[:space:]]" /etc/fstab`

	if [ -z "$varcheck" ]
	then
		vgcheck=`vgdisplay | grep "VG Name" | grep "MyVG"`

		if [ -z "$vgcheck" ]
		then
			vgcreate MyVG /dev/sdb1 &> /dev/null
		fi
		
		lvcheck=`lvdisplay | grep "LV Name" | grep "VARLV"`

		if [ -z "$lvcheck" ]
		then 
			lvcreate -L 5G -n VARLV MyVG &> /dev/null
			mkfs.ext4 /dev/MyVG/VARLV &> /dev/null
		fi

		echo "# /dev/MyVG/VARLV	/var	ext4	defaults 0 0" >> /etc/fstab
		mount -a
		echo "1. /var partition - FIXED"
	fi

	vartmpdircheck=`ls -l /var | grep "tmp"`

	if [ -z "$vartmpdircheck" ]
	then
		mkdir -p /var/tmp
	fi

	vartmpcheck1=`grep -e "/tmp[[:space:]]" /etc/fstab | grep "/var/tmp"`

	if [ -z "$vartmpcheck1" ]
	then
		echo "# /tmp	/var/tmp	none	bind	0 0" >> /etc/fstab 
		echo "2. /var/tmp bind mount - FIXED (Persistent)"
	fi

	vartmpcheck2=`mount | grep "/var/tmp"`

	if [ -z "$vartmpcheck2" ]
	then
		mount --bind /tmp /var/tmp
		echo "3. /var/tmp bind mount - FIXED (Non-persistent)"
	fi

	varlogdircheck=`ls -l /var | grep "log"`
	if [ -z "$varlogdircheck" ]
	then
		mkdir -p /var/log
	fi

	varlogcheck=`grep "[[:space:]]/var/log[[:space:]]" /etc/fstab`

	if [ -z "$varlogcheck" ]
	then
		vgcheck=`vgdisplay | grep "VG Name" | grep "MyVG"`

		if [ -z "$vgcheck" ]
		then
			vgcreate MyVG /dev/sdb1 &> /dev/null
		fi
		
		lvcheck=`lvdisplay | grep "LV Name" | grep "VARLOGLV"`

		if [ -z "$lvcheck" ]
		then 
			lvcreate -L 200M -n VARLOGLV MyVG &> /dev/null
			mkfs.ext4 /dev/MyVG/VARLOGLV &> /dev/null
		fi

		echo "/dev/MyVG/VARLOGLV	/var/log	ext4	defaults 0 0" >> /etc/fstab
		mount -a
		echo "4. /var/log partition - FIXED"
	fi

	auditdircheck=`ls -l /var/log | grep "audit"`

	if [ -z "$auditdircheck" ]
	then
		mkdir -p /var/log/audit	
	fi

	varlogauditcheck=`grep "[[:space:]]/var/log/audit[[:space:]]" /etc/fstab`

	if [ -z "$varlogauditcheck" ]
	then
		vgcheck=`vgdisplay | grep "VG Name" | grep "MyVG"`

		if [ -z "$vgcheck" ]
		then
			vgcreate MyVG /dev/sdb1 &> /dev/null
		fi
		
		lvcheck=`lvdisplay | grep "LV Name" | grep "VARLOGAUDITLV"`

		if [ -z "$lvcheck" ]
		then 
			lvcreate -L 200M -n VARLOGAUDITLV MyVG &> /dev/null
			mkfs.ext4 /dev/MyVG/VARLOGAUDITLV &> /dev/null
		fi

		echo "/dev/MyVG/VARLOGAUDITLV	/var/log/audit	ext4	defaults 0 0" >> /etc/fstab
		mount -a
		echo "5. /var/log/audit partition - FIXED"
	fi

	printf "\n"
	printf "/home\n"
	
	homecheck=`grep "[[:space:]]/home[[:space:]]" /etc/fstab`

	if [ -z "$homecheck" ]
	then
		vgcheck=`vgdisplay | grep "VG Name" | grep "MyVG"`

		if [ -z "$vgcheck" ]
		then
			vgcreate MyVG /dev/sdb1 &> /dev/null
		fi
		
		lvcheck=`lvdisplay | grep "LV Name" | grep "HOMELV"`

		if [ -z "$lvcheck" ]
		then 
			lvcreate -L 500M -n HOMELV MyVG &> /dev/null
			mkfs.ext4 /dev/MyVG/HOMELV &> /dev/null
		fi

		echo "/dev/MyVG/HOMELV	/home	ext4	defaults 0 0" >> /etc/fstab
		mount -a
		echo "1. /home partition - FIXED"
	fi

	homenodevcheck1=`grep "[[:space:]]/home[[:space:]]" /etc/fstab | grep nodev`

	if [ -z "$homenodevcheck1" ]
	then
		sed -ie 's:\(.*\)\(\s/home\s\s*\)\(\w*\s*\)\(\w*\s*\)\(.*\):\1\2\3nodev,\4\5:' /etc/fstab
		echo "2. nodev for /home - FIXED (Persistent)"
	fi

	homenodevcheck2=`mount | grep "[[:space:]]/home[[:space:]]" | grep nodev`

	if [ -z "$homenodevcheck2" ]
	then
		mount -o remount,nodev /home
		echo "3. nodev for /home - FIXED (Non-persistent)"
	fi
fi

printf "\n\n"

# 1.11 to 1.13
echo -e "\e[4m1.11 to 1.13 : Add nodev, nosuid and no exec Option to Removable Media Partitions\e[0m\n"
cdcheck=`grep cd /etc/fstab`
if [ -n "$cdcheck" ]
then
	cdnodevcheck=`grep cdrom /etc/fstab | grep nodev`
	cdnosuidcheck=`grep cdrom /etc/fstab | grep nosuid`
	cdnosuidcheck=`grep cdrom /etc/fstab | grep noexec`
	if [ -z "$cdnosuidcheck" ]
	then
			echo "/cdrom - FAILED (/cdrom not mounted with nodev option)"
	elif [ -z "$cdnosuidcheck" ]
	then
			echo "/cdrom - FAILED (/cdrom not mounted with nosuid option)"
	elif [ -z "$cdnosuidcheck" ]
	then
			echo "/cdrom - FAILED (/cdrom not mounted with noexec option)"
	else
		"/cdrom - PASSED (/cdrom is a mounted with nodev,nosuid,noexec option)"
	fi
else
	echo "/cdrom - PASSED (/cdrom not mounted)"
fi
 
printf "\n\n"

# 1.14
echo -e "\e[4m1.14 : Set Sticky Bit on All World-Writable Directories\e[0m\n"
checkstickybit=`df --local -P | awk {'if (NR1=1) print $6'} | xargs -l '{}' -xdev -type d \(--perm -0002 -a ! -perm -1000 \) 2> /dev/null`
if [ -n "$checkstickybit" ]
then
	echo "Sticky Bit - FAILED (Sticky bit is not set on all world-writable directories)"
else
	echo "Sticky Bit - PASSED (Sticky bit is set on all world-writable directories)"
fi

printf "\n\n"

# 1.15
echo -e "\e[4m1.15 : Disable Mounting of Legacy Filesystems\e[0m\n"
checkcramfs=`/sbin/lsmod | grep cramfs`
checkfreevxfs=`/sbin/lsmod | grep freevxfs`
checkjffs2=`/sbin/lsmod | grep jffs2`
checkhfs=`/sbin/lsmod | grep hfs`
checkhfsplus=`/sbin/lsmod | grep hfsplus`
checksquashfs=`/sbin/lsmod | grep squashfs`
checkudf=`/sbin/lsmod | grep udf`

if [ -n "$checkcramfs" -o -n "$checkfreevxfs" -o -n "$checkjffs2" -o -n "$checkhfs" -o -n "$checkhfsplus" -o -n "$checksquashfs" -o -n "$checkudf" ]
then
	echo "Legacy File Systems - FAILED (Not all legacy file systems are disabled i.e. cramfs, freevxfs, jffs2, hfs, hfsplus, squashfs and udf)"
else
	echo "Legacy File Systems - PASSED (All legacy file systems are disabled i.e. cramfs, freevxfs, jffs2, hfs, hfsplus, squashfs and udf)"
fi

printf "\n\n"

# 2.1 to 2.5
echo -e "\e[4m2.1 to 2.5 : Remove telnet Server & Clients, rsh Server and Clients, NIS Server and Clients, tftp Server and Clients and xinetd\e[0m\n"
services=( "telnet" "telnet-server" "rsh-server" "rsh" "ypserv" "ypbind" "tftp" "tftp-server" "xinetd" )

for eachservice in ${services[*]}
do 
	yum -q list installed $eachservice &>/dev/null && echo "$eachservice - FAILED ($eachservice is Installed)" || echo "$eachservice - PASSED ($eachservice is not installed) "
done 	

printf "\n\n"

checkxinetd=`yum list xinetd | grep "Available Packages"`

if [ -n "$checkxinetd" ]

then

	echo "Xinetd is not installed, hence chargen-dgram is not installed"

else	

	checkchargendgram=`chkconfig --list chargen-dgram | grep "off"`

	if [ -n "$checkchargendgram" ]

	then

		echo "chargen-dgram is not active, hence no action will be taken"

	else

		echo "chargen-dgram is active, it will now be disabled"

		chkconfig chargen-dgram off

	fi 

fi 



if [ -n "$checkxinetd" ]

then

	echo "Xinetd is not installed, hence chargen-stream is not installed"

else	

	checkchargenstream=`chkconfig --list chargen-stream | grep "off"`

	if [ -n "$checkchargenstream" ]

	then

		echo "chargen-stream is not active, hence no action will be taken"

	else

		echo "chargen-stream is active, it will now be disabled"

		chkconfig chargen-stream off

	fi 

fi 



if [ -n "$checkxinetd" ]

then

	echo "Xinetd is not installed, hence daytime-dgram is not installed"

else	

	checkdaytimedgram=`chkconfig --list daytime-dgram | grep "off"`

	if [ -n "$checkdaytimedgram" ]

	then

	echo "daytime-dgram is not active, hence no action will be taken"

	else

	echo "daytime-dgram is active, it will now be disabled"

	chkconfig daytime-dgram off

	fi 

fi



if [ -n "$checkxinetd" ]

then

	echo "Xinetd is not installed, hence daytime-stream is not installed"

else	

	checkdaytimestream=`chkconfig --list daytime-stream | grep "off"`

	if [ -n "$checkdaytimestream" ]

	then

		echo "daytime-stream is not active, hence no action will be taken"

	else

		echo "daytime-stream is active, it will now be disabled"

		chkconfig daytime-stream off

	fi 

fi 



if [ -n "$checkxinetd" ]

then

	echo "Xinetd is not installed, hence echo-dgram is not installed"

else	

	checkechodgram=`chkconfig --list echo-dgram | grep "off"`

	if [ -n "$checkechodgram" ]

	then

		echo "echo-dgram is not active, hence no action will be taken"

	else

		echo "echo-dgram is active, it will now be disabled"

		chkconfig echo-dgram off

	fi

fi



if [ -n "$checkxinetd" ]

then

	echo "Xinetd is not installed, hence echo-stream is not installed"

else	

	checkechostream=`chkconfig --list echo-stream | grep "off"`

	if [ -n "$checkechostream" ]

	then

		echo "echo-stream is not active, hence no action will be taken"

	else

		echo "echo-stream is active, it will now be disabled"

		chkconfig echo-stream off

	fi 

fi



if [ -n "$checkxinetd" ]

then

	echo "Xinetd is not installed, hence tcpmux-server is not installed"

else	

	checktcpmuxserver=`chkconfig --list tcpmux-server | grep "off"`

	if [ -n "$checktcpmuxserver" ]

	then

		echo "tcpmux-server is not active, hence no action will be taken"

	else

		echo "tcpmux-server is active, it will now be disabled"

		chkconfig tcpmux-server off

	fi 

fi 



umaskcheck=`grep ^umask /etc/sysconfig/init`

if [ -z "$umaskcheck" ]

then

	echo "umask 027" >> /etc/sysconfig/init

fi



checkxsystem=`ls -l /etc/systemd/system/default.target | grep graphical.target`

checkxsysteminstalled=`rpm  -q xorg-x11-server-common | grep "not installed"`



if [ -n "$checkxsystem" ]

then

	if [ -z "$checkxsysteminstalled" ]

	then

		rm '/etc/systemd/system/default.target'

		ln -s '/usr/lib/systemd/system/multi-user.target' '/etc/systemd/system/default.target'

		yum remove -y xorg-x11-server-common

	fi

fi

# Start of 6.1.4 coding

echo -e "\e[4m6.1.4 : Create and Set Permissions on rsyslog Log Files\e[0m"



checkformsgfile=$(ls /var/log/ | grep messages)

if [ -z "$checkformsgfile" ]

then

	printf "\n/var/log/messages : FAILED (/var/log/messages file does not exist)"

	printf "\nFile will now be created"

	touch /var/log/messages

else

	printf "\n/var/log/messages : PASSED (/var/log/messages file exist)"

fi



checkmsgowngrp=$(ls -l /var/log/messages | awk -F ' ' '{print $3,$4}')

if [ "$checkmsgowngrp" != "root root" ]

then

	#It is configured wrongly

	printf "\n/var/log/messages : FAILED (Owner and Group owner of file is configured wrongly)"

	chown root:root /var/log/messages

	printf "\nOwner and Group owner will now be changed to root root"	

else

	printf "\n/var/log/messages : PASSED (Owner and Group owner of file is configured correctly)"

fi



checkmsgper=$(ls -l /var/log/messages | awk -F ' ' '{print $1}')

if [ "$checkmsgper" != "-rw-------." ]

then

	printf "\n/var/log/messages : FAILED (Permission of file is configured wrongly)"

	chmod og-rwx /var/log/messages

	printf "\nPermission of file will now be changed to 0600"

else

	printf "\n/var/log/messages : PASSED (Permission of file is configured correctly)"

fi



printf "\n"



# kern.log

checkforkernfile=$(ls /var/log/ | grep kern.log)

if [ -z "$checkforkernfile" ]

then

	printf "\n/var/log/kern.log : FAILED (/var/log/kern.log file does not exist)"

	printf "\nFile will now be created"

	touch /var/log/kern.log

else

	printf "\n/var/log/kern.log : PASSED (/var/log/kern.log file exist)"

fi



checkkernowngrp=$(ls -l /var/log/kern.log | awk -F ' ' '{print $3,$4}')

if [ "$checkkernowngrp" != "root root" ]

then

	#It is configured wrongly

	printf "\n/var/log/kern.log : FAILED (Owner and Group owner of file is configured wrongly)"

	chown root:root /var/log/kern.log

	printf "\nOwner and Group owner will now be changed to root root"	

else

	printf "\n/var/log/kern.log : PASSED (Owner and Group owner of file is configured correctly)"

fi



checkkernper=$(ls -l /var/log/kern.log | awk -F ' ' '{print $1}')

if [ "$checkkernper" != "-rw-------." ]

then

	printf "\n/var/log/kern.log : FAILED (Permission of file is configured wrongly)"

	chmod og-rwx /var/log/kern.log

	printf "\nPermission of file will now be changed to 0600"

else

	printf "\n/var/log/kern.log : PASSED (Permission of file is configured correctly)"

fi



printf "\n"



#daemon.log

checkfordaefile=$(ls /var/log/ | grep daemon.log)

if [ -z "$checkfordaefile" ]

then

	printf "\n/var/log/daemon.log : FAILED (/var/log/daemon.log file does not exist)"

	printf "\nFile will now be created"

	touch /var/log/daemon.log

else

	printf "\n/var/log/daemon.log : PASSED (/var/log/daemon.log file exist)"

fi



checkdaeowngrp=$(ls -l /var/log/daemon.log | awk -F ' ' '{print $3,$4}')

if [ "$checkdaeowngrp" != "root root" ]

then

	#It is configured wrongly

	printf "\n/var/log/daemon.log : FAILED (Owner and Group owner of file is configured wrongly)"

	chown root:root /var/log/daemon.log

	printf "\nOwner and Group owner will now be changed to root root"	

else

	printf "\n/var/log/daemon.log : PASSED (Owner and Group owner of file is configured correctly)"

fi



checkdaeper=$(ls -l /var/log/daemon.log | awk -F ' ' '{print $1}')

if [ "$checkdaeper" != "-rw-------." ]

then

	printf "\n/var/log/daemon.log : FAILED (Permission of file is configured wrongly)"

	chmod og-rwx /var/log/daemon.log

	printf "\nPermission of file will now be changed to 0600"

else

	printf "\n/var/log/daemon.log : PASSED (Permission of file is configured correctly)"

fi



printf "\n"



#syslog.log

checkforsysfile=$(ls /var/log/ | grep syslog.log)

if [ -z "$checkforsysfile" ]

then

	printf "\n/var/log/syslog.log : FAILED (/var/log/syslog.log file does not exist)"

	printf "\nFile will now be created"

	touch /var/log/syslog.log

else

	printf "\n/var/log/syslog.log : PASSED (/var/log/syslog.log file exist)"

fi



checksysowngrp=$(ls -l /var/log/syslog.log | awk -F ' ' '{print $3,$4}')

if [ "$checksysowngrp" != "root root" ]

then

	#It is configured wrongly

	printf "\n/var/log/syslog.log : FAILED (Owner and Group owner of file is configured wrongly)"

	chown root:root /var/log/syslog.log

	printf "\nOwner and Group owner will now be changed to root root"	

else

	printf "\n/var/log/syslog.log : PASSED (Owner and Group owner of file is configured correctly)"

fi



checksysper=$(ls -l /var/log/syslog.log | awk -F ' ' '{print $1}')

if [ "$checksysper" != "-rw-------." ]

then

	printf "\n/var/log/syslog.log : FAILED (Permission of file is configured wrongly)"

	chmod og-rwx /var/log/syslog.log

	printf "\nPermission of file will now be changed to 0600"

else

	printf "\n/var/log/syslog.log : PASSED (Permission of file is configured correctly)"

fi



printf "\n"



#unused

checkforunufile=$(ls /var/log/ | grep unused.log)

if [ -z "$checkforunufile" ]

then

	printf "\n/var/log/unused.log : FAILED (/var/log/unused.log file does not exist)"

	printf "\nFile will now be created"

	touch /var/log/unused.log

else

	printf "\n/var/log/unused.log : PASSED (/var/log/unused.log file exist)"

fi



checkunuowngrp=$(ls -l /var/log/unused.log | awk -F ' ' '{print $3,$4}')

if [ "$checkunuowngrp" != "root root" ]

then

	#It is configured wrongly

	printf "\n/var/log/unused.log : FAILED (Owner and Group owner of file is configured wrongly)"

	chown root:root /var/log/unused.log

	printf "\nOwner and Group owner will now be changed to root root"	

else

	printf "\n/var/log/unused.log : PASSED (Owner and Group owner of file is configured correctly)"

fi



checkunuper=$(ls -l /var/log/unused.log | awk -F ' ' '{print $1}')

if [ "$checkunuper" != "-rw-------." ]

then

	printf "\n/var/log/unused.log : FAILED (Permission of file is configured wrongly)"

	chmod og-rwx /var/log/unused.log

	printf "\nPermission of file will now be changed to 0600"

else

	printf "\n/var/log/unused.log : PASSED (Permission of file is configured correctly)"

fi



printf "\n"

# End of 6.1.4 coding



# To have space

printf "\n\n"



# Start of 6.1.5 coding

echo -e "\e[4m6.1.5 : Configure rsyslogto Send Logs to a Remote Log Host\e[0m\n"

checkloghost=$(grep "^*.*[^|][^|]*@" /etc/rsyslog.conf)

if [ -z "$checkloghost" ]  # If there is no log host

then

	printf "Remote Log Host : FAILED (Remote log host has not been configured)\n"

	printf "\nRemote log host will now be configured"

	printf "\n*.* @@logfile.example.com\n" >> /etc/rsyslog.conf

	

else

	printf "Remote Log Host : PASSED (Remote log host has been configured)\n"

fi

# End of 6.1.5 coding



# Start of 6.1.6 coding

printf "\n\n"



echo -e "\e[4m6.1.6 : Accept Remote rsyslog Messages Only on Designated Log Hosts\e[0m"

checkmodload=$(grep '^$ModLoad imtcp.so' /etc/rsyslog.conf)

checkinput=$(grep '^$InputTCPServerRun' /etc/rsyslog.conf)

if [ -z "$checkmodload" ]

then

	# If the thing has been commented out

	printf "\nModLoad imtcp.so : FAILED (ModLoad imtcp is not configured)"

	printf "\n\$ModLoad imtcp.so" >> /etc/rsyslog.conf

	printf "\nModLoad imtcp will now be configured\n"

else

	#If the string has not been commented out

	printf "\nModLoad imtcp : PASSED (ModLoad imtcp is configured)\n"

fi





if [ -z "$checkinput" ]

then

	# If the string has been commented ouit

    printf "\nInputTCPServerRun : FAILED (InputTCPServerRun is not configured)"

	printf "\n\$InputTCPServerRun 514" >> /etc/rsyslog.conf

    printf "\nInputTCPServerRun wil now be configured\n"

else

    #If the string has not been commented out

    printf "\nInputTCPServerRun : PASSED (InputTCPServerRun is configured)\n"

fi

# End of 6.1.6 coding



# To have space

printf "\n\n"



printf "============================================================================\n"

printf "6.2 : Configure System Accounting\n"

printf "============================================================================\n"

printf "\n"

echo "----------------------------------------------------------------------------"

printf "6.2.1 : Configure Data Retention\n"

echo "----------------------------------------------------------------------------"

printf "\n"



#start of 6.2.1.1 coding

echo -e "\e[4m6.2.1.1 : Configure Audit Log Storage Size\e[0m\n"

checkvalue=$(grep -w "max_log_file" /etc/audit/auditd.conf | awk -F ' ' '{print $3}')

if [ "$checkvalue" != "5" ]

then

	printf "Audit Log Storage Size : FAILED (Maximum size of audit log file is configured incorrectly)\n"

	sed -i /$checkvalue/d /etc/audit/auditd.conf

	printf "max_log_file = 5" >> /etc/audit/auditd.conf

	printf "Audit log storage size value will now be configured\n"

else

	printf "Audit Log Storage Size : PASSED (Maximum size of audit log file is configured correctly)\n"

fi



printf "\n\n"

#end of 6.2.1.1 coding





#start of 6.2.1.2 coding

echo -e "\e[4m6.2.1.2 : Keep All Auditing Information\e[0m\n"

checkvalue2=$(grep -w "max_log_file_action" /etc/audit/auditd.conf | awk -F ' ' '{print $3}')

if [ "$checkvalue2" != "keep_logs" ]

then

	printf "Audit Information : FAILED (All audit logs are not retained)\n"

    sed -i /$checkvalue2/d /etc/audit/auditd.conf

    printf "\nmax_log_file_action = keep_logs" >> /etc/audit/auditd.conf

    printf "All audit log files will now be retained\n"

else

    printf "Audit Information: PASSED (Audit logs are retained)\n"

fi



printf "\n\n"

#End of 6.2.1.2 coding





#Start of 6.2.1.3 coding

echo -e "\e[4m6.2.1.3 : Disable System on Audit Log Full\e[0m\n"

checkvalue3=$(grep -w "space_left_action" /etc/audit/auditd.conf | awk -F ' ' '{print $3}')

if [ "$checkvalue3" != "email" ]

then

	printf "Action : FAILED (Action to take on low disk space is configured incorrectly)\n"

    sed -i /$checkvalue3/d /etc/audit/auditd.conf

    printf "\nspace_left_action = email" >> /etc/audit/auditd.conf

    printf "Action to take on low disk space will now be configured\n"

else

    printf "Action : PASSED (Action to take on low disk space is configured correctly)\n"

fi



printf "\n"



checkvalue4=$(grep -w "action_mail_acct" /etc/audit/auditd.conf | awk -F ' ' '{print $3}')

if [ "$checkvalue4" != "root" ]

then

	printf "Email Account : FAILED (Email account specified for warnings to be sent to is configured incorrectly)\n"

    sed -i /$checkvalue4/d /etc/audit/auditd.conf

    printf "\naction_mail_acct = root" >> /etc/audit/auditd.conf

    printf "Email account specified for warnings to be sent to will now be configured\n"

else

    printf "Email Account : PASSED (Email account specified for warnings to be sent to is configured correctly)\n"

fi



printf "\n"



checkvalue5=$(grep -w "admin_space_left_action" /etc/audit/auditd.conf | awk -F ' ' '{print $3}')

if [ "$checkvalue5" != "halt" ]

then

	printf "Admin Action : FAILED (Admin action to take on low disk space is configured incorrectly)\n"

    sed -i /$checkvalue5/d /etc/audit/auditd.conf

    printf "\nadmin_space_left_action = halt" >> /etc/audit/auditd.conf

    printf "Admin action to take on low disk space will now be configured\n"

else

    printf "Admin Action : PASSED (Admin action to take on low disk space is configured correctly)\n"

fi



printf "\n\n"

#End of 6.2.1.3 coding



#Start of 6.2.1.4 coding

echo -e "\e[4m6.2.1.4 : Enable auditd Service\e[0m\n"

checkauditdservice=`systemctl is-enabled auditd`

if [ "$checkauditdservice" == enabled ]

then

	echo "Auditd Service : PASSED (Auditd is enabled)"



else

	echo "Auditd Service : FAILED (Auditd is not enabled)"

	systemctl enable auditd

	echo "Auditd Service is now enabled"

fi

#End of 6.2.1.4 coding



printf "\n\n"



#Start of 6.2.1.5 coding

echo -e "\e[4m6.2.1.5 : Enable Auditing for Processes That Start Prior to auditd\e[0m\n"

checkgrub=$(grep "linux" /boot/grub2/grub.cfg | grep "audit=1") 

if [ -z "$checkgrub" ]

then

	printf "System Log Processes : FAILED (System is not configured to log processes that start prior to auditd\n"

	var="GRUB_CMDLINE_LINUX"

	sed -i /$var/d /etc/default/grub

	printf "GRUB_CMDLINE_LINUX=\"audit=1\"" >> /etc/default/grub

	printf "System will now be configured to log processes that start prior to auditd\n"

	grub2-mkconfig -o /boot/grub2/grub.cfg &> /dev/null

else

	printf "System Log Processes : PASSED (System is configured to log processes that start prior to auditd\n"

fi



#End of 6.2.1.5 coding



printf "\n\n"

##########################################################################################
#start of 6.2.1.6 coding

echo -e "\e[4m6.2.1.6 : Record Events That Modify Date and Time Information\e[0m\n"
checksystem=`uname -m | grep "64"`
checkmodifydatetimeadjtimex=`egrep 'adjtimex|settimeofday|clock_settime' /etc/audit/audit.rules`

if [ -z "$checksystem" ]
then
	echo "It is a 32-bit system."
	printf "\n"
	
	if [ -z "$checkmodifydatetimeadjtimex" ]
	then
        echo "Date & Time Modified Events : FAILED (Events where system date and/or time has been modified are not captured)"
        echo "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change" >> /etc/audit/audit.rules
		echo "-a always,exit -F arch=b32 -S clock_settime -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b32 -S clock_settime -k time-change" >> /etc/audit/audit.rules
		echo "-w /etc/localtime -p wa -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-w /etc/localtime -p wa -k time-change" >> /etc/audit/audit.rules
        echo "Events where system date and/or time has been modified will now be captured"

	else
		echo "Date & Time Modified Events : PASSED (Events where system date and/or time has been modified are captured)"
	fi

else
	echo "It is a 64-bit system."
	printf "\n"
	
	if [ -z "$checkmodifydatetimeadjtimex" ]
	then
        echo "Date & Time Modified Events : FAILED (Events where system date and/or time has been modified are not captured)"
		echo "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change" >> /etc/audit/audit.rules
        echo "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change" >> /etc/audit/audit.rules
		echo "-a always,exit -F arch=b64 -S clock_settime -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b64 -S clock_settime -k time-change" >> /etc/audit/audit.rules
        echo "-a always,exit -F arch=b32 -S clock_settime -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b32 -S clock_settime -k time-change" >> /etc/audit/audit.rules
		echo "-w /etc/localtime -p wa -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-w /etc/localtime -p wa -k time-change" >> /etc/audit/audit.rules
        echo "Events where system date and/or time has been modified will now be captured"

	else
		echo "Date & Time Modified Events : PASSED (Events where system date and/or time has been modified are captured)"
	fi
fi

pkill -P 1 -HUP auditd
#End of 6.2.1.6 coding

printf "\n\n"

##########################################################################################
#Start of 6.1.2.7 coding

echo -e "\e[4m6.2.1.7 : Record Events That Modify User/Group Information\e[0m\n"
checkmodifyusergroupinfo=`egrep '\/etc\/group' /etc/audit/audit.rules`

if [ -z "$checkmodifyusergroupinfo" ]
then
	echo "Group Configuration - FAILED (Group is not configured)"
	echo "-w /etc/group -p wa -k identity" >> /etc/audit/audit.rules
	echo "-w /etc/group -p wa -k identity" >> /etc/audit/rules.d/audit.rules
	echo "Group will now be configured"

else
	echo "Group Configuration - PASSED (Group is already configured)"
fi

printf "\n"

checkmodifyuserpasswdinfo=`egrep '\/etc\/passwd' /etc/audit/audit.rules`

if [ -z "$checkmodifyuserpasswdinfo" ]
then
	echo "Password Configuration - FAILED (Password is not configured)"
	echo "-w /etc/passwd -p wa -k identity" >> /etc/audit/audit.rules
	echo "-w /etc/passwd -p wa -k identity" >> /etc/audit/rules.d/audit.rules
	echo "Password will now be configured"

else
	echo "Password Configuration - PASSED (Password is configured)"
fi

printf "\n"

checkmodifyusergshadowinfo=`egrep '\/etc\/gshadow' /etc/audit/audit.rules`

if [ -z "$checkmodifyusergshadowinfo" ]
then
	echo "GShadow Configuration - FAILED (GShadow is not configured)"
	echo "-w /etc/gshadow -p wa -k identity" >> /etc/audit/audit.rules
	echo "-w /etc/gshadow -p wa -k identity" >> /etc/audit/rules.d/audit.rules
	echo "GShadow will now be configured"

else
	echo "GShadow Configuration - PASSED (GShadow is configured)"
fi

printf "\n"

checkmodifyusershadowinfo=`egrep '\/etc\/shadow' /etc/audit/audit.rules`

if [ -z "$checkmodifyusershadowinfo" ]
then
	echo "Shadow Configuration - FAILED (Shadow is not configured)"
	echo "-w /etc/shadow -p -k identity" >> /etc/audit/audit.rules
	echo "-w /etc/shadow -p -k identity" >> /etc/audit/rules.d/audit.rules
	echo "Shadow will now be configured"
	
else
	echo "SHadow Configuration - PASSED (Shadow is configured)"
fi

printf "\n"

checkmodifyuseropasswdinfo=`egrep '\/etc\/security\/opasswd' /etc/audit/audit.rules`

if [ -z "$checkmodifyuseropasswdinfo" ]
then
	echo "OPasswd Configuration- FAILED (OPassword not configured)"
	echo "-w /etc/security/opasswd -p wa -k identity" >> /etc/audit/audit.rules
	echo "-w /etc/security/opasswd -p wa -k identity" >> /etc/audit/rules.d/audit.rules
	echo "OPassword will now be configured"

else
	echo "OPasswd Configuration - PASSED (OPassword is configured)"
fi

pkill -P 1 -HUP auditd
#End of 6.2.1.7 coding

printf "\n\n"

##########################################################################################
#Start of 6.2.1.8 coding

echo -e "\e[4m6.2.1.8 : Record Events That Modify the System's Network Environment\e[0m\n"
checksystem=`uname -m | grep "64"`
checkmodifynetworkenvironmentname=`egrep 'sethostname|setdomainname' /etc/audit/audit.rules`

if [ -z "$checksystem" ]
then
	echo "It is a 32-bit system."
	printf "\n"
	
	if [ -z "$checkmodifynetworkenvironmentname" ]
	then
        echo "Modify the System's Network Environment Events : FAILED (Sethostname and setdomainname is not configured)"
        echo "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/audit.rules
        echo "Sethostname and setdomainname will now be configured"

	else
		echo "Modify the System's Network Environment Events : PASSED (Sethostname and setdomainname is configured)"
	fi

else
	echo "It is a 64-bit system."
	printf "\n"
	
	if [ -z "$checkmodifynetworkenvironmentname" ]
	then
        echo "Modify the System's Network Environment Events : FAILED (Sethostname and setdomainname is not configured)"
        echo "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/audit.rules
		echo "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/audit.rules
        echo "Sethostname will now be configured"

	else
		echo "Modify the System's Network Environment Events : PASSED (Sethostname and setdomainname is configured)"
	fi
fi

printf "\n"

checkmodifynetworkenvironmentissue=`egrep '\/etc\/issue' /etc/audit/audit.rules`

if [ -z "$checkmodifynetworkenvironmentissue" ]
then
	echo "Modify the System's Network Environment Events : FAILED (/etc/issue is not configured)"
	echo "-w /etc/issue -p wa -k system-locale" >> /etc/audit/rules.d/audit.rules
	echo "-w /etc/issue -p wa -k system-locale" >> /etc/audit/audit.rules
	echo "-w /etc/issue.net -p wa -k system-locale" >> /etc/audit/rules.d/audit.rules
	echo "-w /etc/issue.net -p wa -k system-locale" >> /etc/audit/audit.rules
	echo "/etc/issue will now be configured"

else
	echo "Modify the System's Network Environment Events : PASSED (/etc/issue is configured)"
fi

printf "\n"

checkmodifynetworkenvironmenthosts=`egrep '\/etc\/hosts' /etc/audit/audit.rules`

if [ -z "$checkmodifynetworkenvironmenthosts" ]
then
	echo "Modify the System's Network Environment Events : FAILED (/etc/hosts is not configured)"
	echo "-w /etc/hosts -p wa -k system-locale" >> /etc/audit/rules.d/audit.rules
	echo "-w /etc/hosts -p wa -k system-locale" >> /etc/audit/audit.rules
	echo "/etc/hosts will now be configured"

else
	echo "Modify the System's Network Environment Events : PASSED (/etc/hosts is configured)"
fi

printf "\n"

checkmodifynetworkenvironmentnetwork=`egrep '\/etc\/sysconfig\/network' /etc/audit/audit.rules`

if [ -z "$checkmodifynetworkenvironmentnetwork" ]
then
	echo "Modify the System's Network Environment Events : FAILED (/etc/sysconfig/network is not configured)"
	echo "-w /etc/sysconfig/network -p wa -k system-locale" >> /etc/audit/rules.d/audit.rules
	echo "-w /etc/sysconfig/network -p wa -k system-locale" >> /etc/audit/audit.rules
	echo "/etc/sysconfig/network will now be configured"

else
	echo "Modify the System's Network Environment Events : PASSED (/etc/sysconfig/network is configured)"
fi

pkill -P 1 -HUP auditd
#End of 6.2.1.8 coding

printf "\n\n"

##########################################################################################
#Start of 6.1.2.9 coding

echo -e "\e[4m6.2.1.9 : Record Events That Modify the System's Mandatory Access Controls\e[0m\n"
var=$(grep \/etc\/selinux /etc/audit/audit.rules)

if [ -z "$var" ]
then
	printf "Monitoring SELinux Mandatory Access Controls : FAILED (/etc/selinux is not configured)\n"
	printf "\n-w /etc/selinux/ -p wa -k MAC-policy" >> /etc/audit/audit.rules
	printf "/etc/selinux will now be configured"
	
else
	printf "Monitoring SELinux Mandatory Access Controls : PASSED (/etc/selinux is configured)\n"
fi
#End of 6.2.1.9 coding

printf "\n\n"

##########################################################################################
#6.2.1.10

echo -e "\e[4m6.2.1.10 : Collect Login and Logout Events\e[0m\n"

loginfail=`grep "\-w /var/log/faillog -p wa -k logins" /etc/audit/audit.rules`
loginlast=`grep "\-w /var/log/lastlog -p wa -k logins" /etc/audit/audit.rules`
logintally=`grep "\-w /var/log/tallylog -p wa -k logins" /etc/audit/audit.rules`

if [ -z "$loginfail" -o -z "$loginlast" -o -z "$logintally" ]
then
	if [ -z "$loginfail" ]
	then
		echo "-w /var/log/faillog -p wa -k logins" >> /etc/audit/audit.rules
	fi
	
	if [ -z "$loginlast" ]
	then
		echo "-w /var/log/lastlog -p wa -k logins" >> /etc/audit/audit.rules
	fi
	
	if [ -z "$logintally" ]
	then
		echo "-w /var/log/tallylog -p wa -k logins" >> /etc/audit/audit.rules
	fi
	
	echo "Login and Logout Events collected"
fi
	
pkill -P 1 -HUP auditd

printf "\n\n"

##########################################################################################
#6.2.1.11

echo -e "\e[4m6.2.1.11 : Collect Session Initiation Information\e[0m\n"

sessionwtmp=`egrep '\-w /var/log/wtmp -p wa -k session' /etc/audit/audit.rules`
sessionbtmp=`egrep '\-w /var/log/btmp -p wa -k session' /etc/audit/audit.rules`
sessionutmp=`egrep '\-w /var/run/utmp -p wa -k session' /etc/audit/audit.rules`

if [ -z "$sessionwtmp" -o -z "$sessionbtmp" -o -z "$sessionutmp" ]
then 
	if [ -z "$sessionwtmp"]
	then 
		echo "-w /var/log/wtmp -p wa -k session" >> /etc/audit/audit.rules
	fi
	
	if [ -z "$sessionbtmp"]
	then 
		echo "-w /var/log/btmp -p wa -k session" >> /etc/audit/audit.rules
	fi
	
	if [ -z "$sessionutmp"]
	then
		echo "-w /var/run/utmp -p wa -k session" >> /etc/audit/audit.rules
	fi
	
	echo "Session Initiation Information Collected"
fi

pkill -HUP -P 1 auditd

printf "\n\n"

##########################################################################################
#6.2.1.12

echo -e "\e[4m6.2.1.12 : Collect Discretionary Access Control Permission Modification Events\e[0m\n"

permission1=`grep "\-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`

permission2=`grep "\-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`

permission3=`grep "\-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S|chown -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`

permission4=`grep "\-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S|chown -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`

permission5=`grep "\-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -Fauid!=4294967295 -k perm_mod" /etc/audit/audit.rules`

permission6=`grep "\-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`

if [ -z "$permission1" -o -z "$permission2" -o -z permission3 -o -z permission4 -o -z permission5 -o -z permission6  ]
then 
	if [ -z "$permission1" ]
	then
		echo "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
	fi

	if [ -z "$permission2" ]
	then 
		echo "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
	fi
	
	if [ -z "$permission3" ]
	then 
		echo "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
	fi
	
	if [ -z "$permission4" ]
	then
		echo "-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
	fi
	
	if [ -z "$permission5" ]
	then 
		echo "-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
	fi
	
	if [ -z "$permission6" ]
	then 
		echo "-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
	fi
	
	echo "Discretionary Access Control Permission Modification Events Collected"
fi

pkill -P 1 -HUP auditd

printf "\n\n"

##########################################################################################
#6.2.1.13

echo -e "\e[4m6.2.1.13 : Collect Unsuccessful Unauthorized Access Attempts to Files\e[0m\n"

access1=`grep "\-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`

access2=`grep "\-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`

access3=`grep "\-a always,exit -F arch=b64 -S creat -S open -S ope
nat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`

access4=`grep "\-a always,exit -F arch=b32 -S creat -S open -S ope
nat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`

access5=`grep "\-a always,exit -F arch=b32 -S creat -S open -S ope
nat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`

access6=`grep "\-a always,exit -F arch=b32 -S creat -S open -S ope
nat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`

if [ -z "$access1" -o -z "$access2" ]
then
	if [ -z "$access1" ]
	then     
   		echo "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" >> /etc/audit/audit.rules
	fi
	
	if [ -z "$access2" ]
	then 
		echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" >> /etc/audit/audit.rules
	fi
	
	if [ -z "$access3" ]
	then
		echo "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" >>  /etc/audit/audit.rules
	fi
	
	if [ -z "$access4" ]
	then 
		echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" >>  /etc/audit/audit.rules
	fi
	
	if [ -z "$access5" ]
	then
		echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" >>  /etc/audit/audit.rules
	fi
	
	if [ -z "$access6" ]
	then 
		echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" >>  /etc/audit/audit.rules
	fi
	
	echo "Unsuccessful Unauthorized Access Attempts to Files Collected"
fi

pkill -P 1 -HUP auditd

printf "\n\n"

#6.2.1.14 Collect Use of Privileged Commands

find / -xdev \( -perm -4000 -o -perm -2000 \) -type f | awk '{print "-a always,exit-F path=" $1 " -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged" }' > /tmp/1.log
checkpriviledge=`cat /tmp/1.log`
cat /etc/audit/audit.rules | grep -- "$checkpriviledge" > /tmp/2.log
checkpriviledgenotinfile=`grep -F -x -v -f /tmp/2.log /tmp/1.log`

if [ -n "$checkpriviledgenotinfile" ]
then
	echo "$checkpriviledgenotinfile" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.14 : Collect Use of Privileged Commands\e[0m\n"
	echo "Use of Privileged Commands Collected"
fi

rm /tmp/1.log
rm /tmp/2.log

#6.2.1.15 Collect Successful File System Mounts

bit64mountb64=`grep "\-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" /etc/audit/audit.rules`
bit64mountb32=`grep "\-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" /etc/audit/audit.rules`
bit32mountb32=`grep "\-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" /etc/audit/audit.rules`

if [ -z "$bit64mountb64" ]
then
	echo "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.15 : Collect Successful File System Mounts\e[0m\n"
	echo "Successful File System Mounts Collected"
fi

if [ -z "$bit64mountb32" ]
then
	echo "-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.15 : Collect Successful File System Mounts\e[0m\n"
	echo "Successful File System Mounts Collected"
fi

pkill -HUP -P 1 auditd

if [ -z "$bit32mountb32" ]
then
	echo "-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.15 : Collect Successful File System Mounts\e[0m\n"
	echo "Successful File System Mounts Collected"
fi

pkill -HUP -P 1 auditd

#2.6.1.16 Collect File Delection Events by User

bit64delb64=`grep "\-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" /etc/audit/audit.rules`
bit64delb32=`grep "\-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" /etc/audit/audit.rules`
bit32delb32=`grep "\-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" /etc/audit/audit.rules`

if [ -z "$bit64delb64" ]
then
	echo "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.16 : Collect File Delection Events by User\e[0m\n"
	echo "File Delection Events by User Collected"
fi

if [ -z "$bit64delb32" ]
then
	echo "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.16 : Collect File Delection Events by User\e[0m\n"
	echo "File Delection Events by User Collected"
fi

pkill -HUP -P 1 auditd

if [ -z "$bit32delb32" ]
then
	echo "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.16 : Collect File Delection Events by User\e[0m\n"
	echo "File Delection Events by User Collected"
fi

pkill -P 1 -HUP auditd

#6.2.1.17 Collect Changes to System Administrator Scope

sudoers=`grep "\-w /etc/sudoers -p wa -k scope" /etc/audit/audit.rules`

if [ -z "$sudoers" ]
then
	echo "-w /etc/sudoers -p wa -k scope" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.17 : Collect Changes to System Administrator Scope\e[0m\n"
	echo "Changes to System Administrator Scope Collected"
fi
pkill -HUP -P 1 auditd

#6.2.1.18

remauditrules=`grep actions /etc/audit/audit.rules`
auditrules='-w /var/log/sudo.log -p wa -k actions'

if [ -z "$remauditrules" -o "$remauditrules" != "$auditrules" ] 
then
	echo "$auditrules" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.18 : Collect System Administrator Actions\e[0m\n"
	echo "System Administrator Actions Collected"
fi

pkill -HUP -P 1 auditd

#6.2.1.19

remmod1=`grep "\-w /sbin/insmod -p x -k modules" /etc/audit/audit.rules`
remmod2=`grep "\-w /sbin/rmmod -p x -k modules" /etc/audit/audit.rules`
remmod3=`grep "\-w /sbin/modprobe -p x -k modules" /etc/audit/audit.rules`
remmod4=`grep "\-a always,exit -F arch=b64 -S init_module -S delete_module -k modules" /etc/audit/audit.rules`

if [ -z "$remmod1" -o -z "$remmod2" -o -z "$remmod3" -o -z "$remmod4" -o -z "$remmod5" ]
then
	if [ -z "$remmod1" ]
	then
		echo "-w /sbin/insmod -p x -k modules" >> /etc/audit/audit.rules
		echo -e "\e[4m6.2.1.19 : Collect Kernel Module Loading and Unloading\e[0m\n"
		echo "Kernel Module Loading and Unloading Collected"
	fi

	if [ -z "$remmod2" ]
	then	
		echo "-w /sbin/rmmod -p x -k modules" >> /etc/audit/audit.rules
		echo -e "\e[4m6.2.1.19 : Collect Kernel Module Loading and Unloading\e[0m\n"
		echo "Kernel Module Loading and Unloading Collected"
	fi

	if [ -z "$remmod3" ]
	then
		echo "-w /sbin/modprobe -p x -k modules" >> /etc/audit/audit.rules
		echo -e "\e[4m6.2.1.19 : Collect Kernel Module Loading and Unloading\e[0m\n"
		echo "Kernel Module Loading and Unloading Collected"
	fi

	if [ -z "$remmod4" ]
	then
		echo "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules" >> /etc/audit/audit.rules
		echo -e "\e[4m6.2.1.9 : Collect Kernel Module Loading and Unloading\e[0m\n"
		echo "Kernel Module Loading and Unloading Collected"
	fi
fi

#6.2.1.20

remimmute=`grep "^-e 2" /etc/audit/audit.rules`
immute='-e 2'

if [ -z "$remimmute" -o "$remimmute" != "$immute" ]
then
	echo "$immute" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.20 : Make the Audit Configuration Immutable\e[0m\n"
	echo "Audit Configuration is Immutable"
fi

#6.2.1.21

remlogrotate=`grep "/var/log" /etc/logrotate.d/syslog`
logrotate='/var/log/messages /var/log/secure /var/log/maillog /var/log/spooler /var/log/boot.log /var/log/cron {'

if [ -z "$remlogrotate" -o "$remlogrotate" != "$logrotate" ]
then
	rotate1=`grep "/var/log/messages" /etc/logrotate.d/syslog`
	rotate2=`grep "/var/log/secure" /etc/logrotate.d/syslog`
	rotate3=`grep "/var/log/maillog" /etc/logrotate.d/syslog`
	rotate4=`grep "/var/log/spooler" /etc/logrotate.d/syslog`
	rotate5=`grep "/var/log/boot.log" /etc/logrotate.d/syslog`
	rotate6=`grep "/var/log/cron" /etc/logrotate.d/syslog`
	
	if [ -z "$rotate1" ]
	then
		echo "/var/log/messages" >> /etc/logrotate.d/syslog
	fi

	if [ -z "$rotate2" ]
	then
		echo "/var/log/secure" >> /etc/logrotate.d/syslog
	fi

	if [ -z "$rotate3" ]
	then 
		echo "/var/log/maillog" >> /etc/logrotate.d/syslog
	fi

	if [ -z "$rotate4" ]
	then
		echo "/var/log/spooler" >> /etc/logrotate.d/syslog
	fi

	if [ -z "$rotate5" ]
	then
		echo "/var/log/boot.log" >> /etc/logrotate.d/syslog
	fi

	if [ -z "$rotate6" ]
	then
		echo "/var/log/cron" /etc/logrotate.d/syslog
	fi
	echo -e "\e[4m6.2.1.21 : Configure logrotate\e[0m\n"
	echo "logrotate Configured"
fi

##########################################################################################
#7.1

echo -e "\e[4m7.1 : Set Password Expiration Days\e[0m\n"
current=$(cat /etc/login.defs | grep "^PASS_MAX_DAYS" | awk '{ print $2 }')
standard=90 #change this value according to the enterprise's required standard

if [ ! $current = $standard ]; then
	sed -i "s/^PASS_MAX_DAYS.*99999/PASS_MAX_DAYS $standard/" /etc/login.defs | grep "^PASS_MAX_DAYS.*$standard"
	printf "\n"
	echo "Password Expiration Days have been set"
fi

printf "\n\n"

##########################################################################################
#7.2

echo -e "\e[4m7.2 : Set Password Change Minimum Number of Days\e[0m\n"
current=$(cat /etc/login.defs | grep "^PASS_MIN_DAYS" | awk '{ print $2 }')
standard=7 #change this value according to the enterprise's required standard
if [ ! $current = $standard ]; then
	sed -i "s/^PASS_MIN_DAYS.*0/PASS_MIN_DAYS $standard/" /etc/login.defs | grep "^PASS_MIN_DAYS.*$standard"
	printf "\n"
	echo "Password Change Minimum Days have been set"
fi

printf "\n\n"

##########################################################################################
#7.3

echo -e "\e[4m7.3 : Set Password Expiring Warning Days\e[0m\n"
current=$(cat /etc/login.defs | grep "^PASS_WARN_AGE" | awk '{ print $2 }')
standard=7 #change this value according to the enterprise's required standard
if [ ! $current = $standard ]; then
	sed -i "s/^PASS_WARN_AGE.*0/PASS_WARN_AGE $standard/" /etc/login.defs | grep "^PASS_WARN_AGE.*$standard"
	printf "\n"
	echo "Password Expiring Warning Days have been set"
fi

printf "\n\n"

##########################################################################################
#7.4

echo -e "\e[4m7.4 : Disable System Accounts\e[0m\n"
for user in `awk -F: '($3 < 1000) { print $1 }' /etc/passwd` ; do 
	if [ $user != "root" ]; then 
		usermod -L $user &> /dev/null 
		if [ $user != "sync" ] && [ $user != "shutdown" ] && [ $user != "halt" ]; then
			usermod -s /sbin/nologin $user &> /dev/null
			fi 
		fi 
	done
printf "\n"
echo "System Accounts has been disabled"

printf "\n\n"

##########################################################################################
#7.5

echo -e "\e[4m7.5 : Set Default Group for root Account\e[0m\n"
current=$(grep "^root:" /etc/passwd | cut -f4 -d:)
  
if [ "$current" != 0 ]; then
    usermod -g 0 root
	printf "\n"
    echo "Default Group for root Account is modified successfully"
fi

printf "\n\n"

##########################################################################################
#7.6

echo -e "\e[4m7.6 : Set Default umask for Users\e[0m\n"
remedy=$(egrep -h "\s+umask ([0-7]{3})" /etc/bashrc /etc/profile | awk '{ print $2 }')

if [ "$remedy" != 077 ];then 
	sed -i 's/022/077/g' /etc/profile /etc/bashrc
	sed -i 's/002/077/g' /etc/profile /etc/bashrc
	printf "\n"
	echo "Default umask has been set for Users"
fi

printf "\n\n"

# 7.7 Lock Inactive User Accounts
printf "\n"
echo -e "\e[4m7.7 Lock Inactive User Accounts\e[0m\n"
useradd -D -f 30
echo "Inactive User Accounts has been locked"

# 7.8 Ensure Password Fields are Not Empty
printf "\n"
echo -e "\e[4m7.8 Ensure Password Fields are Not Empty\e[0m\n"

current=$(cat /etc/shadow | awk -F: '($2 == ""){print $1}')

for line in ${current}
do
	/usr/bin/passwd -l ${line}	
done
echo "Password has been set for all users"


# 7.9 Verify No Legacy "+" Entries Exist in /etc/passwd, /etc/shadow and /etc/group files
printf "\n"
echo -e "\e[4m7.9 Verify No Legacy \"+\" Entries Exist in /etc/passwd,/etc/shadow,/etc/group\e[0m\n"


passwd=$(grep '^+:' /etc/passwd)
shadow=$(grep '^+:' /etc/shadow)
group=$(grep '^+:' /etc/group)

for accounts in $passwd
do
  	if [ "$accounts" != "" ];then
                userdel --force $accounts
                groupdel --force $accounts
fi
done
echo "No Legacy \"+\" Entries Exist in /etc/passwd,/etc/shadow,/etc/group"

# 7.10 Verify No UID 0 Accounts Exist Other Than root
printf "\n"
echo -e "\e[4m7.10 Verify No UID 0 Accounts Exist Other Than Root\e[0m\n"


remedy=$(/bin/cat /etc/passwd | /bin/awk -F: '($3 == 0) { print $1 }')

for accounts in $remedy
do
	if [ "$accounts" != "root" ];then
		userdel --force $accounts
		groupdel --force $accounts
fi
done
echo "No UID 0 Accounts Exist Other Than Root"

#-----------------------------------------------------------------------------------------------------------------

x=0

while [ $x = 0 ]

do

        clear

        echo "Do you want to set all user hidden file permission as default? (y/n) - Press 'q' to quit."

        read answer

        case "$answer" in

                y)

                echo "You said - yes"

                intUserAcc="$(/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }')"

                if [ -z "$intUserAcc" ]

                then

                        echo "There is no interactive user account."

                        echo ' '

                else

                        /bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }' | while read -r line; do

                                hiddenfiles="$(echo .*)"



                                if [ -z "$hiddenfiles" ]

                                then

                                        echo "There is no hidden files."

                                else

					for file in ${hiddenfiles[*]}

                                        do

                                                chmod g-w $file

                                                chmod o-w $file

                                                echo "User directory $line hidden file $file permission is set as default"

                                        done

                                fi

                        done

                fi

                x=1

                ;;

                n)

                echo "You said -No"

                x=1

                ;;

                q)

                x=1

                echo "Exiting..."

                sleep 2

                ;;

  *)

                clear

                echo "This is not an option"

                sleep 3

                ;;

        esac

done



####################################### 7.14 #######################################



x=0

while [ $x = 0 ]

do

        clear

        echo "Do you want to set all user .netrc file  permission as default? (y/n) - Press 'q' to quit."

        read answer

        case "$answer" in

                y)

                echo "You said - yes"

                intUserAcc="$(/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }')"

                if [ -z "$intUserAcc" ]

                then

                        echo "There is no interactive user account."

                        echo ' '

                else

                        /bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }' | while read -r line; do

				  permission="$(ls -al $line | grep .netrc)"

                                if [ -z "$permission" ]

                                then

                                        echo "There is no .netrc file in user directory $line"

                                        echo ' '

                                else

                                        ls -al $line | grep .netrc | while read -r netrc; do

                                                for file in $netrc

                                                do



 cd $line



 if [[ $file = *".netrc"* ]]



 then



         chmod go-rwx $file



         echo "User directory $line .netrc file $file permission is set as default"



 fi

                                                done

                                        done

                                fi

                        done

                fi

                x=1

                ;;

		 n)

                echo "You said -No"

                x=1

                ;;

                q)

                x=1

                echo "Exiting..."

                sleep 2

                ;;

                *)

                clear

                echo "This is not an option"

                sleep 3

                ;;

        esac

done





####################################### 7.15 #######################################



intUserAcc="$(/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }')"

if [ -z "$intUserAcc" ]

then

        #echo "There is no interactive user account."

        echo ''

else

        /bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }' | while read -r line; do

                #echo "Checking user home directory $line"

		rhostsfile="$(ls -al $line | grep .rhosts)"

                if  [ -z "$rhostsfile" ]

                then

                        #echo " There is no .rhosts file"

                        echo ''

                else

                        ls -al $line | grep .rhosts | while read -r rhosts; do

                                for file in $rhosts

                                do

                                        if [[ $file = *".rhosts"* ]]

                                        then

                                                #echo " Checking .rhosts file $file"

                                                #check if file created user matches directory user

                                                filecreateduser=$(stat -c %U $line/$file)

                                                if [[ $filecreateduser = *"$line"* ]]

                                                then

#echo -e "${GREEN} $file created user is the same user in the directory${NC}"



 echo ''

                                                else



 #echo -e "${RED} $file created user is not the same in the directory. This file should be deleted! ${NC}"



 echo ''

                                                        cd $line



 rm $file

                                                fi

                                        fi

                                done

                        done

                fi

        done

fi



####################################### 7.16 ######################################



echo "Remediation for 7.16 groups in /etc/passwd"

x=0

while [ $x = 0 ]

do

        clear

	echo "Groups defined in /etc/passwd file but not in /etc/group file will pose a threat to system security since the group permission are not properly managed."

        echo ' '

	echo " For all groups that are already defined in /etc/passwd, do you want to defined them in /etc/group? (y/n) - Press 'q' to quit."

        read answer

        case "$answer" in

                y)

                echo "You said - yes"

                

		for i in $(cut -s -d: -f4 /etc/passwd | sort -u); do

        		grep -q -P "^.*?:x:$i:" /etc/group

        		if [ $? -ne 0 ]

        		then

                		#echo -e "${RED}Group $i is referenced by /etc/passwd but does not exist in /etc/group${NC}"

				groupadd -g $i group$i

			fi

		done





                x=1

                ;;

                n)

                echo "You said -No"

                x=1

                ;;

                q)

                x=1

                echo "Exiting..."

                sleep 2

                ;;

                *)

                clear

                echo "This is not an option"

                sleep 3

                ;;

        esac

done



####################################### 7.17 ######################################



echo "Remediation for 7.17 users without valid home directories"

x=0

while [ $x = 0 ]

do

        clear

	echo "Users without assigned home directories should be removed or assigned a home directory."

	echo ' '

	echo " For all users without assigned home directories, press 'a' to assign a home directory, 'b' to remove user or 'q' to quit."

        read answer

        case "$answer" in

                a)

                echo "You choose to assign a home directory for all users without an assigned home directory."

                cat /etc/passwd | awk -F: '{ print $1,$3,$6 }' | while read user uid dir; do

                        if [ $uid - ge 500 -a ! -d"$dir" -a $user != "nfsnobody" ]

                        then

				mkhomedir_helper $user

                        fi

                done

                x=1

                ;;

                b)

                echo "You choose to remove all users without an assigned home directory."

		cat /etc/passwd | awk -F: '{ print $1,$3,$6 }' | while read user uid dir; do

			if [ $uid - ge 500 -a ! -d"$dir" -a $user != "nfsnobody" ]

			then

				userdel -r -f $user

			fi

		done

		x=1

                ;;

                q)

                x=1

                echo "Exiting..."

                sleep 2

                ;;

                *)

                clear

                echo "This is not an option"

                sleep 3

                ;;

        esac

done



echo "Remediation for 7.17 For users without ownership for its home directory"

x=0

while [ $x = 0 ]

do

        clear

        echo "For new users, the home directory on the server is automatically created with BUILTIN\Administrators set as owner. Hence, these users might not have ownership over its home directory."

        echo ' '

        echo " Do you want to set ownership for users without ownership over its home directory? (y/n) -- Press 'q' to quit."

        read answer

        case "$answer" in

                y)

                echo "You have said - yes."

		cat /etc/passwd | awk -F: '{ print $1,$3,$6 }' | while read user uid dir; do

                        if [ $uid -ge 500 -a -d"$dir" -a $user != "nfsnobody" ]

                        then

				sudo chown $user: $dir

                        fi

                done

                x=1

                ;;

                n)

                echo "You have said - no."

                x=1

                ;;

                q)

                x=1

                echo "Exiting..."

                sleep 2

                ;;

                *)

                clear

                echo "This is not an option"

                sleep 3

                ;;

        esac

done

##########################################################################################
#9.1 - Check whether Anacron Daemon is enabled or not

echo -e "\e[4m9.1 : Enable anacron Daemon\e[0m\n"

if rpm -q cronie-anacron
then
	echo "Remediation passed: Anacron Daemon is installed."
		
else
	sudo yum install cronie-anacron -y
fi

if rpm -q cronie-anacron #double checking 
then
	:
	
else
	echo "It seems as if an error has occured and the Anacron Daemon service cannot be installed. Pleas ensure that you have created a yum repository."
fi

printf "\n\n"

##########################################################################################
#9.2 - Check if Crond Daemon is enabled

echo -e "\e[4m9.2 : Enable crond Daemon\e[0m\n"

checkCrondDaemon=$(systemctl is-enabled crond)

if [ "$checkCrondDaemon" = "enabled" ]
then
	echo "Remedation passed: Crond Daemon is enabled."
		
else
	systemctl enable crond
	doubleCheckCrondDaemon=$(systemctl is-enabled crond)
	
	if [ "$doubleCheckCrondDaemon" = "enabled" ]
	then
		:
		
	else
		echo "It seems as if an error has occurred and crond cannot be enabled. Please ensure that you have a yum repository available and cron service installed (yum install cron -y)."
	fi
fi

printf "\n\n"

##########################################################################################
#9.3 - Check if the correct permissions is configured for /etc/anacrontab

echo -e "\e[4m9.3 : Set User/Group Owner and Permission on /etc/anacrontab\e[0m\n"

anacrontabFile="/etc/anacrontab"
anacrontabPerm=$(stat -c "%a" "$anacrontabFile")
anacrontabRegex="^[0-7]00$"

if [[ $anacrontabPerm =~ $anacrontabRegex ]]
then
	echo "Remedation passed: The correct permissions has been configured for $anacrontabFile."
	
else
	sudo chmod og-rwx $anacrontabFile
	anacrontabPermCheck=$(stat -c "%a" "$anacrontabFile")
    anacrontabRegexCheck="^[0-7]00$"
	
	if [[ $anacrontabPermCheck =~ $anacrontabRegexCheck ]]
	then
		:
		
	else
		echo "It seems as if an error has occured and the permissions for $anacrontabFile cannot be configured as required."
	fi
fi

anacrontabOwn=$(stat -c "%U" "$anacrontabFile")

if [ $anacrontabOwn = "root" ]
then
	echo "Remediation passed: The owner of the file $anacrontabFile is root."
	
else
	sudo chown root:root $anacrontabFile
	anacrontabOwnCheck=$(stat -c "%U" "$anacrontabFile")
	
	if [ $anacrontabOwnCheck = "root" ]
	then
		:
		
	else
		echo "It seems as if an error has occured and the owner of the file ($anacrontabFile) cannot be set as root."
	fi
fi

anacrontabGrp=$(stat -c "%G" "$anacrontabFile")

if [ $anacrontabGrp = "root" ]
then
	echo "Remediation passed: The group owner of the file $anacrontabFile is root."
	
else
	sudo chown root:root $anacrontabFile
	anacrontabGrpCheck=$(stat -c "%G" "$anacrontabFile")
	
	if [ $anacrontabGrpCheck = "root" ]
	then
		: 

	else
		echo "It seems as if an error has occured and the group owner of the $anacrontabFile file cannot be set as root instead."
	fi
fi

printf "\n\n"

##########################################################################################
#9.4 - Check if the correct permissions has been configured for /etc/crontab

echo -e "\e[4m9.4 : Set User/Group Owner and Permission on /etc/crontab\e[0m\n"

crontabFile="/etc/crontab"
crontabPerm=$(stat -c "%a" "$crontabFile")
crontabRegex="^[0-7]00$"

if [[ $crontabPerm =~ $crontabRegex ]]
then
	echo "Remediation passed: The correct permissions has been set for $crontabFile."
	
else
	sudo chmod og-rwx $crontabFile
	checkCrontabPerm=$(stat -c "%a" "$crontabFile")
	checkCrontabRegex="^[0-7]00$"
	
	if [[ $checkCrontabPerm =~ $checkCrontabRegex ]]
	then
		:
		
	else
		echo "It seems as if an error has occured and the permisions of the file $crontabFile cannot be set as recommended."
	fi
fi

crontabOwn=$(stat -c "%U" "$crontabFile")

if [ $crontabOwn = "root" ]
then
	echo "Remediation passed: The owner of the file $crontabFile is root."
	
else
	sudo chown root:root $crontabFile
	checkCrontabOwn=$(stat -c "%U" "$crontabFile")
	
	if [ $checkCrontabOwn = "root" ]
	then
		:
		
	else
		echo "It seems as if an error has occured and that the owner of the $crontabFile file cannot be set as root instead."
	fi
fi

crontabGrp=$(stat -c "%G" "$crontabFile")

if [ $crontabGrp = "root" ]
then
	echo "Remediation passed: The group owner of the file $crontabFile is root."
	
else
	sudo chown root:root $crontabFile
	checkCrontabGrp=$(stat -c "%G" "$crontabFile")
	
	if [ $checkCrontabGrp = "root" ]
	then
		:
		
	else
		echo "It seems as if an error has occured and that the group owner of the $crontabFile file cannot be set as root instead."
	fi
fi

printf "\n\n"

##########################################################################################
#9.5 - Check if the correct permissions has been set for /etc/cron.XXXX

echo -e "\e[4m9.5 : Set User/Group Owner and Permission on /etc/cron.[hourly,daily,weekly,monthly]\e[0m\n"

patchCronHDWMPerm(){
	local cronHDWMType=$1
	local cronHDWMFile="/etc/cron.$cronHDWMType"
	local cronHDWMPerm=$(stat -c "%a" "$cronHDWMFile")
	local cronHDWMRegex="^[0-7]00$"
	
	if [[ $cronHDWMPerm =~ $cronHDWMRegex ]]
	then
		echo "Remediation passed: The correct permissions has been set for $cronHDWMFile."
		
	else
		sudo chmod og-rwx $cronHDWMFile
		local checkCronHDWMPerm=$(stat -c "%a" "$cronHDWMFile")
		local checkCronHDWMRegex="^[0-7]00$"
		
		if [[ $checkCronHDWMPerm =~ $checkCronHDWMRegex ]]
       	then
  			:
				
       	else
			echo "It seems as if an error has occured and that the permissions for the $cronHDWMFile file cannot be set as recommended."
		fi
	fi

	local cronHDWMOwn="$(stat -c "%U" "$cronHDWMFile")"
	
	if [ $cronHDWMOwn = "root" ]
	then
		echo "Remediation passed: The owner of the $cronHDWMFile file is root."
		
	else
		sudo chown root:root $cronHDWMFile
		local checkCronHDWMOwn="$(stat -c "%U" "$cronHDWMFile")"
		
	    if [ $checkCronHDWMOwn = "root" ]
	    then
			:
			
		else
			echo "It seems as if an error has occured and that the owner of the $cronHDWMFile cannot be set as root instead."
		fi
	fi

	local cronHDWMGrp="$(stat -c "%G" "$cronHDWMFile")"
	
	if [ $cronHDWMGrp = "root" ]
	then
		echo "Remediation passed: The group owner of the $cronHDWMFile file is root."
		
	else
		sudo chown root:root $cronHDWMFile
		local checkCronHDWMGrp="$(stat -c "%G" "$cronHDWMFile")"
		if [ $checkCronHDWMGrp = "root" ]
		then
			:
			
		else
			echo "It seems as if an error has occured and that the group owner of the $cronHDWMFile cannot be set to root instead."
		fi
	fi
}

patchCronHDWMPerm "hourly"
patchCronHDWMPerm "daily"
patchCronHDWMPerm "weekly"
patchCronHDWMPerm "monthly"

printf "\n\n"

##########################################################################################
#9.6 - Check if the permissions has been set correctly for /etc/cron.d

echo -e "\e[4m9.6 : Set User/Group Owner and Permission on /etc/cron.d\e[0m\n"

cronDFile="/etc/cron.d"
cronDPerm=$(stat -c "%a" "$cronDFile")
cronDRegex="^[0-7]00$"

if [[ $cronDPerm =~ $cronDRegex ]]
then
	echo "Remediation passed: The correct permissions has been set for $cronDFile."
	
else
	sudo chmod og-rwx $cronDFile
	checkCronDPerm=$(stat -c "%a" "$cronDFile")
	checkCronDRegex="^[0-7]00$"
	
	if [[ $checkCronDPerm =~ $checkCronDRegex ]]
	then
		:
		
	else
		echo "It seems as if an error has occured and that the recommended permissions for the $cronDFile file cannot be configured."
	fi
fi

cronDOwn=$(stat -c "%U" "$cronDFile")

if [ $cronDOwn = "root" ]
then
	echo "Remediation passed: The owner of the $cronDFile file is root."
	
else
	sudo chown root:root $cronDFile
	checkCronDOwn=$(stat -c "%U" "$cronDFile")
	
	if [ $checkCronDOwn = "root" ]
	then
		:
		
	else
		echo "It seems as if an error has occured and that the owner of the $cronDFile cannot be set as root instead."
	fi
fi

cronDGrp=$(stat -c "%G" "$cronDFile")

if [ $cronDGrp = "root" ]
then
	echo "Remediation passed: The group owner of the $cronDFile file is root."
	
else
	sudo chown root:root $cronDFile
	checkCronDGrp=$(stat -c "%G" "$cronDFile")
	
	if [ $checkCronDGrp = "root" ]
	then
		:
		
	else
		echo "It seems as if an error has occured and that the group owner of the $cronDFile cannot be set as root instead."
	fi
fi

printf "\n\n"

##########################################################################################
#9.7 & 9.8 - Restrict at Daemon & Restrict at/cron to Authorized Users

echo -e "\e[4m9.7 & 9.8 : Restrict at Daemon & Restrict at/cron to Authorized Users\e[0m\n"

#Check if /etc/at.deny is deleted and that a /etc/at.allow exists and check the permissions of the /etc/at.allow file
echo -e "\e[4mat.deny & at.allow files\e[0m\n"

if [ -e "$atDenyFile" ]
then
	sudo rm $atDenyFile
else
	echo "Remediation passed: The file is deleted or does not exist."
fi

atAllowFile="/etc/at.allow"

if [ -e "$atAllowFile" ]
then
	atAllowPerm=$(stat -c "%a" "$atAllowFile")
	atAllowRegex="^[0-7]00$"
	
	if [[ $atAllowPerm =~ $atAllowRegex ]]
	then
		echo "Remediation passed: The correct permissions for $atAllowFile has been configured."
		
	else
		sudo chmod og-rwx $atAllowFile
		checkAtAllowPerm=$(stat -c "%a" "$atAllowFile")
		checkAtAllowRegex="^[0-7]00$"
		
		if [[ $checkAtAllowPerm =~ $checkAtAllowRegex ]]	
		then
			:
			
		else
			echo "It seems as if an error has occured and the recommended permissions cannot be set for the $atAllowFile file."
		fi
    fi

	atAllowOwn=$(stat -c "%U" "$atAllowFile")
	
	if [ $atAllowOwn = "root" ]
	then
		echo "Remediation passed: The owner of the $atAllowFile is root."
		
	else
		sudo chown root:root $atAllowFile
		checkAtAllowOwn=$(stat -c "%U" "$atAllowFile")
		
		if [ $checkAtAllowOwn = "root" ]
		then
			:
			
		else
			echo "It seems as if an error has occured and that the owne of the $overallCounter file cannot be set as root instead."
		fi
    fi

	atAllowGrp=$(stat -c "%G" "$atAllowFile")
	
	if [ $atAllowGrp = "root" ]
	then
		echo "Remediation passed: The group owner of the $atAllowFile is root."
		
	else
		sudo chown root:root $atAllowFile
		checkAtAllowGrp=$(stat -c "%G" "$atAllowFile")
		
		if [ $checkAtAllowGrp = "root" ]
		then
			:
			
		else
			echo "It seems as if an error has occured and that the group owner of the $atAllowFile file cannot as set to root instead."
		fi
    fi
	
else
	touch $atAllowFile
	sudo chmod og-rwx $atAllowFile
	checkAtAllowPerm2=$(stat -c "%a" "$atAllowFile")
	checkAtAllowRegex2="^[0-7]00$"
	
	if [[ $checkAtAllowPerm2 =~ $checkAtAllowRegex2 ]]
	then
		:
		
	else
		echo "It seems as if an error has occured and the recommended permissions cannot be configured for the $atAllowFile file."
	fi
	
	sudo chown root:root $atAllowFile
	checkAtAllowOwn2=$(stat -c "%U" "$atAllowFile")
	
	if [ $checkAtAllowOwn2 = "root" ]
	then
		:
		
	else
		echo "It seems as if an error has occured and that the owner of the $atAllowFile file cannot be set as root instead"
    fi	

	sudo chown root:root $atAllowFile
	checkAtAllowGrp2=$(stat -c "%G" "$atAllowFile")
	
	if [ $checkAtAllowGrp2 = "root" ]
	then
		:
		
	else
		echo "It seems as if an error has occured and that the group owner of the $atAllowFile file cannot be set as root instead."
	fi
fi

printf "\n"

#Check if /etc/cron.deny is deleted and that a /etc/cron.allow exists and check the permissions of the /etc/cron.allow file
echo -e "\e[4mcron.deny & cron.allow files\e[0m\n"

if [ -e "$cronDenyFile" ]
then
    	sudo rm $cronDenyFile
		
else
    	echo "Remediation passed: The file is deleted or does not exist."
fi

cronAllowFile="/etc/cron.allow"

if [ -e "$cronAllowFile" ]
then
	cronAllowPerm=$(stat -c "%a" "$cronAllowFile")
	cronAllowRegex="^[0-7]00$"
		
	if [[ $cronAllowPerm =~ $cronAllowRegex ]]
	then
		echo "Remediation passed: The correct permissions for $cronAllowFile has been configured."
		
	else
		sudo chmod og-rwx $cronAllowFile
		checkCronAllowPerm=$(stat -c "%a" "$atAllowFile")
		checkCronAllowRegex="^[0-7]00$"
		
		if [[ $checkCronAllowPerm =~ $checkCronAllowRegex ]]
		then
			:
			
		else
			echo "It seems as if an error has occured and the recommended permissions cannot be configured for the $cronAllowFile file."
        fi
    fi

	cronAllowOwn=$(stat -c "%U" "$cronAllowFile")
	
	if [ $cronAllowOwn = "root" ]
	then
		echo "Remedation passed: The owner of the $cronAllowFile is root."
		
	else
		sudo chown root:root $cronAllowFile
		checkCronAllowOwn=$(stat -c "%U" "$cronAllowFile")
		
		if [ $checkCronAllowOwn = "root" ]
		then
			:
			
		else
			echo "It seems as if an error has occured and that the owner of the $cronAllowFile file cannot be set as root instead."
		fi
    fi

	cronAllowGrp=$(stat -c "%G" "$cronAllowFile")
	
	if [ $cronAllowGrp = "root" ]
	then
		echo "Remediation passed: The group owner of the $cronAllowFile is set to root."
		
	else
		sudo chown root:root $cronAllowFile
		checkCronAllowGrp=$(stat -c "%G" "$cronAllowFile")
		
		if [ $checkCronAllowGrp = "root" ]
		then
			:
			
		else
			echo "It seems as if an error has occured and that the group owner of the $cronAllowFile cannot be set as root instead."
		fi
	fi
	
else
	touch $cronAllowFile
	sudo chmod og-rwx $cronAllowFile
	checkCronAllowPerm2=$(stat -c "%a" "$cronAllowFile")
	checkCronAllowRegex2="^[0-7]00$"
	
	if [[ $checkCronAllowPerm2 =~ $checkCronAllowRegex2 ]]
	then
		:
		
	else
		echo "It seems as if an error has occured and the recommended permissions cannot be configured for the $cronAllowFIle file."
	fi

	sudo chown root:root $cronAllowFile
	checkCronAllowOwn2=$(stat -c "%U" "$cronAllowFile")
	
	if [ $checkCronAllowOwn2 = "root" ]
	then
		:
		
	else
		echo "It seems as if an error has occured and that the owner of the $cronAllowFile cannot be set as root instead"
	fi

	sudo chown root:root $cronAllowFile
	checkCronAllowGrp2=$(stat -c "%G" "$cronAllowFile")
	
	if [ $checkCronAllowGrp2 = "root" ]
	then
		:
		
	else
		echo "It seems as if an error has occured and that the group owner of the $cronAllowFile cannot be set as root instead."
	fi
fi

printf "\n\n"

#10.1 remedy
remsshprotocol=`grep "^Protocol 2" /etc/ssh/sshd_config`
if [ "$remsshprotocol" != "Protocol 2" ]
then
	echo -e "\e[4m10.1 Set SSH Protocol to 2\e[0m\n"
	sed -ie "23s/#//" /etc/ssh/sshd_config
	echo "SSH Protocol has been set to 2"
fi

#10.2 remedy
remsshloglevel=`grep "^LogLevel" /etc/ssh/sshd_config`
if [ "$remsshloglevel" != "LogLevel INFO" ]
then
	echo -e "\e[4m10.2 Set LogLevel to INFO\e[0m\n"
	sed -ie "43s/#//" /etc/ssh/sshd_config
	echo "LogLevel has been set to INFO"
fi

#10.3 remedy
remdeterusergroupownership=`grep "^LogLevel" /etc/ssh/sshd_config`
if [ -z "$remdeterusergroupownership" ]
then
	echo -e "\e[4m10.3 Set Permissions on /etc/ssh/sshd_config\e[0m\n"
	chown root:root /etc/ssh/sshd_config
	chmod 600 /etc/ssh/sshd_config
	echo "Permissions on /etc/ssh/sshd_config has been set"
fi

#10.4 remedy
remsshx11forwarding=`grep "^X11Forwarding" /etc/ssh/sshd_config`
if [ "$remsshx11forwarding" != "X11Forwarding no" ]
then
	echo -e "\e[4m10.4 Disable SSH X11 Forwarding\e[0m\n"
	sed -ie "116s/#//" /etc/ssh/sshd_config
	sed -ie "117s/^/#/" /etc/ssh/sshd_config
	echo "SSH X11 Forwarding has been disabled"
fi

#10.5 remedy
maxauthtries=`grep "^MaxAuthTries 4" /etc/ssh/sshd_config`
if [ "$maxauthtries" != "MaxAuthTries 4" ]
then
	echo -e "\e[4m10.5 Set SSH MaxAuthTries to 4 or Less\e[0m\n"
	sed -ie "50d" /etc/ssh/sshd_config
	sed -ie "50iMaxAuthTries 4" /etc/ssh/sshd_config
	echo "SSH MaxAuthTries has been set to 4 or Less"
fi

#10.6 remedy
ignorerhosts=`grep "^IgnoreRhosts" /etc/ssh/sshd_config`
if [ "$ignorerhosts" != "IgnoreRhosts yes" ]
then
	echo -e "\e[4m10.6 Set SSH IgnoreRhosts to Yes\e[0m\n"
	sed -ie "73d" /etc/ssh/sshd_config
	sed -ie "73iIgnoreRhosts yes" /etc/ssh/sshd_config
	echo "SSH IgnoreRhosts has been set to Yes"
fi
printf "\n"

#11.1
checkPassAlgo=$(authconfig --test | grep hashing | grep sha512)
checkPassRegex=".*sha512"
if [[ $checkPassAlgo =~ $checkPassRegex ]]
then
    	echo "The password hashing algorithm is set to SHA-512 as recommended."
else
    	authconfig --passalgo=sha512 --update
	doubleCheckPassAlgo2=$(authconfig --test | grep hashing | grep sha512)
	doubleCheckPassRegex2=".*sha512"
	if [[ $doubleCheckPassAlgo2 =~ $doubleCheckPassRegex2 ]]
	then
    		echo "The password hashing algorithm is set to SHA-512 as recommended."
		cat /etc/passwd | awk -F: '($3 >= 1000 && $1 != "test") { print $1 }' | xargs -n 1 chage -d 0
		if [ $? -eq 0 ]
		then
			echo "Users will be required to change their password upon the next log in session."
		else
			echo "It seems as if error has occured and that the userID cannot be immediately expired. After a password hashing algorithm update, it is essential to ensure that all the users have changed their passwords."
		fi
	else
		echo "It seems as if an error has occured and the password hashing algorithm cannot be set as SHA-512."
	fi
fi


#11.2
pampwquality=$(grep pam_pwquality.so /etc/pam.d/system-auth)
pampwqualityrequisite=$(grep "password    requisite" /etc/pam.d/system-auth)
correctpampwquality="password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type="
if [[ $pampwquality == $correctpampwquality ]]
then
echo "No remediation needed."
else
if [[ -n $pampwqualityrequisite ]]
then
sed -i 's/.*requisite.*/password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=/' /etc/pam.d/system-auth
echo "Remediation completed."
else
echo $correctpampwquality >> /etc/pam.d/system-auth
echo "Remediation completed."
fi
fi

minlen=$(grep "minlen" /etc/security/pwquality.conf)
dcredit=$(grep "dcredit" /etc/security/pwquality.conf)
ucredit=$(grep "ucredit" /etc/security/pwquality.conf)
ocredit=$(grep "ocredit" /etc/security/pwquality.conf)
lcredit=$(grep "lcredit" /etc/security/pwquality.conf)
correctminlen="# minlen = 14"
correctdcredit="# dcredit = -1"
correctucredit="# ucredit = -1"
correctocredit="# ocredit = -1"
correctlcredit="# lcredit = -1"


if [[ $minlen == $correctminlen && $dcredit == $correctdcredit && $ucredit == $correctucredit && $ocredit == $correctocredit && $lcredit == $correctlcredit ]]
then
echo "No Remediation needed."
else
sed -i -e 's/.*minlen.*/# minlen = 14/' -e 's/.*dcredit.*/# dcredit = -1/' -e  's/.*ucredit.*/# ucredit = -1/' -e 's/.*ocredit.*/# ocredit = -1/' -e 's/.*lcredit.*/# lcredit = -1/' /etc/security/pwquality.conf
echo "Remediation completed."
fi





#11.3
faillockpassword=$(grep "pam_faillock" /etc/pam.d/password-auth)
faillocksystem=$(grep "pam_faillock" /etc/pam.d/system-auth)

read -d '' correctpamauth << "BLOCK"
auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900
auth        [default=die] pam_faillock.so authfail audit deny=5
auth        sufficient    pam_faillock.so authsucc audit deny=5
account     required      pam_faillock.so
BLOCK


if [[ $faillocksystem == "$correctpamauth" && $faillockpassword == "$correctpamauth" ]]
then
	echo "No remediation needed."
elif [[ $faillocksystem == "$correctpamauth" && $faillockpassword != "$correctpamauth" ]]
then
	if [[ -n $faillockpassword ]]
	then
		sed -i '/pam_faillock.so/d' /etc/pam.d/password-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/password-auth
		echo "Remediation completed."
	else
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/password-auth
		echo "Remediation completed."
	fi
elif [[ $faillocksystem != "$correctpamauth" && $faillockpassword == "$correctpamauth" ]]
then
	if [[ -n $faillocksystem ]]
	then
		sed -i '/pam_faillock.so/d' /etc/pam.d/system-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/system-auth
		echo "Remediation completed."
	else
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/system-auth
		echo "Remediation completed."
	fi
else
	if [[ -n $faillocksystem && -z $faillockpassword ]]
	then
		sed -i '/pam_faillock.so/d' /etc/pam.d/system-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/system-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/password-auth
		echo "Remediation completed."
	elif [[ -z $faillocksystem && -n $faillockpassword ]]
	then
		sed -i '/pam_faillock.so/d' /etc/pam.d/password-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/password-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/system-auth
		echo "Remediation completed."
	elif [[ -n $faillocksystem && -n $faillockpassword ]]
	then
		sed -i '/pam_faillock.so/d' /etc/pam.d/system-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/system-auth
		sed -i '/pam_faillock.so/d' /etc/pam.d/password-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/password-auth
		echo "Remediation completed."
	else
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/system-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/password-auth
		echo "Remediation completed."
	fi
fi






#11.4

pamlimitpw=$(grep "remember" /etc/pam.d/system-auth)
existingpamlimitpw=$(grep "password.*sufficient" /etc/pam.d/system-auth)
if [[ $pamlimitpw == *"remember=5"* ]]
then
echo "No remediation needed."
else
if [[ -n $existingpamlimitpw ]]
then
sed -i 's/password.*sufficient.*/password    sufficient    pam_unix.so sha512 shadow nullok remember=5 try_first_pass use_authtok/' /etc/pam.d/system-auth
echo "Remediation completed."
else
sed -i '/password/a password sufficient pam_unix.so remember=5' /etc/pam.d/system-auth
echo "Remediation completed." 
fi
fi 





#11.5

systemConsole="/etc/securetty"
systemConsoleCounter=0
while read -r line; do
	if [ -n "$line" ]
	then
		[[ "$line" =~ ^#.*$ ]] && continue
		if [ "$line" == "vc/1" ] || [ "$line" == "tty1" ]
		then
			systemConsoleCounter=$((systemConsoleCounter+1))
		else	
			systemConsoleCounter=$((systemConsoleCounter+1))
		fi
	fi
done < "$systemConsole"

read -d '' correctsyscon << "BLOCKED"
vc/1
tty1
BLOCKED


if [ $systemConsoleCounter != 2 ]
then
	echo "$correctsyscon" > /etc/securetty
	echo "Remediation completed."
else
	echo "No remediation needed."
fi



#11.6

pamsu=$(grep pam_wheel.so /etc/pam.d/su | grep required)
if [[ $pamsu =~ ^#auth.*required ]]
then
sed -i 's/#.*pam_wheel.so use_uid/auth            required        pam_wheel.so use_uid/' /etc/pam.d/su
echo "Remediation completed."
else
echo "No remediation needed."
fi

pamwheel=$(grep wheel /etc/group)
if [[ $pamwheel =~ ^wheel.*root ]]
then
echo "No remediation is needed."
else
usermod -aG wheel root
echo "Remediation completed."
fi

##########################################################################################

#read -n 1 -s -r -p "Press any key to exit!"
#kill -9 $PPID

