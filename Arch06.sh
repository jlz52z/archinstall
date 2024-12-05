# Arch 04

pacman -S grub efibootmgr 

sleep 1

BASIC_MODULES="all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat
 font gettext gfxmenu gfxterm gfxterm_background gzio halt help hfsplus iso9660 jpeg 
 keystatus loadenv loopback linux ls lsefi lsefimmap lsefisystab lssal memdisk minicmd
 normal ntfs part_apple part_msdos part_gpt password_pbkdf2 png probe read reboot regexp
 search search_fs_uuid search_fs_file search_label sleep smbios squash4 test true video
 xfs zfs zstd zfscrypt zfsinfo cpuid play tpm usb"
 
GRUB_MODULES="$BASIC_MODULES cryptodisk crypto gcry_arcfour gcry_blowfish gcry_camellia
 gcry_cast5 gcry_crc gcry_des gcry_dsa gcry_idea gcry_md4 gcry_md5 gcry_rfc2268 gcry_rijndael
 gcry_rmd160 gcry_rsa gcry_seed gcry_serpent gcry_sha1 gcry_sha256 gcry_sha512 gcry_tiger 
 gcry_twofish gcry_whirlpool luks lvm mdraid09 mdraid1x raid5rec raid6rec"
 
sudo grub-install --target=x86_64-efi --efi-directory=/boot \
    --bootloader-id=ARCH --modules="${GRUB_MODULES}" \
    --sbat /usr/share/grub/sbat.csv

sleep 1

cp /usr/share/shim-signed/shimx64.efi /boot/EFI/ARCH/BOOTX64.EFI

cp /usr/share/shim-signed/mmx64.efi /boot/EFI/ARCH/

efibootmgr --unicode --disk /dev/sdb --part 1 --create --label "Shim" --loader /EFI/ARCH/BOOTX64.EFI

sleep 1

pacman -S sbsigntools

sleep 1

mkdir /boot/keys

openssl req -newkey rsa:4096 -nodes -keyout /boot/keys/MOK.key -new -x509 -sha256 -days 3650 -subj "/CN=my Machine Owner Key/" -out /boot/keys/MOK.crt

sleep 1

openssl x509 -outform DER -in /boot/keys/MOK.crt -out /boot/keys/MOK.cer

mkdir /etc/secureboot

cp /boot/keys/* /etc/secureboot/

mkdir /boot/unsigned

cp /boot/vmlinuz-linux /boot/unsigned

mkdir /boot/EFI/ARCH/unsigned

cp /boot/EFI/ARCH/grubx64.efi /boot/EFI/ARCH/unsigned/grubx64.efi 

sbsign --key /boot/keys/MOK.key --cert /boot/keys/MOK.crt --output /boot/vmlinuz-linux /boot/vmlinuz-linux

sleep 1

sbsign --key /boot/keys/MOK.key --cert /boot/keys/MOK.crt --output /boot/EFI/ARCH/grubx64.efi /boot/EFI/ARCH/grubx64.efi

grub-mkconfig -o /boot/grub/grub.cfg

sleep 1

echo "Next, please reboot."