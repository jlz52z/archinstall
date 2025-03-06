mkfs.fat -F32 /dev/sdb3
mkfs.btrfs -L arch /dev/sdb4

# 挂载Btrfs分区
mount /dev/sdb4 /mnt
# 创建子卷
btrfs subvolume create /mnt/@        # 系统根
btrfs subvolume create /mnt/@home    # 用户目录
btrfs subvolume create /mnt/@log     # 日志目录（建议加@前缀保持命名规范）
btrfs subvolume create /mnt/@pkg     # 软件包缓存

umount /mnt

mount -o subvol=@,compress=zstd /dev/sdb4 /mnt
mkdir -p /mnt/{home,var/log,var/cache/pacman/pkg}
mount -o subvol=@home /dev/sdb4 /mnt/home
mount -o subvol=@log,noatime /dev/sdb4 /mnt/var/log
mount -o subvol=@pkg,nodatacow /dev/sdb4 /mnt/var/cache/pacman/pkg

mount --mkdir /dev/sdb3 /mnt/boot
