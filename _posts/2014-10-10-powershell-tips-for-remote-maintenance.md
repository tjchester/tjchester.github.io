---
layout: post
title: "PowerShell Tips - Remote Maintenance Helpers"
description: "Describes a couple of short PowerShell commands that can help you when performing remote maintenance."
category: TechNote
tags: [PowerShell]
image: 
  feature: layout-posts.jpg
comments: false
---

Periodically I need to remote into various computers to perform maintenance, which most often occurs in off-hour periods. Many of these computers are located in remote offices which I do not have physical access to. This article contains some PowerShell tips that I have found to be useful.

<!-- more -->

> NOTE: These tips assume that you have administrative authority on affected computers.

## Tip 1: Forced Logoff ##

Normally when an administrator connects into a computer, they have the ability to automatically disconnect any logged in users and gain access to the console. In a few instances, I have found computers where administrative session override is denied. This tip allows you to force the logoff using WMI.

	$computer = Get-WMIObject -Class Win32_OperatingSystem -ComputerName [computer] 
	$computer.Win32Shutdown(4)

> NOTE: You will need to provide an actual computer name for the *[computer]* placeholder in the code above.

Other argument options:

- **0** - Log Off
- **1** - Shutdown
- **2** - Reboot
- **4** - Forced Log Off
- **5** - Forced Shutdown
- **6** - Forced Reboot
- **8** - Power Off
- **12** - Forced Power Off

See Also: [Win32Shutdown method of the Win32_OperatingSystem Class](http://msdn.microsoft.com/en-us/library/aa394058(v=vs.85).aspx)

## Tip 2: Power Plans ##

The other issue that I typically face is that the computers hibernate or go into a sleep state. Typically this would occur after the remote user has gone home for the night. This tip helps to disable those power settings but it must be applied during the day when the computer is actually powered up.

See Also: [Powercfg Command-Line Options](http://technet.microsoft.com/en-us/library/cc748940%28WS.10%29.aspx)

### Hibernation ###

The code below will turn off hibernation. You could replace the *-h* argument's value with *on* if you wanted to activate hibernation instead.

	$cred = Get-Credential [Domain\Username]
	Invoke-WMIMethod -cred $cred `
                     -path Win32_Process `
                     -name Create `
                     -argumentlist "powercfg.exe -h off" `
                     -ComputerName [computer]

> NOTE: You will need to provide an actual administrator account and computer name for the *[Domain\\UserName]* and *[computer]* placeholders in the code above.

### Sleep ##

The code below disables sleep whenever the computer is connected to AC power by setting the standby timeout to 0. Any value greater than 0 would activate sleep mode based on the number of minutes supplied. There are other settings that can be specified for the *-x* argument. For example, if you wanted to disabled sleep mode when on battery or DC power you could use *-standby-timeout-dc 0* instead.

	$cred = Get-Credential [Domain\Username]
	Invoke-WMIMethod -cred $cred `
                     -path Win32_Process `
                     -name Create `
                     -argumentlist "powercfg -x standby-timeout-ac 0" `
                     -ComputerName [computer]

> NOTE: You will need to provide an actual administrator account and computer name for the *[Domain\\UserName]* and *[computer]* placeholders in the code above.
