---
title: "Proxmox Part 1: Installation & Basic Config"
date: 2024-06-04 12:00:00 -500
categories: [Homelab Series, Infrastructure]
tags: [proxmox, homelab, private-cloud, on-prem, sdi, infrastructure-as-code]
published: true
---


The foundation of my homelab is Proxmox, an open-source virtualization platform that allows me to run virtual machines and containers on my hardware. In this post, I'll walk through the installation and basic configuration of Proxmox.

## What is Proxmox and Why Use It?

Proxmox is an open-source virtualization platform that combines the KVM hypervisor and LXC containers to provide a powerful and flexible solution for running virtual machines and containers. Proxmox is designed to be easy to use and manage, making it ideal for homelab enthusiasts and small businesses.

In short, it's a very powerful platform that allows you to run virtual machines and containers on your hardware. It's a great way to learn about virtualization and experiment with different operating systems and applications. Best of all it is free and runs on almost any hardware.

## Hardware

Just a note on hardware. Although you can buy big, VERY loud servers (REAL servers) on eBay, I would recommend using Small Form Factor (SFF) desktops. They are super quiet, generally have decent specs (i5, i7, etc.), and are very power efficient.

What's great is that several vendors have great, inexpensive options. Put another way, these small machines support multi-core processors, often have a limit of 32GB, 64GB and some can use 128GB of RAM. You can get multiple m.2/NVMe drives to have plenty of storage, plus any external storage you might need.

