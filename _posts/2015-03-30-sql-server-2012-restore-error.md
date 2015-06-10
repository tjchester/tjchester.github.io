---
layout: post
title: "SQL Server 2012 Restore Error"
description: "Describes how to workaround an error that can occur when restoring a SQL Server 2008 database backup to SQL Server 2012."
category: TechNote
tags: [Sql Server, Backup]
image: 
  feature: layout-posts.jpg
comments: false
---

This post describes an error that may occur when you are transferring database backup files from a SQL 2008 server to a SQL 2012 server and you are using SQL Server Management Studio (SSMS) to perform the restores.

<!-- more -->

When attempting to restore a transaction log backup created on a SQL Server 2008 server using the SQL Server Management Studio 2012 you receive the following error:

> Unable to create restore plan due to break in the LSN chain.

This is due to a bug in the SQL Server Management Studio 2012 where it fails to properly read the backup headers from the files. The solution is to use T-SQL to perform the restore. See the example below.

```
RESTORE DATABASE [Demo]
   FROM DISK = 'C:\TEMP\DEMO_FULL.bak'
   WITH NORECOVERY, STATS = 10,
      MOVE 'DemoData' TO 'C:\Databases\Demo.mdf', 
      MOVE 'Demo_Log' TO 'C:\Databases\Demo.ldf'

RESTORE DATABASE [Demo]
   FROM DISK = 'C:\TEMP\DEMO_DIFF.bak'
   WITH NORECOVERY, STATS = 10

RESTORE LOG [Demo]
   FROM DISK = 'C:\TEMP\DEMO_TLOG.trn'
   WITH RECOVERY, STATS = 10
```

> In this example, let's assume that separate full, differential, and transaction log backups were created from the [DEMO] database on a SQL Server 2008 instance and that they are being restored to a SQL Server 2012 instance.
