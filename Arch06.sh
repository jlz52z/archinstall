# Arch 06
# 发生错误时退出，将未设置的变量视为错误，防止管道错误掩盖
set -euo pipefail
# --- 核心检查 & 用户识别 ---
# 1. 确保以 root 身份运行
if [[ "$(id -u)" -ne 0 ]]; then
  echo "[ERROR] 必须使用 sudo 运行此脚本。" >&2
  exit 1
fi
# 2. 确定普通用户
REGULAR_USER="${SUDO_USER:-}"
if [[ -z "$REGULAR_USER" || "$REGULAR_USER" == "root" ]]; then
  # 基本回退 - 可能不适用于所有场景（例如，cron）
  REGULAR_USER=$(logname 2>/dev/null || who | awk 'NR==1{print $1}')
fi
if [[ -z "$REGULAR_USER" || "$REGULAR_USER" == "root" ]]; then
  echo "[ERROR] 无法确定要运行 AUR 命令的非 root 用户。" >&2
  exit 1
fi
echo "[INFO] 使用普通用户：$REGULAR_USER"
# --- 以普通用户身份运行命令的函数 ---
run_as_user() {
  sudo -u "$REGULAR_USER" bash -e -c "$@" # -e 确保子 shell 也在发生错误时退出
}
# --- 逻辑 ---
# 1. 检查并安装 yay
if command -v yay >/dev/null 2>&1; then
  echo "[INFO] yay 已经安装。"
else
  echo "[INFO] 未找到 yay。正在安装..."
  # 安装先决条件（以 root 身份）
  echo "[INFO] 正在安装 git 和 base-devel..."
  pacman -Syu --needed --noconfirm git base-devel
  # 构建并安装 yay（以普通用户身份）
  echo "[INFO] 正在以用户 $REGULAR_USER 身份构建 yay..."
  BUILD_DIR="/tmp/yay-build-$" # 使用唯一的临时目录
  run_as_user "
    mkdir -p '$BUILD_DIR' && cd '$BUILD_DIR'
    git clone --depth=1 https://aur.archlinux.org/yay.git .
    makepkg -si --noconfirm
  "
  # 清理构建目录（以 root 身份，因为如果 makepkg 早期失败，它可能包含 root 拥有的文件）
  rm -rf "$BUILD_DIR"
  if ! command -v yay >/dev/null 2>&1; then
     echo "[ERROR] yay 安装失败。" >&2
     exit 1
  fi
  echo "[INFO] yay 安装成功。"
fi
# 2. 检查并安装 shim-signed（使用 yay，以普通用户身份）
echo "[INFO] 正在检查 shim-signed..."
# 使用 run_as_user 执行 yay -Q
if run_as_user "yay -Q shim-signed" >/dev/null 2>&1; then
  echo "[INFO] shim-signed 已经安装。"
else
  echo "[INFO] 未找到 shim-signed。正在使用 yay 安装..."
  echo "[WARN] shim-signed 通常仅在启用安全启动时才需要。"
  # 使用 yay 以普通用户身份安装。此处预计会有用户交互（审查/确认）。
  # 仅当您了解风险并想要完全自动化时才添加 --noconfirm。
  run_as_user "yay -S --needed shim-signed"
  # 尝试安装后验证
  if ! run_as_user "yay -Q shim-signed" >/dev/null 2>&1; then
     echo "[ERROR] shim-signed 安装失败。" >&2
     exit 1
  fi
  echo "[INFO] shim-signed 安装成功。"
fi

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
