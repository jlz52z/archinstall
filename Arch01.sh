# Arch 01

timedatectl set-ntp true

sleep 1

timedatectl set-timezone Asia/Shanghai

sleep 1

mkfs.ext4 /dev/sdb3

sleep 1

mkswap /dev/sdb2

sleep 1

mkfs.fat -F32 /dev/sdb1

sleep 1

mount /dev/sdb3 /mnt

sleep 1

mount --mkdir /dev/sdb1 /mnt/boot

sleep 1

swapon /dev/sdb2

sleep 1


curl -L "https://archlinux.org/mirrorlist/?country=CN&protocol=https" -o /etc/pacman.d/mirrorlist

sleep 1

echo "Next is 02, please remove the comments from /etc/pacman.d/mirrorlist."


