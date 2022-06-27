# Sensorbox station installer / setup #

This is a setup script for **[Sensorbox station](https://github.com/davormalnar/sensorbox-station)** for Raspberry Pi.

## How to install ? ###

* fetch install script and extract it:
    * `wget https://github.com/davormalnar/sensorbox-setup/archive/refs/tags/install.tar.gz -O sensorbox-install.tar.gz && tar -xzf sensorbox-install.tar.gz -C $HOME/`


* run the script with (**non root** privileges)
    * `bash $HOME/sensorbox-setup-install/station-install.sh`

Sensorbox station will be installed to a default (recommended) home path of a RaspberryPi OS: `/home/pi/sensorbox-station`

For more instruction on how to run and/or use Sensorbox-station please check project's [Github page](https://github.com/davormalnar/sensorbox-station).

### The script configures and sets up following:

* adds new bash profile and [aliases](https://github.com/davormalnar/sensorbox-setup/blob/main/files/bash_aliases)
* enables SSH, sets new password and changes default SSH port
* enables I2C and Serial
* performs RPi update & upgrade
* installs necessary and useful packages: `python3-pip i2c-tools python3-smbus neofetch git screen uptimed dnsutils speedtest-cli`
* installs necessary Python libraries `pyserial smbus pymongo meteocalc pyyaml`
* fetches [Sensorbox station](https://github.com/davormalnar/sensorbox-station) script
* adds new WiFi entries to `wpa_supplicant` configuration (optional)
* adds crontab entries (optional) for:
  * periodic system update & upgrade
  * Sensorbox-station auto-start
  * network IP-change notification (useful for RPi headless configuration) (&ast;)
  * bi-daily air quality and temperature notifications (&ast;)

*(&ast;) notifications will be sent through Telegram bot API so Telegram configuration is necessary for Sensorbox-station*

### Tested Raspberry Pi versions ###

* Raspberry Pi 2/3/4 model B
* Raspberry Pi 1 model B (without camera feed)


    
