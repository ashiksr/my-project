#!/bin/bash

echo " "
echo "Welcome to Initial Instance configuration"
echo " "
echo "-----------------------------------------"
echo "|                                       |"
echo "|    Activities                         |"
echo "|    1. Installation of essentials      |"
echo "|    2. Disabling Firewall              |"
echo "|    3. Flush IPTables                  |"
echo "|    4. Disable SELINUX                 |"
echo "|                                       |"
echo "-----------------------------------------"

while true
do
      read -r -p "Do you wish to continue? [Y/n] " input

      case $input in
            [yY][eE][sS]|[yY])
                  echo "Begins"
                  break
                  ;;
            [nN][oO]|[nN])
                  echo "Aborting"
                  exit
                  ;;
            *)
                  echo "Invalid input..."
                  ;;
      esac
done
echo " Step 1 of 4 "

### Essentials Installation ####
echo " Installation... "
function isinstalled {
	if yum list installed "$@" >/dev/null 2>&1; then
		true
	else
		false
	fi
}

package=(vim mlocate net-tools rsync telnet tar nfs-utils libSM php mod_ssl openssl sysstat)
for i in ${package[*]}
  do
	  if isinstalled $i; then
		  echo " $i is installed " :
	  else
		  echo " $i is not installed";
		  echo "installing $i ... ";
		  yum install -y $i;
	  fi
done

### Service Status #####
echo " step 2 0f 4 "
echo " Disabling firewalld and ds_agent "
serv=(firewalld ds_agent)
for j in ${serv[*]}
  do
          if (( $(ps aux | grep -v grep | grep $j | wc -l) > 0 )); then
                  echo " $j .service is not running "
		  systemctl status $j
	  else
		  systemctl stop $j
		  systemctl status $j
	  fi
done

### IPTABLE FLUSH ###
echo " step 3 of 4 "
echo " iptables flushed "
iptables -F

### Disabling SELINUX ###
echo " step 4 of 4"
echo " Disabling SELINUX "
setenforce 0
sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
getenforce

echo " Completed "
