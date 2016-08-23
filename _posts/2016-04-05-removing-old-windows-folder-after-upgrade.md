---
layout: post
title: "Removing Old Windows Folder After Upgrade"
description: "Provides batch commands that can remove the Windows.old folder."
category: Post
tags: [Windows Server]
image:
  feature: layout-posts.jpg
comments: false
---

When you do an inplace upgrade of Windows Server 2008 R2 to Windows Server 2012 R2, the old Windows system files are relocated to a folder named C:\\Windows.old. This is to support a rollback to the prior version if necessary.

<!-- more -->

 This folder can take significant space and the user interface, assuming you are not running a Server Core installation, does not provide an easily locatable method of removing that folder. After enough time has passed that you are comfortable with the upgrade, you can use the commands below to remove the folder.

```
takeown /F c:\Windows.old\* /R /A /D Y
echo y| cacls c:\Windows.old\*.* /T /grant administrators:F
rmdir /S /Q c:\Windows.old  
 
takeown /F c:\Windows.old\* /R /A /D Y
echo y| cacls c:\Windows.old\*.* /T /grant administrators:F
rmdir /S /Q c:\Windows.old  
```

 > The previous lines are duplicated on purpose. Your mileage may vary, but I found that I needed to run each block of commands twice, in order to actually successfully remove the folder.
 
### Additional References

- [How to Use CACLS.EXE in a Batch File](https://support.microsoft.com/en-us/kb/135268)
- [Takeown Command Reference](https://technet.microsoft.com/en-us/library/cc753024(v=ws.11).aspx)
- [Cacls Command Reference](https://technet.microsoft.com/en-us/library/cc732245(v=ws.11).aspx)
- [Rmdir/Rd Command Reference](https://technet.microsoft.com/en-us/library/cc726055(v=ws.11).aspx)