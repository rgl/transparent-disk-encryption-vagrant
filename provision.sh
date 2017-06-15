#!/bin/bash
set -eux

dmi_sys_vendor=$(cat /sys/devices/virtual/dmi/id/sys_vendor)
if [ "$dmi_sys_vendor" == 'QEMU' ]; then
    encrypted_disk_device='/dev/vdb'
else
    encrypted_disk_device='/dev/sdb'
fi
encrypted_disk_passphrase='passphrase'
encrypted_disk_mapper_device_name='encrypted'

# configure apt for non-interactive mode.
export DEBIAN_FRONTEND=noninteractive

# install vim.
apt-get install -y --no-install-recommends vim
cat >/etc/vim/vimrc.local <<'EOF'
syntax on
set background=dark
set esckeys
set ruler
set laststatus=2
set nobackup
EOF

# configure the shell.
cat >/etc/profile.d/login.sh <<'EOF'
[[ "$-" != *i* ]] && return
export EDITOR=vim
export PAGER=less
alias l='ls -lF --color'
alias ll='l -a'
alias h='history 25'
alias j='jobs -l'
EOF

cat >/etc/inputrc <<'EOF'
set input-meta on
set output-meta on
set show-all-if-ambiguous on
set completion-ignore-case on
"\e[A": history-search-backward
"\e[B": history-search-forward
"\eOD": backward-word
"\eOC": forward-word
EOF

# install cryptsetup.
apt-get install -y cryptsetup
cryptsetup --version

# make sure nothing is mis-interpreted on the device we are storing the luks container.
wipefs -a $encrypted_disk_device

# create the luks container (aka luks partition).
# WARN this uses a LOW static iteration time of 10ms.
#      you MUST adapt this to your purposes (e.g. 15000ms)!
echo -n "$encrypted_disk_passphrase" | cryptsetup luksFormat --batch-mode --key-file - --iter-time 10 $encrypted_disk_device

# backup the luks container header.
# NB you need to store this somewhere outside of the machine, in a secure location.
cryptsetup luksHeaderBackup --header-backup-file "$encrypted_disk_mapper_device_name-luks-header.backup" $encrypted_disk_device

# map/unlock/open the container at /dev/mapper/encrypted.
echo -n "$encrypted_disk_passphrase" | cryptsetup luksOpen --batch-mode --key-file - $encrypted_disk_device $encrypted_disk_mapper_device_name

# show information about the container crypto settings.
cryptsetup luksDump $encrypted_disk_device

# show information about the device.
blkid -p $encrypted_disk_device
lsblk -p $encrypted_disk_device

# show the low-level dm-crypt information of the opened luks container
# NB this also shows the **plain-text** master key.
dmsetup table --target crypt --showkey $encrypted_disk_mapper_device_name

# format the file-system inside the container.
mkfs.ext4 /dev/mapper/$encrypted_disk_mapper_device_name

# mount the file-system.
mkdir -p /mnt/$encrypted_disk_mapper_device_name
mount /dev/mapper/$encrypted_disk_mapper_device_name /mnt/$encrypted_disk_mapper_device_name

# write something to the encrypted file-system/disk.
echo hello world >/mnt/$encrypted_disk_mapper_device_name/message.txt

# unmount it.
umount /mnt/$encrypted_disk_mapper_device_name
cryptsetup luksClose $encrypted_disk_mapper_device_name

# mount it again.
echo -n "$encrypted_disk_passphrase" | cryptsetup luksOpen --batch-mode --key-file - $encrypted_disk_device $encrypted_disk_mapper_device_name
mount /dev/mapper/$encrypted_disk_mapper_device_name /mnt/$encrypted_disk_mapper_device_name
