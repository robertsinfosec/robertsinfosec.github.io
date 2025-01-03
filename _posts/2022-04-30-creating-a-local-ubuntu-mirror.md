---
title: Creating a Local Ubuntu Mirror
date: "2022-04-30 05:41"
categories: [Infrastructure, Homelab]
tags: [homelab, proxmox, ubuntu, infrastructure, virtualization, security]
---

## Overview

I almost exclusively use Ubuntu Server as my operating system of choice for everything. This is because there is broad support, it's super-stable, there is lots of engagement where people share solutions to problems, etc. In the end, it's just very reliable. When it's not reliable, it's super easy to get answers to questions.

### What is a mirror?

A *mirror* is generally where you have all of the software that is normally used on Ubuntu. For example if you want to install `apache2`, `nginx`, or `mysql-server`, those are "APT" packages stored on a mirror. What we're talking about here is setting up a mirror on your *own* network, and then periodically sync it. That means, all of your local servers could point to your internal mirror to stay updated or install new software.

A mirror can also be a repository where the installation media is stored. Meaning, the actual `.iso` files. Those only get updated a few times per year.

### The End Goal

The point of this concept is that you have the latest `.iso` images of the operating system, and the latest packages that are all synced regularly.

## Steps Involved

Below are the steps involved assuming you are starting from a freshly-update, empty, regular Ubuntu 22 or later server.

### STEP 1: Run script for initial setup

Below is a set of steps to be run from a `root` prompt to install software and configure directories.

```bash
echo "[*] Installing apache2"
apt install apache2 -y

echo "[*] Enabling apache2 on startup"
systemctl enable apache2

echo "[*] Making directories and setting permissions"
mkdir -p /opt/apt-mirror
chown www-data:www-data /opt/apt-mirror

echo "[*] Installing apt-mirror"
apt install apt-mirror -y
apt update

echo "[*] Backing up /etc/apt/mirror.list"
cp /etc/apt/mirror.list /etc/apt/mirror.list.bak

echo "[*] Making var folder"
mkdir -p /opt/apt-mirror/ubuntu/var

echo "[*] Copying post script into place"
cp /var/spool/apt-mirror/var/postmirror.sh /opt/apt-mirror/ubuntu/var/

echo "[*] Done. Modify 'nano /etc/apt/mirror.list' to your liking"
# TODO:
# nano /etc/apt/mirror.list
# nano /etc/apache2/sites-enabled/000-default.conf
```

### STEP 2: Configure `/etc/apt/mirror.list`
Modify `/etc/apt/mirror.list` with a couple of notable changes. Below is an example file:

```bash
############# config ##################
#
set base_path    /opt/apt-mirror
#
# set mirror_path  $base_path/mirror
# set skel_path    $base_path/skel
# set var_path     $base_path/var
# set cleanscript $var_path/clean.sh
# set defaultarch  <running host architecture>
# set postmirror_script $var_path/postmirror.sh
# set run_postmirror 0
set nthreads     4
set _tilde 0
#
############# end config ##############

###### UBUNTU ######
### Ubuntu Jammy Jellyfish 22.04
deb http://archive.ubuntu.com/ubuntu jammy main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu jammy-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse

### Ubuntu Focal 20.04
deb http://archive.ubuntu.com/ubuntu focal main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu focal-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu focal-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu focal-backports main restricted universe multiverse

### Ubuntu Bionic 18.04
deb http://archive.ubuntu.com/ubuntu bionic main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu bionic-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu bionic-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu bionic-backports main restricted universe multiverse

### Ubuntu Xenial 16.04
deb http://archive.ubuntu.com/ubuntu xenial main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu xenial-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu xenial-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu xenial-backports main restricted universe multiverse

clean http://archive.ubuntu.com/ubuntu

###### DEBIAN ######
### Debian 11 Bullseye (Aug 2021)
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://security.debian.org/debian-security/ bullseye-security main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
deb http://deb.debian.org/debian bullseye-backports main contrib non-free
deb-armhf http://deb.debian.org/debian bullseye main contrib non-free
deb-armhf http://security.debian.org/debian-security/ bullseye-security main contrib non-free
deb-armhf http://deb.debian.org/debian bullseye-updates main contrib non-free
deb-armhf http://deb.debian.org/debian bullseye-backports main contrib non-free

### Debian 10 Buster (July 2019)
deb http://deb.debian.org/debian buster main contrib non-free
deb http://security.debian.org/debian-security/ buster/updates main contrib non-free
deb http://deb.debian.org/debian buster-updates main contrib non-free
deb http://deb.debian.org/debian buster-backports main contrib non-free
deb-armhf http://deb.debian.org/debian buster main contrib non-free
deb-armhf http://security.debian.org/debian-security/ buster/updates main contrib non-free
deb-armhf http://deb.debian.org/debian buster-updates main contrib non-free
deb-armhf http://deb.debian.org/debian buster-backports main contrib non-free

clean http://deb.debian.org/debian

###### KALI ######
deb http://http.kali.org/kali kali-rolling main non-free contrib
```

