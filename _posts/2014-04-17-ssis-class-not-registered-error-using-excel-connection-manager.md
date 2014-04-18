---
layout: post
title: "Class Not Registered Error Using Excel Connection Manager"
description: "Describes how to fix a class not registered Error when using a Microsoft Excel Connection Manager in a SSIS package."
category: TechNote
tags: [Sql Server, BIDS]
image: 
  feature: layout-posts.jpg
comments: false 
---
In this post we will discuss how to address a “Class Not Registered Error” when using a Microsoft Excel Connection Manager in a SSIS package.

<!-- more -->

## Problem ##

When you attempt to run an SSIS package that contains either an input or output file that uses the Excel Connection Manager, the job abends with the following error messages:

> Code: 0xC0209302 Source: \<*package name*\> Connection manager "\<*excel connection name*\>"    Description: SSIS Error Code DTS\_E\_OLEDB\_NOPROVIDER\_ERROR. The requested OLE DB provider Microsoft.ACE.OLEDB.12.0 is not registered. Error code: 0x00000000.  An OLE DB record is available.  Source: "Microsoft OLE DB Service Components"  Hresult: 0x80040154  Description: "Class not registered". 

## Solution ##

To resolve this error you need to perform two steps. The first is to download and install the **Microsoft Access Database Engine 2010 Redistributable** on the server executing the SSIS package.  The second step is to execute the SSIS package using the **32-bit runtime engine**.

The download page for the *Access Database Engine* lists separate files for the 64-bit and the 32-bit engines. Make sure that you download the 32-bit version of **AccessDatabaseEngine.exe**.

* URL: http://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=13255

From the download page the following summary is given:

> “This download will install a set of components that facilitate the transfer of data between existing Microsoft Office files such as Microsoft Office Access 2010 (*.mdb and *.accdb) files and Microsoft Office Excel 2010 (*.xls, *.xlsx, and *.xlsb) files to other data sources such as Microsoft SQL Server. Connectivity to existing text files is also supported. ODBC and OLEDB drivers are installed for application developers to use in developing their applications with connectivity to Office file formats.” - Microsoft

In addition, the SQL Agent job step that runs the package will need to have the **32-bit Runtime** option checked or if you are using DTExec to run the package, add the **/X86** option to the command line.

![SSIS 32-bit Runtime GUI Option](/images/posts/ssis-class-not-registered-error-using-excel-connection-manager.png)

