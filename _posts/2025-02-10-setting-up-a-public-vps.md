---
title: "Setting Up a Public VPS"
date: 2025-02-11 02:42:00 -500
categories: [Installation Guides, Operating Systems]
tags: [linux, ubuntu, vps, security]
published: true
---

There are many reasons you might need to have a public-facing server. You might want to host a website, run a game server, or just have a place to store your files. Whatever the reason, it's important to make sure your server is secure and configured correctly.

Since this comes up both for myself, or when I'm helping others, I thought it would be a good idea to document the steps I take to set up a new server. This guide will cover the basic steps you should take to secure and configure a new server, regardless of how you plan to use it.

> **TIP:**
> If you need a no-frills virtual machine, NerdRack has their "sales" available year-round. For example: [Black Friday](https://www.racknerd.com/BlackFriday/), [New Years](https://www.racknerd.com/NewYear/), etc. I've used them for years with no issues and their prices significantly lower than even a Digital Ocean Droplet.
>
> Example: 2.5GB RAM, 2vCPU, 40GB SSD, 3TB Transfer for $18.93/year, or $1.57/month! These deals are also summarized here [racknerdtracker.com](https://racknerdtracker.com/).
{: .prompt-tip}

## STEP 1: Connect to the Server

Before you can do anything, you need to connect to the server. You can do this using SSH, which is a secure way to connect to a remote server. You will need the IP address of the server, and the username and password you set up when you created the server.

Typically, you will be given a random-looking `root` account password. So, to Secure Shell (SSH) into the server, you can use the following command in your terminal:

```bash
ssh root@<IP_ADDRESS>
```

In present-day, this `ssh` command will be available in Windows (from PowerShell or from cmd.exe), macOS from the Terminal, and of course from Linux clients too. So, you don't need to install any software (like PuTTY) to connect to your server.

## STEP 2: Create Non-Privileged User

It's considered a best practice to create a new user for yourself and disable the root user. This is because the root user has the ability to do anything on the system, and if you make a mistake, it could be catastrophic. By using a non-privileged user, you can still do everything you need to do, but if it would normally require `root` access, you have to use `sudo` to do it.

> **About Sudo:** The `sudo` command allows you to run commands as the root user, but only for that command. This is a good way to prevent mistakes from causing too much damage.
{: .prompt-info}

> **Root Prompt:** If you do want to "drop down" into a `root` shell, you can always use `sudo -s` or `sudo -i`.
>  
> - The `-s` flag will give you a shell, but keep your environment variables.
> - The `-i` flag will give you a shell, but as if you were the root user.
>  
{: .prompt-tip}

### Create the Account

To create a new user, you can use the `adduser` command. This will create a new user and ask you for a password. You can also add the new user to the `sudo` group, which will allow them to run commands as the root user.

> **Sudoers:** In this scenario, I'm suggesting to create an `operations` account, with a strong, unique password, and use that for all administrative tasks. If you work for a company or have a team, you should create a unique account for each person, ideally with Single Sign On (SSO), and `sudo` privileges should be set up for specific things that user needs to do. As an example, if user John Doe (`jdoe`) only needs to be able to restart the Nginx web server and can also reboot the machine, then in the sudoers file you could have something like this:
>  
> ```bash
> jdoe ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx, /sbin/reboot
> ```
>  
> That means that John Doe can run `sudo systemctl restart nginx` and `sudo reboot` without being prompted for a password.
>  
> I just wanted to be clear that there are relatively simple but powerful ways to manage users where they have enough privilege to do their job, but not enough to cause damage. This concept is called the [Principle of Least Privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege).
{: .prompt-tip}

Now, let's create a new user and add them to the `sudo` group:

```bash
# Create a new, non-privileged user
adduser operations

# Add the new user to the sudo group
usermod -aG sudo operations
```

> **TIP:**
> When a user is added to the `sudo` group, then the `/etc/sudoers` file defines what they can see, and if they will be prompted for their password. As a reference, here are the relevant lines from the `/etc/sudoers` file:
>
> ```bash
> # Allow members of group sudo to execute any command
> %sudo   ALL=(ALL:ALL) ALL
> ```
>
> It's not generally a good idea, but if you wanted to allow `sudo` without a password, you could add a line for that specific user, or change it for all `sudo` group users by modifying that line to look like this:
>
> ```bash
> # Allow members of group sudo to execute any command (without a password)
> %sudo   ALL=(ALL:ALL) NOPASSWD: ALL
> ```
{: .prompt-tip}

Back to our server: as of now, we're still connected as the `root` user. Before we disconnect and reconnect as the new `operations` user, we need to set up SSH authentication.

## STEP 3: Establish SSH Key Authentication

When you connect to a server using SSH, you can either use a password or a public/private key pair. Using a password is less secure because it can be guessed or brute-forced, but using a key pair is much more secure because it's nearly impossible to guess.

### Generate SSH Key Pair

If you don't already have an SSH keypair, then you will need to generate one. How do do you know if you have one on your local workstation? You can check by looking in your `~/.ssh` directory. If you see files named `id_rsa` and `id_rsa.pub`, then you already have a keypair. In Windows, the `~/.ssh` directory is really just `C:\Users\<USERNAME>\.ssh`.

If you don't have a keypair, you can generate one using the `ssh-keygen` command, from your local workstation. You can use the default settings, or you can specify a different filename or passphrase. Here is a place to start:

```bash
# Create a high-strength Elliptic Curve Cryptography (ECC) keypair
ssh-keygen -t ed25519 -C "operations"
```

> **ECC vs RSA Keys:** ECC keys are considered to be more secure than RSA keys, and they are also shorter. This means that they are faster to generate, faster to use, and more secure
{: .prompt-tip}

You should now have two files in your `~/.ssh` directory: `id_ed25519` and `id_ed25519.pub`. The `.pub` file is your public key, and the other file is your private key. You should never share your private key with anyone, but you can share your public key if you'd like.

### Copy Public Key to Server

Now that you have a keypair, you need to copy the public key to the server.

#### OPTION A: Copy and Paste

You can do this by copying the contents of the `id_ed25519.pub` file and pasting it into the `/home/operations/.ssh/authorized_keys` file on the server. You can do this by running the following command on the remote server:

```bash
# Create the destination directory
mkdir -p /home/operations/.ssh/

# Edit the `authorized_keys` file
nano /home/operations/.ssh/authorized_keys

# Paste the contents of the `id_ed25519.pub` file into the `authorized_keys` file
# Save and exit the editor after pasting the public key
```

#### OPTION B: Using `ssh-copy-id`

You can do this from your workstation using the `ssh-copy-id` command. This will copy the public key to the server and add it to the `authorized_keys` file in the `~/.ssh` directory of the user you specify.

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub operations@<IP_ADDRESS>
```

You will need to enter the password for the `operations` user, and then the public key will be copied to the server.

## STEP 4: Review `sudo` privilege

Before we go on, we need to verify that the `operations` user has the correct `sudo` privileges. You can do this by running the following command, assuming you are still connected as `root`:

```bash
# Switch to the operations user
sudo -u operations /bin/bash

# Check the sudo privileges
sudo -l
```

This will list the commands that the `operations` user is allowed to run with `sudo`. You should see something like this:

```bash
Matching Defaults entries for robert on miniwin:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin,
    use_pty

User robert may run the following commands on miniwin:
    (ALL : ALL) ALL
```

## STEP 5: Fix Color Prompts

To make it easier to distinguish between the `root` user and the `operations` user, we can change the color of the prompt. We will make the prompt green for the `operations` user and red for the `root` user.

> Before running this, be logged in as the `operations` user. For a moment, switch to the `root` account by running `sudo -s` so that you get the password prompt out of the way. Type `exit` to return to the `operations` account and run this:
{: .prompt-warning}

```bash
echo "[*] Show the full hostname in the prompt unprivileged prompt."
sed -i 's/\\h/$(hostname -f)/g' ~/.bashrc
source ~/.bashrc

echo "[*] Copy this file to /root/"
sudo cp ~/.bashrc /root/

echo "[*] Change the root prompt to be red."
sudo sed -i 's/01;32m/01;31m/g' /root/.bashrc
```

That will give you colored prompts like this:

![colored prompts](/assets/img/2025-02-10-colored-prompts.png)

## STEP 6: Install Basic Tools & `update.sh`

We will install some basic tools and create an `update.sh` script to keep the system updated.

```bash
apt update
apt install neofetch figlet net-tools htop -y
```

You can grab the `update.sh` script from here:

> **[https://github.com/robertsinfosec/sysadmin-utils/blob/master/src/scripts/bash/update.sh](https://github.com/robertsinfosec/sysadmin-utils/blob/master/src/scripts/bash/update.sh)**

That will basically update `apt`, `snaps`, and `flatpaks` to the latest version and cleanup unused files related to the installers. You'll see an output like this from the script:

![alt text](/assets/img/2025-02-10-update-output.png)

## STEP 7: Harden SSH Configuration

Next, we will configure SSH to disallow `root` login and password authentication, and only allow SSH key authentication. To start, let's edit the config file:

```bash
sudo nano /etc/ssh/sshd_config
```

### Login Banner

When you log in to a Linux machine, you often see a message that looks like this:

```bash
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-77-generic x86_64)
```

This is isn't particularly useful for regular users, but it is useful for attackers. So, it's a good idea to change this message to something more useful.

> The banner alerts anyone accessing the system that unauthorized use is prohibited and that activities may be monitored - this can help support legal actions by demonstrating that users were informed of the system’s policies.
{: .prompt-warning}

Instead of the OS version, you could put a warning message. This is done by modifying the `/etc/issue` file (for local logins) and `/etc/issue.net` (for network logins). Example content is here:

> **[https://github.com/robertsinfosec/sysadmin-utils/blob/master/src/content/banner/issue.net](https://github.com/robertsinfosec/sysadmin-utils/blob/master/src/content/banner/issue.net)**

Usually you need to uncomment the line for `Banner` and change it to point to `/etc/issue.net`:

```bash
# Existing entry:
# Banner none

# Change it to:
Banner /etc/issue.net
```

and you should see the warning message before attempting to SSH into the machine.

### Other SSHD Configuration

Here are some other settings you should consider changing in the `/etc/ssh/sshd_config` file. Change your file to match these settings:

```bash
# You cannot SSH in as root. You can ONLY SSH in as an unpriviliged user, 
# then `sudo` or `su` to do administrative tasks.
PermitRootLogin no

# Do not allow password authentication. You must use SSH keys.
PasswordAuthentication no

# Allow only SSH key authentication
PubkeyAuthentication yes

# Disable X11 forwarding
ChallengeResponseAuthentication no
```

Finally, run the following to restart the SSH service:

```bash
sudo systemctl restart sshd
```

## STEP 8: Install `ufw` Firewall

We will install and configure the Uncomplicated FireWall (UFW), or `ufw` firewall to allow ports 22, 80, and 443 by default.

```bash
sudo apt install ufw -y
# Reset in case there were any other rules in place.
sudo ufw reset
# By default, deny everything incoming
sudo ufw default deny incoming
# By default, allow everything outgoing
sudo ufw default allow outgoing

# EXCEPTIONS to the rule:
sudo ufw allow 22   # SSH
sudo ufw allow 80   # HTTP
sudo ufw allow 443  # HTTPS

# Turn on the rules.
sudo ufw enable
```

## STEP 9: Install `fail2ban` IDS/IPS

We will install and configure an Intrusion Detection System / Intrusion Prevention System (IDS/IPS) `fail2ban` to protect against brute-force attacks. This works by monitoring log files for malicious activity. When certain thresholds are hit, then firewall rules are added temporarily to block the attacker.

```bash
sudo apt install fail2ban -y
```

It installs as not-started and not-enabled on boot, so make sure to set that:

```bash
systemctl enable fail2ban
systemctl start fail2ban
```

You can create your own "jails" for all kinds of services, but it comes with the SSH one installed and enabled by default.

To see the status of the "jails", you can use this script:

> **[https://github.com/robertsinfosec/sysadmin-utils/blob/master/src/scripts/bash/all-jails.sh](https://github.com/robertsinfosec/sysadmin-utils/blob/master/src/scripts/bash/all-jails.sh)**

Just download/copy that to the `/root/all-jails.sh` file, and mark it as executable `chmod +x ./all-jails.sh`. Then, when you run it, you'll see output like this:

```text
1) Status for the jail: sshd
|- Filter
|  |- Currently failed: 2
|  |- Total failed:     15
|  `- File list:        /var/log/auth.log
`- Actions
   |- Currently banned: 2
   |- Total banned:     2
   `- Banned IP list:   92.255.85.37 92.255.85.107

13332 blocks in the past 24 hours.
```

## STEP 10: Configure Unattended Upgrades

Lastly, we will configure unattended upgrades to automatically install security updates.

```bash
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

Enable unattended upgrades:

```bash
sudo systemctl enable unattended-upgrades
```

## Conclusion

By following these steps, you will have a reasonably secure and well-configured server to start from. Remember to regularly update your server and review its security settings to ensure it remains secure. As a summarized, final checklist, here's what should be completed:

- [X] You log in as `operations` via SSH key. You can't SSH in as `root` and you can't SSH in as any account with a password; only SSH keys are allowed.
- [X] When you do SSH in, you see a warning banner.
- [X] Your `operations` account has `sudo` privilege, and prompts for a password (run: `sudo -l`)
- [X] Your firewall is installed and enabled (run: `ufw status`)
- [X] Your IDS/IPS is running (run: `all-jails.sh`)
- [X] Unattended Upgrades is turned on for security updates, and you can run `update.sh` to manually update the system too.
- [X] You have different color prompts for unprivileged vs `root` user.
