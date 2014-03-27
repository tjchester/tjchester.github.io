---
layout: post
title: "ConvertStringSidToSid Error from the Volume Shadow Copy Service"
description: "Describes how to fix an invalid SID error from the VSS service."
category: TechNote
tags: [Windows Server, Registry]
image: 
  feature: layout-posts.jpg
comments: false
---

In this post we discuss how to fix the ConvertStringSidToSid error from the Volume Shadow Copy Service.

<!-- more -->

## Symptoms ##
You see the following error recorded in the Windows Event Log:

> Volume Shadow Copy Service error: Unexpected error calling routine ConvertStringSidToSid(**S-1-5-21-1014438854-1672741230-9522986-94341.bak**). hr = 0x80070539, The security ID structure is invalid. . Operation: OnIdentify event Gathering Writer Data Context: Execution Context: Shadow Copy Optimization Writer Writer Class Id: {4dc3bdd4-ab48-4d07-adb0-3bee2926fd7f} Writer Name: Shadow Copy Optimization Writer Writer Instance ID: {df5009d9-e1fd-4799-86d7-bb04068af671}
> 
     
## Solution ##
1.	Open the registry editor and browse to the key listed below
	- HKEY\_LOCAL\_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList
2.	Expand the registry key and look for the Security Identifier (Sid) mentioned in the event log
3.	Delete this sub-key
4.	Reboot the server

![Registry Example](/images/posts/convertstringsidtosid-error-from-the-volume-shadow-copy-service.png)
