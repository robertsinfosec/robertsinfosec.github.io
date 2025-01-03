---
title: Patching and Updating Ubuntu
date: "2022-05-31 18:30"
categories: [Infrastructure, Maintenance]
tags: [homelab, ubuntu, infrastructure]
published: true
---

## Overview

It's important to keep your servers patched to the latest, stable version of software. Patching often is risky; patching rarely is risky. There will always be risk. However, Linux patching seems to be very, very stable. It's quite rare to run into an issue while upgrading software.

With that said, devise an upgrade scheme that is compatible with your risk tolerance. If you upgrade once per quarter, you could be going months with an unpatched, vulnerable machine. If you patch every day, you might have outages. So, decide what is right for you.

### Update Script
An easy script you can deploy to any Debian-based Linux distribution is this `update.sh`. Before running it, would be ideal to install two packages:

```bash
sudo apt update
sudo apt install figlet neofetch
```

**Figlet** is a tool that prints things in very big letters. This script will output the computer name in big letters. **Neofetch** is a utility that shows the operating system logo, and basic information about the current computer. 

> **Note:**
>  
> What this script does is:
> 
> - Refreshes the repository cache
> - Upgrades all upgradeable packages
> - Attempts upgrades for packages that have dependencies
> - Cleans up unused and cached packages
>  
> Then, it sees if a reboot is required, and prompts you if it is.
{: .prompt-info}


Consider copying the code below and save this as `/root/update.sh`. Then, mark it executable with:

```bash
sudo chmod +x /root/update.sh
```
This is an idempotent script, you can run it over-and-over without issue.

```bash
sudo /root/update.sh
```

#### File: `update.sh`
```bash
#!/bin/bash

Black='\033[0;30m'
DarkGray='\033[1;30m'
Red='\033[0;31m'
LightRed='\033[1;31m'
Green='\033[0;32m'
LightGreen='\033[1;32m'
Brown='\033[0;33m'
Yellow='\033[1;33m'
Blue='\033[0;34m'
LightBlue='\033[1;34m'
Purple='\033[0;35m'
LightPurple='\033[1;35m'
Cyan='\033[0;36m'
LightCyan='\033[1;36m'
LightGray='\033[0;37m'
White='\033[1;37m'
NC='\033[0m' # No Color

Name='Debian-based System Update Utility'
Version='v1.0.0-alpha.1'

function setXtermTitle () {

    newTitle=$1

    if [[ -z $newTitle ]]
    then
        case "$TERM" in
            xterm*|rxvt*)
                PS1="\[\e]0;$newTitle\u@\h: \w\a\]$PS1"
            ;;
            *)
            ;;
        esac
    else
        case "$TERM" in
            xterm*|rxvt*)
                PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
            ;;
            *)
            ;;
        esac
    fi
}

function setStatus(){

    description=$1
    severity=$2

    setXtermTitle $description

    logger "$Name $Version: [${severity}] $description"


    case "$severity" in
        s)
            echo -e "[${LightGreen}+${NC}] ${LightGreen}${description}${NC}"
        ;;
        f)
            echo -e "[${Red}-${NC}] ${LightRed}${description}${NC}"
        ;;
        q)
            echo -e "[${LightPurple}?${NC}] ${LightPurple}${description}${NC}"
        ;;
        *)
            echo -e "[${LightCyan}*${NC}] ${LightCyan}${description}${NC}"
        ;;
    esac

    [[ $WithVoice -eq 1 ]] && echo -e ${description} | espeak
}

function runCommand(){

    beforeText=$1
    afterText=$2
    commandToRun=$3

    setStatus "${beforeText}" "s"

    eval $commandToRun

    setStatus "$afterText" "s"

}

echo -e "${LightPurple}$Name $Version${NC}"


if [[ $1 == "?" || $1 == "/?" || $1 == "--help" ]];
then
    setStatus "USAGE: sudo $0" "i"
    exit -2
fi

if [[ $(whoami) != "root" ]];
then
    setStatus "ERROR: This utility must be run as root (or sudo)." "f"
    exit -1
fi

WithVoice=0

if [[ $WithVoice -eq 1 && ($(which espeak | wc -l) -eq 0) ]];
then
    setStatus "ERROR: To use speech, please install espeak (sudo apt-get install espeak)" "f"
    exit -1
elif [[ $WithVoice -eq 1 ]];
then
    setStatus "Voice detected - using espeak." "s"
fi

if [ $(which neofetch | wc -l) -gt 0 ];
then
    echo -e -n "${Yellow}"
    neofetch
    echo -e "${NC}"
fi

if [ $(which figlet | wc -l) -gt 0 ];
then
    echo -e -n "${Yellow}"
    echo $(hostname) | figlet
    echo -e "${NC}"
fi

setStatus "Update starting..." "s"

runCommand "STEP 1 of 4: Refreshing repository cache..." "Repository cache refreshed." "sudo apt-get update -y"
runCommand "STEP 2 of 4: Upgrading all existing packages..." "Existing packages upgraded." "sudo apt-get upgrade -y"
runCommand "STEP 3 of 4: Upgrading packages with conflict detection..." "Upgrade processed." "sudo apt-get dist-upgrade -y"
runCommand "STEP 4 of 4: Cleaning up unused and cached packages..." "Package cleanup complete." "sudo apt-get autoclean -y && sudo apt-get autoremove -y"

setStatus "Update complete." "s"

# if [ $(which rpi-update | wc -l) -gt 0 ]; then
#         echo -e "[${LightGreen}+${NC}] ${LightGreen}Raspberry Pi Detected.${NC}"
#         [[ $WithVoice -eq 1 ]] && echo -e "Raspberry Pi Detected." | espeak
#         echo -e "[${LightGreen}+${NC}] ${LightGreen}Updating the Raspberry Pi firmware to the latest (if available)...${NC}"
#         [[ $WithVoice -eq 1 ]] && echo -e "Updating the Raspberry Pi firmware to the latest." | espeak
#         sudo rpi-update
#         echo -e "[${LightGreen}+${NC}] ${LightGreen}Done updating firmware.${NC}"
#         [[ $WithVoice -eq 1 ]] && echo -e "Done updating firmware." | espeak
# fi


if [ -f /var/run/reboot-required ]; then
    setStatus "PLEASE NOTE: A reboot is required." "i"
    setStatus "Would you like to reboot now?" "?"
    [[ $WithVoice -eq 1 ]] && echo -e "Would you like to reboot now?" | espeak
    while true; do
        read -e -r -p "> " choice
        case "$choice" in
            y|Y )
                setStatus "Rebooting..." "i"
                sudo reboot
                break
            ;;
            n|N )
                setStatus "Done." "+"
                break
            ;;
            * )
                setStatus "Invalid response. Use 'y' or 'n'." "-"
            ;;
        esac
    done

else
    setStatus "No reboot is required." "i"
fi

setStatus "System update complete." "+"
```

