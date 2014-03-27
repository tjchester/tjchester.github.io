---
layout: post
title: "Designer Stops Working in BIDS"
category: TechNote
tags: [Sql Server, BIDS]
image: 
  feature: layout-posts.jpg
comments: false
---

This post describes how to fix the Business Intelligence Development Studio 2008 error that occurs when trying to view the design surface of a SSIS package.

<!-- more -->

## Problem ##

When trying to view the diagram surface of a SQL Server Integration Services project from within the Business Intelligence Development Studio you receive the error shown below. The problem is caused when Visual Studio 11 or newer is installed on the same machine, the installation will overwrite the msdds.dll, msddsf.dll, msddslm.dll, msddslmp.dll, and msddsp.dll with newer versions. These versions are not backward compatible with Visual Studio 2008 and break the SSIS diagram editor.

![BIDS Error](/images/posts/designer-stops-working-in-bids.png)
 
## Solution ##

The solution is to manually copy and replace the contents of the **C:\Program Files (x86)\Common Files\Microsoft Shared\MSDesigners8** folder on the broken computer using the files from a computer that does not have a newer version of the Visual Studio IDE on it.

### See Also ###

[http://social.msdn.microsoft.com/Forums/sqlserver/en-US/0bcf22d6-adab-4595-b0d8-3a37ce7fbff3/2008-ssis-designer-stops-working-after-installing-vs11-dev-preview?forum=sqlintegrationservices](http://social.msdn.microsoft.com/Forums/sqlserver/en-US/0bcf22d6-adab-4595-b0d8-3a37ce7fbff3/2008-ssis-designer-stops-working-after-installing-vs11-dev-preview?forum=sqlintegrationservices "Microsoft Forums")
