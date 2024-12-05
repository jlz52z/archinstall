echo "YanjysARCH" > /etc/hostname

sleep 1

echo "Input ROOT password"

sleep 1

passwd

sleep 1

# Add new user
sudo useradd -m garinyan

# Set user password
echo "Please set a password for user garinyan:"
sudo passwd garinyan

# Optionally add user to sudo group
sudo usermod -aG wheel garinyan

echo "User garinyan has been successfully created!"

echo "export EDITOR=nvim" | sudo tee -a /etc/profile
echo "export VISUAL=nvim" | sudo tee -a /etc/profile
source /etc/profile

echo "Next is 05, please use visudo to add sudo privileges and run su - garinyan."
