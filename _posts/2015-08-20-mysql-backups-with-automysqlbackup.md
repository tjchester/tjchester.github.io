---
layout: post
title: "MySQL Backups with AutoMySQLBackup"
description: "Describes how to setup AutoMySQLBackup to perform scheduled backups of your MySQL database and then to rsync a redundant copy to another computer."
category: HowTo
tags: [Linux, MySQL, Mac OS X]
image: 
  feature: layout-posts.jpg
comments: false
---

This walk-through will describe how to configure AutoMySQLBackup to perform scheduled backups of a MySQL database and then use rsync to make a redundant copy to another computer. For this example, I will be show how it can be used to backup databases on a hosted server and then sending a copy of those backups to our computer at home.

<!-- more -->

To limit the scope of this article I am going to assume that you already have a functioning MySQL server with databases that you want to backup. In addition, I am going to assume that you have root level authority to the computer where MySQL is installed. 

For the purposes of the examples in this article I am going to use an [ArchLinux](https://www.archlinux.org) [vagrant](https://www.vagrantup.com) box with [MariaDB](https://mariadb.org) and the *world* database from [here](http://dev.mysql.com/doc/index-other.html).

> To differentiate commands entered on the vagrant machine vs the local Mac computer, I will use **[vagrant@arch ~]$** vs **$** respectively for the command prompt indicators.

## Software

The first step is to download a copy of the AutoMySQLBackup software to the database server. The canonical site is located [here](http://sourceforge.net/projects/automysqlbackup/). The latest update, at the time of this article, was v3.0 RC6 (*automysqlbackup-v3.0_rc6.tar.gz*) released in December 2011.

> The maintainer mentioned on this site that he would like to hand it off to another person who has the time and interest to keep updating it. Consequently, there are several forks and backup copies of this script on [GitHub](http://github.com) as well.

To paraphrase the project's site, this software will help maintain a rotated copy of daily, weekly, and monthly backups of one or multiple MySQL databases.

## Installation

> The release package contains an *install.sh* script but I was unable to get it to run successfully. Since the *application* only consists of a shell script and a configuration file, we can just handle the installation manually.

```
[vagrant@arch ~]$ mkdir -p ~/database/backups
[vagrant@arch ~]$ mkdir -p ~/database/scripts
[vagrant@arch ~]$ cp automysqlbackup ~/database/scripts
[vagrant@arch ~]$ cp automysqlbackup.conf ~/database/scripts
[vagrant@arch ~]$ chmod +x automysqlbackup
```

## Configuration

Edit the **automysqlbackup.conf** file using your favorite editor. At a minimum you should customize the parameters related to database username, password, host, and backup folder.

> NOTE: Any line that starts with a hash mark, *#*, is considered a comment and the value shown will be the default. This means that any parameters that you want to change will need the leading *#* character removed in order for your value to be used.

- Username to use to connect to the database server
  - [Default] #CONFIG\_mysql\_dump_username='root'

- Password to use to connect to the database server
  - [Default] #CONFIG\_mysql\_dump\_password=''

- Host to use to connect to the database server
  - [Default] #CONFIG\_mysql\_dump\_host='localhost'

- Folder name to use for hold the database backups
  - [Default] #CONFIG\_backup\_dir='/var/backup/db'

- List of database names to backup daily
  - [Default] #CONFIG\_db\_names=()

- List of database names to backup monthly
  - [Default] #CONFIG\_db\_month\_names=()

> NOTE: For any of the CONFIG\_db\_\* arrays if you leave the default value then that implies all databases will be backed up. Otherwise you should one or more comma separated database names enclosed in single quotations marks. For example to backup the *test* and *marketing* databases daily you would enter a *CONFIG\_db\_names=('test','marketing')*


## Running Manually

Assuming at this stage we have installed the script and modified the configuration file, before we automate the backups with cron, we should run the backup manually to make sure it works.

Within a shell window, either on the host or remotely via SSH, you want to run the script passing the **-c** parameter to identify the configuration file to use, and the **-b** parameter to perform a backup.

In the window below, we can see the command and its results.

```
[vagrant@arch ~]$ /home/vagrant/database/scripts/automysqlbackup -c /home/vagrant/database/scripts/automysqlbackup.conf -b

Using "/home/vagrant/database/scripts/automysqlbackup.conf" as optional config file.

MySQL backup method invoked.


# Checking for permissions to write to folders:
base folder /home/vagrant/database ... exists ... ok.
backup folder /home/vagrant/database/backups ... exists ... writable? yes. Proceeding.
checking directory "/home/vagrant/database/backups/daily" ... exists.
checking directory "/home/vagrant/database/backups/weekly" ... exists.
checking directory "/home/vagrant/database/backups/monthly" ... exists.
checking directory "/home/vagrant/database/backups/latest" ... exists.
checking directory "/home/vagrant/database/backups/tmp" ... exists.
checking directory "/home/vagrant/database/backups/fullschema" ... exists.
checking directory "/home/vagrant/database/backups/status" ... exists.

# Testing for installed programs
WARNING: Turning off multicore support, since pigz isn't there.
mysql ... found.
mysqldump ... found.

# Parsing databases ... done.
======================================================================
AutoMySQLBackup version 3.0
http://sourceforge.net/projects/automysqlbackup/

Backup of Database Server - localhost
Databases - world
Databases (monthly) - world
======================================================================
======================================================================
Dump full schema.

Rotating 4 month backups for 

======================================================================

======================================================================
Dump status.

Rotating 4 month backups for 

======================================================================

Backup Start Time Wed Aug 19 16:06:42 EDT 2015
======================================================================
Daily Backup ...

Daily Backup of Database ( world )
Rotating 6 day backups for world
----------------------------------------------------------------------

Backup End Time Wed Aug 19 16:06:42 EDT 2015
======================================================================
Total disk space used for backup storage...
Size - Location
744K /home/vagrant/database/backups

======================================================================
```


## Running Automatically With Cron

> NOTE: By default, ArchLinux, used in this example, uses [Systemd Timers](https://wiki.archlinux.org/index.php/Systemd/Timers) but since we are emulating a hosted server situation, it is most likely that cron will be available so we will use that instead.

Setting up periodic jobs will vary among the hosted server implementations, so for our purposes we are going to assume that user crontab files are allowed.

To edit an existing file or create a new one we use the **-e** parameter to the **crontab** program.

In the example below I am configuring the backup to run everyday at 4:50 PM (server time).

```
[vagrant@arch ~]$ crontab -e
no crontab for vagrant - using an empty one

50 16 * * * sh -c $'/home/vagrant/database/scripts/automysqlbackup -c /home/vagrant/database/scripts/automysqlbackup.conf -b'

crontab: installing new crontab
```

The basic format of each line in the crontab file is:

```
[minute] [hour] [day_of_month] [month] [day_of_week] [command_to_run]
```

Where the *minute* ranges from *0* to *59*, the hour ranges from *0* to *23*, the day\_of\_month ranges from *1* to *31*, the month ranges from *1* to *12*, and the day\_of\_week ranges from *0* (i.e. Sunday) to *6*.


To view our existing crontab entries we can use the **-l** parameter:

```
[vagrant@arch ~]$ crontab -l
50 16 * * * sh -c $'/home/vagrant/database/scripts/automysqlbackup -c /home/vagrant/database/scripts/automysqlbackup.conf -b'
```

> NOTE: Typically, but not shown here, you would also configure cron and the backup script to email the results of the run to you so that you know it is running correctly. You don't want to find out that the backups had been failing when you actually need them to perform a restore. Once again, I am going to assume that the hosted server has mail already configured and I am just going to show you what configuration entries to change and how to modify your crontab file.

#### Optional Parameters To Review

Within the **automysqlbackup.conf** file we are going to want to locate the parameters shown below and edit them.

- CONFIG\_mailcontent='log'
- CONFIG\_mail\_address='me@example.com'

In the crontab file, I can also add a *MAILTO* directive as well. Cron has the ability to mail the results from the standard output and standard error output.

```
[vagrant@arch ~]$ crontab -e

MAILTO=me@example.com
50 16 * * * sh -c $'/home/vagrant/database/scripts/automysqlbackup -c /home/vagrant/database/scripts/automysqlbackup.conf -b'

```

## Off-Host Backup

So we have tested the backup manually and scheduled it so that it runs everyday; we now want to setup remote copies of the backups for extra safety.

To accomplish this using an iMac we are going to need to do three things:

1. Configure password-less SSH to the host server for my account
2. Create a shell script that will use rsync over SSH to perform the copies
3. Create a *launchd* agent script to run the copy at scheduled intervals

### Set Password-less SSH

> When I was initially setting this up I was unable to locate the *ssh-copy-id* program so I needed to install it using the [Homebrew](http://brew.sh) package manager.

First I need to generate a public/private key pair for myself. Since I already have one, the example shown below was for the *vagrant* user, but normally you would do it for the user on your Mac that will be receiving the offsite copies.

```
[vagrant@arch ~]$ ssh-keygen

Generating public/private rsa key pair.
Enter file in which to save the key (/home/vagrant/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/vagrant/.ssh/id_rsa.
Your public key has been saved in /home/vagrant/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:j7HRjCnpnaLOBRtWna9s9vY0Xbx9HqMxynJbijtuMKI vagrant@arch
The key's randomart image is:
+---[RSA 2048]----+
|                 |
|       . .       |
|      . o        |
|     . . *     . |
|    + o S +     o|
|   . * * O   . .o|
|    o = % . o+.+o|
|   E o + =+o+.+.+|
|   .+   o=**o.  .|
+----[SHA256]-----+
```

If we look in the *vagrant* user's home directory we can see that an **.ssh** directory has been created and we can see the private key, **id_rsa**, and the public key, **id_rsa.pub**.

```
[vagrant@arch ~]$ ls -al
total 24
drwx------ 4 vagrant vagrant 4096 Aug 19 16:52 .
drwxr-xr-x 3 root    root    4096 Sep 29  2014 ..
-rw------- 1 vagrant vagrant  508 Aug 19 16:33 .bash_history
drwxr-xr-x 4 vagrant vagrant 4096 Aug 14 19:32 database
-rw------- 1 vagrant vagrant   78 Aug 19 16:04 .mysql_history
drwx------ 2 vagrant vagrant 4096 Aug 19 17:00 .ssh
[vagrant@arch ~]$ ls -al .ssh
total 20
drwx------ 2 vagrant vagrant 4096 Aug 19 17:00 .
drwx------ 4 vagrant vagrant 4096 Aug 19 16:52 ..
-rw------- 1 vagrant vagrant  389 Aug 13 04:54 authorized_keys
-rw------- 1 vagrant vagrant 1679 Aug 19 17:00 id_rsa
-rw-r--r-- 1 vagrant vagrant  394 Aug 19 17:00 id_rsa.pub
[vagrant@arch ~]$ 
```

Next we need to get our public key into the **authorized_keys** file on the host server for the user that we will be connecting as. I used the *vagrant* user to demo the creation of the keys,  but in this step I am going to put my public key into the *vagrant* user's *authorized_keys* file using the **ssh-copy-id** command.

```
$ ssh-copy-id vagrant@localhost -p 2222

The authenticity of host '[localhost]:2222 ([127.0.0.1]:2222)' can't be established.
RSA key fingerprint is 02:55:ac:d6:26:19:fe:94:9c:6c:33:8f:c0:39:2a:22.
Are you sure you want to continue connecting (yes/no)? yes
/usr/local/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/local/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
vagrant@localhost's password: 

Number of key(s) added:        1

Now try logging into the machine, with:   "ssh -p '2222' 'vagrant@localhost'"
and check to make sure that only the key(s) you wanted were added.
```

So let's try to login and see if it works without a password.

```
$ ssh vagrant@localhost -p 2222
Last login: Wed Aug 19 16:34:21 2015 from 10.0.2.2
```

> The default vagrant configuration remaps port 2222 on the localhost to port 22 on the virtual machine that is why I specified the *-p 2222* parameter.

### Create rsync Script

All right, the next step is to create the shell script that will perform the copies of the database backups from the remote host.

I am going to use the same folder that my *Vagrantfile* is in for demonstration purposes. I first create a **backup.sh** with the contents below.

```
$ vi ~/Vagrant/mysql/backup.sh

/usr/bin/rsync -az -e 'ssh -p 2222' vagrant@localhost:/home/vagrant/database/backups /Users/tjchester/Vagrant/mysql/
echo "Exit code from rsync: $?"
``` 

So the first part of the script calls the rsync command with the *-a* and *-z* arguments. The *-a* specifies archive mode and the *-z* indicates to use compression on the transfer. The *--delete* option says to delete any local files that do not exist on the remote side. If you want to keep all of your remote backups, then do not add this switch. One use of the *-e* option is to allow me to specify a non-standard SSH port to use. In this case, my vagrant machine exposes port 22 for SSH which is mapped to port 2222 on my host machine.  Next we specify the location to copy files from. Since I am copying from a remote host I specify the user name at (i.e. *@*) the specified host name, a colon, then the absolute path to where the backups are stored. The last argument is where on the local machine the backups should be copied to.

Next we will test it by manually running it.

```
$ cd ~/Vagrant/mysql
$ chmod +x ./backup.sh
$ ./backup.sh
Exit code from rsync: 0
```

### Create Launchd Agent

Finally, we need a mechanism to run the rsync script on a scheduled basis. Fortunately, Mac OS X has such a framework named [launchd](https://en.wikipedia.org/wiki/Launchd).

I just need to create a property list (i.e. plist) file, place in a particular folder, and then register it with the the *launchd* framework.

I first open a terminal, change to my personal **LaunchAgent** folder, create an empty file, and finally edit it using the vi editor. In the example property file shown below, I set the script to be run everyday at 6 AM.

```
$ cd ~/Library/LaunchAgents/
$ touch net.tjc.Backups.plist
$ vi net.tjc.Backups.plist

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
        <dict>
                <key>Label</key>
                <string>net.tjc.Backups</string>
                <key>ProgramArguments</key>
                <array>
                    <string>/bin/bash</string>
                        <string>/Users/tjchester/Vagrant/mysql/backup.sh</string>
                </array>
                <key>StartCalendarInterval</key>
                <dict>
                        <key>Hour</key>
                        <integer>6</integer>
                        <key>Minute</key>
                        <integer>00</integer>
                </dict>
        </dict>
</plist>
$
```         

Next I need to register the property list with the launchd subsystem and then verify it has been accepted. This can be done through the **launchctl** command.

```
$ launchctl load net.tjc.Backups.plist 
$ launchctl list | grep net.tjc.Backups
-	0	net.tjc.Backups
```

> You can unregister a task using the *launchctl unload [name of plist file]* command.

For extra confidence, I am going to want to test it without waiting for 6 AM to role around. I can accomplish this using the aforementioned *launchctl* command. In the case of the *start* command we pass the string value we used for the *label* key in the property list.

```
$ launchctl start net.tjc.Backups
```

# Conclusion

So, in conclusion, with this walk-through I described how to install and configure AutoMySQLBackup to perform scheduled backups of one or more hosted MySQL databases. Then, for extra backup safety, I showed how you can use rsync and launchd on Mac OS X to make regular scheduled copies of the hosted database backups to an offsite machine. While I used a vagrant machine to demo the procedure, the steps are easily translatable to a real server setup.

