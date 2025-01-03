---
title: Installing Ubuntu into VirtualBox on Windows 11
date: "2022-06-06 23:36"
categories: [Series, VirtualBox Installs]
tags: [homelab, virtualbox, ubuntu, windows, infrastructure, virtualization]
published: true
---
## Overview

Suppose you want to play around with Linux and maybe you've heard people talking about [Ubuntu](https://www.ubuntu.com). But you don't have an extra computer laying around to try it, and you certainly don't want to replace your main computer with this experimental idea. What should you do?

Enter "virtualization". In modern day, pretty much any computer can host a [hypervisor](https://www.vmware.com/topics/glossary/content/hypervisor.html). That is, a piece of software that can host a virtual computer, inside of your actual computer. Meaning, you could create a "virtual machine" on your main computer, and try out Ubuntu on that virtual machine, or VM. When you are done, you can delete it, install other operating systems, etc.

## What You'll Need

There's really two things you need here, a hypervisor of some sort, and some installation media for the operating system that you want to install.

### PART 1: A Hypervisor

On macOS, you have a couple of choices, but for a few reasons, we'll cover how to set up VirtualBox.

#### PART 1a: Install VirtualBox

First, navigate to:

- **[www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)**

From here, there are two things to download:

- **Platform Package** - click on "Windows hosts" to download an `.exe` file. This is the main hypervisor software and user interface.
- **Extension Pack** - click on "All supported platforms" to download a `.vbox-extpack` file. This has some extended functionality that is useful.

They upgrade VirtualBox all of the time, but here is a snapshot of what this looks like on the day of this writing, and what to click on:

![What to download](/assets/img/virtualbox-ubuntu-windows11/virtualbox-what-to-download.png)

Next, in your Downloads folder you should see the two downloaded files:

![Downloads folder](/assets/img/virtualbox-ubuntu-windows11/virtualbox-downloads.png)

Double-click the `.exe` file to launch the installer:

![VirtualBox Install Launcher](/assets/img/virtualbox-ubuntu-windows11/virtualbox-installer.png)

Take all of the defaults, until complete:

![VirtualBox Install Launcher](/assets/img/virtualbox-ubuntu-windows11/virtualbox-installer-done.png)

Click "Finish" to land on the main window:

![VirtualBox Installer Main Window](/assets/img/virtualbox-ubuntu-windows11/virtualbox-main-window.png)


#### PART 1b: Install VirtualBox Extensions

From the main VirtualBox window, click on the File, and the Preferences menu:

![VirtualBox Preferences Menu](/assets/img/virtualbox-ubuntu-windows11/virtualbox-preferences-menu.png)

Next, click on Extensions. Then, click the "Add" button:

![VirtualBox Extension Before Installation](/assets/img/virtualbox-ubuntu-windows11/virtualbox-ext-click-add.png)

Choose the `.vbox-extpack` file downloaded in the previous step. Follow the prompts:

![VirtualBox Extension Prompt](/assets/img/virtualbox-ubuntu-windows11/virtualbox-ext-install-prompt.png)

![VirtualBox Extension PUEL Prompt](/assets/img/virtualbox-ubuntu-windows11/virtualbox-ext-puel-prompt.png)

![VirtualBox Extension Confirmation](/assets/img/virtualbox-ubuntu-windows11/virtualbox-ext-install-confirmed.png)

When complete, you should see the Extension Pack installed like this:

![VirtualBox Extension After Installation](/assets/img/virtualbox-ubuntu-windows11/virtualbox-ext-after.png)

### PART 2: Installation Media

VirtualBox gives you a way to host virtual machines. This is like having extra computer hardware laying around: it can't do much without an operating system. The scope of this post is to show how to install Ubuntu. For first, we need to download the installation media. Navigate to:

> **[https://ubuntu.com/download/desktop](https://ubuntu.com/download/desktop)**

and download the latest "LTS" (Long Term Support) version that is there. That is version 22.04, as of this writing. 

## Creating your first VM

First, a quick checklist. You should have:

- [X] Downloaded and installed VirtualBox
- [X] Downloaded and installed the VirtualBox Extensions
- [X] Downloaded the latest Ubuntu Desktop image (e.g. `%UserProfile%\Downloads\ubuntu-22.04-desktop-amd64.iso`)

If so, then we are ready to go. Start by launching VirtualBox. Next, click "New":

![VirtualBox New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-new1.png)

Ideally, set the "Name" to be the same as you intend the computer name to be:

![VirtualBox New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-new2.png)

If possible, I like to give (window-based) Linux distributions 2GB of RAM or more  :

![VirtualBox New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-new3.png)
![VirtualBox New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-new4.png)
![VirtualBox New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-new5.png)

A "Fixed size" disk allocates the entire disk on your hard drive, right now. If you configured a 200GB disk for your virtual machine, a Fixed disk will allocate 200GB on your computer right now. However, if you are short on disk space, but want to give the VM the impression that it has more, you can set this to "Dynamically allocated". This means that VirtualBox will only use as much physical disk space as the virtual machine is taking up. 

If you've allocated more than you have, then this is going to a problem one day. However, just having the ability to do this can fix some short-term, tedious problems.

![VirtualBox New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-new6.png)

The operating system and software typically takes 5-20GB depending on what you have installed, however if you have the extra disk space, ideally give it a bit more breathing room.

![VirtualBox New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-new7.png)

When done, you should see your new VM configured, but not powered-on yet.

![VirtualBox New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-new8.png)

> **WAIT!** This isn't super important, but can make a big different during the installation of the OS. I like to do two things before starting the VM for the first time: 1) add more CPU cores and 2) add more video memory.
{: .prompt-warning }

### Adding more cores

By default, your new VM will just get 1 CPU core. In modern computers, you typically more. VirtualBox, to not overwhelm the host of the VM, only allows you to allocate up to HALF of the number of total cores. This example is running on a Mac Mini with 4 cores. So, I can only up this to two - but it does make a difference!

![VirtualBox New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-new10.png)

### Adding more video memory

Next, by default, you get the minimal amount of video RAM which can cause you to run into problems with certain OS'es. So, up this to the maxmimum amount.

![VirtualBox New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-new11.png)

## Starting your first VM

At this point we can finally click "Start" on the VM.

![VirtualBox Start New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-new9.png)

Upon first launch, VirtualBox assumes you want to install an operating system. So, this first screen is prompting you to (virtually) insert some media into the (virtual) DVD reader. Click on the little button to browse for files.

![VirtualBox Start New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-start1.png)

Next, click the Add button to add media to the "media library" that VirtualBox uses. You should navigate to your Downloads folder and point to that `ubuntu-22.04-desktop-amd64.iso` file you downloaded. Once added, click "Choose" to use that as your boot media.

![VirtualBox Start New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-start3.png)

Then click "Start":

![VirtualBox Start New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-start4.png)

Next, the Ubuntu installer will launch. You can either hit <keyb>Enter</keyb> to start immediately, or there is a timer that will start it automatically after some time:

![VirtualBox Start New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-start5.png)

At that point, you should be at the main screen of the Ubuntu installer. You can play around and see if Ubuntu is working correctly - *but no files will be saved* - OR you can install it on this virtual machine.

![VirtualBox Start New VM](/assets/img/virtualbox-ubuntu-windows11/virtualbox-vm-start6.png)

## Conclusion

There is obviously a lot more to many parts of this. However, hopefully this was useful in at least getting Ubuntu up and running on a VM.
