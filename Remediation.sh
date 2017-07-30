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

##########################################################################################

#read -n 1 -s -r -p "Press any key to exit!"
#kill -9 $PPID

