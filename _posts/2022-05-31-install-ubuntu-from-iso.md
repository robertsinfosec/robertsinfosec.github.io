---
title: Install Ubuntu from ISO
date: "2022-05-31 20:13"
categories: [Installation Guides, Operating Systems]
tags: [homelab, virtualbox, ubuntu, infrastructure, virtualization]
published: true
---

# Overview

There are several scenarios where you might run a server. In cases like cloud providers (e.g. Digital Ocean, Microsoft Azure, Amazon AWS, etc) - you typically just choose an OS option, and you get access to a server that is already installed.

However, if you are working on some hypervisors (e.g. ESXi, ProxMox, Microsoft Hyper-V Server, etc), or if you are installing Linux on bare metal (e.g. a physical computer) - you will need to install the operating system from scratch.

This page serves as a guide on how to install Ubuntu Linux (version 21.04, as of this writing), and explains what options you have during the install.

# Downloading an ISO

An `.iso` file is basically like a disc image. You can think of it like the contents of a DVD or a CD, but in a single file format. How this works is that you boot from these ISO files, and what ensues is an installer that walks you through the installation. To download the latest Ubuntu Server, navigate here:

> **[https://ubuntu.com/download/server](https://ubuntu.com/download/server)**
{: .prompt-info}

From this screen, as of this writing, choose: "Manual Server Installation"

> **Tip:**
>  
> You will have the option to download a Long Term Support (LTS) version, or the very latest version. The LTS version is considered a very stable release, where there will be widespread support by vendors, and layered products that you might install.
> 
> Conversely, if you install the very latest, some vendors won't fully support it yet. Or, you may go to install software, and it won't have support for your version of software.
> 
> **As a general rule, install the the most-recent "LTS" version that is available.**
{: .prompt-tip}

# Creating Physical Media

If you are installing Linux on a physical computer, you will probably want to boot from a DVD or USB thumb drive. 

## Creating a DVD Disc

The easiest of these methods is to create a bootable DVD. This requires a few things:

1. Your workstation, where you downloaded the `.iso` file, must have a DVD writer drive. You can [buy portable USB devices like this at office supply stores](https://www.staples.com/Transcend-TS8XDVDS-K-Black-USB-2-0-External-DVD-Writer/product_IM1RV9067).
1. You must have a writable DVD. You can buy these are office supply stores.
1. The server where Linux will be installed, must have a DVD drive, or you could use a USB, portable DVD drive.

This is called the easiest option because all you need to do is right-click on the `.iso` file, and choose "Burn disc image":

![ubuntu-install-burn-disc-image.png](/assets/img/ubuntu-install-burn-disc-image.png)

## Creating a USB Thumb Drive (on Windows)

To create a bootable USB thumb drive you'll need an external tool. There are a few that will do the job, but we'll recommend Rufus:

> **[https://rufus.ie/en/](https://rufus.ie/en/)**
{: .prompt-info}

You can install the "portable" version. That is basically just a standalone `.exe` that doesn't need an installer. Download the file and run it. It will give you a User Access Control (UAC) prompt in Windows:

![rufus-uac-prompt.png](/assets/img/ubuntu-install-rufus-uac-prompt.png)

Then, in the main window: point to your `.iso` file and point to your USB drive:

![rufus-create-usb.png](/assets/img/ubuntu-install-rufus-create-usb.png)

Click "Start" and it will overwrite your USB device with the contents of the `.iso` file.

## Creating a USB Thumb Drive (on macOS or Linux)

To create a bootable URB thumb drive, your best option is to use `dd`. The syntax is something like this:

```bash
sudo dd if=./input of=./output status=progress
```

In this case, let's assume the input file is an `.iso` file in your `~/Downloads` folder, and your output is your USB thumb drive. You should be able to discern what the device name is from `lsblk` and/or `lsusb`. Assuming your thumb drive might be `/dev/sdb`, your command might be:

```bash
# WARNING: This is an example, make sure this is correct for your system.
#sudo dd if=~/Downloads/ubuntu-21.04-live-server-amd64.iso of=/dev/sdb status=progress
```

# Installation Steps

Put your installation media (the virtual `.iso` file, or the physical DVD, or USB device) into the machine. Then, boot the machine:

## Step 1: Launch screen

![00.png](/assets/img/ubuntu-install-00.png)

Hit <kbd>Enter</kbd>.

## Step 2: Choose a language

![01.png](/assets/img/ubuntu-install-01.png)

Choose a language and then hit <kbd>Enter</kbd>.

## Step 3: Update the installer

![02.png](/assets/img/ubuntu-install-02.png)

You don't need to, but if you have network access then you can <kbd>Tab</kbd> down to Update, or just Continue, then hit <kbd>Enter</kbd>.

## Step 4: Keyboard configuration

![03.png](/assets/img/ubuntu-install-03.png)

Hit <kbd>Enter</kbd>.

## Step 5: Network configuration

![04.png](/assets/img/ubuntu-install-04.png)

Unless you have some custom setup, you can just hit <kbd>Enter</kbd>.

## Step 6: Proxy server

![05.png](/assets/img/ubuntu-install-05.png)

A proxy server is typically only used in a corporate environment. It's a server that you must traverse through, to get out to the internet. In most cases, this is not used.

Hit <kbd>Enter</kbd>.

## Step 7: Installation mirror

![06.png](/assets/img/ubuntu-install-06.png)

For updates and additional files, the installer may need to find source files. These are typically installed on many "mirrors" across the internet, unless you've [set up your own, local Ubuntu mirrors]({{ site.url }}{% post_url 2022-04-30-creating-a-local-ubuntu-mirror %}). 

In just about all cases, you can just hit <kbd>Enter</kbd>.

## Step 8: Disk configuration

![07.png](/assets/img/ubuntu-install-07.png)

There are many complex scenarios you may explore in the future, including encrypting your disk. However, in most cases you can just hit <kbd>Enter</kbd>.

## Step 9: Disk confirmation

![08.png](/assets/img/ubuntu-install-08.png)

Hit <kbd>Enter</kbd>. Then you will see a confirmation:

![09.png](/assets/img/ubuntu-install-09.png)

<kbd>Tab</kbd> to "Continue" and then hit <kbd>Enter</kbd>.

## Step 10: Create an account

This step will create a non-privileged user that has "sudo" access. Unless this is a personal account for you, personally, this could be a generic account. For example, consider `sysadmin` or `operations` as the name and username. The server name is the name as it will appear on the network.

![10.png](/assets/img/ubuntu-install-10.png)

<kbd>Tab<kbd> down to "Done", then hit <kbd>Enter</kbd>.

## Step 11: Install SSH Server

Hit the <kbd>Space</kbd> bar to select "Install OpenSSH server". <kbd>Tab</kbd> down to "Done", then hit <kbd>Enter</kbd>. Note that if you [use LaunchPad for SSH keys]({{ site.url }}{% post_url 2022-05-29-using-launchpad-for-ssh-keys %}), you can import your workstation SSH keys so that you'll automatically be able to log in from all of your regular workstations.
  
![11.png](/assets/img/ubuntu-install-11.png)

## Step 12: Install optional software

![12.png](/assets/img/ubuntu-install-12.png)

You don't need to install anything from here. You can install whatever you need later, once the OS is installed.
  
<kbd>Tab</kbd> down to "Done", then hit <kbd>Enter</kbd>.

## Step 13: Installation progress

You will now see some status and progress as the operating system is installed on your computer.
  
![13.png](/assets/img/ubuntu-install-13.png)

## Step 14: System Update

The installer will then check for updates and patches, and install those. Ideally, let this continue. Later, consider reviewing [Patching and Updating Ubuntu]({{ site.url }}{% post_url 2022-05-31-patching-and-updating-ubuntu %}).
  
![14.png](/assets/img/ubuntu-install-14.png)

## Step 15: Reboot

When complete, you will be prompted to reboot. <kbd>Tab</kbd> down to "Reboot Now", then hit <kbd>Enter</kbd>.
  
![15.png](/assets/img/ubuntu-install-15.png)

## Step 16: Initial Login

After the reboot, this is the default screen for the server. Log in with the credentials you specified back in [Step 10: Create an account](#step-10-create-an-account).
  
![16.png](/assets/img/ubuntu-install-16.png)

## Step 17: Post-Login

Once logged in, you are now at a "Bash" prompt and can begin configuring your system.
  
![17.png](/assets/img/ubuntu-install-17.png)
