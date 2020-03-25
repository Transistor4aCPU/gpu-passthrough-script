#!/bin/bash
# Check that the script is running with root permissions
if [ "$EUID" -ne 0 ]
  then kdialog --error "You have to run this script as root"
  exit
fi

# Check that the system is booted in UEFI mode
if [ "[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS | grep -c UEFI" == "0" ]
	then
		kdialog --error "You have to boot with UEFI"
		exit
fi

# Check cpu vendor
if [ "cat /proc/cpuinfo | grep -c AuthenticAMD" > "0" ]
	then cpuvendor=AMD
	elif [ "cat /proc/cpuinfo | grep -c GenuineIntel" > "0" ]
		then cpuvendor=Intel
	else
		kdialog --msgbox "Unknown CPU Vendor.\nYou have to edit the grub file"
fi

# Configure Grub 2
kdialog --msgbox "We have to configure grub"
grub="$(kdialog --menu "Choose how you want to configure grub" 1 "Automatic configuration [Broken]" 2 "Manual configuration [Recommended]")"
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
				kdialog --error "Grub configuration error. Choose manual configuration"
				exit
		fi
	elif [ "$grub" == "2" ]
		then
			if [ "$cpuvendor" == "AMD" ]
				then
					apt-get -y install gedit
					kdialog --msgbox  "Add amd_iommu=on iommu=pt kvm_amd.npt=1 kvm_amd.avic=1 to GRUB_CMDLINE_LINUX_Default.\nPress OK if you have copied"
					gedit /etc/default/grub
					update-grub
				elif [ "$cpuvendor" == "Intel" ]
					then
						apt-get -y install gedit
						kdialog --msgbox "Add intel_iommu=on iommu=pt to GRUB_CMDLINE_LINUX_Default.\nPress OK if you have copied"
                                                gedit /etc/default/grub
                                                update-grub
			fi
	else
		exit
fi

# Reboot dialog
kdialog --msgbox "You should run gpu-configuration.sh after reboot to configure gpu passthrough\nYou have to enable IOMMU and SVM/VT-d in the UEFI"
kdialog --yesno "Do you want to reboot?"
if [[ $? = 0 ]]; then
  reboot
fi
exit


