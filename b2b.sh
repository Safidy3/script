#!/bin/bash

# this script needs to be run with 'su -' in debian 11
password="XOu7E4fL2M"

# sudo
if ! apt-get install sudo; then
    echo "Failed to install OpenSSH server."
    exit 1
fi

# SSH
ssh_conf='/etc/ssh/sshd_config'
if ! apt-get install -y openssh-server; then
    echo "Failed to install OpenSSH server."
    exit 1
fi
sed -i 's/#Port 22/Port 4242/;s/#PermitRootLogin prohibit-password/PermitRootLogin no/' "$ssh_conf"
systemctl restart ssh
systemctl enable ssh

# UFW
if ! apt-get install -y ufw; then
    echo "Failed to install ufw."
    exit 1
fi
ufw allow 4242
ufw enable
systemctl start ufw

# HOSTNAME
hostnamectl set-hostname safandri42

# PASSWORD RULE
login_defs="/etc/login.defs"
sed -i '/^PASS_MAX_DAYS[[:space:]]*[0-9]*/s/[0-9]\+$/30/' "$login_defs"
sed -i '/^PASS_MIN_DAYS[[:space:]]*[0-9]*/s/[0-9]\+$/2/' "$login_defs"

if ! apt-get install -y libpam-pwquality; then
    echo "Failed to install libpam-pwquality."
    exit 1
fi
password_path="/etc/pam.d/common-password"
old_rule=$(grep 'pam_pwquality.so' "$password_path")
new="password requisite pam_pwquality.so retry=3 minlen=10 ucredit=-1 dcredit=-1 maxrepeat=3 reject_username enforce_for_root difok=7"
if [ -z "$old_rule" ]; then
  echo "No existing pam_pwquality.so rule found." >&2
  exit 1
fi
printf '%s\n' "s/${old_rule}/${new}/" | sed -i -f- "$password_path"

# NEW USER
groupadd user42
usermod -aG sudo,user42 safandri

# SUDO CONFIGURATION
custom_sudo_conf="/etc/sudoers.d/local_sudo_conf"
mkdir /var/log/sudo
touch /var/log/sudo/sudo.log
echo 'Defaults	passwd_tries=3
Defaults	badpass_message="Diso password !"
Defaults	requiretty
Defaults	log_input, log_output
Defaults	logfile=/var/log/sudo/sudo.log
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"' > $custom_sudo_conf
chmod 440 $custom_sudo_conf

chmod +x monitoring.sh
path=$(pwd)
cron_schedule="*/10 * * * *"
echo "$cron_schedule sh $path/monitoring.sh" | crontab -
