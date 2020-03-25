#!/bin/bash
# Getopts
unset VERBOSE
while getopts 'v' c
do
  case $c in
    v) VERBOSE=true ;;
  esac
done
if [ $VERBOSE ]; then
  set -x
fi

# Check that the script is running with root permissions
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Check that the system is booted in UEFI mode
if [ "[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS | grep -c UEFI" == "0" ]
	then
		echo "You have to boot with UEFI"
		exit
fi

# Check cpu vendor
if [ "cat /proc/cpuinfo | grep -c AuthenticAMD" > "0" ]
	then cpuvendor=AMD
	elif [ "cat /proc/cpuinfo | grep -c GenuineIntel" > "0" ]
		then cpuvendor=Intel
	else
		echo "Unknown CPU vendor"
		echo "You have to edit the grub file"
fi

# Configure Grub 2
echo "We have to configure grub"
echo "Choose on of the following options, print only the number"
echo "1. Automatic configuration [Broken]"
echo "2. Manual configuration"
echo "3. Abort"
read grub
if [ "$grub" == "1" ]
	then
		if [ "$cpuvendor" == "AMD" ]
			then
				sed s/"quiet splash"/"amd_iommu=on iommu=pt kvm_amd.npt=1 kvm_amd.avic=1"/g /etc/default/grub
				update-grub
			elif [ "$cpuvendor" == "Intel" ]
				then
					sed s/"quiet splash"/"intel_iommu=on"/g /etc/default/grub
					update-grub
			else
				echo "Grub autoconfiguration error. Choose manual configuration"
				exit
		fi
	elif [ "$grub" == "2" ]
		then
			if [ "$cpuvendor" == "AMD" ]
				then
					apt-get -y install nano
					echo "Add "amd_iommu=on iommu=pt kvm_amd.npt=1 kvm_amd.avic=1" to GRUB_CMDLINE_LINUX_Default"
					echo "Press "Y" if you have copied what you should add"
					read grubdefault
					if [ "$grubdefault" == "Y" ]
						then
							nano /etc/default/grub
							update-grub
					fi
				elif [ "$cpuvendor" == "Intel" ]
					then
						apt-get -y install nano
						echo "Add "intel_iommu=on" to GRUB_CMDLINE_LINUX_Default"
						echo "Press "Y" if you have copied what you should add"
                                        	read grubdefault
                                        	if [ "$grubdefault" == "Y" ]
                                                	then
                                                        	nano /etc/default/grub
                                                        	update-grub
                                        	fi
			fi
	else
		exit
fi

# Reboot dialog
echo "You should run gpu-configuration.sh after reboot to configure gpu passthrough"
echo "You have to enable IOMMU and SVM/VT-d in the UEFI"
echo "Do you want reboot now? [Y/n]"
read reboot
if [ "$reboot" == "Y" ]
	then
		reboot
	else
		exit
fi
