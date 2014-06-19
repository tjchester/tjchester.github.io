---
layout: post
title: "SSIS Multi-Environment Configration"
description: "Describes how to store multiple environment settings for SSIS packages in support of automatic deployment scenarios."
category: HowTo
tags: [Sql Server, SSIS]
image: 
  feature: layout-posts.jpg
comments: false 
---

This post describes a method of managing multiple SQL Server Integration Services (SSIS) package configurations across environments using a single SQL Server table.

<!-- more -->

The following articles were consulted in the creation of this document:
- [MSDN: Package Configurations](http://msdn.microsoft.com/en-us/library/ms141682.aspx)
- [Understanding Integration Services Package Configurations](http://msdn.microsoft.com/en-us/library/cc895212.aspx)
- [SSIS multi-environment configuration in a single SQL Server table](http://www.sqlservercentralcom/articles/Integration+Services+\(SSIS\)/66426/)
- [SQL Server Integration Services SSIS Package Configuration](http://www.mssqltips.com/sqlservertip/1405/sql-server-integration-services-ssis-package-configuration/)
- [SSIS: Mo' Secure Configurations](http://sqlblog.com/blogs/michael_coles/archive/2010/01/18/ssis-mo-secure-configurations.aspx)
- [Encrypted SQL Server SSIS Configurations](http://curionorg.blogspot.com/2007/05/encrypted-sql-server-ssis.html)
- [Using a SQL Server Alias for SSIS Package Configuration Database Connection String](http://www.mssqltips.com/sqlservertip/2459/using-a-sql-server-alias-for-ssis-package-configuration-database-connection-string/)
- [Create a SQL Alias with a PowerShell Script](http://habaneroconsulting.com/blog/Posts/Create_a_SQL_Alias_with_a_PowerShell_Script.aspx#.UZIkl83D_Oh)

## Background ##

The database build process needs a consistent and managed way to provide different configuration settings to SSIS packages depending on the current environment. SQL Server packages support configurations via XML files, environment variables, registry entries, parent package variables, and SQL Server tables. The database build process is designed for the controlled deployment of databases therefore the SQL Server table configuration type is the match that is most consistent with that philosophy. Out of the box, the SQL Server configuration type is limited to a single environment and does not impose any default security or encryption capabilities. By building some additional infrastructure around the base implementation we can enhance it to handle multiple environments, a more secure default security model, and optionally encryption.

## Solution ##

### SQL Server Table ###

#### Default ####

The Package Configuration Wizard will use the CREATE TABLE statement below to create the default configuration table.

##### Default Configuration Table ######

```sql
CREATE TABLE [dbo].[SSIS Configurations]
(
    ConfigurationFilter NVARCHAR(255) NOT NULL,
    ConfiguredValue     NVARCHAR(255) NULL,
    PackagePath         NVARCHAR(255) NOT NULL,
    ConfiguredValueType NVARCHAR(20)  NOT NULL
)
```

The table columns have the following meanings:

- The **ConfigurationFilter** column is used to identify a group of property/value pairs.
- The **ConfiguredValue** is the value that is assigned to the property specified by PackagePath.
- The **PackagePath** is the SSIS path used to identify the property that the ConfigurationValue is being stored for.
- The **ConfiguredValueType** is the SSIS data type of the ConfigurationValue. The entry stored in this column is case-sensitive and supports one of the following values: *Boolean*, *Byte*, *Char*, *DateTime*, *DBNull*, *Decimal*, *Double*, *Empty*, *Int16*, *Int32*, *Int64*, *Object*, *Sbyte*, *Single*, *String*, *UInt32*, and *UInt64*.
 
#### Enhanced Table ####

The base table design has been enhanced to support multiple environments and encrypted values.

##### Enhanced Configuration Table #####

```sql
CREATE TABLE [ssis].[ConfigurationsBase]
(
    [ConfigurationFilter] [nvarchar](255) 
        COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ConfiguredValue]     [varbinary](512) NULL,
    [PackagePath]         [nvarchar](255) 
        COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ConfiguredValueType] [nvarchar](20) 
        COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [EnvironmentEnum]     [tinyint] NOT NULL DEFAULT (0),
    [EnvironmentDesc]     AS (CASE [EnvironmentEnum] 
                                WHEN (0) THEN 'Default' 
                                WHEN (1) THEN 'Development' 
                                WHEN (2) THEN 'Test' 
                                WHEN (3) THEN 'Production'  
                              END),
    [ConfigurationId]     [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [HostNameDesc]        AS (CASE [EnvironmentEnum] 
                                WHEN (0) THEN 'Default' 
                                WHEN (1) THEN 'DEV_DB_HOSTNAME' 
                                WHEN (2) THEN 'QA_DB_HOSTNAME' 
                                WHEN (3) THEN 'PROD_DB_HOSTNAME'  
                              END),
)
```

The table columns have the following meanings:

- The **ConfigurationFilter** column has the same meaning as the default table but its definition was changed to be case-sensitive.
- The **ConfiguredValue** column has the same meaning as the default table but its definition was changed to *varbinary* to store the encrypted data.
- The **PackagePath** column as the same meaning as the default table but its definition was changed to be case-sensitive.
- The **ConfiguredValueType** column has the same meaning as the default table but its definition was changed to be case sensitive. In addition, a check constraint was added (not shown) to restrict the allowed values to the supported SSIS types as described in the default table definition.
- The **EnvironmentEnum** column is new and is used to identify the environment the property/value pair applies to. The default environment, usually the developer’s local machine, will have a value that is default to 0. Defaulting the column is this manner, completely coincides with the behavior expected by Business Intelligence Development Studio (BIDS). The value of 1 is used to identify the *Development* server, 2 for the *Test* server, and 3 for the *Production* server.
- The **EnvironmentDesc** column is a new computed column to display friendly and consistent names for the value in the *EnvironmentEnum* column.
- The **ConfigurationId** column is a new column to be used as a primary key column which makes working with the individual entries easier.
- The **HostNameDesc** column is a new computed column to display friendly and consistent names for the expected host server that coincides with the value from *EnvironmentEnum*. Note that the creation of this computed column depends on hooks within the database build process to fill out the case statement values prior to the table being initially created.

It should also be noted that the table has been moved under a new **[ssis]** schema. A separate schema simplifies the security management and also can prevent namespace conflicts with existing objects. In addition, a unique non-clustered index was created over the **[ConfigurationFilter]**, **[EnvironmentEnum]**, and **[PackagePath]** columns. Since the values in the configuration table will be manipulated outside of the BIDS environment the index has prevent multiple values from being entered for the same property within the same environment.

### Supporting Objects (Mandatory) ###

The objects in this section are required for proper execution of SSIS and the BIDS environments.

#### Views ####

In order for SSIS and BIDS to work with the enhanced table we need a view to act as the intermediary between those products and our base table. This view will be in charge of encrypting and decrypting the property values. Creation of this view depends on hooks in the database build process in order to store the passphrase that will be used by the *EncryptByPassPhase* and *DecryptByPassPhrase* T-SQL functions. In order to prevent the passphrase to be disclosed, outside of the developer groups, the view is created with the encryption option. The CASE statement within the JOIN clause will select the appropriate environment’s values based on the host server. This statement also relies on hooks within the database build process to replace the tokens with actual server names.

##### SSIS and BIDS Interface View #####

```sql
CREATE VIEW [ssis].[Configurations] WITH ENCRYPTION AS
    SELECT ConfigurationFilter,
           ConfiguredValue = CAST (                                        DecryptByPassPhrase('SSIS_CONFIGURATION_PASSPHRASE'
                                    , ConfiguredValue) AS NVARCHAR(255)),
           PackagePath,
           ConfiguredValueType,
           EnvironmentEnum,
           EnvironmentDesc,
           ConfigurationId,
           HostNameDesc
      FROM [ssis].[ConfigurationsBase] base
           INNER JOIN (SELECT CurrentEnvironment = 
                CASE WHEN HOST_NAME() = 'DEV_DB_HOSTNAME'  THEN 1
                         WHEN HOST_NAME() = 'QA_DB_HOSTNAME'   THEN 2
                         WHEN HOST_NAME() = 'PROD_DB_HOSTNAME' THEN 3
                    END) e
             ON base.EnvironmentEnum = 0 
                OR base.EnvironmentEnum = e.CurrentEnvironment
```

#### Triggers ####

In order to allow the view to encrypt the property values on insert and update we need to use INSTEAD OF triggers. Similar to the view discussed previously, these triggers rely on hooks within the database build process in order to set the passphrase used for encryption and decryption. The triggers are created with the encryption option as well in order to prevent disclosure of the passphrase in the object definition.

##### Insert Trigger #####

```sql
CREATE TRIGGER [ssis].[Configurations_Trigger_Instead_Insert] 
ON [ssis].[Configurations] WITH ENCRYPTION INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [ssis].[ConfigurationsBase]
    (
        ConfigurationFilter,
        ConfiguredValue,
        PackagePath,
        ConfiguredValueType,
        EnvironmentEnum
    )
    SELECT ConfigurationFilter,
           EncryptByPassPhrase('SSIS_CONFIGURATION_PASSPHRASE', ConfiguredValue),
           PackagePath,
           ConfiguredValueType,
           ISNULL(EnvironmentEnum, 0)
      FROM inserted 
END
```

##### Update Trigger #####

```sql
CREATE TRIGGER [ssis].[Configurations_Trigger_Instead_Update] 
ON [ssis].[Configurations] WITH ENCRYPTION INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE target
       SET target.ConfiguredValue = EncryptByPassPhrase('SSIS_CONFIGURATION_PASSPHRASE', source.ConfiguredValue)
      FROM inserted AS source 
         JOIN [ssis].[ConfigurationsBase] target
           ON target.ConfigurationFilter = source.ConfigurationFilter
             AND target.PackagePath = source.PackagePath
               AND target.ConfiguredValueType = source.ConfiguredValueType
                 AND target.EnvironmentEnum = ISNULL(source.EnvironmentEnum, 0)
END
```

#### Roles ####

Permissions to the [ssis] schema object s are controlled through database role membership. The following roles are defined:

- ssis_owner
- ssis_datareader
- ssis_datawriter

#### Permissions ####

| Role Name       | Full | Select | View Definition | Insert | Update | Delete |
| --------------- | ---- | ------ | --------------- | ------ | ------ | ------ |
| ssis_owner      | X    |        |                 |        |        |        |
| ssis_datareader |      | X      | X               |        |        |        |
| ssis_datawriter |      |        |                 | X      | X      | X      |

### Supporting Objects (Optional) ###

The objects in this section are not strictly required for proper execution of SSIS and the BIDS environments. Their purpose is to facilitate interaction with the people who are in charge of maintaining the settings for the additional environments beyond the local developer’s station. Similarly to the mandatory objects discussed previously, the creation of these objects depends on hooks within the build process and also the use of object encryption options.

#### Views ####

This view provides a convenient way of viewing all of the decrypted options across all the environments in a tabular format. This view is also has triggers (not shown) similar to the ones on the Configurations view. This is to support configuration maintenance scripts or tools that need to have an unfiltered view of the base table for maintenance tasks.

##### All Configurations - Tabular Format #####

```sql
CREATE VIEW [ssis].[ConfigurationsAll] WITH ENCRYPTION AS
SELECT ConfigurationFilter,
       ConfiguredValue = CAST (
                  DecryptByPassPhrase('SSIS_CONFIGURATION_PASSPHRASE'
                                      , ConfiguredValue) AS NVARCHAR(255)),
       PackagePath,
       ConfiguredValueType,
       EnvironmentEnum,
       EnvironmentDesc,
       ConfigurationId,
       HostNameDesc
  FROM [ssis].[ConfigurationsBase]
```

This view provides a convenient way of viewing all of the decrypted options across all the environments in a crosstab format.

##### All Configurations - Crosstab Format #####

```sql
CREATE VIEW [ssis].[ConfigurationsCrosstab] WITH ENCRYPTION AS
SELECT ConfigurationFilter,
       PackagePath,
       SUBSTRING(t.ConfiguredValueTypeList, 4, 999) AS ConfiguredValueType,
       [0] AS [DefaultValue],
       [1] AS [DevelopmentValue],
       [2] AS [TestValue],
       [3] AS [ProductionValue]
  FROM (
         SELECT ConfigurationFilter,
                PackagePath,
                EnvironmentEnum,
                ConfiguredValue = CAST (
                     DecryptByPassPhrase('SSIS_CONFIGURATION_PASSPHRASE'
                         , ConfiguredValue) AS NVARCHAR(255))
           FROM [ssis].[ConfigurationsBase]
       ) base
  PIVOT (MAX(ConfiguredValue) FOR EnvironmentEnum IN ([0], [1], [2], [3])) pvt

-- Use CROSS APPLY ... FOR XML PATH trick to concatenate different ConfiguredValueType entries
-- There shouldn't be any differences, but if there are it should be made obvious
-- The initial space-semicolon-space delimiter is removed by SUBSTRING above

  CROSS APPLY (
    SELECT DISTINCT ' ; ' + ConfiguredValueType
      FROM [ssis].[Configurations]
     WHERE ConfigurationFilter = pvt.ConfigurationFilter
       AND PackagePath = pvt.PackagePath
       FOR XML PATH('') ) t ( ConfiguredValueTypeList )
```

This view looks for possible errors in the stored configurations and presents them in a tabular format.

##### Configuration Warnings - Tabular Format #####

```sql
CREATE VIEW [ssis].[ConfigurationsWarnings] WITH ENCRYPTION AS
SELECT ConfigurationFilter,
       PackagePath,
       ConfiguredValueType,
       [DefaultValue],
       [DevelopmentValue],
       [TestValue],
       [ProductionValue]
  FROM [ssis].[ConfigurationsCrosstab]
 WHERE ConfiguredValueType LIKE '% ; %'
    OR (DefaultValue IS NULL AND (ProductionValue IS NULL
                                    OR DevelopmentValue IS NULL 
                                      OR TestValue IS NULL))
```

#### Procedures ####

This procedure provides a convenient way of viewing the decrypted settings for a specific server. When this procedure is executed it will provide the values specific to the environment that matches the server and the default values for those values that were not overridden for the specified server’s. When both a default value and an environment specific value exist the latter will be chosen.

##### Configuration for Specified Server Only #####

```sql
CREATE PROCEDURE [ssis].[ConfigurationsForHostName] 
(
    @HostName NVARCHAR(128)
)
    WITH ENCRYPTION
AS
BEGIN
    -- This query returns the result set of settings for a specified server.
    -- In actual reality the SSIS execution environment will return all the
    -- default settings as well as the environment specific settings and will
    -- then internally override the default values whenever an specific 
    -- settings is found.

    -- First identify all the settings that have been explicitly defined
    -- for the specified server.
    SELECT ConfigurationFilter,
           ConfiguredValue = CAST (
            DecryptByPassPhrase('SSIS_CONFIGURATION_PASSPHRASE', 
                      ConfiguredValue) AS NVARCHAR(255)),
           PackagePath,
           ConfiguredValueType,
           EnvironmentEnum,
           EnvironmentDesc,
           ConfigurationId,
           HostNameDesc
      INTO #EnvironmentSettings
      FROM [ssis].[ConfigurationsBase] base
     WHERE base.EnvironmentEnum = 
                CASE 
                  WHEN @HostName = 'DEV_DB_HOSTNAME'  THEN 1
                  WHEN @HostName = 'QA_DB_HOSTNAME'   THEN 2
                  WHEN @HostName = 'PROD_DB_HOSTNAME' THEN 3
                END

    -- Second identify all the default settings that have not been 
    -- overridden by a specific setting for this server (i.e. exclude
    -- results from the previous query)                   
    SELECT ConfigurationFilter,
           ConfiguredValue = CAST (
                DecryptByPassPhrase('SSIS_CONFIGURATION_PASSPHRASE', 
                      ConfiguredValue) AS NVARCHAR(255)),
           PackagePath,
           ConfiguredValueType,
           EnvironmentEnum,
           EnvironmentDesc,
           ConfigurationId,
           HostNameDesc
      INTO #DefaultSettings
      FROM [ssis].[ConfigurationsBase]
     WHERE ConfigurationId NOT IN 
               (SELECT base.ConfigurationId
                  FROM [ssis].[ConfigurationsBase] base 
                       INNER JOIN #EnvironmentSettings s
                         ON base.[ConfigurationFilter] = s.[ConfigurationFilter]
                           AND base.[PackagePath] = s.[PackagePath])
       AND [EnvironmentEnum] = 0

    -- The real set of settings for the specified server is the union of
    -- the explicit settings from the first query and the implicit 
    -- settings from the second query.    
    SELECT * FROM #EnvironmentSettings
      UNION ALL
    SELECT * FROM #DefaultSettings     
END
```

### Database Server Alias ###

The connection string used by SSIS and BIDS to connect to the database in order to access the stored values is stored within the package itself. The enhanced solution uses database server alias so that we do not have to rely on the same database server and instance names existing across the environments. In order to avoid name conflicts between different databases using this solution, the alias will be named **SSIS\_CONFIG\_\<databasename\>**. The database build process will have additional tasks that will enable the creation of these aliases in a consistent manner. In addition, because the TCP connection can be configured on different addresses and use either dynamic or static ports; to simplify matters the alias is created using the Named Pipe connection instead. As an aside, the local Shared Memory connection does not allow aliases.

### Security Implications ###

The use of encrypted settings and a separate schema would tend to imply a very tight security model but this is not necessarily the case. The separate schema prevents inadvertent viewing of the configuration settings such as might be the case were the objects in the *dbo* schema. The encryption of the actual data within the table helps to keep the data safe in external files such as backups as well as restores of those backups onto other servers. In the end, the SSIS and BIDS tools need access to the unencrypted data so the members of the *ssis_reader* role are able to see all of the configuration data. Role membership will be generally confined to the database developers. These developers will also have access to the database project repositories which will contain the additional passphrase and server names that are encoded in the objects. If this is a concern, the act of creating the database objects related to configuration management could be moved to a separate repository with tighter controls; and the views that return data, further strengthened with additional role or user name checks. In general, tighter security models are more complex to manage and more prone to leaks than simpler models. This paper promotes the simpler model whereby the database development team has knowledge of the encryption passphrase and the values all of the unencrypted configurations.

### Basic Workflow ###

The section below outlines the basic tasks, on how SSIS package management might be inserted into the database build process, and who is responsible for them.

#### Lead Developer ####

1. In the initial database project setup, the Lead Developer would make a decision about whether this SSIS configuration solution would be applied to the project.
2. Assuming this solution was chosen, while specifying the shared project settings, a passphrase would be chosen and saved to the repository.
3. The SSIS configuration objects (mandatory and optional) would be created in the initial database and checked into the repository.
4. The database project repository is released to the general developers 

#### Developer ####

1. Development of SSIS packages occurs no different than today where environment specific settings are not used
2. When the developer is completed and tested the SSIS package, but prior to pushing it back to the repository, package configuration is activated.
3. The developer takes an inventory of the SSIS package and identifies any variables, properties, or connection managers whose value might change based on the environment
4. A unique configuration filter value is created using the SSIS packages name, in order to properly identify which package those settings go to
5. The settings are stored in the database using the SQL Server Alias
6. The base table data is added to source control so that changes can be tracked
7. The developer commits their SSIS packages and pushes to the central repository

#### Lead Developer or Build Manager ####

1. Using T-SQL statements or a client UI, build settings for additional environments would be added to the base table.
