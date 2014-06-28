---
layout: post
title: "How To Source Control Your SQL Server Databases"
description: "Describes how to apply source control practices to your database management system."
category: HowTo
tags: [Source Control, SQL Server]
image: 
  feature: layout-posts-2.jpg
comments: false
---

This document discusses the feasibility of using source control with database development for SQL Server (2005 and newer) databases. 

<!-- more -->

While it has long been a practice to manage application source code through version control systems, up until recently it has not been practical to perform the same activities with databases. The advent of tools that connect database development tools to the same version control systems used by the application teams opens up a new window of opportunity for controlled and repeatable processes to be built around an organization’s database development. It is this paper’s posture that Microsoft SQL Server database source control is feasible and practical provided there is an investment in tools and the development of processes around the use of those tools. In addition, there are some limitations to the list of recommended tools that will require some custom in-house development to resolve.

## Purpose ##

This document discusses the feasibility of using source control with database development for SQL Server (2005 and newer) databases. First some background around the problem is discussed; which includes the differences between shared and dedicated databases. Next, the Red Gate toolset is introduced, followed by some examples demonstrating the use of their SQL Source Control plug-in. Those examples are then followed by a discussion of some limitations of the current version of that plug-in. The last section talks about how to extend basic version control with issue tracking, code reviews, continuous integration, and the support of version control for other SQL Server technologies such as Integration Services.

## Background ##
Source control systems give you the ability to track and retain the history of changes to the files that make up an application or system. These shared repositories provide a central authoritative source for a system and allow the controlled collaboration between the people involved in the development and maintenance of that system. Traditionally these benefits have not extended to database development because databases do not consist of strict source files, but are comprised of schema and data – usually held within some form of binary container. Corporate databases are storage areas for the majority of a business’s vital information and changes to the objects and logic contained in them should be visible and auditable. In addition, to having databases under source control a method of controlled and repeatable migrations between environments is needed. Up until recently, there were not any available tools that could assist with this process.

One potential method of managing databases under source control is to create a directory containing sequentially number SQL scripts that are applied to the database in order by an external tool. This tool further creates a table within the database for tracking which scripts have been applied. These scripts can be source controlled and applied in a controlled manner. The limitation lies in the fact that changes to the database are isolated in batches and you lose the ability to see the history to individual objects in any easily accessible manner.

One of the difficulties around database objects is that one set of syntax is used to create the object and a different set of syntax is used to change the object. Application source files on the other hand have no such limitation. In order for a source control system to handle the history around database objects, it must store the initial CREATE syntax and then apply each successive ALTER as a transformation on the CREATE rather than a CREATE file followed by successive ALTER files. 

This is best illustrated using an example. Suppose we have the following syntax used to create a table to store state information:

```sql
CREATE TABLE MyStateTable
(
  StateAbbrev CHAR(2) NOT NULL PRIMARY KEY,
  StateName   VARCHAR(50) NOT NULL
)
```

Our version control system sees the following:

![](/images/posts/sql-server-source-control-01.png)

Now let us suppose that we forgot to add a field for the state capital. Normally through SQL we would create the following file:

```sql
ALTER TABLE MyStateTable
  ADD StateCapital VARCHAR(100) NULL
```

Behind the scenes, our tool stores the following which preserves the history of the object but takes into account the actual change:

![](/images/posts/sql-server-source-control-02.png)

```
It should be pointed out that since the tool is storing objects with only CREATE syntax, it must support the ability to compare a version in source control to the current version and generate the sequence of ALTER statements that will be needed to transform the old object into the new object.
```
 
## Development Models ##

There are two common database development models: shared and dedicated. In the shared model, developers work on a common database typically located on a development server. In the dedicated model, developers work on a local copy of the database on their machines.

### Shared Model ###

In this model, the development database is typically created using a restored backup from the production database. All developers work on their own objects within the database and at some point changes will be migrated to a test or production environment.

While this model does simplify some change management activities it has some limitations and risks. For one it typically requires that developers have elevated privileges on the server and database as well as remote access to the server’s desktop. Additionally, it is difficult for developers to experiment or make changes without impacting the other developers. Finally, it is difficult to stabilize test data as each developer may be creating or modifying data to test their particular changes.

### Dedicated Model ###
In this model, each developer works with their own copy of the database which could be either located on a server or on their local machine.

