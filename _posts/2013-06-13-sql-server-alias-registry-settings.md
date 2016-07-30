---
layout: post
title: "SQL Server Alias Registry Settings"
description: "Describes the Windows registry locations where SQL Server aliases are stored."
category: TechNote
tags: [Sql Server, Registry]
image: 
  feature: layout-posts.jpg
comments: false 
---
In this post we will discuss where SQL Server Aliases, defined through the SQL Server Configuration Manager, are stored in the Windows registry.

<!-- more -->

This note identifies the registry locations where SQL Server Aliases defined using the SQL Server Configuration Manager tool are stored. It should be noted that the locations represent both the 32-bit and 64-bit client aliases as stored on a 64-bit operation system.

## Default Instance

### 32-Bit

![32-Bit Default Instance](/images/posts/sql-server-alias-registry-settings-01.png)

### 64-Bit

![64-Bit Default Instance](/images/posts/sql-server-alias-registry-settings-02.png)

## Named Instance

### 32-Bit

![32-Bit Named Instance](/images/posts/sql-server-alias-registry-settings-03.png)

### 64-Bit

![64-Bit Named Instance](/images/posts/sql-server-alias-registry-settings-04.png)
