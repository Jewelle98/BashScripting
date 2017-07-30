#!/bin/bash

trap '' 2
trap '' SIGTSTP

##########################################################################################

checktmp=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab`

if [ -z "$checktmp" ]
then
	echo "1. /tmp - FAILED (A separate /tmp partition has not been created.)"

else
	checknodev=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nodev`
	checknodev1=`mount | grep "[[:space:]]/tmp[[:space:]]" | grep nodev`

	if [ -z "$checknodev" -a -z "$checknodev1" ]
	then
		echo "1. /tmp - FAILED (/tmp not mounted with nodev option)"

	elif [ -z "$checknodev" -a -n "$checknodev1" ]
	then
		echo "1. /tmp - FAILED (/tmp not mounted persistently with nodev option)"

	elif [ -n "$checknodev" -a -z "$checknodev1" ]
	then
		echo "1. /tmp - FAILED (/tmp currently not mounted with nodev option)"

	else
		checknosuid=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nosuid`
		checknosuid1=`mount | grep "[[:space:]]/tmp[[:space:]]" | grep nosuid`

		if [ -z "$checknosuid" -a -z "$checknosuid1" ]
		then
			echo "1. /tmp - FAILED (/tmp not mounted with nosuid option)"

		elif [ -z "$checknosuid" -a -n "$checknosuid1" ]
		then
			echo "1. /tmp - FAILED (/tmp not mounted persistently with nosuid option)"

		elif [ -n "$checknosuid" -a -z "$checknosuid1" ]
		then
			echo "1. /tmp - FAILED (/tmp currently not mounted with nosuid option)"

		else	
			checknoexec=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep noexec`
			checknoexec1=`mount | grep "[[:space:]]/tmp[[:space:]]" | grep noexec`

			if [ -z "$checknoexec" -a -z "$checknoexec1" ]
			then
				echo "1. /tmp - FAILED (/tmp not mounted with noexec option)"

			elif [ -z "$checknoexec" -a -n "$checknoexec1" ]
			then
				echo "1. /tmp - FAILED (/tmp not mounted persistently with noexec option)"

			elif [ -n "$checknoexec" -a -z "$checknoexec1" ]
			then
				echo "1. /tmp - FAILED (/tmp currently not mounted with noexec option)"

			else
				echo "1. /tmp - PASSED (/tmp is a separate partition with nodev,nosuid,noexec option)"
			fi
		fi
	fi
fi

##########################################################################################

checkvar=` grep "[[:space:]]/var[[:space:]]" /etc/fstab`

if [ -z "$checkvar" ]
then
	echo "2. /var - FAILED (A separate /var partition has not been created.)"

else 
	echo "2. /var - PASSED (A separate /var partition has been created)"
fi

##########################################################################################

checkbind=`grep -e "^/tmp[[:space:]]" /etc/fstab | grep /var/tmp` 
checkbind1=`mount | grep /var/tmp`

if [ -z "$checkbind" -a -z "$checkbind1" ]
then
	echo "3. /var/tmp - FAILED (/var/tmp mount is not bounded to /tmp)"

elif [ -z "$checkbind" -a -n "$checkbind1" ]
then
	echo "3. /var/tmp - FAILED (/var/tmp mount has not been binded to /tmp persistently.)"

elif [ -n "$checkbind" -a -z "$checkbind1" ]
then
	echo "3. /var/tmp - FAILED (/var/tmp mount is not currently bounded to /tmp)"

else 
	echo "3. /var/tmp - PASSED (/var/tmp has been binded and mounted to /tmp)"
fi

##########################################################################################

checkvarlog=`grep "[[:space:]]/var/log[[:space:]]" /etc/fstab`

if [ -z "$checkvarlog" ]
then
	echo "4. /var/log - FAILED (A separate /var/log partition has not been created.)"

else 
	echo "4. /var/log - PASSED (A separate /var/log partition has been created)"
fi	

##########################################################################################

checkvarlogaudit=`grep "[[:space:]]/var/log/audit[[:space:]]" /etc/fstab`

if [ -z "$checkvarlogaudit" ]
then
	echo "5. /var/log/audit - FAILED (A separate /var/log/audit partition has not been created.)"

else 
	echo "5. /var/log/audit - PASSED (A separate /var/log/audit partition has been created)"
fi	

##########################################################################################

checkhome=` grep "[[:space:]]/home[[:space:]]" /etc/fstab`

if [ -z "$checkhome" ]
then
	echo "6. /home - FAILED (A separate /home partition has not been created.)"

