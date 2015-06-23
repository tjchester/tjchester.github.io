---
layout: post
title: "Setup an ArchLinux System"
description: "Describes how to setup a new ArchLinux system on an HP Envy all-in-one computer."
category: HowTo
tags: [Linux, ArchLinux]
image: 
  feature: layout-posts.jpg
comments: false
---

This walk-through will focus on a fresh installation of ArchLinux on a HP Envy TouchSmart SE all-in-one computer. The all-in-one has an existing installation of Windows 8.1 that will be replaced.

<!-- more -->

## Pre-Setup

There are two steps which I need to do before I can begin: first I need to make an ArchLinux bootable USB stick and second I need to turn off Secure Boot on the target computer.

### Make Bootable Media

> I will be performing these steps under Mac OS X, therefore the steps may vary if you are working under a different operating system.

I first download the latest ArchLinux installation [ISO](https://www.archlinux.org/download/) and then verify the MD5 checksum.

```
$ md5 ~/Downloads/archlinux-2015.06.01-dual.iso 
MD5 (/Users/user1/Downloads/archlinux-2015.06.01-dual.iso) = 1fe5c63ca870ac68dba08d14919e61d6
```

After the ISO has been verified, I need to insert a USB stick to write the image to. In this case I am using a PNY 8GB USB stick.

> Note the contents of the USB stick will be completely overwritten by the installation setup process. Make sure you make a backup of any contents of the stick before proceeding.

After the stick is inserted, I open a terminal session and get a list of the disks to identify my USB stick.

```
$ diskutil list
/dev/disk0
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *500.1 GB   disk0
   1:                        EFI EFI                     209.7 MB   disk0s1
   2:                  Apple_HFS Macintosh HD            499.2 GB   disk0s2
   3:                 Apple_Boot Recovery HD             650.0 MB   disk0s3
/dev/disk1
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:                            IPFire_2.17            *8.2 GB     disk1
```

From the output listed above I can see that the USB stick is listed as *disk1* and that it currently has the installation image of the IPFire firewall software.

Now that I have identified the appropriate disk, I need to unmount it so that I can write to it.

```
$ diskutil unmountDisk disk1
Volume IPFire_2.17 on disk1 unmounted
```

Next I need to write the downloaded ArchLinux ISO to the USB stick via the *dd* command. This might take up to 30 minutes or so and will not display any output on the terminal window until it has completed.

```
$ sudo dd if=~/Downloads/archlinux-2015.06.01-dual.iso of=/dev/rdisk1
1304576+0 records in
1304576+0 records out
667942912 bytes transferred in 1217.234593 secs (548738 bytes/sec)
```

When the dd command finishes writing to the disk, the Finder will attempt to mount the disk, and will display a dialog stating that *The disk you inserted was not readable by this computer. Initialize - Ignore - Eject*. I will click the *Ignore* button and then unmount the disk from the terminal.

```
$ diskutil eject disk1
Disk disk1 ejected
```

> Optionally you could click the *Eject* button on the dialog and then skip entering the terminal command above to eject the disk.

I now remove the USB stick from the Mac OS X computer and insert it into a free USB port on the HP Envy before proceeding to the next step.


### Turn Off Secure Boot

When the HP Envy is powered on, I will need to press the **F10** key to enter BIOS setup. Once in the BIOS, I select *Secure Boot Configuration* from the *Security* menu, and press *F10* on the confirmation dialog. Within the *Secure Boot Configuration* menu use the down cursor key to the row labeled *Secure Boot*, and press the right cursor key to change *Enable* to *Disable* on that entry. Press *F10* to accept and then select *Save Changes and Exit* from the *File* menu. I then select *Yes* on the save changes and exit confirmation box.


## Installation

Restart the all-in-one pressing the **F9** button to select the boot device. Highlight the entry for the USB stick under the **UEFI Boot Sources** category and then press the **Enter** button. In my case the entry appears as:

```
UEFI: PNY USB 2.0 FD 1100
```

I can ignore the GRUB menu that first pops up as the default boot option will automatically load ArchLinux and login me into to a root prompt.

> The ArchLinux site has an excellent Wiki [article](https://wiki.archlinux.org/index.php/Beginners%27_guide) on performing the installation. My instructions are an abbreviated version with the specifics listed that only apply to my situation.



### Disk Partitioning

The HP Envy has a current disk layout that resembles the following:

```
Part.#  Size         Partition Type           Partition Name
------  ----------   ---------------------    ------------------------
        1007.0 KiB   Free Space
  1     1023.0 MiB   Windows RE               Basic data partition
  2      360.0 MiB   EFI System               EFI System Partition
  3      128.0 MiB   Microsoft reserved       Microsoft reserved partition
  4      913.6 GiB   Microsoft basic data     Basic data partition
  5       16.4 GiB   Microsoft basic data     Basic data partition
           7.7 MiB   Free Space
```

The disk layout that I desire resembles the following:

```
Part.#  Size         Partition Type           Partition Name
------  ----------   ---------------------    ------------------------
        1024.0 MiB   Free Space
  2      360.0 MiB   EFI System               EFI System Partition
  1        8.0 GiB   Linux swap               Arch swap partition
  3      922.2 GiB   Linux LVM                Arch lvm partition
```

Do get from the original to the desired configuration I am going to use the **cgdisk** program making the following changes:

```
$ cgdisk /dev/sda
```

- Delete partition 1 (Windows RE) which will create the 1024.0 MiB free space at the beginning of the disk
- Leave partition 2 alone, as this is the existing UEFI boot partition that I can utilize later
- Delete partition 3
- Delete partition 4
- Delete partition 5
- Create a new 8.0 GiB partition with type 0x8200 (Linux Swap)
- Create a new partition with all remaining space with type 0x8E00 (Linux LVM)

The side benefit of deleting the original partition 1 and merging it the free space at the front of the desk is that the successive partitions will be aligned. We can confirm that by running:

```
$ blockdev --getalignoff /dev/sda[1,2,3]
0
0
0
```


### File System Creation

In this section, I am going to create the swap partition, the LVM volume groups, and create the system partitions.

First I create and activate the swap partition from partition 1.

```
$ mkswap /dev/sda1
$ swapon /dev/sda1
```

Next I create the LVM physical volume and volume groups from partition 3.

```
$ pvcreate /dev/sda3
Physical volume "/dev/sda3" successfully created
$ vgcreate vg-arch /dev/sda3
Volume group "vg-arch" successfully created
```

Finally, I create and format the system partitions. I have decided ahead of time that I want the following partitions:

```
Partition   Size      Logical Volume Name  Filesystem
---------   ------    -------------------  ----------
/           20 GiB    lv-root              XFS
/var        15 GiB    lv-var               XFS
/home       75 GiB    lv-home              XFS
```

The commands to do that for me are:

```
$ lvcreate -L 20G vg-arch -n lv-root
Logical volume "lv-root" created
$ lvcreate -L 15G vg-arch -n lv-var
Logical volume "lv-var" created
$ lvcreate -L 75G vg-arch -n lv-home
Logical volume "lv-home" created
$ mkfs.xfs /dev/vg-arch/lv-root
$ mkfs.xfs /dev/vg-arch/lv-var
$ mkfs.xfs /dev/vg-arch/lv-home
```

> Note that some output generated from the above commands was omitted from the example.


### Mount Partitions and Bootstrap System

The next step is that I need to mount each of the partitions under a single mount point on the live system.

First I need to mount the new root partition under the **/mnt** folder of the live installation system.

```
$ mount /dev/vg-arch/lv-root /mnt
```

Next I need to create subfolders under the **/mnt** folder for the different partitions in my system.

```
$ mkdir /mnt/boot
$ mkdir /mnt/var
$ mkdir /mnt/home
```

Finally I need to mount each of the remaining LVM partitions, including the UEFI partition.

```
$ mount /dev/sda2 /mnt/boot
$ mount /dev/vg-arch/lv-var /mnt/var
$ mount /dev/vg-arch/lv-home /mnt/home
```

At this stage you can optionally edit the mirrorlist where the packages will be downloaded from. I chose to skip this step but if instead I chose to do it, I would edit the file via the command below.

```
$ vi /etc/pacman.d/mirrorlist
```

Next I am going to boostrap the base system including the development packages (i.e. *base* and *base-devel*) via:

```
$ pacstrap -i /mnt base base-devel
```

> I needed to confirm the package installation, but that dialog and output is not shown above. I simply chose *all* when given the choice.

Next I need to generate the *fstab* file and verify it.

```
$ genfstab -U -p /mnt >> /mnt/etc/fstab
$ cat /mnt/etc/fstab
# 
# /etc/fstab: static file system information
#
# <file system>	<dir>	<type>	<options>	<dump>	<pass>
# /dev/mapper/vg--arch-lv--root
UUID=1552ea4e-34ea-4380-9a42-8c6d3cc48691	/         	xfs       	rw,relatime,attr2,inode64,noquota	0 1

# /dev/sda2 LABEL=SYSTEM
UUID=B239-840A      	/boot     	vfat      	rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro	0 2

# /dev/mapper/vg--arch-lv--var
UUID=2ea23bb8-94b0-4514-a209-402c71b34ea7	/var      	xfs       	rw,relatime,attr2,inode64,noquota	0 2

# /dev/mapper/vg--arch-lv--home
UUID=df96830b-fd5b-4234-a1a7-a139cfb2768d	/home     	xfs       	rw,relatime,attr2,inode64,noquota	0 2
```

> A quick visual inspection shows that I have my three LVM partitions formatted as XFS and also the pre-existing UEFI system partition is identified for booting. 

At this point I can change my root from the live file system to the new file system I setup under **/mnt** via the commands below.

```
$ arch-chroot /mnt /bin/bash
```

### Miscellaneous Customization

The first step is to set my locale so that locale-aware programs will display the correct monetary symbols, date and time formats, etc. Per the setup recommendation I am going to use *UTF-8* format with my country selection of *US*.

```
$ vi /etc/locale.gen

...
#en_SG.UTF-8 UTF-8  
#en_SG ISO-8859-1  
en_US.UTF-8 UTF-8  
#en_US ISO-8859-1  
#en_ZA.UTF-8 UTF-8  
...

$ locale-gen
$ echo LANG=en_US.UTF-8 > /etc/locale.conf
$ export LANG=en_US.UTF-8
```

Next I am going to set the local timezone to *US/Eastern*.

```
$ ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime
```

Since this server will not dual-boot with Windows, the install article recommendation is to set the hardware clock to UTC time via the command below.

```
$ hwclock --systohc --utc
```

I am a fan of the Lord of the Rings so I will set the host name of this server to *Gandalf*. I will also update the *hosts* file.

```
$ echo gandalf > /etc/hostname
$ vi /etc/hosts

...
#
# /etc/hosts: static lookup table for host names
#

#<ip-address>   <hostname.domain.org>   <hostname>
127.0.0.1       localhost.localdomain   localhost gandalf
::1             localhost.localdomain   localhost gandalf

# End of file
...

```

### Networking

My network configuration is relatively simple. I have a wired connection to the switch and will assign the address via a static DHCP reservation.

First I need to determine the interface via the *ip* commands.

```
$ ip link

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp4s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 0c:54:a5:18:b7:fa brd ff:ff:ff:ff:ff:ff
```

So from the output, I can see that my wired connection is *enp4s0*. According to the installation article under the *Wired* *Dynamic IP* section I can use the command below to set it up for DHCP.

```
$ systemctl enable dhcpcd@enp4s0.service
```

In my case, pretty straight forward to setup networking.

### Initial Environment Modules

Since my *root* volume lies on an LVM drive, I need to include the *lvm* module in the initial ram disk otherwise the kernel will not be able to find the root partition.

To do this I will edit the *mkinitcpio.conf* file and add the *lvm2* module in between the *block* and *filesystems* modules on the *HOOKS* line.

```
$ vi /etc/mkinitcpio.conf

...
#    usr, fsck and shutdown hooks.
HOOKS="base udev autodetect modconf block lvm2 filesystems keyboard fsck"
...
```

With that out of the way, I now need to regenerate the initramfs image using the command below.

```
$ mkinitcpio -p linux
```

### Set Root Password

Next I need to create a password for the root user.

```
$ passwd
```

### Boot Loader Installation

The last step I need to complete before booting into the new system is to install the boot loader. Within the installation article I am following the information related to *For UEFI motherboards* and *GRUB*.

```
$ pacman -S dosfstools grub efibootmgr
$ grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck
Installing for x86_64-efi platform.
Installation finished. No error reported.
$ grub-mkconfig -o /boot/grub/grub.cfg
Generating grub configuration file ...
  /run/lvm/lvmetad.socket: connect failed: No such file or directory
  WARNING: Failed to connect to lvmetad. Falling back to internal scanning.
  ...
Found linux image: /boot/vmlinuz-linux
Found initrd image: /boot/initramfs-linux.img
Found fallback initramfs image: /boot/initramfs-linux-fallback.img
  ...
done
```

#### HP Envy Workaround

I ran into a particular problem with the HP Envy where if I rebooted at this stage, the computer would attempt to start Windows that was no longer there. This seems to be an issue with certain products and I was able to find a similar situation on the Arch site with the [HP EliteBook 840 G1](https://wiki.archlinux.org/index.php/HP_EliteBook_840_G1) article.

The workaround is the following:

```
$ cd /boot/EFI/Microsoft/Boot
$ cp ../../arch_grub/grubx64.efi bootmgfw.efi
```

I missed this step the first time I performed the installation but I was able to fix it without performing a full re-install by doing the following:

- Boot off of the original ArchLinux USB
- At the root prompt, make a *boot* folder under */mnt*
- Mount the *sda2* partition on */mnt/boot*
- Change to the */mnt/boot/EFI/Microsoft/Boot* folder
- Copy the grubx64.efi file into the current folder as *bootmgfw.ef*
- Change back to the */* folder
- Unmount the */mnt/boot* filesystem 
- Reboot out of the live USB system

### Reboot 

I have completed the setup of the system and am ready to reboot into it. I need to exit the change root environment and reboot via the commands below.

```
$ exit
$ reboot
```


## Wrap Up

At this stage my system is up and ready for additional package installations. The first package I will install is an SSH server so that I can remotely control this machine in the future. I am going to give the quick and dirty setup below but you should refer to the excellent ArchLinux wiki article [here](https://wiki.archlinux.org/index.php/Secure_Shell) for more details.

```
$ su -
<enter root password>
$ pacman -S openssh
$ systemctl enable sshd.socket
$ systemctl start sshd.socket
```

