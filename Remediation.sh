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

##########################################################################################

#read -n 1 -s -r -p "Press any key to exit!"
#kill -9 $PPID