else 
	checknodevhome=`grep "[[:space:]]/home[[:space:]]" /etc/fstab | grep nodev`
	checknodevhome1=`mount | grep "[[:space:]]/home[[:space:]]" | grep nodev`
	
		if [ -z "$checknodevhome" -a -z "$checknodevhome1" ]
		then
			echo "6. /home - FAILED (/home not mounted with nodev option)"

		elif [ -z "$checknodevhome" -a -n "$checknodevhome1" ]
		then
			echo "6. /home - FAILED (/home not mounted persistently with nodev option)"

		elif [ -n "$checknodevhome" -a -z "$checknodevhome1" ]
		then
			echo "6. /home - FAILED (/home currently not mounted with nodev option)"

	else
		echo "6. /home - PASSED (/home is a separate partition with nodev option)"
	fi
fi

printf "\n\n"

##########################################################################################
#6.2.1.6

echo -e "\e[4m6.2.1.6 : Record Events That Modify Date and Time Information\e[0m\n"

checksystem=`uname -m | grep "64"`
checkmodifydatetimeadjtimex=`egrep 'adjtimex|settimeofday|clock_settime' /etc/audit/audit.rules`

if [ -z "$checksystem" ]
then
	echo "It is a 32-bit system."
	printf "\n"

	if [ -z "$checkmodifydatetimeadjtimex" ]
	then
		echo "Date & Time Modified Events - FAILED (Events where system date and/or time has been modified are not captured)"

	else
		echo "Date & Time Modified Events - PASSED (Events where system date and/or time has been modified are captured)"
	fi

else
	echo "It is a 64-bit system."
	printf "\n" 

	if [ -z "$checkmodifydatetimeadjtimex" ]
	then
		echo "Date & Time Modified Events - FAILED (Events where system date and/or time has been modified are not captured)"

	else
		echo "Date & Time Modified Events - PASSED (Events where system date and/or time has been modified are captured)"
	fi
fi

printf "\n\n"

##########################################################################################
#6.2.1.7

echo -e "\e[4m6.2.1.7 : Record Events That Modify User/Group Information\e[0m\n"

checkmodifyusergroupinfo=`egrep '\/etc\/group' /etc/audit/audit.rules`

if [ -z "$checkmodifyusergroupinfo" ]
then
	echo "Group Configuration - FAILED (Group is not configured)"

else
	echo "Group Configuration - PASSED (Group is already configured)"
fi

printf "\n"

checkmodifyuserpasswdinfo=`egrep '\/etc\/passwd' /etc/audit/audit.rules`

if [ -z "$checkmodifyuserpasswdinfo" ]
then
	echo "Password Configuration - FAILED (Password is not configured)"

else
	echo "Password Configuration - PASSED (Password is configured)"
fi

printf "\n"

checkmodifyusergshadowinfo=`egrep '\/etc\/gshadow' /etc/audit/audit.rules`

if [ -z "$checkmodifyusergshadowinfo" ]
then
	echo "GShadow Configuration - FAILED (GShadow is not configured)"

else
	echo "GShadow Configuration - PASSED (GShadow is configured)"
fi

printf "\n"

checkmodifyusershadowinfo=`egrep '\/etc\/shadow' /etc/audit/audit.rules`

if [ -z "$checkmodifyusershadowinfo" ]
then
	echo "Shadow Configuration - FAILED (Shadow is not configured)"

else
	echo "Shadow Configuration - PASSED (Shadow is configured)"
fi

printf "\n"

checkmodifyuseropasswdinfo=`egrep '\/etc\/security\/opasswd' /etc/audit/audit.rules`

if [ -z "$checkmodifyuseropasswdinfo" ]
then
	echo "OPasswd Configuration- FAILED (OPassword not configured)"

else
	echo "OPasswd Configuration - PASSED (OPassword is configured)"
fi

printf "\n\n"

##########################################################################################
#6.2.1.8

echo -e "\e[4m6.2.1.8 : Record Events That Modify the System's Network Environment\e[0m\n"

checksystem=`uname -m | grep "64"`
checkmodifynetworkenvironmentname=`egrep 'sethostname|setdomainname' /etc/audit/audit.rules`

if [ -z "$checksystem" ]
then
	echo "It is a 32-bit system."
	printf "\n"
	
	if [ -z "$checkmodifynetworkenvironmentname" ]
	then
		echo "Modify the System's Network Environment Events - FAILED (Sethostname and setdomainname is not configured)"

	else
		echo "Modify the System's Network Environment Events - PASSED (Sethostname and setdomainname is configured)"
	fi

else
	echo "It is a 64-bit system."
	printf "\n"
	
	if [ -z "$checkmodifynetworkenvironmentname" ]
	then
        echo "Modify the System's Network Environment Events - FAILED (Sethostname and setdomainname is not configured)"

	else
		echo "Modify the System's Network Environment Events - PASSED (Sethostname and setdomainname is configured)"
	fi
