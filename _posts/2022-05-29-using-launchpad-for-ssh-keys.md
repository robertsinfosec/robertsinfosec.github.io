---
title: Using Launchpad for SSH Keys
date: "2022-05-29 11:01"
categories: [Infrastructure, Homelab]
tags: [homelab, proxmox, ubuntu, infrastructure, virtualization, security]
---

## Overview

Ideally, when you create new servers, you want to turn OFF SSH password authentication and only allow SSH key logins. This eliminates the possiblity of bad-actors trying to brute-force thier way into SSH. However, it is kind of a pain to set up and coordinate, isn't it?

If you use Ubuntu as your server platform, what if I told you there was a dead-simple way to address this? Imagine that you could store your SSH public keys in one place, and then your Ubuntu installations (and other place you need it) could very easily download them?

## Use-Case: From the Ubuntu OS installation

During the installation of Ubuntu, it allows "importing" SSH keys from some accessible places. I've never been able to get the Github one to work, but Launchpad is dead simple.

![Ubuntu SSH key prompt](/assets/img/launchpad-installer-prompt.png)

## Use-Case: While building Cloud Images for ProxMox

Without any login required, you can `curl` or `wget` your SSH keys from a URL like this if your Launchpad account was `jdoe55555` for example:

> **[https://launchpad.net/~jdoe55555/+sshkeys](https://launchpad.net/~jdoe55555/+sshkeys)**

That just returns registered SSH public keys for that account.

## Getting Started

Assuming you find this useful, how to do this is the following:

1. Create a Launchpad / UbuntuOne account via: [https://launchpad.net/+login](https://launchpad.net/+login).
1. Verify your e-mail address.
1. Click on your name in the top-right to bring you to your profile screen. (ex.: [https://launchpad.net/~jdoe55555](https://launchpad.net/~jdoe55555))
1. Click on the the little pencil icon next to SSH keys. From there, you can add and remove your SSH keys.

![Launchpad Profile Page](/assets/img/launchpad-profile-page.png)