## Configure Apache

I ultimately want to be able to point my internal machines to similar URLs as the real-thing, like: `http://mirror.lab.example.com/ubuntu`. So, I need to offer those directories under `/opt/apt-mirror` under the root of the website at `/var/www/html`. After a fair bit of trial-and-error, I created "symlinks", or symbolic links like this, assuming you have the same `/etc/apt/mirrors.list` file as above:

```bash
# From the /var/www/html/ folder:

ln -s /opt/apt-mirror/mirror/deb.debian.org/debian/ ./debian
ln -s /opt/apt-mirror/mirror/deb.debian.org/debian-security/ ./debian-security
ln -s /opt/apt-mirror/mirror/http.kali.org/kali/ ./kali
ln -s /opt/apt-mirror/mirror/archive.ubuntu.com/ubuntu/ ./ubuntu
```

## Configure the Clients

That allows for an `/etc/apt/sources.list` to look like the following on your client machines:

### Ubuntu

Change `jammy` to whichever other distribution you need, and that you are currently mirroring (as defined in the `/etc/apt/mirrors.list`, above):

```bash
deb http://mirror.lab.example.com/ubuntu jammy main restricted universe multiverse
deb http://mirror.lab.example.com/ubuntu jammy-updates main restricted universe multiverse
deb http://mirror.lab.example.com/ubuntu jammy-security main restricted universe multiverse
deb http://mirror.lab.example.com/ubuntu jammy-backports main restricted universe multiverse
```

### Debian

Change `bullseye` to whichever other distribution you need, and that you are currently mirroring (as defined in the `/etc/apt/mirrors.list`, above):

```bash
deb http://mirror.lab.example.com/debian bullseye main restricted universe multiverse
deb http://mirror.lab.example.com/debian bullseye-updates main restricted universe multiverse
deb http://mirror.lab.example.com/debian-security bullseye-security main restricted universe multiverse
deb http://mirror.lab.example.com/debian bullseye-backports main restricted universe multiverse
```

> **Note:** I got `bullseye` working, but the previous version `buster` was a little flaky. I think it was at that version that they switched some things in these mirrors. I could not get ANY of the previous versions working, using this same technique.
{: .prompt-info }

### Raspberry Pi

This assumes you are running the latest `bullseye` version and not any other OS.

> **Note:** The reason this works is because note in the `/etc/apt/mirrors.list` file above, we retrieve the `deb-armhf` architecture files in addition to the default `amd64`
{: .prompt-info }

```bash
deb http://mirror.lab.example.com/debian bullseye main contrib non-free
deb http://mirror.lab.example.com/debian-security bullseye-security main contrib non-free
deb http://mirror.lab.example.com/debian bullseye-updates main contrib non-free
```

## Set the Schedule

Back on the mirror server, from everything I could tell, it is reasonable to run this sync job twice per day. So, mine run at 1am and 1pm, and typically just run for a few minutes.

```bash
#       m       h       dom     mon     dow     command
        0       1,13    *       *       *       /usr/bin/apt-mirror > /root/apt-mirror_lastrun.log 2>&1
```

## Syncing Other Mirrors

Internally, you likely have at least one other "backup" mirror server. It's wasteful for this second machine to also kill those Internet servers to get a second copy of the mirror. It's wasteful to them, eats up your bandwidth, and is slow.

Instead, you should just have your backup server(s) copy from the primary on a regular basis. How I did this was by "pulling" the content from the primary, to the secondary server. So, on the *secondary* server, I have a bash script called `sync-content.sh` that looks like this:

```bash
#!/bin/bash

echo "[*] Syncing content from mirror01"
rsync -arvzh -e 'ssh -p 22' --progress \
    sysadmin@mirror01.lab.example.com:/opt/apt-mirror/ \
    /opt/apt-mirror/ --delete-before
```

This will do an effecient sync between the two servers. The `--delete-before` deletes any local files, first, which no longer exist on the source server. Practically, as "apt" packages expire, they are removed. So, you'd want to remove those from your repository also.

Next, I have a cron job that runs every 2 hours at :30 minutes past the hour, which goes and makes sure this server is in-sync. In my observations, the syncing on the primary server took seconds to maybe several minutes, depending on what is new. So this waits until :30 minutes have passed, and then syncs it. The other iterations are just in case something was missed. Rsync runs in seconds if it verifies that everything is already synced. Here is the cron job definition:

```bash
#       Min     Hour    DoM     Month   DayOfWeek       Command
        30      */2     *       *       *       /root/sync-content.sh > /root/sync-contents_lastrun.log 2>&1
```

## Resources

This information is mostly put together from this site:

> **[https://linuxconfig.org/how-to-create-a-ubuntu-repository-server](https://linuxconfig.org/how-to-create-a-ubuntu-repository-server)**