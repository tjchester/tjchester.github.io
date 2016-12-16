---
layout: post
title: "Lost Disk Space to Fuslogvw"
description: "Describes how to identify and stop losing disk space because of the .Net binding logs."
category: Technote
tags: [Windows, .NET, Fuslogvw]
image: 
  feature: layout-posts.jpg
comments: false
---

This post will discuss a recent problem I encountered when installing Visual Studio 2015 *(although the actual software being installed does not matter)*. During the installation process, the 250GB drive in my computer ran out of space.

<!-- more -->
 
This was a rather odd occurrence. A quick check, using Windows Explorer, of the sizes of the *C:\ProgramData\\*, *C:\Users\\*, *C:\Program Files\\*, and *C:\Program Files (x86)\\* folders, did not show any obvious problems. Also there wasn't a hibernate file and the paging file was a reasonable size. On the other hand the *C:\Windows\\* folder was using over 100GB and had millions of files.

I first turned on showing hidden files and turned off hiding protected OS files, in Windows Explorer, to see if I could quickly spot anything.

    Windows Explorer -> Tools -> Folder Options...
        View tab
            - Hidden files and folders
                - [X] Show hidden files, folders, and drives
            - [ ] Hide protected operating system files (Recommended)

The usual problem folders such as *C:\Windows\Temp\\* and the *C:\Windows\WinSxS\\* looked fine.

I next downloaded the free space analysis program [TreeSize](https://www.jam-software.com/treesize_free/) from JAM Software. That program identified the following two hidden and protected folders below:

- C:\Windows\SysWOW64\config\ystemprofile\AppData\Local\Microsoft\Windows\Temporary Internet Files\Content.IE5\
- C:\Windows\System32\config\systemprofile\AppData\Local\Microsoft\Windows\Temporary Internet Files\Content.IE5\

Taken together they were using 75GB of space and holding over ten million files. Now that I had identified the issue, I figured I would just delete them using the built-in *del* command.

It took many hours but the directories finally cleared out. Problem solved? Actually not, fresh new files started appearing in the folders throughout the day. This time around, I actually looked at the content of one of the files, in this case, one named *ZZE6KS5D.HTM*.
 
![Sample File](/images/posts/lost-disk-space-to-fuslogvw-03.png)
 
A quick search of the internet for the terms "*Assembly Binder Log Entry*" identified the .NET Framework [**fuslowvw.exe**](https://msdn.microsoft.com/en-us/library/e74a18c4(v=vs.110).aspx) utility.

This program is typically located in *C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin* folder, although the version number of the SDK, v7.0A in this case, will vary.

Starting the program displays the following main screen. In this case we are interested in the "*Settings*" button.

![Utility Main Screen](/images/posts/lost-disk-space-to-fuslogvw-01.png)

In my case, the setting **Log all binds to disk** was checked, rather than the default setting of **Log disabled**. This setting was causing the binding logs (refer to the *ZZE6KS5D.HTM* mentioned above for an example log file) to be saved to my disk everytime a .NET program such as Powershell or Visual Studio was used.

![Utility Main Screen](/images/posts/lost-disk-space-to-fuslogvw-02.png)

Changing the setting back to **Log disabled** stopped the creation of the files I was seeing and allowed me to finally cleanup the originally sited folders for good.

> In conclusion, I can only assume that at some point in the last couple of years, I had activated that setting for debugging purposes and then had forgotten all about it. All that time, the small log files had been accumulating and using up my disk space slowly. In this case searching for a few large files as the culprits would have turned up nothing. With the assistance of TreeSize I was able locate the problematic folders. Finally with a quick search of the internet I was able to identify the program that started it all.


