pacman -S --needed base base-devel intel-ucode lvm2 mdadm linux-firmware sof-firmware linux-firmware-marvell broadcom-wl networkmanager wpa_supplicant modemmanager nano neovim man-db man-pages texinfo xfsprogs btrfs-progs dosfstools ntfs-3g

sleep 1

systemctl enable NetworkManager

sleep 1

systemctl enable wpa_supplicant

sleep 1

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

sleep 1

hwclock --systohc

sleep 1

echo "Next is 04, please edit /etc/locale.gen, run locale-gen, and create /etc/locale.conf, adding LANG=en_US.UTF-8."
