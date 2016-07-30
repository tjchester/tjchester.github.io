---
layout: post
title: "SQL Server Database Mirroring Failover Notes"
description: "Contains a collection of techniques on executing a failover when using SQL Server database mirroring."
category: TechNote
tags: [Sql Server, Database Mirroring]
image: 
  feature: layout-posts.jpg
comments: false 
---
In this post we will highlight some techniques on executing a failover when using SQL Server database mirroring.

<!-- more -->

## Full Safety Mode without a Witness Server

### Principal Server Available

If the principal server is online, then you can initiate manual failover using the following commands:

```
ALTER DATABASE [name] SET PARTNER FAILOVER
```

The table below lists the changes in status of the database:

<table>
	<tr style="background-color: #f5f5f5;">
		<td style="border: 1px solid black; text-align: left;">Server</td>
		<td style="border: 1px solid black; text-align: left;">Status Before Failover</td>
		<td style="border: 1px solid black; text-align: left;">Status After Failover</td>
	</tr>
	<tr>
		<td style="border: 1px solid black; text-align: left;">Principal</td>
		<td style="border: 1px solid black; text-align: left;">Principal, Synchronized</td>
		<td style="border: 1px solid black; text-align: left;">Mirror, Synchronized / Restoring ...</td>
	</tr>
	<tr>
		<td style="border: 1px solid black; text-align: left;">Mirror</td>
		<td style="border: 1px solid black; text-align: left;">Mirror, Synchronized / Restoring ...</td>
		<td style="border: 1px solid black; text-align: left;">Principal, Disconnected</td>
	</tr>
</table>



### Principal Server Unavailable

If the principal server is offline or failed, then you can initiate a manual failover using the following commands:

```
ALTER DATABASE [name] SET PARTNER FORCE_SERVICE_ALLOW_DATA_LOSS
```

> NOTE: There may be a slight delay (i.e. minutes) before the database is recognized as the principal. Sometimes you can stop and restart the mirroring endpoint to speed this process up.

```
ALTER ENDPOINT [Mirroring] STATE = STOPPED
ALTER ENDPOINT [Mirroring] STATE = STARTED
```

If the principal comes back online, you can resume mirroring and transfer the main role back from the mirroring server using the following commands:

```
ALTER DATABASE [name] SET PARTNER RESUME
```

After the partner status changes to SYNCHRONIZED then you can run the following command:

```
ALTER DATABASE [name] SET PARTNER FAILOVER
```

The table below lists the changes in status of the database:

<table>
	<tr style="background-color: #f5f5f5;">
		<td style="border: 1px solid black; text-align: left;">Server</td>
		<td style="border: 1px solid black; text-align: left;">Status Before Failover</td>
		<td style="border: 1px solid black; text-align: left;">Status After Failover</td>
	</tr>
	<tr>
		<td style="border: 1px solid black; text-align: left;">Principal</td>
		<td style="border: 1px solid black; text-align: left;">N/A</td>
		<td style="border: 1px solid black; text-align: left;">N/A</td>
	</tr>
	<tr>
		<td style="border: 1px solid black; text-align: left;">Mirror</td>
		<td style="border: 1px solid black; text-align: left;">Mirror, Disconnected / In Recovery</td>
		<td style="border: 1px solid black; text-align: left;">Principal, Disconnected</td>
	</tr>
</table>



## High Performance Mode without Witness Server

### Principal Server Available

If the principal server is online, then you can initiate manual failover using the following commands:

```
ALTER DATABASE [name] SET PARTNER SAFETY FULL
```

You will have to wait a few seconds or longer for the outstanding transactions to be confirmed by the mirror (i.e. status shows Synchronized) before using the following command:

```
ALTER DATABASE [name] SET PARTNER FAILOVER
```

After the failover has occurred, you can change by the high-performance mode by using the following commands on the new principal (i.e. former mirror):

```
ALTER DATABASE [name] SET PARTNER SAFETY OFF
```

The table below lists the changes in status of the database:

<table>
	<tr style="background-color: #f5f5f5;">
		<td style="border: 1px solid black; text-align: left;">Server</td>
		<td style="border: 1px solid black; text-align: left;">Status Before Failover</td>
		<td style="border: 1px solid black; text-align: left;">Status After Failover</td>
	</tr>
	<tr>
		<td style="border: 1px solid black; text-align: left;">Principal</td>
		<td style="border: 1px solid black; text-align: left;">Principal, Synchronized</td>
		<td style="border: 1px solid black; text-align: left;">Mirror, Synchronized / Restoring ...</td>
	</tr>
	<tr>
		<td style="border: 1px solid black; text-align: left;">Mirror</td>
		<td style="border: 1px solid black; text-align: left;">Mirror, Synchronized / Restoring ...</td>
		<td style="border: 1px solid black; text-align: left;">Principal, Synchronized</td>
	</tr>
</table>


## Principal Server Available (Log Tail Available)

If the principal server is online but the principal database is damaged, then you can initiate a manual failover using the following commands:

First you need to attempt a backup of the tail of the principal database log and then copy that backup to the mirror server (if the principal database is damaged then use CONTINUE_AFTER_ERROR instead of the NO_TRUNCATE option below):

```
BACKUP LOG [name] TO [device] WITH NO_TRUNCATE
```

On the mirror server you first need to break the mirror using the following command:

```
ALTER DATABASE [name] SET PARTNER OFF
```

Next you need to restore the log tail from the principal database to the mirror database:

```
RESTORE LOG [name] FROM [device] WITH RECOVERY
```


### Principal Server Unavailable (Log Tail Unavailable)

If the principal database is no longer available and backing up the tail of the log was unsuccessful then you can break mirroring and recover the database to the last synchronized transaction using the following command:

```
ALTER DATABASE [name] SET PARTNER OFF
```
