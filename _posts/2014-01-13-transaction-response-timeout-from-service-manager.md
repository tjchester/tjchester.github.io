---
layout: post
title: "Transaction Response Timeout from Service Manager"
description: "Describes how to fix a service manager timeout that occurs while waiting for a Windows service to start."
category: TechNote
tags: [Windows Server, Registry]
image: 
  feature: layout-posts.jpg
comments: false 
---
In this post we will discuss how to address a timeout error that occurs during a service startup.

<!-- more -->

## Problem ##

The Windows Event Log shows one or more entries related to a timeout that occurs while waiting for a service to start. For example,

> Event Type: Error <br/>
> Event Source: Service Control Manager <br/>
> Event Category: None <br/>
> Event ID: 7011 <br/>
> 
> Description: <br/>
> A timeout (30000 milliseconds) was reached while waiting for a transaction response from the Netman service. 

## Solution ##

Create or increase the **ServicesPipeTimeout** entry's value in the Windows registry per the references Microsoft article listed above. If the key does not exist, create a new **DWORD** entry with an initial *decimal* value of **60000**. The value specified is in milliseconds so the recommended starting value is equivalent to one minute.

- HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Control

### See Also ###

[http://support.microsoft.com/kb/922918](http://support.microsoft.com/kb/922918 "Microsoft Knowledge Base Article 922918")