Working in this model requires some form of source control to manage the publication of the developer’s local changes as well as being able to synchronize the changes from other developers. Each developer gains isolation for the development and testing of their changes. The choice of a server or local location for the development database typically depends on the power of the developer machines and the sensitivity of the data in the database. As a general rule, the data contained within the database should neither be direct production data nor should it be production volumes.

Compared to the shared model, the dedicated model facilitates better project tracking. When developers use a shared model there is no real need to commit changes since everybody is working on a common database and repository. When developers work on their own dedicated database, then they need to perform commits and pushes to the master repository in order for their changes to be visible to the other developers. If a project manager fails to see commits to the master repository from a developer then that can be a tickler to follow-up and see what issues may be holding that person up.

One of the pre-requisites of this model is that developers are supplied with machines that are suitable for this kind of development; which is not typically the same machines that are deployed for regular desktop use. In particular, faster processors, more RAM, multiple monitors, and fast large and local disks are required.

## Red Gate Tools ##

[Red Gate](http://www.red-gate.com/) produces a variety of tools related to database development and administration.

The Red Gate SQL Server Development Tools are listed in the table below with the costs for a single developer buying the tools separately.

| Tool Name(1) | Description | Cost(2) |
| --------- | ----------- | ---- | 
| SQL Source Control | Database source control within SSMS | $395 |
| SQL Compare Professional | Compares and synchronizes database schemas | $595 |
| SQL Data Compare Professional | Compares and synchronizes database contents | $595 |
| SQL Data Generator | Test data generator for SQL Server databases | $295 |
| SQL Packager | Packages a database for deployment or update | $295 |
| SQL Doc | Document SQL Server databases | $295 |
| SQL Dependency Tracker | Visualizes SQL Server object dependencies | $295 |
| SQL Prompt | Write, edit, and explore SQL effortlessly | $295 |
| SQL Multi Script Unlimited | Deploy multiple scripts to multiple servers with one click | $195 |
|  |  |		$3255.00 |

```
(1) It appears from Section 5.3 of the Red Gate License Agreement, the tools listed here are classified as “Per User Licensed Software” which allows a single specified user to use those tools on more than one OSE (Operating System Environment). This would seem to imply that we could not purchase only the SQL Source Control plug-in for each developer and then install the bundle on a server for shared access without first purchasing a bundle license for each user.
(2) The prices listed do not reflect any discounts, such as for volume purchases.
```

The table below lists the bundle price for a single developer.

| Bundle | Cost |
| ------ | ---- |
| SQL Developer Bundle | $1495 |
| - SQL Source Control |       |
| - SQL Compare Professional |  |
| - SQL Data Compare Professional |  |
| - SQL Data Generator |  |
| - SQL Packager |  |
| - SQL Doc |  |
| - SQL Dependency Tracker |  |
| - SQL Prompt Professional |  |
| - SQL Multi-Script Unlimited |  |

```
The SQL Source Control tool is required at a bare minimum in order to support version control for SQL Server objects. The additional tools add value in the areas of environment migration, test data generation, and impact analysis but are not strictly required just to support version control.
```

## SQL Source Control ##

SQL Source Control is an add-in for Microsoft SQL Server Management Studio that acts as a connector between a database and an external source control system such as Subversion, Team Foundation Server or Mercurial. This add-in can track changes for both database objects and static table data.

```
Best practices state that any data created through the use of the system such as transaction data should not be managed through source control.
```

### Example 1: Adding a Database to Source Control ###

This example demonstrates how an existing production database might be added to source control. This example assumes an empty Mercurial repository has been created prior to the linking step. The act of creating a new repository in Kiln and then cloning that repository is sufficient to complete the setup.

In this example we are going to add the *Adventure Works* sample database to source control. First select the database and then select **SQL Source Control** from the **Tools** menu. When the *Link a database to source control* tab is displayed, click the **Link database to source control…** link.

![](/images/posts/sql-server-source-control-example-01-01.png)

We will need to complete the dialog shown below. Item 1 specifies the working folder where the empty repository resides. For Item 2 we need to select *Mercurial* from the list. Per database development best practices, we should select **Dedicated database** from *Development Model*. Finally, click the **Link** button to complete.

![](/images/posts/sql-server-source-control-example-01-02.png)

The following dialog will be displayed to indicate the link is complete. At this stage, the database has been linked to the repository, but no objects have actually been committed to source control. That will be done in the next step. Click **OK** to close this dialog.

![](/images/posts/sql-server-source-control-example-01-03.png)

Select the *Commit Changes* tab to see a list of objects that are ready to be committed to source control. Enter a commit message and click **Commit**. You can uncheck the box next to an individual object to exclude if from the current commit operation. In addition, you can specify filter rules (not shown in this example) that will remove certain objects from appearing in the *Commit*, *Get Latest*, or *Undo* lists.

![](/images/posts/sql-server-source-control-example-01-04.png)

At the completion of this commit operation, the dialog, shown below, will be displayed. At this stage, your database objects are in the local repository but not yet available for other developers to access. Click the **OK** button to close out this dialog.

![](/images/posts/sql-server-source-control-example-01-05.png)

As the final step, use either [*TortoiseHg*](http://tortoisehg.bitbucket.org/) or the *Mercurial* command line to push your local repository back to the central repository (in this example that would be Kiln) in order for other developers to access your changes.

### Example 2: Developer Database Setup ###

This example demonstrates how a developer gets a copy of the production database now under source control and recreates it on a development machine. This example also assumes that an existing Mercurial repository has been created prior to the linking step. The act of cloning the master repository from Kiln is sufficient to complete the setup. In addition, an empty database must also be created, although the name does not have to match the name of the production database.

In this example, assume we have already created a database named *AdventureWorks-Developer1* on our development machine. We select that database in the SQL Server Management Studio and then select **SQL Source Control** from the **Tools** menu. When the *Link a database to source control* tab is displayed, click the **Link database to source control…** link.

![](/images/posts/sql-server-source-control-example-02-01.png)

We will need to complete the dialog shown below. Item 1 specifies the working folder where the empty repository resides. For Item 2 we need to select *Mercurial* from the list. Per database development best practices, we should select **Dedicated database** from *Development Model*. Finally, click the **Link** button to complete.

![](/images/posts/sql-server-source-control-example-02-02.png)

The following dialog will be displayed to indicate the link is complete. At this stage, the database has been linked to the repository, but no objects have actually been retrieved from source control into our local database. That will be done in the next step. Click **OK** to close this dialog.

![](/images/posts/sql-server-source-control-example-02-03.png)

Select the *Get Latest* tab to see a list of objects that are ready to be retrieved from source control. You can uncheck the box next to an individual object to exclude if from the current operation. In addition, you can specify filter rules (not shown in this example) that will remove certain objects from appearing in the *Commit*, *Get Latest*, or *Undo* lists. Click the **Get Latest** button.

![](/images/posts/sql-server-source-control-example-02-04.png)

At the completion of this operation the following dialog will be displayed. At this stage, your database objects are synchronized with the master copy and your database is ready for development. Click the **OK** button to close out this dialog.

![](/images/posts/sql-server-source-control-example-02-05.png)

### Example 3: Adding Static Data to Source Control ###

This example demonstrates how static data can be placed under source control.

We first select out database in SQL Server Management Studio, then right-click and select **Link/Unlink Static Data** from the **Other SQL Source Control Tasks** menu.

![](/images/posts/sql-server-source-control-example-03-01.png)

On the *Link/Unlink Static Data* tab select the tables that you want to include and then click the **Save and close** button. This dialog shows all tables that have been selected for linking, either currently, or in the past, so we may see some tables that are already selected in the list.

```
As noted in the Tool Limitations section, the tool will not detect foreign key dependencies between tables when you are selecting tables to link.
```

![](/images/posts/sql-server-source-control-example-03-02.png)

Select the *Commit Changes* tab to see a list of objects that are ready to be committed to source control. You can uncheck the box next to an individual object to exclude if from the current commit operation. In addition, you can specify filter rules (not shown in this example) that will remove certain objects from appearing in the *Commit*, *Get Latest*, or *Undo* lists. Enter a commit message and click the **Commit** button.

![](/images/posts/sql-server-source-control-example-03-03.png)

After the changes are successfully committed, you will see the following dialog. Click **OK** to close it.

![](/images/posts/sql-server-source-control-example-03-04.png)

As the final step, use either [*TortoiseHg*](http://tortoisehg.bitbucket.org/) or the *Mercurial* command line to push your local repository back to the central repository (in this example that would be Kiln) in order for other developers to access your changes.

## Tool Limitations ##

### SQL Source Control ###

#### Link/Unlink Data ####

This function does not detect foreign key relationships when selecting tables to link data for. For instance in the *AdventureWorks* database, we could select just the *Person.StateProvince* table for linking and the tool would not alert us to the fact that it depends on data in the *Person.CountryRegion* and *Sales.SalesTerritory* tables.

This function is not subject to the “Undo Change” functionality of the Source Control plugin. If we unlink a table and then decide that we still needed it; we must manually go in and re-add it because there is no undo.

```
It appears that the unlinking of static data is a non-destructive operation. The Source Control Plugin Commit screen shows the following in the change area:
 “This change is a data unlink. Data unlink. This is a configuration change. When you commit a data unlink the table’s data is removed from source control and data changes for the table are no longer detected. The data in your database does not change.”
```

#### Miscellaneous ####

The order of some of the *sp_addextendedproperty N’MS_Description’* entries changed between the source database and when the script was applied to the target database. This resulted in a “commit” required back to the original database. In general, this would not have caused any problems but it was unexpected behavior.

#### Migration Scripts ####

Migration scripts are not currently supported when using Mercurial as your source control system. This means that certain destructive operations, such as table renames, cannot be handled through the source control plugin without assistance. The Red Gate documentation identifies the four most common operations which require a migration script:

1. Adding a NOT NULL constraint to a column that has data in it already but doesn’t have a default value specified.
2. Renaming a table causes a DROP then CREATE table which results in a loss of data
3. Table and column splits and merges results in the DROP of the old column and the CREATE of the new columns resulting a loss of data
4. Changing the data type (or size) of a column could result in truncation or existing data or the change to fail if existing data cannot be converted to the new data type

In theory, a possible solution is to create database deployment scripts in version control along with the object changes. A database deployment tool, such as [*psake*](https://github.com/psake/psake), will execute those scripts before the object changes are applied to the database.

```
The Source Control Plugin seemed to identify changes that could cause problems such as shortening the column length on the Commit side, but on the Get Latest side did not indicate that would happen until you actually ran the operation, then a dialog appeared asking you to confirm.
```

### Multiple Tools ###

#### Version Selection and History Viewing ####

In their current versions, the Red Gate tools support a tighter integration with other source control systems such as Team Foundation Server and Subversion. Because the integration with Mercurial is not as tight, you are not able to specify the version of the schema to migrate using the Data Compare tool nor are you able to view object history from within the SQL Source Control tool.

## Looking to the Future ##

Having databases under source control opens the possibility of integrating more agile development techniques into the database development process. A couple of these techniques are applying version control to other SQL Server technologies, issue tracking with code reviews, continuous integration and unit testing.

### Integration Services and Reporting Services ###

SQL Server Integration Services (SSIS) packages and SQL Server Reporting Services (SSRS) reports are created and maintained through the SQL Server Business Intelligence Development Studio (BIDS), which is based on the editor used in the Visual Studio product. This editor supports source control through a plug-in interface. Out of the box it supports Microsoft SourceSafe but through the use of the free [VisualHG plug-in](http://visualhg.codeplex.com/) it can be made to support Mercurial. This plug-in does not currently work with SQL Server Management Studio (SSMS).

### Issue Tracking / Code Reviews ###

[Fog Creek Software](http://www.fogcreek.com) produces an integrated set of tools known as FogBugz and Kiln. FogBugz is an issue tracker and Kiln is a source control product based on Mercurial. The integration between the two products allows changes to be tied to issues, time to be estimated and tracked against those issues, and the option of online code reviews of changes.

The Fog Creek tools are listed in the table below with the costs for a single developer buying the tools separately.

| Software | Cost |
| -------- | ---- | 
| Self-Hosted FogBugz – 1 license | $299 |
| Self-Hosted Kiln – 1 license | $299 |
|  | $598.00 |

```
The prices listed do not reflect any discounts, such as for volume purchases.
```

The table below lists the bundle price for a single developer.

| Software | Cost |
| -------- | ---- | 
| Self-Hosted FogBugz with Kiln Integration – 1 License | $449 |

#### Example 1: Linking a Bug to a Change ####

In this example, we create an issue in order to track activity related to a change request.

In FogBugz, we have created issue 74415 to track the request to store state abbreviations in an existing table.

![](/images/posts/sql-server-source-control-example-04-01.png)

As the assigned developer, we are making the change within SQL Server Management Studio. We could just have easily scripted the change using an ALTER script, and the change would still have been detected by the SQL Control Plugin.

![](/images/posts/sql-server-source-control-example-04-02.png)

After testing our change, we are ready to commit it into our local repository. Activating the *Source Control* tab and going to the *Commit Changes* tab, we enter our commit message. As long as we preface our change with the word *Bug* (*Case* or *Review*) and the number (i.e. Bug 74415 or Case 74415) our changes will automatically be linked between FogBugz and Kiln.

![](/images/posts/sql-server-source-control-example-04-03.png)

After committing to our local repository, we still need to push the changes to the remote Kiln repository that contains the master copy of the database objects. Once that push has been made, then going back into our open issue shows a new *Changeset* comment added to the work log.

![](/images/posts/sql-server-source-control-example-04-04.png)

#### Example 2: Using a Code Review for a Change ####

In this example, we view the change activity within Kiln and request a code review of the change.

In Kiln, we can see our change in the list of recent activities.

![](/images/posts/sql-server-source-control-example-05-01.png)

Clicking on the commit message takes us to the details of that change set which in this example is only a single file related to the table definition of the *MyNewTable* object. The red and green highlighted lines indicate the actual change.

![](/images/posts/sql-server-source-control-example-05-02.png)

Within the change view, shown above, you can click the *Reviews* link to view existing reviews or to create a new review. As an alternative, you can also create a review from the recent activity view as shown in the image below. In either case, we then select a number of people to be involved in the review and click **Request Review**.

![](/images/posts/sql-server-source-control-example-05-03.png)

Once inside the review, shown below, the reviewer can sign-off on the change by clicking the **Approved** button on the *Approve/Reject* tab.

![](/images/posts/sql-server-source-control-example-05-04.png)

The approval or rejection of the code review is reflected in the issue that is tracking this change.

![](/images/posts/sql-server-source-control-example-05-05.png)

## Continuous Integration ##

Continues integration means that development occurs in small batches and is combined together on a frequent basis including running additional tests. The purpose of this process is to ensure that problems are found and fixed earlier in the development process. In database development terms, this would be a development build server that continually gets the latest source, updates the database, and then optionally runs automated tests.

> Continuous Integration is a software development practice where members of a team integrate their work frequently, usually each person integrates at least daily — leading to multiple integrations per day. Many teams find that this approach leads to significantly reduced integration problems and allows a team to develop cohesive software more rapidly. – Martin Fowler

Using a combination of [JetBrains TeamCity](http://www.jetbrains.com/teamcity/) and Red Gate Data Compare with Red Gate SQL Data Compare tools, a build server can be built.

```
The professional versions of the Data Compare and SQL Data Compare tools are needed in order to: (1) deploy from source control and (2) to have command line access to the tools.
```

```
The Professional (free) version of Team City supports 20 build configurations and 5 build agents. Some investigation would still need to be done to see if it is possible to programmatically or manually change a set of build configurations in order to use them for more than 20 databases. If this is not possible then and Enterprise License would be needed for TeamCity.
```

| Software | Cost |
| -------- | ---- |
| JetBrains TeamCity Enterprise License | $1999 |
| Red Gate Data SQL Compare Professional | $595 |
| Red Gate SQL Compare Professional | $595 |
| Total Per Development Server | $3189.00 |

Best Practices state that the production database environment should not be automatically updated through a continuous build process but through the use of scripts created generated by the Data Compare and SQL Data Compare tools.

```
An automated build server depends on a resolution to the Migration Script issues as discussed in the Tool Limitations section above.
```

#### Example 1: Automated Database Documentation ####

Database documentation aids in the impact analysis of new changes as well as research into bugs related to recent changes. Red Gate has a tool called *SQL Doc 2* that can generate database documentation through a user interface as well as through the command line (after a project file has been created through the GUI). This tool can output documentation in one of four formats: HTML, HTML with frames, Microsoft Word, and Microsoft Help File (i.e. CHM).

The image below shows a sample from the CHM file format.

![](/images/posts/sql-server-source-control-example-06-01.png)

### Unit Testing ###

Red Gate is currently previewing *SQL Test*, a unit test add-in for SQL Server Management Studio. This tool is actually a graphical interface over the open-source [*tSQLt*](http://tsqlt.org/sql-test/) tool. Out of the box the tool comes with *SQL Cop* rules which perform static analysis tests against your SQL.

Installing the tSQLt framework requires several changes to your server and database that require elevated privileges. In addition, each test you create will be its own stored procedure and the framework will create objects within your database that manage the execution of the tests. Your database migration plans may have to be updated if you want to prevent the migration of the test specific objects.

#### Example 1: Running Unit Tests Using SQL Server Management Studio ####

This example walks through the simple use case of running the tests manually using SQL Server Management Studio.

After selecting **SQL Test** from the Tools menu, you are presented with the following dialog:

![](/images/posts/sql-server-source-control-example-07-01.png)

Click the **Add Database to SQL Test** link, select the *tSQLt_Example* database from the list, and click the **Add Database** button. NOTE: If you do not have the tSQLt_Example database in the list you can click the Install Sample Database link at the bottom of the dialog to install it.

![](/images/posts/sql-server-source-control-example-07-02.png)

After selecting the database that you want to test, you are presented with a dialog which displays the available tests within that database. By highlighting either the database name or the test grouping names you can control the number of tests that are run. In this example, the database name is highlighted indicating that we want to run all available tests.

![](/images/posts/sql-server-source-control-example-07-03.png)

The results of the test are shown below indicating that two test failures have occurred.

![](/images/posts/sql-server-source-control-example-07-04.png)

Double-clicking the name of test, in this case *test Decimal Size Problem*, opens up the test script (i.e. stored procedure) in the query editor window.

#### Example 2: Running Unit Tests Using TeamCity ####

This example walks through the setup and execution of units tests through a TeamCity project. It is assumed that the tSQLt setup has already been completed in the example database.

First connect to TeamCity and create a new project.

![](/images/posts/sql-server-source-control-example-08-01.png)

Next we will add a build configuration.

![](/images/posts/sql-server-source-control-example-08-02.png)

Next we will add a build step to execute all of the unit tests.

![](/images/posts/sql-server-source-control-example-08-03.png)

Next we will add an additional build step to retrieve the test results as an XML file.

![](/images/posts/sql-server-source-control-example-08-04.png)

Next we will add a build feature to parse the XML results file.

![](/images/posts/sql-server-source-control-example-08-05.png)

Next we will manually run the build configuration.

![](/images/posts/sql-server-source-control-example-08-06.png)

The build configuration has failed and we can view the results.

![](/images/posts/sql-server-source-control-example-08-07.png)

![](/images/posts/sql-server-source-control-example-08-08.png)

Clicking the Tests tab shows all of the tests that were run.

![](/images/posts/sql-server-source-control-example-08-09.png)

If the additional build step and build feature to export the results as XML was not included; you could still find the tests that failed, but it would require a manual inspection of the build log as shown below.

![](/images/posts/sql-server-source-control-example-08-10.png)

## Citations and Additional Reading ##

The following articles and websites were used in the production of this document and contain additional information related to the products and processes discussed. They appear in no particular order.

1. [SQL Source Control – Q & A, 08/26/2012, SQL Server Central](http://www.sqlservercentral.com/articles/Red+Gate+Software/71062/Printable)
2. [The business benefits of database source control – Improving productivity, change management, scalability, and code quality with SQL Source Control, Red Gate](http://www.red-gate.com)
3. [Database development models – SQL Source Control version 3.0 Help Documentation, Red Gate](http://www.red-gate.com)
4. [The 10 commandments of good source control management, Troy Hunt, 05/10/2011](http://www.troyhunt.com/2011/05/10-commandments-of-good-source-control.html)
5. [Evolutionary Database Design, Martin Fowler and Pramod Sadalage, 01/2003](http://martinfowler.com/articles/evodb.html)
6. [The unnecessary evil of the shared development database, Troy Hunt, 02/2011](http://www.troyhunt.com/2011/02/unnecessary-evil-of-shared-development.html)
7. [Rocking your SQL Source Control world with Red Gate, Troy Hunt, 07/2010](http://www.troyhunt.com/2010/07/rocking-your-sql-source-control-world.html)
8. [Automated database releases with TeamCity and Red Gate, Troy Hunt, 02/2011](http://www.troyhunt.com/2011/02/automated-database-releases-with.html)
9. [Using SQL Test Database Unit Testing with TeamCity Continuous Integration, Dave Green, 02/02/2012](http://www.simple-talk.com/content/print.aspx?article=1436)


