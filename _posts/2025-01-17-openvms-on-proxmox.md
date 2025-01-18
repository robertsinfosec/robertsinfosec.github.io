---
title: "OpenVMS on ProxMox"
date: 2025-01-17 12:00:00 -500
categories: [Homelab Series, Other OSes]
tags: [homelab, openvms, proxmox]
published: true
---

This post is for a very specific niche, but also just so I have it documented somewhere. In the world of midrange and mainframe computers, particularly from the Golden Age of computing in the 1970's and 1980's, there is OpenVMS. This operating system was originally developed by Digital Equipment Corporation (DEC) for their VAX minicomputers. OpenVMS is still in use today, particularly in the financial and healthcare sectors, and is known for its stability and security features. It's also known for its unique command line interface and file system.

![VSI Logo](/assets/img/2025-01-17-vsi-logo.png)

In modern day, OpenVMS is owned and supported by [VMS Software Inc. (VSI)](https://vmssoftware.com/), which continues to develop and maintain the operating system. VSI has made OpenVMS available on x86-64 hardware, which means it can run on modern servers and virtualization platforms. One such platform which isn't officially supported, but technically works - is [ProxMox](https://proxmox.com/en/products/proxmox-virtual-environment/overview), an open-source virtualization platform that is based on KVM and LXC, and my hypervisor of choice!

## The VSI Community License

VSI offers a free Community License for OpenVMS, which allows you to run OpenVMS on x86-64 hardware for non-production use. This is great for hobbyists, enthusiasts, and anyone who wants to learn more about OpenVMS without having to pay for a commercial license. You can find more information about the VSI Community License, and also apply here:

> **[https://vmssoftware.com/community/community-license/](https://vmssoftware.com/community/community-license/)**

Within about a day I recieved an e-mail with how to download the `.vmdk` files, which is the only supported format. The `.vmdk` files are for VMware, but can be converted to `.qcow2` for ProxMox. It is essentially a virtual hard disk that already has the operating system installed.

It's not officially documented, so this took some experimenting to get working, so this post will serve to document how I got it working.

## Installation Steps

There are supported and documented platforms like [VMWare ESXi](https://en.wikipedia.org/wiki/VMware_ESXi) and [VirtualBox](https://www.virtualbox.org/), but I wanted to see if I could get OpenVMS working on ProxMox. Here are the steps I took:

### Step 1: Download the OpenVMS VMDK Files & Upload to ProxMox

In the e-mail from VSI, there is a specialized link to download the `.vmdk` files for OpenVMS. Download the `.zip` file and then upload them to your ProxMox server. Inside of the `.zip` was really two files:

```bash
-rw-r--r-- 1 root root 8.0G Jan 17 09:22 community-flat.vmdk
-rw-r--r-- 1 root root  718 Jan 17 09:22 community.vmdk
```

However, if you look inside of that `community.vmdk` file (`cat ./community.vmdk`), you'll see that it's just a pointer to the `community-flat.vmdk` file, but with a different name: `X86_V923-community-flat.vmdk`

So, one thing you'll need to do is rename the `community-flat.vmdk` file to `X86_V923-community-flat.vmdk`:

```bash
mv community-flat.vmdk X86_V923-community-flat.vmdk
```

I used `scp` to upload the files to my ProxMox server:

```bash
scp .\community* root@proxmox.example.com:/mnt/pve/SSD-x1A
```

Before moving on, the end-result is that I have the following files in place, on the ProxMox host:

```bash
/mnt/pve/SSD-x1A/openvms/community.vmdk
/mnt/pve/SSD-x1A/openvms/X86_V923-community-flat.vmdk
```

### Step 2: Create a Blank VM in ProxMox

We're going to "import" the operating system drive, so we just need a basic VM. We also are going to override most of this in the config file, so it doesn't need to be perfect. Basically, just create a VM and I'll reference it as VM ID `1003`, going forward.

### STEP 3: Import the VMDK File into VM ID 1003

We want to import the VMDK into the VM we just created, and specify the format as `raw`. So, given the variables above, for me it was this command line (from the ProxMox host):

```bash
qm importdisk 1003 /mnt/pve/SSD-x1A/openvms/community.vmdk SSD-x1A --format raw
```

<p>Explanation of the command line:
<ul>
    <li><code>qm importdisk</code> is the command to import a disk into a VM</li>
    <li><code>1003</code> is the VM ID</li>
    <li><code>/mnt/pve/SSD-x1A/openvms/community.vmdk</code> is the path to the VMDK file</li>
    <li><code>SSD-x1A</code> is the storage ID of where the imported drive will live</li>
    <li><code>--format raw</code> specifies the format of the disk</li>
</ul>
</p>

### STEP 4: Edit the VM Config File

Instead of going through the ProxMox GUI, I just edited the config file directly, while SSH'ed into the ProxMox host.

```bash
nano /etc/pve/qemu-server/1003.conf
```

Here is what that file looks like, for a working setup. Please note that the UUID's should be unique:

```plaintext
args: -machine hpet=off
bios: ovmf
boot: order=scsi0
cores: 2
cpu: host
machine: q35
memory: 6144
meta: creation-qemu=9.0.2,ctime=1737127215
name: VMSTS1
net0: e1000=BC:24:11:9D:10:A5,bridge=vmbr0,firewall=1
numa: 0
ostype: other
scsi0: SSD-x1A:1003/vm-1003-disk-0.raw,iothread=1,size=8G
scsihw: virtio-scsi-single
serial0: socket
smbios1: uuid=2df32a97-3d8e-4113-a6a6-6e66c6be2eb4
sockets: 1
vmgenid: f5ba574e-e87a-4a83-bbcd-5037236bfddd
```

> **WARNING**
>  
> Just a reminder that things like the MAC address in `net0`, `smbios1`, and `vmgenid` should be unique.
{: .prompt-warning }

### Step 5: Start the VM

If you are used to other OSes like Linux or Windows Server, this is a little bit different. How this works is we are connecting to the virtual "serial port" of the server to see the initial boot output. Then, we can connect to the OpenVMS system via SSH or indirectly via the ProxMox host.

Within the ProxMox UI, click Start. Then, click on the Console tab to see the output. You should end up on a screen like this:

![alt text](/assets/img/2025-01-17-openvms-boot1.png)

You can see in the middle area that `DKB0` is the boot manager. So, from this `BOOTMGR>` prompt, you can type `BOOT DKB0` and press Enter. You should see the system booting up for a moment and then land on this screen:

![alt text](/assets/img/2025-01-17-openvms-boot2.png)

That's all we can do from the ProxMox console.

### Step 6: Connect to OpenVMS

There are two ways to get to a system prompt.

#### OPTION 1: The QEMU Terminal `qm terminal 1003`

While SSH'ed into ProxMox, this is the ProxMox command to connect to the virtual serial port of the VM. This is the most direct way to get to the system prompt. However, it's not the most user-friendly.

```bash
qm terminal 1003
```

To "escape" from the terminal, you can press <kbd>Ctrl</kbd> + <kbd>]</kbd> or <kbd>Ctrl</kbd> + <kbd>O</kbd> and then press `q` and press `Enter`.

#### OPTION 2: SSH to the ProxMox Host

I mention this as #2 because:

1. We may not easily be able to tell what the IP address is of the system, since it uses DHCP by default. When we are logged in, we can run `TCPIP SHOW INTERFACE` to see the IP address, but before then we don't know.
2. On one setup, SSHD was enabled by default, but on another it was not. So, you may need to enable SSH.

##### Enabling SSH

As mentioned above, if SSH is not enabled, you will need to SSH into your proxmox server and use `qm terminal 1003` to get to the OpenVMS system prompt.

Once you have a terminal open on the OpenVMS system, you should be sitting at a `$` prompt. The default username is `SYSTEM` and the ***default password was provided in the e-mail that you received from VSI***.

You should be able to see the status of the Secure Shell (SSH) service by running the following command:

```bash
$ TCPIP SHOW SERVICE
```

That should look something like this if SSH is disabled:

```plaintext
Service             Port  Proto    Process          Address            State

FTP                   21  TCP      TCPIP$FTP        0.0.0.0             Disabled
SSHD22                22  TCP      SSHD22           0.0.0.0             Disabled
TELNET                23  TCP      not defined      0.0.0.0             Enabled
```

To start/enable this service, you can run the following command:

```bash
$ TCPIP ENABLE SERVICE/PORT=22
```

Then, when you re-run `TCPIP SHOW SERVICE`, you should see that SSH is enabled:

```plaintext
Service             Port  Proto    Process          Address            State

FTP                   21  TCP      TCPIP$FTP        0.0.0.0             Disabled
SSHD22                22  TCP      SSHD22           0.0.0.0             Enabled
TELNET                23  TCP      not defined      0.0.0.0             Enabled
```

Now, if you couldn't before you should be able to SSH into the OpenVMS system. You can find the IP address by running the following command:

```bash
$ TCPIP SHOW INTERFACE
```

That results in something like:

```plaintext
Interface   IP_Addr         Network mask          Receive          Send     MTU

 IE0        192.168.20.180  255.255.255.0             398            48    1500
 LO0        127.0.0.1       255.0.0.0                  11            11    4096
```

This will show you the IP address of the system. You can now SSH into the system using the username `SYSTEM` and the password provided in the e-mail from VSI.

```bash
ssh SYSTEM@192.168.20.180
```

But obviously your IP address will be different.

### APPENDIX: Additional Commands

With a barebones system up and running, here are some additional commands that you may find useful:

#### Show System Information

```bash
$ SHOW SYSTEM
```

#### Show Disk Information

```bash
$ SHOW DEVICE
```

#### Show Network Information

```bash
$ TCPIP SHOW INTERFACE
```

#### Show Running Processes

```bash
$ SHOW PROCESS
```

#### Show Running Jobs

```bash
$ SHOW QUEUE
```

#### Show System Date

```bash
$ SHOW TIME
```

#### Defaults and Prompt

Lastly, a place to start to upgrade the default `$` prompt to something more useful, and some aliases to make things easier, you can create a `LOGIN.COM` file in the `SYS$LOGIN` directory, that is, your home folder. Here is an example of what that file could look like:

```bash
$ LS :== "DIR"
$ LL :== "DIR/SIZE/DATE/OWNER"
$!
$ CD :== "SET DEFAULT"
$ DEFINE/PROCESS "~" SYS$LOGIN
$!
$ ADD_LOG_TO_FILE_OPERATIONS:
$!
$       BAC*KUP :=="BACKUP/LOG"
$       COPY    :=="COPY/LOG"
$       CP      :=="COPY/LOG"
$       DEL*ETE :=="DELETE/LOG"
$       RM      :=="DELETE/LOG"
$       PURGE   :=="PURGE/LOG"
$       MOVE    :=="RENAME/LOG"
$       MV      :=="RENAME/LOG"
$       REN*AME :=="RENAME/LOG"
$!
$ SET TERM/ANSI/INSERT
$
$! Dynamically set the prompt with hostname and username, removing spaces
$ NODENAME = F$EDIT(F$GETSYI("NODENAME"),"TRIM")     ! Trim extra spaces
$ USERNAME = F$EDIT(F$GETJPI("","USERNAME"),"TRIM")  ! Trim extra spaces
$ SET PROMPT="''NODENAME'_''USERNAME'> "
$
$ NANO :=="EDIT"
$ EXIT
```

This solves several "problems" for me:

1. Instead of a `$` prompt, it shows the hostname and username (e.g. `X86923_SYSTEM> `)
2. I can use `~` to go to my home directory like in Linux (e.g. `CD ~` or `SET DEFAULT ~`)
3. I can use `LS` and `LL` to list files and directories
4. I can use `cd` to change directories
5. I can use `nano` to edit files. In reality, it's going to use the Eve/TPU editor, but this helps with muscle-memory is used to typing `nano`
6. For file operations (e.g. copy, delete, move, etc), by default, those commands don't show any output. So, appending the `/LOG` will make them default to showing output.

I also have this as a GitHub Gist, here, which I might continue to tweak as time goes on:

> **[https://gist.github.com/robertsinfosec/373f8fd4dc0a999436a6eaea9d1e3a30](https://gist.github.com/robertsinfosec/373f8fd4dc0a999436a6eaea9d1e3a30)**

This is just a starting point, but it makes the system a little more user-friendly as you are getting used to it.