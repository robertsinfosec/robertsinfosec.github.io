---
title: Install CentOS from ISO
date: "2022-05-31 22:22"
categories: [Installation Guides, Operating Systems]
tags: [homelab, virtualbox, centos, infrastructure, virtualization]
published: true
---

# Overview

There are several scenarios where you might run a server. In cases like cloud providers (e.g. Digital Ocean, Microsoft Azure, Amazon AWS, etc) - you typically just choose an OS option, and you get access to a server that is already installed.

However, if you are working on some hypervisors (e.g. ESXi, ProxMox, Microsoft Hyper-V Server, etc), or if you are installing Linux on bare metal (e.g. a physical computer) - you will need to install the operating system from scratch.

This page serves as a guide on how to install CentOS Linux (version 8 Stream, as of this writing), and explains what options you have during the install.

# Downloading an ISO

An `.iso` file is basically like a disc image. You can think of it like the contents of a DVD or a CD, but in a single file format. How this works is that you boot from these ISO files, and what ensues is an installer that walks you through the installation. To download the latest Ubuntu Server, navigate here:

> **[https://www.centos.org/download/](https://www.centos.org/download/)**
{: .prompt-info}

From this screen, as of this writing, choose: "x86_64" and download the "boot" image.

> **Tip:**
>  
> You will have the option to download CentOS 8 or CentOS Stream. CentOS 8 will be deprecated 12/31/2021. For a comparison and reason why there is a split, [see here](https://www.centos.org/cl-vs-cs/).
> 
> **As a general rule, install the latest CentOS Stream version that is available.**
{: .prompt-tip}

# Creating Physical Media

If you are installing Linux on a physical computer, you will probably want to boot from a DVD or USB thumb drive. 

## Creating a DVD Disc

The easiest of these methods is to create a bootable DVD. This requires a few things:

1. Your workstation, where you downloaded the `.iso` file, must have a DVD writer drive. You can [buy portable USB devices like this at office supply stores](https://www.staples.com/Transcend-TS8XDVDS-K-Black-USB-2-0-External-DVD-Writer/product_IM1RV9067).
1. You must have a writable DVD. You can buy these are office supply stores.
1. The server where Linux will be installed, must have a DVD drive, or you could use a USB, portable DVD drive.

This is called the easiest option because all you need to do is right-click on an `.iso` file, and choose "Burn disc image":

![burn-disc-image.png](/assets/img/centos-install-burn-disc-image.png)

## Creating a USB Thumb Drive (on Windows)

To create a bootable USB thumb drive you'll need an external tool. There are a few that will do the job, but we'll recommend Rufus:

> **[https://rufus.ie/en/](https://rufus.ie/en/)**
{: .prompt-info}

You can install the "portable" version. That is basically just a standalone `.exe` that doesn't need an installer. Download the file and run it. It will give you a User Access Control (UAC) prompt in Windows:

![rufus-uac-prompt.png](/assets/img/centos-install-rufus-uac-prompt.png)

Then, in the main window: point to your `.iso` file and point to your USB drive:

![rufus-create-usb.png](/assets/img/centos-install-rufus-create-usb.png)

Click "Start" and it will overwrite your USB device with the contents of the `.iso` file.

## Creating a USB Thumb Drive (on macOS or Linux)

To create a bootable URB thumb drive, your best option is to use `dd`. The syntax is something like this:

```bash
sudo dd if=./input of=./output status=progress
```

In this case, let's assume the input file is an `.iso` file in your `~/Downloads` folder, and your output is your USB thumb drive. You should be able to discern what the device name is from `lsblk` and/or `lsusb`. Assuming your thumb drive might be `/dev/sdb`, your command might be:

```bash
# WARNING: This is an example, make sure this is correct for your system.
#sudo dd if=~/Downloads/CentOS-Stream-8-x86_64-latest-boot.iso of=/dev/sdb status=progress
```

# Installation Steps

Put your installation media (the virtual `.iso` file, or the physical DVD, or USB device) into the machine. Then, boot the machine:

## Step 1: Launch screen

Use the <kbd>▲</kbd> key to choose Install, and then hit <kbd>Enter</kbd>.

![00.png](/assets/img/centos-install-00.png)

## Step 2: Choose language

Choose a language and click Continue.

![01.png](/assets/img/centos-install-01.png)

## Step 3: The ToDo List

The way this installer works is it won't let you continue until you address each section that has an alert next to it. So, click into each section, confirm your selections and click Done on each screen.

![02.png](/assets/img/centos-install-02.png)

## Step 4: Network configuration

If you click on the Network section, do two things on this page:

1. Set the "Host Name" in the bottom left to be whatever you want the server name to be.
1. Click the button in the top-right to toggle the network card into the "On" position, to enable the network card. You should see the IP address and other details fill in immediately.

Then, click the Done button in the top-left.

![03.png](/assets/img/centos-install-03.png)

## Step 5: Disk configuration

Unless you need to do something special, you don't need to do anything on this screen, just click the Done button in the top-left.

![04.png](/assets/img/centos-install-04.png)

## Step 6: Software selection

Unless something specific is needed, you can choose "Server" in the left list to install the bare minimum that you'll need for your server. Then, click the Done button in the top-left.

![05.png](/assets/img/centos-install-05.png)

## Step 7: Create an account

From the main screen scroll down. 

![06a.png](/assets/img/centos-install-06a.png)

Below the "Root Password" section (which can be ignored), this install does need you to create at least one user. So, click "User Creation". Fill out these details and choose to "Make this user administrator" (via `sudo`). Consider a name like `sysadmin` or `operations`, perhaps. When done, click the Done button in the top-left.

![06b.png](/assets/img/centos-install-06b.png)

## Step 8: Final checklist

When you come back to the main screen of the installer, there should be no more alerts, and the "Begin Installation" button should now be enable. Click: Begin Installation to start installing the operating system on this computer.

![07.png](/assets/img/centos-install-07.png)

## Step 9: Installation progress

You will now see some status and progress as the operating system is installed on your computer.

![08.png](/assets/img/centos-install-08.png)
![09.png](/assets/img/centos-install-09.png)

## Step 10: Reboot

After a bit, the installation is complete and you will be prompted to reboot:

![10.png](/assets/img/centos-install-10.png)

## Step 11: Initial Login

After rebooting, you will briefly see a boot prompt screen (the default entry boots in 5 seconds. Hit any key to interrupt the boot):

![11.png](/assets/img/centos-install-11.png)

Then, you see the default, initial login screen:

![12.png](/assets/img/centos-install-12.png)

## Step 12: Post-Login

After you login, there is no fanfare, you just get dropped at a Bash prompt. From here, you can start configuring your system:

![13.png](/assets/img/centos-install-13.png)
