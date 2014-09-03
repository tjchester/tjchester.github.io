---
layout: post
title: "Fedora Fails to Boot After Install"
description: "Describes a bug in the Fedora install and some suggested workarounds."
category: TechNote
tags: [Linux, Fedora]
image: 
  feature: layout-posts.jpg
comments: false
---

In this post I discuss a fatal bug that I ran into while installing Fedora 20.

<!-- more -->

I recently downloaded the 64-bit installation DVD for Fedora 20. During the interactive install, I selected automatic partitioning using LVM thin provisioning. The installation proceeded without issue but upon reboot the system hung for several minutes on the graphical load screen before dumping me into the emergency mode console.

A quick trip to the Fedora site identified the issue as [*System fails to boot after install using LVM Thin Provisioning*](http://fedoraproject.org/wiki/Common_F20_bugs#System_fails_to_boot_after_install_using_LVM_Thin_Provisioning). There are two suggested workarounds. The first which I chose was to re-install and select a disk partitioning scheme other than *LVM Thin Provisioning* such as just plain *LVM*. The other workaround is reproduced from their site:

>Boot to rescue mode and choose *Continue* to mount your installed system and go to a shell. Now run the following:

>```
chroot /mnt/sysimage /bin/bash
yum update dracut
dracut -f
exit
reboot
>```

See also: [Bug 1040669](https://bugzilla.redhat.com/show_bug.cgi?id=1040669)
