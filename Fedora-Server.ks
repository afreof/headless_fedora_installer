# System authorization information
auth --enableshadow --passalgo=sha512

# Install OS instead of upgrade
install

# Use text mode install
text
# Use graphical install
# graphical
# vnc --password=blabla


# Run the Setup Agent on first boot
firstboot --enable
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch

# For development and testing environment: use enp1s0 and VLANs
# Configure the WAN connection (server is as a router to the productive network for internet access on dev LAN)
#   Note: gets 99.2 assigned based on MAC address, default route
#   If sata adapter is plugged: enp2s0, enp3s0, enp4s0
network --device=enp2s0 --bootproto=dhcp --activate
# Configure a development LAN on VLAN 98
# network --device=enp2s0 --vlanid=98 --bootproto=static --ip=192.168.98.2 --netmask=255.255.255.0 --onboot=yes --nodefroute --activate
# hostname
network --hostname=host.example.com

# Firewall setup with salt
firewall --enabled

# SELinux configuration
selinux --enforcing
# selinux --permissive

# System timezone
timezone Europe/Zurich --isUtc

# System bootloader configuration
# Tip: Replace /dev/sd. with /dev/disk/by-id/...
bootloader --location=mbr --boot-drive=/dev/sda
# Partition clearing information
clearpart --all --initlabel --drives=/dev/sda,/dev/sdb,/dev/sdc,/dev/sdb,/dev/sdd
# Disk partitioning information
part swap --fstype="swap" --ondisk=/dev/sda --size=3969
part btrfs.01 --fstype="btrfs" --ondisk=/dev/sda --grow
part /boot --fstype="ext4" --ondisk=/dev/sda --size=500
btrfs none --label=fedora btrfs.01
btrfs / --subvol --name=root LABEL=fedora

# BTRFS RAID 1 for data consisting of 3 disks
part btrfs.02 --grow --ondisk=/dev/sdb
part btrfs.03 --grow --ondisk=/dev/sdc
part btrfs.04 --grow --ondisk=/dev/sdd
btrfs none --data=1 --metadata=1 --label=datadisk1 btrfs.02 btrfs.03 btrfs.04
btrfs /home --subvol --name=home datadisk1
btrfs /shares --subvol --name=shares datadisk1


# user setup
rootpw "pcengines"

# Do not configure the X Window System
skipx

# Stop qemu after installation, this allows to restart
poweroff


%post --log=/root/anaconda-post.log

# # Create the SSH authorized_keys file
# mkdir /root/.ssh
# chmod 700 /root/.ssh
# cat  << xxEOFxx >> /root/.ssh/authorized_keys
# your public key...
# xxEOFxx
# chmod 600 /root/.ssh/authorized_keys
# # SE Linux blocks the key based authentication
# restorecon -Rv /root/.ssh/

%end

%packages
@^server-product-environment
setools-console
usbutils
pciutils
smartmontools
tmux
vim-enhanced
iotop
htop
bash-completion
%end

%addon com_redhat_kdump --disable --reserve-mb='128'

%end

