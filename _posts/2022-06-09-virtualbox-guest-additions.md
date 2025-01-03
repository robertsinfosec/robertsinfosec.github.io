---
title: VirtualBox Guest Additions
date: "2022-06-09 19:36"
categories: [Series, VirtualBox Installs]
tags: [homelab, virtualbox, ubuntu, infrastructure, virtualization]
published: true
---
## Overview

A key part of using VirtualBox is knowing that there is technology like the "VirtualBox Guest Additions". What this is, are libraries and drivers that tell the hosted operating system, that it is hosted in VirtualBox, and it lets the two operating systems work together!

There are at least huge benefits of installing these:

1. **Shared Clipboard** - you can configure a one-way or two-way clipboard sharing. For example, you *Copy* a value on your PC and *Paste* it in your guest VM. Without something as basic as that, how would exchange simple data? You'd have to manually type everything.
1. **Shared Folder** - you can configure a shared folder between the guest and the host. Meaning, you can have a folder on your desktop, and that same folder can be mounted inside of your virtual machine! This lets you easily copy files back and forth through a "portal" that connects your guest and host computer.
1. **Screen Resolution** - once installed, if you resize your VM window, the guest OS will instantly re-size the resolution. If you go to full-screen, it will re-adjust the resolution for full-screen!

There are several other benefits, but as you can see, it's a valuable thing to do and just takes a minute.

## Steps

Below are the steps to install the VirtualBox Guest Additions on Ubuntu.

### STEP 1: Virtually insert CD

In the "Devices" menu, choose "Insert Guest Additions CD Image...". On macOS:

![Insert CD - macOS](/assets/img/virtualbox-guest-additions/vbox-menu.png)

and on Windows:

![Insert CD - Windows](/assets/img/virtualbox-guest-additions/vbox-menu-win.png)

### STEP 2: Run `autorun.sh`

Next, open the newly-mounted CD in the main menu on the left. That brings up a file explorer. Right-click on `autorun.sh` and choose to "Run as a program":

![Folder View](/assets/img/virtualbox-guest-additions/pre-autorun.png)

That should prompt you for your password:

![Folder View](/assets/img/virtualbox-guest-additions/sudo-prompt.png)

### STEP 3: Reboot

When done, it should prompt you to reboot:

![Post-run](/assets/img/virtualbox-guest-additions/post-autorun.png)

## Summary

Upon reboot you should now see that the resolution changes when you resize the window, you can set up a shared clipboard or shared folder in the settings too.