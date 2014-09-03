---
layout: post
title: "Create a Debian Bootable Install Disk"
description: "Describes how to create a Debian bootable install USB disk."
category: TechNote
tags: [Linux, Debian]
image: 
  feature: layout-posts.jpg
comments: false
---

In this post I discuss how to create a bootable USB disk on Mac OS X for the Debian "Testing" network installer.

<!-- more -->

First you need to download the appropriate installation ISO from the Debian site. For the purposes of this example, I will use the x64 "testing" release which is generated on a weekly basis.

- Open a browser to [debian.org](http://www.debian.org)
- From the main page select the [CD ISO images](https://www.debian.org/CD/) under the *Getting Debian* section
- Click the [Download CD/DVD images using HTTP or FTP](https://www.debian.org/CD/http-ftp/) link
- Click the [Official CD/DVD images of the "testing" distribution (regenerated weekly)](http://cdimage.debian.org/cdimage/weekly-builds/) link
- Click the [amd64](http://cdimage.debian.org/cdimage/weekly-builds/amd64/) link
- Click the [debian-testing-amd64-netinst.iso](http://cdimage.debian.org/cdimage/weekly-builds/amd64/iso-cd/debian-testing-amd64-netinst.iso) link to download the ISO file


You should now have the ISO in your *Downloads* folder, next open the Mac's Terminal program. If you do not have an entry in your Dock, you can find the program in the /Applications/Utilities folder using the Finder.

Locate the USB disk you want to use for the installation and connect it to your Mac. If you are informed that *"The disk you inserted was not readable by this computer."*, as shown in the image below, just click the **Ignore** button.

![](/images/posts/create-a-debian-bootable-install-disk-01.png)

>WARNING: The contents of the USB disk will be destroyed, make a backup first if you need to save any information on this disk.

With the Terminal open, execute the following command to list the USB disks that are connected to your Mac:

```
diskutil list
```

The list of disks that you will see is dependent on your system. In my case, I only have the main drive in the Mac and the USB stick plugged in. You can see in the image below that /dev/disk0 refers to the main Mac disk which you can identify by its label *Macintosh HD*. The second disk, /dev/disk1, is the USB stick that I have chosen for the installation image.

![](/images/posts/create-a-debian-bootable-install-disk-02.png)

You need the output of the previous *list* command so that you can unmount the USB disk prior to writing to it. The next command unmounts the disk, */dev/disk1* in my case.

```
diskutil unmountDisk /dev/disk1
```

After this command has finished you should see the message - *Unmount of all volumes on disk1 was successful*. Next you need to copy the ISO image onto to the USB disk. As stated in the [Debian installation manual](https://www.debian.org/releases/stable/amd64/ch04s03.html.en) the image (i.e. ISO file) can be written directly to disk using the *cp* (i.e. copy) command. Since you are writing directly to the raw disk device (i.e. rdisk1), you need to elevate your privileges using the *sudo* command.

```
sudo cp ~/Downloads/debian-7.6.0-amd64-netinst.iso /dev/rdisk1
```

You will receive a message from the *cp* command stating that it could not copy extended attributes to the disk because the operation was not permitted. This message can safely be ignored.

When this command finishes you will have a bootable USB disk that can be used to start a Debian network installation. When the Mac Finder reprocesses the USB stick after the copy has finished, it will display the message - *The disk you inserted was not readable by this computer*. At this point the copy is done, so you can click **Eject** and remove your USB drive.

