---
layout: post
title: "Dell PowerEdge Degraded Backplane Error"
description: "Describes how to fix a problem with the Dell management agents after replacing a failed disk."
category: TechNote
tags: [Dell PowerEdge, Dell OpenManage]
image: 
  feature: layout-posts.jpg
comments: false
---

This brief note talks about an issue I encountered with the Dell OpenManage agents after replacing a failed disk.

<!-- more -->

Recently on one of my Dell PowerEdge servers, a disk failed within one of the local RAID-5 arrays. The disk was replaced and the array rebuild and background initialization completed successfully without errors. After the rebuild operations had completed I opened the Dell OpenManage status page to review the system and noticed that one the connectors on the PERC controller was flagged with a warning state.

Drilling down to the backplane properties showed the state was **Degraded**, yet the Virtual Disks showed all green.

![](/images/posts/dell-degraded-backplane-error-after-disk-replace-01.png)

The actual problem appears to be a disconnect between the management agents and the PERC controller where they are not registering the stable state of the controller after a failed disk has been replaced.

The solution is to simply restart the Dell OpenManage Windows services.

![](/images/posts/dell-degraded-backplane-error-after-disk-replace-02.png)

After the management agents have been restarted, the system page should show a green status on the connector that was previously showing degraded.

![](/images/posts/dell-degraded-backplane-error-after-disk-replace-03.png)
