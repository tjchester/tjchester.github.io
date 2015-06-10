---
layout: post
title: "Monitoring RabbitMQ Hosted on Microsoft Windows"
description: "Describes how to configure a Zenoss instance to monitor a RabbitMQ instance hosted on a Windows Server."
category: TechNote
tags: [Windows Server, RabbitMQ, Zenoss]
image: 
  feature: layout-posts.jpg
comments: false 
---

This post will discuss how to monitor a Windows hosted RabbitMQ installation from a Linux based Zenoss monitor using the RabbitMQ plugin. 

<!-- more -->

Before we begin there is an assumption being made that you already have a Windows server running a RabbitMQ instance and that you also have an existing Zenoss server setup for monitoring.

With those requirements out of the way, there are three basic steps to the process:

1. Configure SSH server on Windows
2. Install Zenoss RabbitMq plugin
3. Configure Zenoss to monitor RabbitMq on Windows

> Note that these instructions were created on a Zenoss 3.2, what is considered a [legacy](http://wiki.zenoss.org/Legacy_Zenoss) version. For the most part the instructions should apply from version 3.2.x to 4.2.x.

## Install and Configure SSH Service on Windows Host

The Zenoss command runner will SSH into the Windows machine and run a batch file that is masquerading as the *rabbitmqctl* program typically found on Linux Rabbit installations.

> See also [Setup an SSH Server in Vista](http://www.petri.co.il/setup-ssh-server-vista.htm)

The first part of these instructions will install the SSH server service using Cygwin.

- Logon to the Windows machine as a local administrator
- Download [Cygwin](http://cygwin.com) installer
- Run setup program
- From package selection expand **Net** category and select **OpenSSH**
- Finsh the installation
- Run the Cygwin terminal as Administrator (elevated command prompt)
- Run the **ssh-host-config** program
- Answer **yes** to **Should privilege separation be used?**
- Answer **yes** to **Should this script create a local user 'sshd' on this machine**
- Answer **yes** to **Do you want to install sshd as a service?**
- Answer **no** to **Should this script create a new local account 'ssh_server' which has the required privileges?**
- When prompted for a username and password for the service, enter an existing local Windows account that has adminstrator privileges
- Answer **ntsec tty** for **Which value should the environment variable CYGWIN have when sshd starts?**
- Finish the configuration
- Start the service with **net start sshd**


The second step is to create a batch file that will wrap the **rabbitmqctl** batch file that is installed along with RabbitMQ.

> I found this extra step to be necessary for a couple of reasons including the Zenoss SSH session not being able to find the command if it wasn't in the *System32* folder, the Zenoss plugin expects the command to be *rabbitmqctl* with no file extension, and the *ERLANG_HOME* environment variable did not get exposed to the Cygwin environment.

- Create a text file named **rabbitmqctl** in the **C:\Windows\System32** folder with the following contents:

```
ERLANG_HOME="C:\Program Files\erl5.10.3"

export ERLANG_HOME

cmd.exe /c "C:\\PROGRA~2\\RABBIT~1\\RABBIT~1.0\\sbin\\rabbitmqctl.bat $*"

REM Use the short path information to the SBIN folder because the SSH 
REM session from Zenoss will have trouble if this path contains spaces.
REM You can get the short file names by running the DIR command with the
REM /X parameter.
    
REM Also note that the global Windows environment does not fully apply to
REM SSH sessions and therefore the ERLANG_HOME variable is not typically
REM set. Set it explicity here to the applicable Erlang installation on 
REM your Windows machine.
```  

> This batch file assumes that Erlang 5.10.3 is installed. If you install a different version then you will need to update the *ERLANG_HOME* variable in the script. Also take note of the *REM* statements so that you identify the proper short names for the folders that the *rabbitmqctl.bat* file resides in.


## Install RabbitMQ Plugin on Zenoss Host

This step downloads the RabbitMQ Plugin and installs it into the Zenoss instance.

- Download Zenoss RabbitMq [Plugin](http://wiki.zenoss.org/ZenPack:RabbitMQ) zip file from [Github](https://github.com/zenoss/rabbitmq)

### For the packaged egg

- Download the egg file appropriate for your version of Zenoss
- Ensure you are logged in as the *zenoss* user

```
$ zenpack --install ZenPacks.zenoss.RabbitMQ-*.egg
$ zenoss restart
```

### For the developer version

- Download the source file appropriate for your version of Zenoss
- Change into the ZenPacks.zenoss.RabbitMq-develop folder

```
$ python setup.py build
$ python setup.py install
$ cd dist
$ zenpack --install ZenPacks.zenoss.RabbitMQ-*.egg
```

> The developer version instructions worked under Python 2.6 with version 1.0.6 of the plugin. Newer versions of the plugin may build differently.

  
## Setup the Monitor in Zenoss

In this last step, I will configure the monitor for my Windows host via the installed plugin.

- Open a web browser to the Zenoss web administration interface
- Locate the server that you want to monitor and edit its configuration
- Click **Configuration Properties**
- Fill out the zencommand properties with an Windows Administrator
  - zCommandUsername
  - zCommandPassword
- Click **Modeler Plugins**
- Locate **zenoss.ssh.RabbitMQ** plugin in the *Available* list of plugins
- Click the **->** button to add this plugin to the server list
- Click the **Save** button to save the modeler plugin
- Click the **Model Device...** option to activate the plugin
- After a few moments the server model will now have the following new components:
  - RabbitMQ Exchanges
  - RabbitMQ Nodes
  - RabbitMQ VHosts
  - RabbitMQ Queues
