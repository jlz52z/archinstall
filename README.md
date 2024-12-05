首先进入LiveCD环境，对硬盘进行分区，这里我分了三个区：
1. EFI
2. swap
3. /

使用fdisk分区时记得使用`t`选项确定类型。

然后执行Arch01.sh

然后将/etc/pacman.d/mirrorlist中的注释给去掉

执行Arch02.sh，执行完后运行`arch-chroot /mnt`

然后执行Arch03.sh，执行完后编辑 `/etc/locale.gen`, 运行 `locale-gen`,  创建 `/etc/locale.conf`, 在里面添加 `LANG=en_US.UTF-8`

然后执行Arch04.sh，执行完后运行`visudo`赋予sudo权限，然后运行 `su - garinyan`

然后执行Arch05.sh，执行完后运行`exit`退出garinyan用户

然后执行Arch06.sh，执行完后重启即可

注意两点：
1. 执行完Arch04.sh后，可能要运行`source /etc/profile`
2. 执行完Arch06.sh后，可能要运行`grub-mkconfig -o /boot/grub/grub.cfg`


