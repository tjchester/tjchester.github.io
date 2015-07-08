---
layout: post
title: "Regain Access to SQL Server When Locked Out"
description: "Describes how to regain control of a SQL Server that you can no longer connect to because of a lost password or incorrect security settings."
category: TechNote
tags: [Sql Server, Recovery]
image: 
  feature: layout-posts.jpg
comments: false
---

This post describes how to regain access to a SQL server when you are denied access and the sa password has been lost.

<!-- more -->

When you try to connect to a SQL Server instance from SQL Server Management Studio for example, you receive the following error:

	Error connecting to 'SQLServerInstance'.
	Additional Information:
  		Login failed for user 'MyUser'. (Microsoft SQL Server, Error 18456)

> The steps below assume that you are a Windows administrator on the machine that is hosting the SQL Server that you are trying to gain access to.

## Procedure

For the purposes of demonstation I am going to assume that we are working with a default installation of SQL Server 2012 although the steps work just as well with versions 2005 and 2008 R2 as well. I would just need to change the program directory to the appropriate one for that instance.

First stop the service if it is running from the command line, as shown below, or through the Services management console.

	NET STOP MSSQL$SQL2012

Next change to the executable directory (i.e. Binn) for the particular instance of SQL Server you want to fix, and start the service (specified by the *-s* parameter) in single-user mode (specified by the *-m* parameter). 

	"C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\Binn\sqlservr.exe" -sSQL2012 -m

Now in a separate command window connect to the single-user instance you just started using the *sqlcmd* tool. The *-S* parameter specifies the instance name and the *-E* parameter specifies Windows Authentication.

	sqlcmd -S .\SQL2012 -E

Within the *sqlcmd* tool the following commands will set the 'sa' user's password to a new value.

	1> ALTER LOGIN [sa] WITH PASSWORD='MyNewPassword';
	2> GO

If in addition, you wanted to add a Windows server login and grant that user administrative authority for the SQL instance then use the additional commands below.

1> CREATE LOGIN [MYDOMAIN\MYUSER] FROM WINDOWS WITH DEFAULT_DATABASE=[master];
2> GO
1> EXEC sp_addsrvrolemember @loginame='MYDOMAIN\MYUSER', @rolename='sysadmin';
2> GO

Once you have completed that steps that you wanted to perform you can exit the *sqlcmd* tool and close the connection to SQL Server.

	1> EXIT

Now switch back to the original command window from where you manually started SQL Server and press **Ctrl+C**. Confirm that you would like to stop this running instance by entering *Y*. Once the single-user instance has completed shutdown you can start up the original multi-user instance using the command below or through the Services management console.

	NET START MSSQL$SQL2012

You should now be able to connect to your SQL instance using SQL Server Management Studio.


## Troubleshooting

### Version Mismatch

When you are manually starting your SQL Server in single-user mode you receive the following error:

![Your SQL Server installation is either corrupt or has been tampered with (Error getting instance ID from name). Please uninstall then re-run setup to correct this problem.](/images/posts/regain-access-sql-server-when-locked-out-01.png)

This usually means that there is a mismatch between the version of the sqlservr.exe program and the instance name that you supplied. This can only occur on a computer where there is more than one SQL server installation. 

For instance if you typed the command below you would trigger the error because you have asked the 2005 version of SQL Server to start-up the 2012 instance.

	"C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Binn\sqlservr.exe" -sSQL2012 

### Server Running

When you are manually starting your SQL Server in single-user mode you receive the following error:


	2015-07-08 06:14:26.13 Server      Error: 17058, Severity: 16, State: 1.
	2015-07-08 06:14:26.13 Server      initerrlog: Could not open error log file 'C:
	\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\LOG\ERRORLOG'. Operating syste
	m error = 32(The process cannot access the file because it is being used by anot
	her process.).

This usually means that you forgot to stop the SQL Service prior to trying to restart it.

## For Additional Information

* [Aaron Bertrand: Recover access to a SQL Server instance](https://www.mssqltips.com/sqlservertip/2682/recover-access-to-a-sql-server-instance/)
* [Argenis Fernandez: Leveraging Service SIDs to Logon to SQL Server 2012 and SQL Server 2014 Instances with Sysadmin Privileges](http://sqlblog.com/blogs/argenis_fernandez/archive/2012/01/12/leveraging-service-sids-to-logon-to-sql-server-2012-instances-with-sysadmin-privileges.aspx)
* [MSDN: CREATE LOGIN (Transact-SQL)](https://msdn.microsoft.com/en-us/library/ms189751.aspx)
* [MSDN: sp_addsrvrolemember (Transact-SQL)](https://msdn.microsoft.com/en-us/library/ms186320.aspx)
* [TechNet: Connect to SQL Server When System Administrators Are Locked Out](https://technet.microsoft.com/en-us/library/dd207004.aspx)
