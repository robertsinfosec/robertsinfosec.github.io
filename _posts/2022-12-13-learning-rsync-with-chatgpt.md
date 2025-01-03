---
title: Learning rsync with ChatGPT
date: "2022-12-13 21:15"
categories: [education]
tags: [education, chatgpt, backups, linux]
published: true
---
## Overview

As people play around with ChatGPT, I've been seeing all sorts of reactions, and all sorts of things those people are trying. For me, one of the first places I gravitated to was to help me with some bash script. As I've dabbled in bash over the years, I've learned more and more little tricks. However, there were still some things I would get stuck on.

At the moment, I'm revamping how I do Linux backups. One of the things I'd like to figure out "once and for all" is how to `rsync` my backups off my server and get them to my NAS. I thought: this is a good time to see if ChatGPT has some ideas!

### Tips on using ChatGPT

One of the really key elements of success, is to give it as much information as possible. If you just ask a superficial question, you'll get a superficial answer. However, if you give it: machine names, user names, variable names, explain the logic that is needed - it will produce *really* high quality output. So, that is what I tried.

### Asking ChatGPT how to use `rsync` correctly

Below is my copy/pasted transcript of what I asked, and what it responded with. This is primarily to show that if you give it deep details, it will create *very* high quality responses. This short conversation gave me a lot of new information I didn't know, and many new things to try, to solve my problem.

This isn't about `rsync`, it's about what questions I asked, and how it responded. Below is the exact transcript (typos and all):

---

> OK, so here's the deal. I have a backup server named "archive". On there, I have a non-priviledged account called "archiver". On that server, I have a volume mounted on "/var/archive" which has like 20TB of space. I also created an SSH keypair for the archiver account.
>  
> From various other linux machines on the network, I would like to use rsync to push backup files to the archive machine, using this one SSH key, so there is no password prompt.
>  
> However, I since this SSH key will be available in a lot of places, I want to really restrict it. Can I make it so when remote systems log in to archiver@archive, all they can do is rsync push files, and nothing else? They shouldn't be able to change directories, get a bash shell, and if they used the key with ssh or scp, they should not be able to do anything, to work with any files. I want this archiver account to only be able to be used by remote machines to push files to "archive" and no have any other permissions.
>  
> How would I need to configure my archiver@archive account, in terms of changing it's shell perhaps, or changing permissions? For example, I would going to create a soft link in the home directory of archive for "ln -s /var/archive/ ~/archive" and try to give it write-only access? Will that work?
>  
> What's the correct way to set this up?
{: .prompt-info }

To restrict the archiver account to only allow rsync push commands, you can do the following:

On the archive server, log in to the archiver account and create a new directory where the files will be pushed. For example, you could create a directory called "backups" in the home directory of the archiver account, like this:

```bash
mkdir backups
```

Set the permissions on the backups directory so that it is write-only for the archiver account. This will prevent the archiver account from being able to read or execute any files in the backups directory. You can do this by running the following command:

```bash
chmod 700 backups
```

Edit the `.ssh/authorized_keys` file for the archiver account and add the following restricted command to the end of the key that you want to use:

```bash
command="rsync --server --sender -logDtpre.iLsf --numeric-ids . /backups" ssh-rsa [SSH KEY HERE]
```

This will allow the archiver account to only execute the rsync command with the specified options. Any other commands that are attempted, including logging in with ssh or using scp, will be denied.

To create the soft link, you can run the following command:

```bash
ln -s /var/archive/ ~/archive
```

This will create a symbolic link in the home directory of the archiver account that points to the `/var/archive` directory. You can then use this link when specifying the destination for rsync commands from remote machines.

Keep in mind that you may need to adjust the permissions on the `/var/archive directory` to allow the archiver account to write to it. You can do this by running the following command:

```bash
chmod g+w /var/archive
```

This will add write permissions for the group that the archiver account belongs to.

I hope this helps! Let me know if you have any other questions.

> OK, and then from "test-server", what would be the rsync command to push "backup.tar.gz.gpg" to that server. Doesn't rsync want to read the directory contents first? Do I need to tell rsync to not try to "read" anything, and to JUST write?
{: .prompt-info }

To push a file called "backup.tar.gz.gpg" to the archive server using rsync, you can use the following command on the test-server:

```bash
rsync -e ssh -avz backup.tar.gz.gpg archiver@archive:~/archive
```

This command will use ssh to connect to the archiver account on the archive server, and will then use rsync to push the "backup.tar.gz.gpg" file to the `/var/archive` directory on the archive server, using the symbolic link that you created.

The -e ssh option specifies that ssh should be used for the transport, the -avz options are rsync options that enable archive mode, verbose output, and compression, and the final argument specifies the source file and the destination on the remote server.

Since the archiver account has write-only permissions on the `/var/archive` directory, it will not be able to read the contents of the directory. This means that rsync will not try to read the directory contents before transferring the file. It will simply transfer the file and then exit.