fi

printf "\n"

checkmodifynetworkenvironmentissue=`egrep '\/etc\/issue' /etc/audit/audit.rules`

if [ -z "$checkmodifynetworkenvironmentissue" ]
then
    echo "Modify the System's Network Environment Events - FAILED (/etc/issue is not configured)"

else
    echo "Modify the System's Network Environment Events - PASSED (/etc/issue is configured)"
fi

printf "\n"

checkmodifynetworkenvironmenthosts=`egrep '\/etc\/hosts' /etc/audit/audit.rules`

if [ -z "$checkmodifynetworkenvironmenthosts" ]
then
    echo "Modify the System's Network Environment Events - FAILED (/etc/hosts is not configured)"

else
	echo "Modify the System's Network Environment Events - PASSED (/etc/hosts is configured)"
fi

printf "\n"

checkmodifynetworkenvironmentnetwork=`egrep '\/etc\/sysconfig\/network' /etc/audit/audit.rules`

if [ -z "$checkmodifynetworkenvironmentnetwork" ]
then
    echo "Modify the System's Network Environment Events - FAILED (/etc/sysconfig/network is not configured)"

else
    echo "Modify the System's Network Environment Events - PASSED (/etc/sysconfig/network is configured)"
fi

printf "\n\n"

##########################################################################################
#6.2.1.9

echo -e "\e[4m6.2.1.9 : Record Events That Modify the System's Mandatory Access Controls\e[0m\n"

checkmodifymandatoryaccesscontrol=`grep \/etc\/selinux /etc/audit/audit.rules`

if [ -z "$checkmodifymandatoryaccesscontrol" ]
then
	echo "Modify the System's Mandatory Access Controls Events - FAILED (Recording of modified system's mandatory access controls events is not configured)"

else
	echo "Modify the System's Mandatory Access Controls Events - PASSED (Recording of modified system's mandatory access controls events is configured)"
fi

printf "\n\n"

##########################################################################################
#6.2.1.10

echo -e "\e[4m6.2.1.10 : Collect Login and Logout Events\e[0m\n"

chklogins=`grep logins /etc/audit/audit.rules`
loginfail=`grep "\-w /var/log/faillog -p wa -k logins" /etc/audit/audit.rules`
loginlast=`grep "\-w /var/log/lastlog -p wa -k logins" /etc/audit/audit.rules`
logintally=`grep "\-w /var/log/tallylog -p wa -k logins" /etc/audit/audit.rules`

if [ -z "$loginfail" -o -z "$loginlast" -o -z "$logintally" ]
then
	echo "FAILED - Login and logout events not recorded."

else
	echo "PASSED - Login and logout events recorded."
fi

printf "\n\n"

##########################################################################################
#6.2.1.11

echo -e "\e[4m6.2.1.11 : Collect Session Initiation Information\e[0m\n"

chksession=`egrep 'wtmp|btmp|utmp' /etc/audit/audit.rules`
sessionwtmp=`egrep "\-w /var/log/wtmp -p wa -k session" /etc/audit/audit.rules`
sessionbtmp=`egrep "\-w /var/log/btmp -p wa -k session" /etc/audit/audit.rules`
sessionutmp=`egrep "\-w /var/run/utmp -p wa -k session" /etc/audit/audit.rules`

if [ -z "$sessionwtmp" -o -z "$sessionbtmp" -o -z "sessionutmp" ]
then
	echo "FAILED - Session initiation information not collected."

else
	echo "PASSED - Session initiation information is collected."
fi

printf "\n\n"

##########################################################################################
#6.2.1.12

echo -e "\e[4m6.2.1.12 : Collect Discretionary Access Control Permission Modification Events\e[0m\n"

chkpermission64=`grep perm_mod /etc/audit/audit.rules`
permission1=`grep "\-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`
permission2=`grep "\-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F
auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`
permission3=`grep "\-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S|chown -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`
permission4=`grep "\-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S|chown -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`
permission5=`grep "\-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -Fauid!=4294967295 -k perm_mod" /etc/audit/audit.rules`
permission6=`grep "\-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S
 fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F
auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`

if [ -z "$permission1" -o -z "$permission2" -o -z permission3 -o -z permission4 -o -z permission5 -o -z permission6 ]
then
	echo "FAILED - Permission modifications not recorded."

else
	echo "PASSED - Permission modification are recorded."
fi

printf "\n\n"

##########################################################################################
#6.2.1.13

echo -e "\e[4m6.2.1.13 : Collect Unsuccessful Unauthorized Access Attempts to Files\e[0m\n"

