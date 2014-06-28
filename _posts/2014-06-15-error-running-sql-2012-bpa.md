---
layout: post
title: "Error Running SQL 2012 Best Practice Analyzer"
description: "Describes how to fix the invalid permissions error when attempting to run the SQL 2012 Best Practice Analyzer."
category: TechNote
tags: [SQL Server, BPA]
image: 
  feature: layout-posts.jpg
comments: false 
---
In this post we will discuss how to address a permissions problem when attempting to run the SQL Server 2012 Best Practice Analyzer.

<!-- more -->

When you attempt to run the BPA you receive a message, similar to the one below, stating that "*Login does not exist or is not a member of the Systems Administrator role*". 

![](/images/posts/error-running-sql-2012-bpa.png)

Besides the general case of this error message, where in fact you do not have the correct permissions, this error can also occur when you have sysadmin authority granted via group membership. The SQL Server 2012 Best Practice Analyzer (BPA) has a known limitation in that it does not recognize security permissions granted via group membership. 

## Solution ##

The workaround for this issue is to add an explicit SQL Login for your account rather than rely on the group membership. This is only needed to run the BPA tool and then the login can be removed if you wish.