I hope this helps! Let me know if you have any other questions.

> One more thing: could you please modify the command about and show how I might use archiver_id.key as my SSH key whilst connecting as archiver@archive?
{: .prompt-info }

To use a specific SSH key when connecting to the archiver account on the archive server, you can use the -i option with ssh, like this:

```bash
rsync -e "ssh -i archiver_id.key" -avz backup.tar.gz.gpg archiver@archive:~/archive
```

This will use the `archiver_id.key` file as the SSH key for the connection.

You can also specify the SSH key in the ssh_config file on the test-server, which will allow you to use the ssh command without the -i option. To do this, add the following lines to the ssh_config file:

```bash
Host archive
  Hostname [SERVER HOSTNAME]
  User archiver
  IdentityFile /path/to/archiver_id.key
```

Replace `[SERVER HOSTNAME]` with the hostname of the archive server.

You can then use the following rsync command to push the file:

```bash
rsync -e ssh -avz backup.tar.gz.gpg archiver@archive:~/archive
```

This will use the settings from the ssh_config file to connect to the archiver account on the archive server using the specified SSH key.

I hope this helps! Let me know if you have any other questions.

> Can I make it so I can rsync as archiver@archive without using any authentication?
{: .prompt-info }

If you want to use rsync to transfer files to the archiver account on the archive server without using any authentication, you can use rsync's built-in "daemon" mode. In this mode, rsync will listen on a specified port for incoming connections, and will allow clients to transfer files without requiring any authentication.

To use this mode, you can start the rsync daemon on the archive server by running the following command:

```bash
rsync --daemon --no-detach --log-file /var/log/rsyncd.log
```

This will start the rsync daemon in the foreground, logging output to the specified log file. The --no-detach option is included so that you can easily stop the daemon by pressing Ctrl+C.

Once the daemon is running, you can use the following rsync command on the test-server to transfer a file:

```bash
rsync -avz backup.tar.gz.gpg rsync://archive/backups
```

This will use rsync to connect to the rsync daemon on the archive server and transfer the "backup.tar.gz.gpg" file to the `/var/archive/backups` directory on the archive server.

Keep in mind that using the rsync daemon in this way is not very secure, since it does not require any authentication. You should only use this method if the archive server is on a secure, trusted network and if you are confident that no unauthorized users will be able to access it.

I hope this helps! Let me know if you have any other questions.

> But wait, could I also still do the write-only method we discussed earlier? In other words, this technique wouldn't be too dangerous if all this "archiver" account can do, is blindly drop files into a write-only folder, and it would not be possible to get to a shell, right? 
>  
> Can I still do write-only with this technique?
{: .prompt-info }

Yes, you can still use the write-only technique that we discussed earlier when using the rsync daemon in this way. To do this, you would need to add the following lines to the /etc/rsyncd.conf file on the archive server:

```bash
[backups]
    path = /var/archive/backups
    read only = false
    write only = true
    uid = archiver
```

This will configure the rsync daemon to only allow write operations to the `/var/archive/backups` directory, and to run all operations as the archiver user. This will prevent clients from being able to read or execute any files in the backups directory.

Once you have added these lines to the rsyncd.conf file, you can restart the rsync daemon by running the following command:

```bash
rsync --daemon --no-detach --log-file /var/log/rsyncd.log
```

You can then use the following rsync command on the test-server to transfer a file:

```bash
rsync -avz backup.tar.gz.gpg rsync://archive/backups
```

This will transfer the "backup.tar.gz.gpg" file to the `/var/archive/backups` directory on the archive server, using the write-only permissions that you configured.

As long as you have set the write-only permissions on the backups directory and have configured the rsync daemon to run as the archiver user, it will not be possible for clients to get a shell or to perform any other operations on the server.

I hope this helps! Let me know if you have any other questions.

> One last question: how can I have this rsync-daemon run on a different port? What do I need to configure on the server, and where do I specify the port syntax from the client?
{: .prompt-info }

To configure the rsync daemon to listen on a different port, you can add the following line to the `/etc/rsyncd.conf` file on the archive server:

```bash
port = [PORT NUMBER]
```

Replace `[PORT NUMBER]` with the port number that you want the rsync daemon to listen on. For example, if you want the rsync daemon to listen on port 873, you would use the following line:

```bash
port = 873
```

Once you have added this line to the rsyncd.conf file, you can restart the rsync daemon by running the following command:

```bash
rsync --daemon --no-detach --log-file /var/log/rsyncd.log
```

To specify the port number when connecting to the rsync daemon from the test-server, you can use the -p option with rsync, like this:

```bash
rsync -avz -p873 backup.tar.gz.gpg rsync://archive/backups
```

This will use rsync to connect to the rsync daemon on the archive server using port 873, and will transfer the "backup.tar.gz.gpg" file to the /var/archive/backups directory on the archive server.

I hope this helps! Let me know if you have any other questions.
