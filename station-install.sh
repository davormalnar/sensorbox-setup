#!/bin/bash
MY_PATH=$(dirname "$0")
MY_PATH=$(cd "$MY_PATH" && pwd)

#
# bash profile and aliases
#

BASH_ALIASES="$MY_PATH/files/bash_aliases"
BASH_PROFILE="$MY_PATH/files/bash_profile"

echo -e "-> adding bash profile\n"

if [ -f "$BASH_ALIASES" ]; then
    if [ -f "$HOME/.bash_aliases" ]; then
        mv $HOME/.bash_aliases $HOME/.bash_aliases.old
    fi

    mv $BASH_ALIASES $HOME/.bash_aliases
fi

if [ -f "$BASH_PROFILE" ]; then
    if [ -f "$HOME/.bash_profile" ]; then
        mv $HOME/.bash_profile $HOME/.bash_profile.old
    fi

    mv $BASH_PROFILE $HOME/.bash_profile
fi


# reloading bash
source $HOME/.bashrc

#
# lets configure RPi
#


echo -e "-> setting up timezone \n"
read -e -p "Please enter your timezone (default): " -i "Europe/Zagreb" TIMEZONE
sudo timedatectl set-timezone $TIMEZONE

# lets restart cron so that the tasks we schedule will be set for the appropriate timezone
echo -e "\n-> restarting cron service \n"
sudo service cron restart

echo -e "-> enabling SSH\n"
sudo raspi-config nonint do_ssh 0

echo -e "-> enabling I2C\n"
sudo raspi-config nonint do_i2c 0 #temp

echo -e "-> enabling Serial\n"
sudo raspi-config nonint do_serial 0 #aqi

#
# lets change default sensorbox port
#

echo -e "-> changing ssh port\n"

read -ep "Please enter new ssh port: " sshPort
while [[ $sshPort -lt 1024 || $sshPort -gt 65536 ]]; do
  echo -e "Please enter port between 1024 and 65536\n"
  read -ep "Please enter new ssh port: " sshPort
done

echo -e "\n#Sensorbox ssh port \nPort $sshPort \n\n" | sudo tee -a /etc/ssh/sshd_config > /dev/null

echo -e "-> restarting ssh service\n"
sudo service ssh restart

#
# changing default password
#

echo -e "-> changing default password for user pi\n"
sudo passwd

#
# updates package list and install updates
#

echo -e "-> update & upgrade\n"
sudo apt update -y && sudo apt upgrade -y

echo -e "-> installing necessary packages\n"
sudo apt install python3-pip i2c-tools python3-smbus neofetch git screen uptimed dnsutils speedtest-cli

echo -e "-> installing necessary python libs\n"
sudo pip3 install pyserial smbus meteocalc pyyaml pyjwt requests

#
# create sensorbox folder and fetch scripts
#

echo -e "-> fetching GIT repo\n"
cd $HOME

if [ -d "sensorbox-station" ]; then
  echo -e "sensorbox station already exists; pulling latest version from github\n"
  cd sensorbox-station
  git pull
else
  git clone https://github.com/davormalnar/sensorbox-station.git
fi


#
# wifi configuration
#

configFile="/etc/wpa_supplicant/wpa_supplicant.conf"

add_wifi () {
sudo echo """
network={
        ssid=\"$1\"
        psk=\"$2\"
}""" >> $configFile

echo -e "\nAdded wifi config entry"
}

prompt_wifi () {
        read -p "Please enter WiFi SSID: " ssid
        read -p "Please enter WiFi Password: " psk
        add_wifi $ssid $psk
        another=" another"
}

# --------- wifi configuration ---------
another=""
while true; do
    echo -e "\n"
    read -p "Would you like to add$another WiFi config? (y/n) " yn
    case $yn in
        [Yy]* ) prompt_wifi ;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done


#
# crontab entries and prompting for user response
#

# weekly update & upgrade ?
while true; do
    read -p "(crontab entry) Do you want to enable weekly update&upgrade of RPi ? (y/n) " yn
    case $yn in
        [Yy]* ) (sudo crontab -l | grep 'update') || { sudo crontab -l; echo "5 6 * * 0 $HOME/sensorbox-station/scripts/update"; } | sudo crontab - ; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# sensorbox autostart ?
while true; do
    read -p "(crontab entry) Do you want to enable auto-start of sensorbox ? (y/n) " yn
    case $yn in
        [Yy]* ) (crontab -l | grep 'sensorbox-station/start') || { crontab -l ; echo "@reboot $HOME/sensorbox-station/start" ; } | crontab - ; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# IP change notifications ?
while true; do
    read -p "(crontab entry) Do you want to receive network IP-change notification on telegram (useful on headless + WiFi)? (y/n) " yn
    case $yn in
        [Yy]* ) (crontab -l | grep 'checkNetworkChange') || { crontab -l; echo "* * * * * $HOME/sensorbox-station/scripts/checkNetworkChange"; } | crontab - ; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# bi-daily status notifications
while true; do
    read -p "(crontab entry) Do you want to receive bi-daily air quality and temperature notifications on telegram ? (y/n) " yn
    case $yn in
        [Yy]* ) (crontab -l | grep 'notifyAll.py') || { crontab -l; echo "5 9,17 * * * $HOME/sensorbox-station/scripts/notifyAll.py"; } | crontab - ; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done


# --------- reboot and done ---------
echo -e "\n----------------\n\nWe're all done with the instalation.\n\n"
while true; do
    read -p "You should reboot your station before proceeding! Do you want to reboot now? (y/n) " yn
    case $yn in
        [Yy]* ) sudo reboot ; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

