---
layout: post
title: "Unable to Connect to Remote SQL Server Integration Services"
description: "Describes how to fix an access denied error when trying to connect to a remote instance of SQL Server integration services."
category: TechNote
tags: [Sql Server, Ssis]
image: 
  feature: layout-posts.jpg
comments: false 
---
In this post we will discuss how to address an *"Access Is Denied"* error when trying to connect to a remote instance SQL Server Integration Services.

<!-- more -->

## Problem

When you try to connect to a remote instance of SQL Server Integration Services, you receive an *“Access Is Denied”* error.

## Reason

The user you are trying to connect with is not a member or the local administrators group on the remote machine and you are not part of the Distributed COM Users group on the remote machine either.

See: [http://msdn.microsoft.com/en-us/library/aa337083.aspx](http://msdn.microsoft.com/en-us/library/aa337083.aspx)

## Solution

Follow the instructions above to grant the Distributed COM Users group on the remote machine, access and launch/activate permissions on the MsDtsServer component. In addition, you will need to add the users, needing remote SSIS access, into that local group.

## Remarks

In addition, if the remote users are going to be utilizing the File System store of SSIS; you need to grant NTFS Modify rights to the DTS package directory on the remote machine for those users. Without this right, the user will be able to create but not delete or update packages in that store. The File System store is typically located in the **C:\Program Files\Microsoft Sql Server\90\dts\packages** folder.

## Applies To

SQL Server 2005