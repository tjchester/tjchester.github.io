---
layout: post
title: "Installing ownCloud on ArchLinux"
description: "Describes how to setup a new ownCloud server on an ArchLinux system and start syncing with it from Mac OS X."
category: HowTo
tags: [Linux, ArchLinux, ownCloud, Apple]
image: 
  feature: layout-posts.jpg
comments: false
---

Do you like the idea of DropBox but want to host the files on a server that you control. That is exactly what [ownCloud](https://owncloud.org) allows you to do. This how-to will walkthrough installing ownCloud on an ArchLinux installation and then configuring a Mac client to sync with it.

<!-- more -->

> This how-to assumes that you already have an ArchLinux installation up and running. If not, please see my other article [Setup and ArchLinux System](http://dragonflyreflections.com/howto/setup-an-archlinux-system/) for instructions.

# Install Dependencies

This first step is to visit the ownCloud community [page](https://www.archlinux.org/packages/community/any/owncloud/).

![ownCloud Community Page](/images/posts/installing-owncloud-on-archlinux-01.png)

Within the list of dependencies they are several groups that can be made from which one selection can be made. For instance you can use either Nginx or Apache as the web server; either sqlite, postgresql, or mariadb for the database server; and either apcu or xcache as the PHP accelerator.

I have made the following choices:

* Web Server: Nginx
* Database Server: Mariadb
* PHP Accelerator: xcache

Based on these choices I need to install the following packages:

* nginx
* uwsgi-plugin-php
* mariadb
* php
* php-gd
* php-xcache
* php-mcrypt
* php-intl

These packages can be installed using the command below.

```
$ pacman -S nginx uwsgi-plugin-php mariadb php php-gd php-xcache php-mcrypt php-intl
resolving dependencies...
looking for conflicting packages...
warning: dependency cycle detected:
warning: harfbuzz will be installed before its freetype2 dependency

Packages (43) fontconfig-2.11.1-1  freetype2-2.6-1  gd-2.1.1-2  graphite-1:1.2.4-1
              harfbuzz-0.9.41-1  icu-55.1-1  jansson-2.7-1 jemalloc-3.6.0-1  
              kbproto-1.0.7-1  libice-1.0.9-1  libjpeg-turbo-1.4.1-1  
              libmariadbclient-10.0.20-1  libmcrypt-2.5.8-4
              libpng-1.6.16-1  libsm-1.2.2-2  libtiff-4.0.3-5  libvpx-1.4.0-2
              libx11-1.6.3-1  libxau-1.0.8-2  libxcb-1.11-1  libxdmcp-1.1.2-1
              libxext-1.3.3-1  libxml2-2.9.2-2  libxpm-3.5.11-1  libxt-1.1.5-1
              libyaml-0.1.6-1  libzip-1.0.1-1  mariadb-clients-10.0.20-1
              php-embed-5.6.10-1  python2-2.7.10-1  sqlite-3.8.10.2-1  uwsgi-2.0.10-3
              xcb-proto-1.11-1  xextproto-7.3.0-1  xproto-7.0.28-1
              mariadb-10.0.20-1  nginx-1.8.0-1  php-5.6.10-1  php-gd-5.6.10-1
              php-intl-5.6.10-1  php-mcrypt-5.6.10-1  php-xcache-3.2.0-2
              uwsgi-plugin-php-2.0.10-3

Total Download Size:    52.43 MiB
Total Installed Size:  334.54 MiB

:: Proceed with installation? [Y/n] Y
...
```

The following optional packages enhance the file viewing capabilities within *ownCloud* so I will install them as well:

* exiv2
* ffmpeg
* libreoffice

```
$ pacman -S exiv2 ffmpeg libreoffice
:: There are 2 providers available for libreoffice:
:: Repository extra
   1) libreoffice-fresh  2) libreoffice-still

Enter a number (default=1): 1    
resolving dependencies...
:: There are 4 providers available for libgl:
:: Repository extra
   1) mesa-libgl  2) nvidia-304xx-libgl  3) nvidia-340xx-libgl  4) nvidia-libgl

Enter a number (default=1): 1
:: There are 2 providers available for libx264.so=144-64:
:: Repository extra
   1) libx264  2) libx264-10bit

Enter a number (default=1): 1

Packages (108) alsa-lib-1.0.29-1  boost-libs-1.58.0-2  cairo-1.14.2-1  
               clucene-2.3.3.4-8  damageproto-1.2.1-3  dbus-glib-0.104-1
               desktop-file-utils-0.22-1  elfutils-0.161-3  enca-1.16-1  
               fixesproto-5.0-3  flac-1.3.1-1  fribidi-0.19.6-2  glew-1.12.0-1
               glu-9.0.0-3  gsm-1.0.13-8  gst-plugins-base-libs-1.4.5-1  
               gstreamer-1.4.5-1  harfbuzz-icu-0.9.41-1  hicolor-icon-theme-0.13-1
               hunspell-1.3.3-1  hyphen-2.8.8-1  inputproto-2.3.1-1  
               json-c-0.12-2  lame-3.99.5-2  lcms2-2.7-1  libabw-0.1.1-1  
               libass-0.12.3-1 libasyncns-0.8-5  libbluray-0.8.1-1  libcdr-0.1.1-2
               libdatrie-0.2.8-1  libdrm-2.4.62-1  libe-book-0.1.2-2  
               libetonyek-0.1.3-1 libmodplug-0.8.8.5-1  libmspub-0.1.2-2
               libmwaw-0.3.5-1  libodfgen-0.1.4-1  libogg-1.3.2-1 
               libomxil-bellagio-0.9.3-1 libpagemaker-0.0.2-1  libpciaccess-0.13.4-1
               libpulse-6.0-2 librevenge-0.0.2-1  libsndfile-1.0.25-3  libssh-0.7.0-2
               libthai-0.1.21-1  libtheora-1.1.1-3  libtxc_dxtn-1.0.1-6  libva-1.6.0-1
               libvdpau-1.1-1  libvisio-0.1.1-2  libvorbis-1.3.5-1
               libwpd-0.10.0-1  libwpg-0.3.0-1  libx264-2:144.20150223-1  
               libxdamage-1.1.4-2  libxfixes-5.0.1-1  libxft-2.3.2-1  libxi-1.7.4-1
               libxinerama-1.1.3-2  libxmu-1.1.2-1  libxrandr-1.5.0-1  
               libxrender-0.9.9-1  libxshmfence-1.2-1  libxslt-1.1.28-3
               libxtst-1.2.2-1  libxv-1.0.10-1  libxxf86vm-1.1.4-1  
               llvm-libs-3.6.1-1  lpsolve-5.5.2.0-3  mesa-10.6.1-1 
               mesa-libgl-10.6.1-1 neon-0.30.1-1  nspr-4.10.8-1  nss-3.19.2-2
               opencore-amr-0.1.3-2  openjpeg-1.5.2-1  opus-1.1-1  orc-0.4.23-1
               pango-1.36.8-1 pixman-0.32.6-1  poppler-0.33.0-1  python-3.4.3-2
               randrproto-1.5.0-1  raptor-2.0.15-2  rasqal-1:0.9.33-1  recode-3.6-8
               recordproto-1.14.2-2  redland-1:1.0.17-2  renderproto-0.11.1-3  
               schroedinger-1.0.11-2  sdl-1.2.15-7  shared-mime-info-1.4-1
               speex-1.2rc2-1  speexdsp-1.2rc3-2  v4l-utils-1.6.3-1  
               videoproto-2.3.2-1  wayland-1.8.1-1  x265-1.7-2
               xdg-utils-1.1.0.git20150323-1  xf86vidmodeproto-2.3.1-3  
               xineramaproto-1.2.1-3  xorg-xset-1.2.3-1  xvidcore-1.3.4-1
               exiv2-0.24-1  ffmpeg-1:2.7.1-1  libreoffice-fresh-4.4.4-1

Total Download Size:   155.87 MiB
Total Installed Size:  741.01 MiB

:: Proceed with installation? [Y/n] Y
...
```

# Install ownCloud

Now that I have the dependencies installed *(note I still need to configure them)*, I am going to install the base *ownCloud* package using the command below.

```
$ pacman -S owncloud
resolving dependencies...
looking for conflicting packages...

Packages (1) owncloud-8.0.4-2

Total Download Size:   10.37 MiB
Total Installed Size:  62.76 MiB

:: Proceed with installation? [Y/n] Y
...
```

# Configure Dependencies

Now that the base packages are installed, I need to complete configuration before I can launch the service; specifically I need to configure *PHP*, *Nginx+uWSGI*, and *Mariadb*.


## PHP

I need to edit the PHP configuration file to activate several extensions that will be needed by ownCloud.

To activate an extension, I will need to uncomment them within the *php.ini* file by removing the leading semi-colon (i.e. ";") from the extension line. For example, changing *;extension=curl.so* to *extension=curl.so* activates the curl extension.


```
$ vi /etc/php/php.ini
...
extension=bz2.so
extension=curl.so
extension=exif.so
extension=gd.so
extension=iconv.so
extension=intl.so
extension=mcrypt.so
extension=mysql.so
extension=pdo_mysql.so
extension=posix.so
extension=xmlrpc.so
extension=zip.so
...
```

I also need to activate the *xcache* extension by editing its configuration file as well.

```
$ vi /etc/php/conf.d/xache.ini
extension=xcache.so   ; <-- Remove leading semi-colon on this line only
xcache.size=64M
xcache.var_size=64M
```

## Nginx

Next I am going to configure the virtual host in the web server. I customized the example configuration [here](https://wiki.archlinux.org/index.php/OwnCloud) to change the listening port and the listening server name to my server's host name.

```
$ vi /etc/nginx/nginx.conf
...

http {

...

    # Start of new server section
    server {
        listen       8080;        # <-- Port my instance will listen on
        server_name  owncloud;    # <-- Host name my instance will listen on
      
        # This is to avoid Request Entity Too Large error
        client_max_body_size 1000M;

        # Deny access to some special files
        location ~ ^/(data|config|\.ht|db_structure\.xml|README) {
            deny all;
        }

        # Pass all .php or .php/path urls to uWSGI
        location ~ ^(.+\.php)(.*)$ {
            include uwsgi_params;
            uwsgi_modifier1 14;
            # Uncomment line below if you get connection refused error. Remember
            # to comment out line with "uwsgi_pass 127.0.0.1:3001;" below
            #uwsgi_pass unix:/run/uwsgi/owncloud.sock;
            uwsgi_pass 127.0.0.1:3001;
        }

        # Everything else goes to the filesystem,
        # but / will be mapped to index.php and run through uwsgi
        location / {
            root /usr/share/webapps/owncloud;
            index index.php;
            rewrite ^/.well-known/carddav /remote.php/carddav/ redirect;
            rewrite ^/.well-known/caldav /remote.php/caldav/ redirect;
        }
    }
    # End of new server section

} # http
```

## uWSGI 

Next I am going to configure the uWSGI plugin which will act as the application server running the PHP code on behalf of the web server. In this case, I just used the base configuration given [here](https://wiki.archlinux.org/index.php/OwnCloud).

**NOTE**: The example configuration specifies the *owncloud_data_dir* as */usr/share/webapps/owncloud/data* which by default does not exist. If you choose to use this location or specify a new one then remember that you will need to manually create it before trying to start the uWSGI service.


```
$ vi /etc/uwsgi/owncloud.ini

[uwsgi]
master = true
socket = 127.0.0.1:3001

# Change this to where you want ownlcoud data to be stored (maybe /home/owncloud)
owncloud_data_dir = /usr/share/webapps/owncloud/data/ 
chdir             = %(owncloud_data_dir)

plugins = php
php-docroot     = /usr/share/webapps/owncloud
php-index       = index.php

# only allow these php files, I do not want to inadvertently run something else
php-allowed-ext = /index.php
php-allowed-ext = /public.php
php-allowed-ext = /remote.php
php-allowed-ext = /cron.php
php-allowed-ext = /status.php
php-allowed-ext = /settings/apps.php
php-allowed-ext = /core/ajax/update.php
php-allowed-ext = /core/ajax/share.php
php-allowed-ext = /core/ajax/requesttoken.php
php-allowed-ext = /core/ajax/translations.php
php-allowed-ext = /search/ajax/search.php
php-allowed-ext = /search/templates/part.results.php
php-allowed-ext = /settings/admin.php
php-allowed-ext = /settings/users.php
php-allowed-ext = /settings/personal.php
php-allowed-ext = /settings/help.php
php-allowed-ext = /settings/ajax/getlog.php
php-allowed-ext = /settings/ajax/setlanguage.php
php-allowed-ext = /settings/ajax/setquota.php
php-allowed-ext = /settings/ajax/userlist.php
php-allowed-ext = /settings/ajax/createuser.php
php-allowed-ext = /settings/ajax/removeuser.php
php-allowed-ext = /settings/ajax/enableapp.php
php-allowed-ext = /core/ajax/appconfig.php
php-allowed-ext = /settings/ajax/setloglevel.php
php-allowed-ext = /ocs/v1.php

# set php configuration for this instance of php, no need to edit global php.ini
php-set = date.timezone=Etc/UTC
php-set = open_basedir=%(owncloud_data_dir):/tmp/:/usr/share/pear/:/usr/share/webapps/owncloud:/etc/webapps/owncloud
php-set = session.save_path=/tmp
php-set = post_max_size=1000M
php-set = upload_max_filesize=1000M
php-set = always_populate_raw_post_data=-1

# load all extensions only in this instance of php, no need to edit global php.ini
php-set = extension=bz2.so
php-set = extension=curl.so
php-set = extension=intl.so
php-set = extension=openssl.so
php-set = extension=pdo_sqlite.so
php-set = extension=exif.so
php-set = extension=gd.so
php-set = extension=imagick.so
php-set = extension=gmp.so
php-set = extension=iconv.so
php-set = extension=mcrypt.so
php-set = extension=sockets.so
php-set = extension=sqlite3.so
php-set = extension=xmlrpc.so
php-set = extension=xsl.so
php-set = extension=zip.so

processes = 10
cheaper = 2
cron = -3 -1 -1 -1 -1 /usr/bin/php -f /usr/share/webapps/owncloud/cron.php 1>/dev/null
```

Now I just need to create the data directory that I specified in the configuration above.

```
$ mkdir /usr/share/webapps/owncloud/data
$ chown root:http /usr/share/webapps/owncloud/data
```

## Mariadb

The setup of the database server involves installing the system database, enabling/starting the service, and then using the supplied script to configure the baseline security.

### Install the system database

```
$ mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
Installing MariaDB/MySQL system tables in '/var/lib/mysql' ...
150705 15:25:30 [Note] /usr/sbin/mysqld (mysqld 10.0.20-MariaDB-log) starting as process 4742 ...
150705 15:25:30 [Note] InnoDB: Using mutexes to ref count buffer pool pages
150705 15:25:30 [Note] InnoDB: The InnoDB memory heap is disabled
150705 15:25:30 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
150705 15:25:30 [Note] InnoDB: Memory barrier is not used
150705 15:25:30 [Note] InnoDB: Compressed tables use zlib 1.2.8
150705 15:25:30 [Note] InnoDB: Using Linux native AIO
150705 15:25:30 [Note] InnoDB: Using CPU crc32 instructions
150705 15:25:30 [Note] InnoDB: Initializing buffer pool, size = 128.0M
150705 15:25:30 [Note] InnoDB: Completed initialization of buffer pool
150705 15:25:30 [Note] InnoDB: The first specified data file ./ibdata1 did not exist: a new database to be created!
150705 15:25:30 [Note] InnoDB: Setting file ./ibdata1 size to 12 MB
150705 15:25:30 [Note] InnoDB: Database physically writes the file full: wait...
150705 15:25:30 [Note] InnoDB: Setting log file ./ib_logfile101 size to 48 MB
150705 15:25:30 [Note] InnoDB: Setting log file ./ib_logfile1 size to 48 MB
150705 15:25:30 [Note] InnoDB: Renaming log file ./ib_logfile101 to ./ib_logfile0
150705 15:25:30 [Warning] InnoDB: New log files created, LSN=45781
150705 15:25:30 [Note] InnoDB: Doublewrite buffer not found: creating new
150705 15:25:31 [Note] InnoDB: Doublewrite buffer created
150705 15:25:31 [Note] InnoDB: 128 rollback segment(s) are active.
150705 15:25:31 [Warning] InnoDB: Creating foreign key constraint system tables.
150705 15:25:31 [Note] InnoDB: Foreign key constraint system tables created
150705 15:25:31 [Note] InnoDB: Creating tablespace and datafile system tables.
150705 15:25:31 [Note] InnoDB: Tablespace and datafile system tables created.
150705 15:25:31 [Note] InnoDB: Waiting for purge to start
150705 15:25:31 [Note] InnoDB:  Percona XtraDB (http://www.percona.com) 5.6.24-72.2 started; log sequence number 0
150705 15:25:31 [Warning] Failed to load slave replication state from table mysql.gtid_slave_pos: 1146: Table 'mysql.gtid_slave_pos' doesn't exist
150705 15:25:32 [Note] InnoDB: FTS optimize thread exiting.
150705 15:25:32 [Note] InnoDB: Starting shutdown...
150705 15:25:34 [Note] InnoDB: Shutdown completed; log sequence number 1616697
OK
Filling help tables...
150705 15:25:34 [Note] /usr/sbin/mysqld (mysqld 10.0.20-MariaDB-log) starting as process 4771 ...
150705 15:25:34 [Note] InnoDB: Using mutexes to ref count buffer pool pages
150705 15:25:34 [Note] InnoDB: The InnoDB memory heap is disabled
150705 15:25:34 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
150705 15:25:34 [Note] InnoDB: Memory barrier is not used
150705 15:25:34 [Note] InnoDB: Compressed tables use zlib 1.2.8
150705 15:25:34 [Note] InnoDB: Using Linux native AIO
150705 15:25:34 [Note] InnoDB: Using CPU crc32 instructions
150705 15:25:34 [Note] InnoDB: Initializing buffer pool, size = 128.0M
150705 15:25:34 [Note] InnoDB: Completed initialization of buffer pool
150705 15:25:34 [Note] InnoDB: Highest supported file format is Barracuda.
150705 15:25:34 [Note] InnoDB: 128 rollback segment(s) are active.
150705 15:25:34 [Note] InnoDB: Waiting for purge to start
150705 15:25:34 [Note] InnoDB:  Percona XtraDB (http://www.percona.com) 5.6.24-72.2 started; log sequence number 1616697
150705 15:25:34 [Note] InnoDB: FTS optimize thread exiting.
150705 15:25:34 [Note] InnoDB: Starting shutdown...
150705 15:25:36 [Note] InnoDB: Shutdown completed; log sequence number 1616707
OK

To start mysqld at boot time you have to copy
support-files/mysql.server to the right place for your system

PLEASE REMEMBER TO SET A PASSWORD FOR THE MariaDB root USER !
To do so, start the server, then issue the following commands:

'/usr/bin/mysqladmin' -u root password 'new-password'
'/usr/bin/mysqladmin' -u root -h owncloud password 'new-password'

Alternatively you can run:
'/usr/bin/mysql_secure_installation'

which will also give you the option of removing the test
databases and anonymous user created by default.  This is
strongly recommended for production servers.

See the MariaDB Knowledgebase at http://mariadb.com/kb or the
MySQL manual for more instructions.

You can start the MariaDB daemon with:
cd '/usr' ; /usr/bin/mysqld_safe --datadir='/var/lib/mysql'

You can test the MariaDB daemon with mysql-test-run.pl
cd '/usr/mysql-test' ; perl mysql-test-run.pl

Please report any problems at http://mariadb.org/jira

The latest information about MariaDB is available at http://mariadb.org/.
You can find additional information about the MySQL part at:
http://dev.mysql.com
Support MariaDB development by buying support/new features from MariaDB
Corporation Ab. You can contact us about this at sales@mariadb.com.
Alternatively consider joining our community based development effort:
http://mariadb.com/kb/en/contributing-to-the-mariadb-project/
```

### Enable and start the service

```
$ systemctl enable mysqld.service
Created symlink from /etc/systemd/system/multi-user.target.wants/mysqld.service to /usr/lib/systemd/system/mysqld.service.
$ systemctl start mysqld.service
```

### Secure the installation

```
$ mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none): 

OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n] y
New password: 
Re-enter new password: 
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] y
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

### Create the ownCloud Database and User

Next I am going to create the database that the *ownCloud* service will use as well as the user it will connect with.

**NOTE:** that user and password values you choose should be appropriate for the amount of security you need in your environment. In my case, a home server for my use does not require a complicated username and password.

```
$ mysql -u root -p
Enter password: 

Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 12
Server version: 10.0.20-MariaDB-log MariaDB Server

Copyright (c) 2000, 2015, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE owncloud;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> CREATE USER 'owncloud'@'localhost' IDENTIFIED BY 'owncloud';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON owncloud.* TO 'owncloud'@'localhost';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> quit;
Bye
```

# Enable and Start the Service

I am now ready to enable and start the services and perform the initial web based setup process for *ownCloud*.

```
$ systemctl enable nginx
Created symlink from /etc/systemd/system/multi-user.target.wants/nginx.service to /usr/lib/systemd/system/nginx.service.
$ systemctl enable uwsgi@owncloud
Created symlink from /etc/systemd/system/multi-user.target.wants/uwsgi@owncloud.service to /usr/lib/systemd/system/uwsgi@.service.
$ systemctl start nginx
$ systemctl start uwsgi@owncloud
```

# Perform Inital Setup

With the services running, I should be able to open a web browser to the host and port I specified: http://owncloud:8080/

**NOTE:** On my home network I needed to add a host entry to Mac OS X by adding an entry to the */private/etc/hosts* file.

I filled out the form similar to the image below and then clicked the *Finished* button.

![Initial Web Setup](/images/posts/installing-owncloud-on-archlinux-02.png)

After clicking *Finished* you are presented with the following screen.

![Initial Admin Logon](/images/posts/installing-owncloud-on-archlinux-03.png)

## Download Desktop Client

I am going to download the desktop client here by clicking the *Desktop app* button.

Click the *Desktop Clients* button under the *Sync* section.

![Desktop Clients](/images/posts/installing-owncloud-on-archlinux-07.png)

On the next screen, I click the button that is appropriate for the operating system I am downloading the client for.

![Mac OS X Client Download](/images/posts/installing-owncloud-on-archlinux-08.png)


## Create non-admin user

The web setup created the first admin user but in this step I want to create a non-admin user for myself. This is the user that I will setup within the desktop client to actually start syncing with the server.

From the dropdown menu in the upper right, select *Users*.

![Admin Dropdown Menu](/images/posts/installing-owncloud-on-archlinux-04.png)

Fill out the user and password boxes at the top of the screen and then click the *Create* button.

![Create User Form](/images/posts/installing-owncloud-on-archlinux-05.png)

Viewing the user list with my new user created.

![User List View](/images/posts/installing-owncloud-on-archlinux-06.png)


## Install and Configure the Desktop Client

### Download Desktop Client
The desktop client can be downloaded from the *ownCloud* website via the links that are displayed when a user first logs into the web interface.

The installation of the client is straight forward and I am going to show the installation steps without any additional explanation.

#### Step 1

![Install Desktop Client Step 1](/images/posts/installing-owncloud-on-archlinux-09.png)

#### Step 2

![Install Desktop Client Step 2](/images/posts/installing-owncloud-on-archlinux-10.png)

#### Step 3

![Install Desktop Client Step 3](/images/posts/installing-owncloud-on-archlinux-11.png)


### Configure desktop client

The final step is to connect the desktop client with my server instace.

The first setup page requests the *http* or *https* url (server and port) that my instance is listening on. From my setup I know that this is *http://owncloud:8080*.

![Configure Desktop Client Step 1](/images/posts/installing-owncloud-on-archlinux-12.png)

The next setup page requests the user id and password that will be used to connect to the instance. I will fill in the information I used to previously create my non-admin user.

![Configure Desktop Client Step 2](/images/posts/installing-owncloud-on-archlinux-13.png)

The next step asks me what I want to synchronize and where I want to synchronize from. The wizard supplied intelligent defaults so I went with those.

![Configure Desktop Client Step 3](/images/posts/installing-owncloud-on-archlinux-14.png)

On the last setup page I just clicked the *Finish* button.

![Configure Desktop Client Step 4](/images/posts/installing-owncloud-on-archlinux-15.png)

# Wrap-Up

At this stage I have successfully installed the *ownCloud* service and configured the desktop client to sync with it. The image below shows that the contents of the folder in my home directory are in sync with the web interface on the server.

![Desktop in Sync With Server](/images/posts/installing-owncloud-on-archlinux-16.png)

From here I can install additional applications to extend the functionality of my *ownCloud* instance. I can also look into securing the communication between the desktop client and the server with *https* as the client recommended.