chkaccess=`grep access /etc/audit/audit.rules`
access1=`grep "\-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`
access2=`grep "\-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`
access3=`grep "\-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`
access4=`grep "\-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`
access5=`grep "\-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`
access6=`grep "\-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`

if [ -z "$access1" -o -z "$access2" -o -z "$access3" -o -z "$access4" -o -z "$access5" -o -z "$access6" ]
then
	echo "FAILED - Unsuccesful attempts to access files."

else
	echo "PASSED - Successful attempts to access files."
fi

printf "\n\n"

##########################################################################################
#7.1

count=1
echo -e "\e[4m7.$count : Set Password Expiration Days\e[0m\n"
value=$(cat /etc/login.defs | grep "^PASS_MAX_DAYS" | awk '{ print $2 }')

standard=90 

if [ ! $value = $standard ]; then
	echo "Current PASS_MAX_DAYS = $value"
	echo "Result: FAILED! (PASS_MAX_DAYS should be set to less than 90 days)"
	((count++))
	
elif [ $value = $standard ]; then
	echo "Current Password Maximum = $value"
	echo "Result: PASSED! (PASS_MAX_DAYS is set to less than 90 days)"
	((count++))
	
else
	echo "Result: ERROR, CONTACT SYSTEM ADMINISTRATOR!"
	((count++))
fi

##########################################################################################
#7.2

printf "\n\n"
echo -e "\e[4m7.$count : Set Password Change Minimum Number of Days\e[0m\n"
value=$(cat /etc/login.defs | grep "^PASS_MIN_DAYS" | awk '{ print $2 }')

standard=7 

if [ ! $value = $standard ]; then
	echo "Current PASS_MIN_DAYS = $value"
	echo "Result: FAILED! (PASS_MIN_DAYS should be set to more than 7 days)"
	((count++))
	
elif [ $value = $standard ]; then
	echo "Current PASS_MIN_DAYS = $value"
	echo "Result: PASSED! (PASS_MIN_DAYS is be set to more than 7 days)"
	((count++))
	
else
	echo "Result: ERROR, CONTACT SYSTEM ADMINISTRATOR!"
   ((count++))
fi

##########################################################################################
#7.3

printf "\n\n"
echo -e "\e[4m7.$count : Set Password Expiring Warning Days\e[0m\n"
value=$(cat /etc/login.defs | grep "^PASS_WARN_AGE" | awk '{ print $2 }')

standard=7 

if [ ! $value = $standard ]; then
	echo "Current PASS_WARN_AGE = $value"
	echo "Result: FAILED! (PASS_WARN_AGE should be set to more than 7 days)"
	((count++))
	
elif [ $value = $standard ]; then
	echo "Current PASS_WARN_AGE = $value"
	echo "Result: PASSED! (PASS_WARN_AGE is be set to more than 7 days)"
	((count++))
	
else
	echo "Result: ERROR, CONTACT SYSTEM ADMINISTRATOR!"
   ((count++))
fi

##########################################################################################
#7.4

printf "\n\n"
echo -e "\e[4m7.$count : Disable System Accounts\e[0m\n"

current=$(egrep -v "^\+" /etc/passwd | awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $3<1000 && $7!="/sbin/nologin" && $7!="/bin/false") { print $1 }')

if [ -z "$current" ]; then
	echo "Result: PASSED! (No system accounts can be accessed)"
	((count++))
	
elif [ ! -z "$current" ]; then
	echo "Result: FAILED! (System account(s) can be accessed)"
	((count++))
	
else
	echo "Result: ERROR, CONTACT SYSTEM ADMINISTRATOR!"
	((count++))
fi

##########################################################################################
#7.5

printf "\n\n"
echo -e "\e[4m7.$count : Set Default Group for root Account\e[0m\n"

current=$(grep "^root:" /etc/passwd | cut -f4 -d:)

if [ "$current" == 0 ]; then
	echo "Result: PASSED! (Default group for root configured correctly)"
	((count++))
	
else
	echo "Result: FAILED! (Default group for root configured incorrectly)"
	((count++))
fi

##########################################################################################
#7.6

printf "\n\n"
echo -e "\e[4m7.$count : Set Default umask for Users\e[0m\n"

current=$(egrep -h "\s+umask ([0-7]{3})" /etc/bashrc /etc/profile | awk '{print $2}')

counter=0

for line in ${current}
do
	if [ "${line}" != "077" ] 
	then
		((counter++))	
	fi
done

if [ ${counter} == 0 ]
then 
	echo "Result: PASSED! (Umask is set to 077)"
	((count++))
	
else     
	 echo "Result: FAILED! (Umask is not set to 077)"
	((count++))
fi

printf "\n\n"

##########################################################################################

#read -n 1 -s -r -p "Press any key to exit!"
#kill -9 $PPID

