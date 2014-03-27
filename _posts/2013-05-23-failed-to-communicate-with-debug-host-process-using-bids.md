---
layout: post
title: "Failed to Communicate with Debug Host Process in BIDS"
description: "Describes how to fix an issue with the debugger in SSIS projects."
category: TechNote
tags: [Sql Server, BIDS]
image: 
  feature: layout-posts.jpg
comments: false
---

In this post we will discuss how to fix the *“cannot communicate with the debug host process”* error when trying to debug SQL Server Integration Services projects using the Business Intelligence Development Studio (BIDS).

<!-- more -->

## Problem ##

When trying to debug a SQL Server Integration Services project from within the Business Intelligence Development Studio you receive the error shown below.
 
![BIDS Error](/images/posts/failed-to-communicate-with-debug-host-process-in-bids.png)

## Solution ##

The solution is to manually register the DTS/SSIS debug host program from a Windows command prompt. Execute the following command in the directories shown depending on what version you have installed. 

    DtsDebugHost.exe /regserver

**SQL Server 2005**

- C:\Program Files (x86)\Microsoft SQL Server\90\DTS\Binn\

**SQL Server 2008**

- C:\Program Files (x86)\Microsoft SQL Server\100\DTS\Binn\
- C:\Program Files\Microsoft SQL Server\100\DTS\Binn\

*NOTE: The folder paths shown assume a 64-bit operating system.*