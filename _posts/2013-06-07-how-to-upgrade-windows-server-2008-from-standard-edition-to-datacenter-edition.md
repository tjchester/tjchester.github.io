---
layout: post
title: "How To Upgrade Windows Server 2008 from Standard Edition to Datacenter Edition"
description: "Describes how to upgrade Windows Server from Standard Edition to the Datacenter edition."
category: HowTo
tags: [Windows Server, DISM]
image: 
  feature: layout-posts.jpg
comments: false
---

This post describes a process for upgrading a Microsoft Windows Server 2008 R2 Standard edition to the Datacenter edition using generic Key Management Server (KMS) keys.

<!-- more -->

### See Also ###

- Microsoft TechNet – KMS Client Setup Keys
  - [http://technet.microsoft.com/en-us/library/ff793421.aspx](http://technet.microsoft.com/en-us/library/ff793421.aspx "KMS Client Setup Keys at TechNet")
- Microsoft TechNet – Windows Server 2008 R2 Upgrade Paths
  - [http://technet.microsoft.com/en-us/library/dd979563(v=WS.10).aspx](http://technet.microsoft.com/en-us/library/dd979563(v=WS.10).aspx "Windows 2008 R2 Upgrade Paths at TechNet")

## Procedure ##

The **Deployment Image Servicing and Management Tool (DISM)** will work for what you need to do, but it has to be done according to the supported upgrade path:

- Windows Server 2008 R2 Standard 
  - Windows Server 2008 R2 Enterprise
	  - Windows Server 2008 R2 Datacenter

*NOTE: If the server you are trying to upgrade is a domain controller then you will need to demote it first, convert it, and then promote it again.*
 
*NOTE: All of the steps below need to be run from an elevated command prompt.*

### Upgrade Server Version to Enterprise ###

    DISM /online /Get-CurrentEdition
 
![Use DISM to check for current edition](/images/posts/how-to-upgrade-windows-server-2008-from-standard-edition-to-datacenter-edition-1.png)

    DISM /online /Get-TargetEditions

![Use DISM to activate enterprise edition](/images/posts/how-to-upgrade-windows-server-2008-from-standard-edition-to-datacenter-edition-2.png)
 
    DISM /online /Set-Edition:ServerEnterprise /ProductKey:489J6-VHDMP-X63PK-3K798-CPX3Y

(Reboot recommended, note several automatic reboots may occur as part of the upgrade process)

### Upgrade Server Version to Datacenter ###

    DISM /online /Get-CurrentEdition
    DISM /online /Get-TargetEditions
    DISM /online /Set-Edition:ServerDataCenter /ProductKey:74YFP-3QFB3-KQT8W-PMXWJ-7M648

(Reboot recommended, note several automatic reboots may occur as part of the upgrade process)

### Confirm Server Version is Datacenter ###

    DISM /online /Get-CurrentEdition
 
![Use DISM to check for current edition](/images/posts/how-to-upgrade-windows-server-2008-from-standard-edition-to-datacenter-edition-3.png)

### Activate server ###

Check the server properties page from the Control Panel application (Control Panel -> System and Security -> System) to see if activation is needed. If the activation fails with the Key Management Server (KMS) then you can try to activate using a Multiple Activation Key (MAK).
