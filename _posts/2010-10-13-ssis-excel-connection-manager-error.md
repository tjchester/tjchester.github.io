---
layout: post
title: "Failed to Acquire Excel Connection Manager"
description: "Describes how to fix an OLE DB error when using a Microsoft Excel Connection Manager in a SSIS package."
category: TechNote
tags: [Sql Server, BIDS]
image: 
  feature: layout-posts.jpg
comments: false 
---
In this post we will discuss how to address an "OLE DB error … failed to acquire connection" when using a Microsoft Excel Connection Manager in a SSIS package.

<!-- more -->

## Problem

When you run an SSIS package on your local machine, it runs successfully; but when run on the server, the package ends abnormally with the following error message:

>Error: 0xC0202009 at <package name>, Connection manager "Excel Connection Manager": SSIS Error Code DTS_E_OLEDBERROR.  An OLE DB error has occurred. Error code: 0x80040154.


>An OLE DB record is available.  Source: "Microsoft OLE DB Service Components" Hresult: 0x80040154 Description: "Class not registered".


> Error: 0xC00291EC at Create Excel File, Execute SQL Task: Failed to acquire connection "Excel Connection Manager". Connection may not be configured correctly or you may not have the right permissions on this connection.

This error can occur when you run your package under a 64-bit version of SQL Server which is unable to access the 32-bit versions of the OLE DB components necessary for using Excel.

## Solution

When running your package interactively on the server, you need to set the **Run64BitRuntime** settings to **False** under **Project** → **Properties** → **Configuration** **Properties** → **Debugging**.

When running your package using a SQL Agent job, you need to change your job step to be type “**Operating system (CmdExec)**” instead of “**SQL Server Integration Services Package**”. In addition, you need to fully qualify the path to the 32bit version of the *dtexec.exe* program.
 
	"C:\Program Files (x86)\Microsoft SQL Server\90\DTS\Binn\dtexec.exe" /FILE …
