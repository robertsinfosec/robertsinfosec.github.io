---
title: Expanding Disk Volumes on Ubuntu
date: "2022-12-04 21:32"
categories: [Infrastructure]
tags: [homelab, virtualbox, ubuntu, infrastructure, virtualization]
published: true
---
## Overview

There are times when you need to expand the size of a disk or volume in a virtualized environment, and you'd ideally want to do that without having to move or copy files. This page shows how to resize a disk or volume, in-place, without any downtime or data loss.

### DigitalOcean - Initial Setup

Within DigitalOcean, assume you a virtual machine defined. In the left-side navigation, click on "Volumes", and then the "Create Volume" button.

![](/assets/img/do-create-volume.png)

> PRO TIP: Choose to "Automatically Format & Mount" here, because it does make things easier if you need to expand the drive later. This puts a file system on the device without any partitions.
{: .prompt-tip }

Now, if you run `lsblk` or `df -H`, you will see the `sda` device mounted to `/mnt/[volumename]`, by default:

![](/assets/img/do-volume-before.png)

If you wanted this disk space to be used for your website for example, you might mount this volume in the web root (e.g. `/var/web/html`). So, you might modify the `/etc/fstab` file and add something like:

```fstab
/dev/sda        /var/www/html   ext4    defaults        0 1
```

Now, upon boot-up or if you manually mount all with `mount -a`, you can now run `df -H` and see that the new volume is mounted at `/var/www/html`:

![](/assets/img/do-mounted.png)

### DigitalOcean - Expanding Disk Volume

With the above setup, the operating system runs off of `/dev/vda1` and the website has all it's files on `/dev/sda` which is mounted on `/var/www/html`. But now some time has passed and we are starting to run out of disk space. What do we do?

We start over in DigitalOcean. We open the Volume that is defined there, and expand it:

![](/assets/img/do-new-size.png)

#### Using: Automatic

If you did choose the "Automatically Format & Mount" option above, you should be able to just run:

```bash
resize2fs /dev/sda
```

Assuming your volume device name is `sda1`. For more details, see: [https://docs.digitalocean.com/products/volumes/how-to/increase-size/#expand-the-filesystem](https://docs.digitalocean.com/products/volumes/how-to/increase-size/#expand-the-filesystem)

That produces this output and you can run a `df -H` to verify the new space.

![](/assets/img/do-volume-after.png)

Note there is no downtime or outage for this.

> PRO TIP: Do a backup before you do anything with disk. Just in case.
{: .prompt-tip }

#### Using: Manual

If you chose the "Manually Format & Mount" option, things are a little different.

![](/assets/img/do-create-volume-manual.png)

You probably ran `fdisk /dev/sdb` and did `n` for new, took the defaults and did `w` to write changes. That created your partitions. Then, you probably ran `mkfs.ext4 /dev/sdb1` to format the partition.

In this case the *specific* partition of `/dev/sdb1` is what you probably put in the `/etc/fstab` file.

MEANING: when you expand the volume on DigitalOcean, it's a bit more complex because the partition table *itself* needs to be modified, and then the file system needs to be resized. Luckily, there is one-line shortcut for this:

```bash
# You point growpart at your device name and partition number. 
# Notice you would NOT use sda1 here (the shortcut for the device AND partition)
growpart /dev/sda 1

# Now, resize the file system, same as you would using the automatic method
resize2fs /dev/sda1
```

That's it. You should see the new volume space become available, thusly:

![](/assets/img/do-volume-after-manual.png)


### ProxMox

To show another example of this, it's very similar in ProxMox, if you're using that for virtualization. First, you'd go into the Hardware tab of the virtual machine and add a new Hard Disk:

![](/assets/img/pm-add-disk.png)

You can see the device on your VM with `lsblk` or `df -H`. Similar to the Digital Ocean example above, you can use the disk directly (without partitioning it) by just formatting the raw device with:

```bash
mkfs.ext4 /dev/sdb
```

Then you can mount that formatted device in your `/etc/fstab` with something like:

```fstab
/dev/sdb    /var/www/html   ext4    defaults    0 1
```

> NOTE: You can put a file system directly on a device, without creating partitions first.
{: .prompt-info }

Later, when you run low on disk space, you can go back into ProxMox and under Disk Action, you can Resize the disk:

![](/assets/img/pm-resize-disk.png)

If you didn't create any partitions, you can run something like:

```bash
resize2fs /dev/sda
```

Confirm it by running `df -H` again and you should see the new size:

![](/assets/img/pm-before-and-after.png)

Similarly, if you did use `fdisk` for example and create a partition, you could need to follow the steps above by using the `growpart` command first.