> Proxmox also supports [iSCSI](https://pve.proxmox.com/wiki/Storage:_iSCSI), [CEPH](https://pve.proxmox.com/wiki/Deploy_Hyper-Converged_Ceph_Cluster), [NFS](https://pve.proxmox.com/wiki/Storage:_NFS), etc., so you can add network-based, external storage as needed. More on [CEPH](https://ceph.io/en/), too.
{: .prompt-tip }

### Small Form Factor Desktops

Below are some examples of what to search for on eBay, for example if you want to go the very-inexpensive route:

1. Dell Optiplex 7010 SFF, 7020 SFF, 7040 SFF, etc.
2. HP EliteDesk 800 G1 SFF, 800 G2 SFF, etc., or ProDesk 600 G1 SFF, 600 G2 SFF, etc.
3. Lenovo ThinkCentre M93p SFF, M92p SFF, etc., or M83 SFF, M82 SFF, etc.

### Intel NUCs

If you want to go the more expensive route, you can look at [Intel NUCs](https://en.wikipedia.org/wiki/Next_Unit_of_Computing). They are small, quiet, and very power efficient. They are also very powerful, with the latest models supporting up to 64GB of RAM and multiple m.2/NVMe drives.

> **NOTE**:
>  
> The "**Skylake-U**", or **6th Generation** and up is where 32GB of RAM and more is supported. Before this, the maximum was typically 8GB or 16GB, which is not-great when you want to host multiple VM's in your Proxmox environment.
>
> The "**Whiskey Lake-U**", or **8th generation** and up, is where 64GB of RAM is supported. This is a great option if you want to run multiple VM's and containers.
{: .prompt-info }

## Installation

To install Proxmox, you will need to download the Proxmox VE ISO from the Proxmox website and create a bootable USB drive. You can then boot from the USB drive on the hardware you want to install Proxmox on and follow the on-screen instructions to install Proxmox.

1. Download the Proxmox VE ISO from the [Proxmox website](https://www.proxmox.com/en/downloads/category/iso-images-pve).
2. Create a bootable USB drive with the Proxmox VE ISO using a tool like [Rufus](https://rufus.ie/). You can also use [Balena Etcher](https://www.balena.io/etcher/). See [this page](/posts/install-ubuntu-from-iso/#creating-a-usb-thumb-drive-on-windows) for more detail about creating a bootable USB drive.
3. Boot from the USB drive on the hardware you want to install Proxmox on.
4. Follow the on-screen instructions to install Proxmox. You can choose to install Proxmox on the local disk or a USB drive.
5. Once the installation is complete, remove the USB drive and reboot the system.
6. Access the Proxmox web interface by navigating to `https://<your-proxmox-ip>:8006` in a web browser.

That is all that you need to do at the console of the server. So, if you want to run Proxmox "headless", that is all you need to do. Everything else you can do remotely via the web interface, which again will be:

> `https://<your-proxmox-ip>:8006`

## Basic Configuration

Once you have installed Proxmox, there are a few basic configuration steps you should take to get started.

1. Log in to the Proxmox web interface using the username `root` and the password you set during installation.
2. Change the default password for the `root` user by clicking on your username in the top right corner and selecting "Change Password."
3. Configure the network settings for Proxmox by clicking on the "Datacenter" node in the tree view, selecting the "Network" tab, and clicking "Create" to add a new network interface.

## Storage Configuration

Configuration of storage is a critical step in setting up Proxmox. You can use local storage, network storage, or a combination of both. Unfortunately, this is not a straight-forward setup. Well, if you are not familiar with Logical Volume Manager (LVM) or ZFS, you might find it a bit challenging.

### About Logical Volume Manager (LVM)

LVM is a logical volume manager for the Linux kernel that manages disk drives and similar mass-storage devices. It provides a way to create logical volumes from physical volumes, allowing you to resize and move them easily.

### About ZFS

ZFS is a combined file system and logical volume manager designed by Sun Microsystems. It is scalable, includes features such as data integrity verification, compression, and snapshots, and supports high storage capacities.

### Quick Setup

The most straight-forward way to get started is to SSH into the machine (or use the Console from the web interface) and do the following to use ZFS:

#### STEP 1: Assess the Disks

From the console, run the following command to see the disks that are available:

```bash
# Run this to see a visual represetation of the disks:
lsblk
```

You should see something like this:

```bash
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    0 238.5G  0 disk
├─sda1   8:1    0   512M  0 part /boot/efi
├─sda2   8:2    0   244M  0 part /boot
└─sda3   8:3    0 237.8G  0 part
  └─pve-root 253:0    0 237.8G  0 lvm  /
sdb      8:16   0 238.5G  0 disk
└─sdb1   8:17   0 238.5G  0 part
  └─pve-data 253:1    0 238.5G  0 lvm  /var/lib/vz
```

In this example, we have two disks, `sda` and `sdb`, that we can use for storage, as those equate to `/dev/sda` and `/dev/sdb`.


#### STEP 2: Create a ZFS Pool

ZFS is the simplest option but also a very good option for your hypervisor storage. You can create a ZFS pool using the disks you want to use, based on what you learned from `lsblk`:

```bash
# Create a ZFS pool using the disks you want to use
# zpool create <pool-name> <disk1> <disk2> ...

# Example:
zpool create prox-data sda sdb
```

You can then run `zpool status` to see the status of the pool.

```bash
# Verify the ZFS pool
zpool status
```

At this point, you should see the pool you created and the disks that are part of it.

#### STEP 3: Create a ZFS Dataset

Next, you can create a ZFS dataset to store your virtual machines:

```bash
# Create a ZFS dataset for storing VMs
# zfs create <pool-name>/<dataset-name>

# Example:
zfs create prox-data/vmdata
```

You can then run `zfs list` to see the datasets you have created.

```bash
# Verify the ZFS dataset
zfs list
```

You should see the dataset you created and the pool it is part of.

#### STEP 4: Set the Default Storage

Finally, you can set the default storage for Proxmox to use the ZFS dataset you created:

```bash
# Set the default storage to the ZFS dataset
pvesm set local-zfs --dir /prox-data/vmdata
```

#### STEP 5: Verify the Storage

You can then run `pvesm status` to see the storage configuration.

```bash
# Verify the storage configuration
pvesm status
```

What this is showing is that you have a storage configuration that is using ZFS and the dataset you created. You can now see this storage available in the Proxmox web interface in the "Storage" tab.

### Advanced Setup

If you want to use LVM or a more complex storage setup, you can refer to the [Proxmox documentation](https://pve.proxmox.com/wiki/Storage).

## Summary

At this point you should be able to navigate to your Proxmox web interface and start creating virtual machines and containers. You should be able to see your storage available in the web interface in the "Storage" tab.

At this point, can you create VM's and containers.