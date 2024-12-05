#Arch 02

pacstrap -K /mnt base linux linux-firmware

sleep 1

genfstab -U /mnt >> /mnt/etc/fstab

echo "Next is 03, run arch-chroot /mnt to enter the new system."
