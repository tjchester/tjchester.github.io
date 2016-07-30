---
layout: post
title: "Failed to Change SQL Agent Job Ownership"
description: "Describes how to fix a error when reassigning ownership of a SQL Agent job."
category: TechNote
tags: [Sql Server, Sql Server Agent]
image: 
  feature: layout-posts.jpg
comments: false 
---
In this post we will discuss how to address a typical error when trying to reassign SQL Agent job ownership.

<!-- more -->

## Problem

When you attempt to change the owner of a SQL Agent job you receive the following error message:

> Only a system administrator can reassign ownership of a job. (Microsoft SQL Server, Error: 14242)

![Example Error Message](/images/posts/sql-agent-change-job-ownership-01.png)

## Reason

Only members of the sysadmin role have the ability to change job ownership. 

See: [http://msdn.microsoft.com/en-us/library/ms178031.aspx](http://msdn.microsoft.com/en-us/library/ms178031.aspx)

## Solution

Have a user that is a member of the sysadmin role change the job ownership.

## Remarks

If you change job ownership to a user who is not a member of the sysadmin fixed server role, and the job is executing job steps that require proxy accounts, for example SSIS package execution, make sure that the user has access to that proxy account or else the job will fail.

## Applies To

SQL Server 2005, SQL Server 2008, SQL Server 2008 R2
