---
layout: post
title: "Dell PowerEdge OpenManage Firmware Notice"
description: "Describes how to turn off the firmware checks in Dell OpenManage."
category: TechNote
tags: [Dell PowerEdge, Dell OpenManage]
image: 
  feature: layout-posts.jpg
comments: false
---

This brief note talks about how to turn off the Dell OpenManage disk firmware and driver checks.

<!-- more -->

Dell OpenManage has the ability to check that the RAID controller firmware and operating system drivers are the latest version. In the event that the actual versions do not match the expected versions, the OpenManage storage agent will flag this condition to aler to you. The problem arises because the agent marks the controller in a degraded status which can inadvertantly desensitize you causing you to miss "degraged" conditions that you would want to be aware of like a failed physical disk resulted in a degraded RAID array. 

In this first set of three images you can see as we drill into the storage agent how the degraded condition is flagged and somewhat misleading.

![](/images/posts/dell-openmanage-firmware-notice-01.png)
![](/images/posts/dell-openmanage-firmware-notice-02.png)
![](/images/posts/dell-openmanage-firmware-notice-03.png)

I found this setting poorly documented in the manuals and only ran across it by chance when reviewing the INI files. The key file you are looking for is in the **stsvc.ini** file located in either the *C:\\Program Files\\Dell\\SysMgt\\sm\\* or the *C:\\Program Files (x86)\\Dell\\SysMgt\\sm\\* folder.

Once you have located this file, you can edit it with any text editor, notepad for example. You are looking for the **DepCheck** setting. Changing it from *On* to *Off* will disable the checks. This is shown in the image below.

![](/images/posts/dell-openmanage-firmware-notice-04.png)

Once you have modified the INI file you need to restart the **DSM SA Data Manager** service as shown in the image below. I also restarted the Dell OpenManage web interface service as well, **DSM SA Connection Server**.

![](/images/posts/dell-openmanage-firmware-notice-05.png)

As you can see in the images below, now when we drill into the OpenManage storage section the firmware and driver checks are no longer being done and the false degraded condition has been masked.

![](/images/posts/dell-openmanage-firmware-notice-06.png)
![](/images/posts/dell-openmanage-firmware-notice-07.png)
![](/images/posts/dell-openmanage-firmware-notice-08.png)
![](/images/posts/dell-openmanage-firmware-notice-09.png)

