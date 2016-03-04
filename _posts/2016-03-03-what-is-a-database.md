---
layout: post
title: "What Is A Database?"
description: "Posits a new way of thinking about what can constitute a database."
category: Post
tags: [Database, PowerShell]
image:
  feature: layout-posts.jpg
comments: false
---

If I were to say the word *database* to you, what might be the first thing that would come to mind. It would probably depend on your current situation and background. Corporate developers might immediately think of Oracle Database or Microsoft SQL Server. Open-source developers would probably think of MySQL/MariaDB, PostgreSQL, or MongoDB. Desktop users might think of Microsoft Access, Paradox, or even dBase. In general, what you are actually thinking of is the DBMS (Database Management System) or the software that allows you to interact with the database. 

<!-- more -->

At its most basic, a *database* is an organized collection of related information. On top of this data collection is a standardized way of interacting and managing that collection. This interface is generally exposed to the end-user in the form of the DBMS software. If you look at databases, using this more general manner; it opens up a whole world of items that you might not have considered. For instance, a CSV (comma-separated values) file of your contacts, that you manage with Microsoft Excel could be considered a database.

For the rest of this article I would like to describe one-such custom *database* that I built to maintain a list of tasks (i.e. database) via Windows PowerShell (i.e. database management system). As we progress through the discussion, I will relate back to similar features in a relational database.

## Schema

Let's start with the basics, the organization of the database. My database is going to consist of a single text file (i.e. table). Each to-do will be contained on a single line (i.e. record or row). Each line is going to specify the kinds of information (i.e. columns or attributes) that I want to record about a task.

### File Format

A to-do (record) consists of the following attributes (columns):

- completed: a true or false value indicating if the to-do has been completed or not
- completed_date: if completed is true then this is the date it was completed on
- priority: a value of "A" to "Z" that indicates the urgency, "A" being the highest
- created_date: the date this to-do item was entered in the database
- projects: a list of projects associated with this to-do
- contexts: a list of places/tools needed to complete this to-do
- metadata: an optional list of key/value pairs that add extra non-standard information to that to-do
- description: what is the task that that needs to be performed
- line_number: the line number this to-do is on within the text file

> Actually, the line_number is a virtual attribute because it is not stored in the database file itself, but is instead only presented in the interface with the user.

In a traditional, relational database, I could accomplish this with SQL similar to:

```
CREATE TABLE todos (
  line_number    INT      NOT NULL PRIMARY KEY,
  created_date   DATETIME NOT NULL DEFAULT(GETDATE()),
  description    TEXT     NOT NULL,
  completed      BIT      NOT NULL DEFAULT(0),
  completed_date DATETIME NULL,
  priority       CHAR(1)  NULL,
  projects       TEXT     NULL,
  contexts       TEXT     NULL,
  metadata       TEXT     NULL,
);
```

## Data Manipulation

Now that I have a database definition, I need a standardized way of getting information in and out of the database (i.e. DBMS). The interface will give me the ability to create, search for, update, and delete tasks via a fixed set of PowerShell verbs. Let's discuss each one of them individually using an example everyone is familiar with.

### Creating

While at work, I remember that I need to pick up milk on the way home. I want to create a to-do for myself so I do not forget.


From a PowerShell command prompt, I tell the database system to add a record using the *Add-ToDo* verb. I am also indicating this task is a type of "Errand" that will need to be accomplished using my "Car" and it has a priority of "M"edium.

```
C:\PS> Add-ToDo -Text "Pick up milk" -Projects Errands -Context Car -Priority M
TODO: 'Pick up milk @Car +Errands' added on line 1.
```

In a traditional, relational database, I could accomplish this with SQL similar to:

```
INSERT INTO todos(description, projects, contexts, priority)
  VALUES("Pick up milk", "Errands", "Car", "M") 
```

### Searching

It is now the end of the day, and I need to check to see if I have any errands to run on the way home. I am going to search for any tasks that are classified as "Errands". I receive one task from the search, the task I created earlier in the day to pick up milk.

```
C:\PS> Get-ToDo -SearchProject Errands

LineNumber    : 1
CreatedDate   : 2016-03-03
Priority      : M
Projects      : {Errands}
Text          : Pick up milk
Completed     : False
CompletedDate :
Contexts      : {Car}
Metadata      : {}

TODO: 1 tasks in todo.txt
```

In a traditional, relational database, I could accomplish this with SQL similar to:

```
SELECT * 
  FROM todos
  WHERE projects LIKE "%Errands%"
```

### Updating

At this point, I have made it to the store, picked up the milk, and am ready to mark that task as done. From the search I did in the previous step, I know that I want to update task #1 and mark it done.

```
C:\PS> Set-ToDo -LineNumber 1 -MarkCompleted
```

In a traditional, relational database, I could accomplish this with SQL similar to:

```
UPDATE todos
   SET completed = 1
     , completed_date = GETDATE()
 WHERE line_number = 1 
```

### Deleting

Now that I am home, I want to clear out today's to-do list so that I have a fresh slate for tomorrow. From the previous two steps, I know that I want to delete task #1.

```
C:\PS> Remove-ToDo -LineNumber 1
```

In a traditional, relational database, I could accomplish this with SQL similar to:

```
DELETE FROM todos
 WHERE line_number = 1 
```

## Conclusion

In conclusion, I hope with this article that I have presented a useful tool that you might want to use. In addition, I want you to glimpse the many possibilities there are when we refer to a *database*.

> I would be remiss if I didn't mention that while this implementation is original, it is based off the ideas originally presented on [todotxt.com](http://todotxt.com). Please see that website for additional language implementations from others, as well as links to the [documentation](https://github.com/ginatrapani/todo.txt-cli/wiki) for the format.

If you like to download my version of this tool please head over to [GitHub](https://github.com/tjchester/ToDo) and check it out.