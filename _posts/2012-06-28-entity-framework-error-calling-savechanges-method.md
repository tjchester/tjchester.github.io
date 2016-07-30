---
layout: post
title: "Entity Framework Error When Calling SaveChanges Method"
description: "Describes how to fix a a transaction error when calling the SaveChanges method on an Entity Framework context variable."
category: TechNote
tags: [.NET 2.0, Entity Framework]
image: 
  feature: layout-posts.jpg
comments: false 
---
In this post we will discuss how to address a potential transaction error when calling the SaveChanges method on an Entity Framework context variable.

<!-- more -->

## Problem

When calling **SaveChanges()** on an Entity Framework context variable you receive the following error: *New transaction is not allowed because there are other threads running in the session.*

## Reason

When you call *SaveChanges()* a new transaction is started with SQL Server, but SQL Server will not allow that transaction to start if there are currently data readers accessing the data that you are trying to save. This most likely will occur when you call *SaveChanges()* within a *For Each *loop that is iterating over a *LINQ* query.

## Solution

At the start of your *For Each* loop make a call to **ToArray()** on the *LINQ* query so that rather than keeping a data reader open to process each successive row, it will retrieve all rows at once and close the reader. This should allow your changes to be saved.

## Applies To

.NET Framework 2.0