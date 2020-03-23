# GPU passthrough script
An interactive script that configures gpu passthrough on debian/ubuntu based linux systems.
It automatically configures IOMMU in grub and isolates the GPU choosen for passthrough.

After following the following steps your GPU should be isolated and ready for GPU passthrough
```
# Configure IOMMU in Grub
sudo bash grub-iommu-conf.sh
```
After reboot
```
# Configure GPU passthrough
sudo bash gpu-passthrough-script.sh
```
After reboot
```
# Check that the passthrough gpu use the vfio driver
lspci -nnv
```
Troubleshooting notes:

You can't use your initialising GPU for passthrough.

You need at least 2 graphics cards.

If you have additional devices in the IOMMU Group of your GPU and GPU audiocontroller, you need to install and configure the 
ACSO Kernel patch. Download precompiled Kernels with ACSO Patch: https://queuecumber.gitlab.io/linux-acs-override/

If you have an AM4 based system, you may have error 127 when you start a VM with gpu passthrough. You can prevent that with the Agesa Kernel Patch. The Agesa Kernel Patch https://clbin.com/VCiYJ by Reddit user Hansmoman https://www.reddit.com/r/VFIO/comments/bqeixd/apparently_the_latest_bios_on_asrockmsi_boards/eo4neta/ 

If you have an AMD GPU with GCN2 or higher, you may will have the restart bug, which doesn't allow you to restart your VM without a system reboot. You can prevent that with various Kernel Patches.

This script https://gist.github.com/mdPlusPlus/031ec2dac2295c9aaf1fc0b0e808e21a automatically compiles an Kernel with the ACSO Patch, Agesa Patch and Vega reset bug Patch.


