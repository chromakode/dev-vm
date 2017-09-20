#!/bin/sh

# `ubuntu` this is the default on the ubuntu cloud images
USER=ubuntu

# ensure it exists and has the correct permissions
mkdir /mnt/shared-host /mnt/shared-local /mnt/shared-work /mnt/shared
chown ubuntu:ubuntu /mnt/shared-local /mnt/shared-work /mnt/shared

# add 9p to initrd so mountall can mount these filesystems early on during boot
cat <<END >> /etc/initramfs-tools/modules
9p
9pnet
9pnet_virtio
END
update-initramfs -u

# set up the fstab entries for the passthrough and overlay filesystems
cat <<END >> /etc/fstab
src-passthrough /mnt/shared-host 9p ro,trans=virtio,version=9p2000.L 0 0
overlay /mnt/shared overlay lowerdir=/mnt/shared-host,upperdir=/mnt/shared-local,workdir=/mnt/shared-work 0 0
END

# mount them right now
mount /mnt/shared-host
mount /mnt/shared