### Update Script for Batch

Again, depending on your risk tolerance, this may not be an option for you. You can take that `update.sh` file, and modify from line 150-171, and make it so: if it needs a reboot, then you reboot it. If this update is running via batch process in the middle of the night, then it will have updated the OS and quietly rebooted when it's done.

If you would like to have functionality like this consider changing the `if..then` block at the end of the file to something like this:

```bash
if [ -f /var/run/reboot-required ]; then
    sudo reboot
else
    setStatus "No reboot is required." "i"
fi
```

Save that modified file as `/root/update-batch.sh`. Then, you can turn that into a regular batch job, via cron.

## Automating Upgrades

Whether you want to fully-upgrade your system on a regular basis, or if you just want to stay current with critical security updates, you should have some kind of upgrade automation in place. Below are some options.

### Using `unattended-upgrades`

On Ubuntu, if you install this package:

```bash
sudo apt update
sudo apt install unattended-upgrades
```

You can then configure your system to always stay updated with the latest security patches. You configure this by running:

```bash
sudo dpkg-reconfigure unattended-upgrades
```

That will show you a screen like this, where you can choose:

![Ubuntu Unattended Upgrades](/assets/img/ubuntu-unattended-upgrades.png)


### Using a `cron` job

If you created an `update-batch.sh` from the previous section, you can now run that on a regular basis. Edit your cron jobs by running:

```bash
sudo crontab -e
```

Then, add line like the following to run this job once per day at 8am:

```bash
# m     h       dom     mon     dow     command
  0     8       *       *       *       /root/update-batch.sh > /root/update-batch_lastrun.log 2>&1
```
To change the time frequency to something more tolerable, check out:

> **https://crontab.guru**

This website will help you figure out the correct crontab string to use, to represent the correct frequency that you want.


## OS Upgrades

Operating System (OS) upgrades tend to be more risky, and tend to break more things. Therefore, they should probably be scheduled. It would be ideal to have 1-2 backups on-hand too, in case you need to fully-recover.

On an Ubuntu-based system, you check-for, and also kick-off an operating system upgrade by running:

```bash
sudo do-release-upgrade
```

Then, follow the prompts.

> **Warning:** 
>  
> Please do make sure you have backups, and plan for the worst. If the operating system upgrade fails, it can leave everything on that server unusable. So, plan, prep, and schedule accordingly!
{: .prompt-warning}


## SSL Certificate Renewals

Assuming you are using `certbot` on  your web server as a way to provision and update your SSL certificates, you can simply run `certbot renew` on a regular basis. If checks locally if the certificates are close to expiring. If they are, they it reaches out to [LetsEncrypt](https://letsencrypt.org/) to renew them. Otherwise, the program exits.

To set up this auto-renewal, edit your cron jobs with: 

```bash
sudo crontab -e
```

And then add a command like this:

```bash
# m     h       dom     mon     dow     command
  0     0       *       *       SAT     certbot renew > /root/certbot_lastrun.log 2>&1
```

This will run this renewal process every Saturday at midnight (technically, Friday night). To change the time frequency to something else, check out:

> **https://crontab.guru**

This website will help you figure out the correct crontab string to use, to represent the correct frequency that you want. Thie `certbot` first only runs locally to see if the certificates are close to expiration. If they are not, it exits out - so there is not much harm in running this program on a regular basis.
