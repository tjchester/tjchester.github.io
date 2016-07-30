---
layout: post
title: "SQL Server Database Mirroring Troubleshooting Notes"
description: "Contains a collection of troubleshooting notes related to SQL Server database mirroring."
category: TechNote
tags: [Sql Server, Database Mirroring]
image: 
  feature: layout-posts.jpg
comments: false 
---
In this post we will highlight a collection of troubleshooting notes related to SQL Server database mirroring.

<!-- more -->

Error: This operation cannot be performed on database “X” because it is involved in a database mirroring session.

Solution: The following restrictions apply to mirrored databases:

- Backup and restore of the mirror database are not allowed
- Backup of the principal database is allowed, but BACKUP LOG WITH NORECOVERY is not
- Restoring the principal database is not allowed

If you are trying to perform one of the operations that is not allowed, such are restoring from a backup or reverting from a snapshot database, then you must first break the mirror, carry out your intended action on the principal, and then recreate the mirror using a new set of full and transaction log backups from the principal database.

---

Error: This database cannot be mirrored because it does not use the full recovery model.

Solution: Change the recovery model of the database to FULL, then take a full backup and a log backup. Transfer to the mirror server and then attempt to setup mirroring.

---

Error: Database Mirroring cannot be enabled because the database may have bulk logged changes that have not been backed up. The last log backup on the principal must be restored on the mirror. (Microsoft SQL Server, Error 1475)

Solution: Take a full backup and log backup on the principal. Restore the full backup and the log backup on the mirror with the NORECOVERY option. Restart mirroring.

---

Error: BACKUP LOG cannot be performed because there is no current backup.

Solution: Run a new full backup (not COPY-ONLY) of the database and then rerun the BACKUP LOG statement.

---

Error: RESTORE cannot operate on database ‘&lt;name&gt;’ because it is configured for database mirroring. Use ALTER DATABASE to remove mirroring if you intend to restore the database.

Solution: Run the command below.

```
ALTER DATABASE [name] SET PARTNER OFF
```

---

Error: Msg 1477, Level 16, State 1, Line 3 The database mirroring safety level must be FULL to manually failover database "Scratch".  Set safety level to FULL and retry.  – This error occurs when trying to initiate a manual failover operation on the principal (i.e. ALTER DATABASE [Scratch] SET PARTNER FAILOVER;)

Solution: Change the SAFETY level to FULL on the principal server for the database (i.e. ALTER DATABASE [Scratch] SET PARTNER SAFETY FULL) – then retry the manual failover.

In the Database Properties dialog, if the safety level is full, the following option will be checked under Operating Mode: High safety without automatic failover (synchronous) – Always commit changes at both the principal and mirror.

---

Error: The alter database for this partner config values may only be initiated on the current principal server for database "Scratch". – when trying to initiate a manual failover on the mirror (i.e. ALTER DATABASE [Scratch] SET PARTNER FAILOVER)

Solution: This command can only be executed on the principal server. You either have to execute it on the principal server or execute the following to force a failover on the mirror (i.e. ALTER DATABASE [Scratch] SET PARTER FORCE_SERVICE_ALLOW_DATA_LOSS).

---
 
Error: The database mirroring service cannot be forced for database "Scratch" because the database is not in the correct state to become the principal database. – when trying to force a failover on the mirror.

Solution: This usually means that the principal server is still up and running (i.e. connected) and the mirror status probably shows (Mirror, Synchronized / Restoring…). You must stop the SQL service or the mirroring endpoint on the principal server first.
