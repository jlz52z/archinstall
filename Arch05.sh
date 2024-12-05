cd

sudo pacman -S --needed git

sleep 1

git clone https://aur.archlinux.org/yay.git

cd yay

makepkg -si

yay -S shim-signed

echo "Next is 06, please exit"
