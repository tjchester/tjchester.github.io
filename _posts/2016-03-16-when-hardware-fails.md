---
layout: post
title: "When Hardware Fails?"
description: "A case study on handling a server hardware failure."
category: Post
tags: [Server, Failure]
image:
  feature: layout-posts.jpg
comments: false
---

## Overview

A failure of any kind requires you to remain calm while you triage the event, in order to minimize the damage as much as possible. Afterwards, you can look back on the failure with a clear head and identify the conditions that led to it, and implement improvements that minimize the change of the same failure in the future. In short, it is an opportunity to grow.

<!-- more -->

## Background

The company I work for provides lifestyle coaching to participants to help them improve their quality of life and minimize their need for drastic medical intervention. The staff is comprised of registered nurses, dietitians, exercise physiologists, and diabetes educators. The company is paid by the organizations that the participants are part of, typically self-insured employers. The incentive is that if the participants change their lifestyles and become healthier, that will minimize the possible insurance expenses their employers will incur from extensive medical treatments. Our staff operates similar to a call center and uses a in-house hosted clinical application to drive and record the process. It should be obvious the the uptime of the clinical platform is very important.

## Disaster Strikes

A little over a year ago, in the middle of the afternoon, I received an alert that one of the two clinical platforms was down. To complicate matters, the server hosting the platform was in one of our other sites halfway across the country. An onsite person conducted a visual inspection of the server and indicated that amber lights were showing on the front panel. Fortunately a basic KVM was attached to the server so that I could see the console remotely. It was sitting on the disk array BIOS screen indicating a drive had failed. This initially was somewhat puzzling as all of the servers I setup had either RAID-1 or RAID-5 arrays which can survive a single drive failure. To my horror, this server, which had been setup by one of my predecessors, was RAID-0. RAID-0 is designed for performance and does not have any redundancy built into it. This means that not only was the server down, but the data was not recoverable.

## Options

Our first priority was to get the server online as soon as possible. To that end we had two options: one, replace the drive and rebuild the server, or two, re-purpose another online server.

In regard to the first option, we had two spare drives of a larger capacity which would give us a new RAID-1 drive array. This new array, due to the larger drives, would have more capacity than the original RAID-0 drive. Then we would need to reinstall the operating system, the hardware drivers, and finally the backup agent. At that point we could connect to the backup server and restore the original drive contents. The downside to this option was that the onsite personnel were developers and not system administrators skilled at bootstrapping a system.

Option two seemed like a better option since the server chosen for re-purposing was closer to the specifications of the failed server. In addition it also had the same operating system and database server versions. This would lessen the upfront time needed and allow us to immediately focus on the tape restores.

We chose option two and were able to have the server back online early the next morning. Because of that choice the call center was only down for about seven hours out of a normal twelve hour day. Also due to the database log backups occurring once an hour, in total less than an hour of data was lost due to the failure.

## Lessons Learned

Immediately after the server was brought back online, I reviewed all of the servers to confirm that they were all running at RAID-1 or RAID-5. In addition, I had an onsite inventory of spare disks conducted and put in a requisition for any sizes that were missing. Secondly, there was a chance that the failed disk had actually been failing for a while but monitoring wasn't in place to detect it. I then deployed the hardware vendor's SNMP monitoring software to any server that did not currently have it. After it was deployed, I reviewed the disk inventory on each server to verify the health status of the RAID arrays as well as the status of the hot spares.

With the remaining servers inventoried and monitored, I turned my attention back to thoughts on minimizing recovery windows in the future. I requisitioned replacement parts, both memory and disks, for the original failed server. I was going to bring it back as a standby server for not only the call center application that was originally hosted, but also the other one that was spared from the failure. The rebuilt server would have two database instances and enough storage and memory to run both clinical applications if necessary. 

Database backups are made to the storage arrays so the most recent copies are always available. That being said, there were other files on the application servers that changed daily and were backed up to tape. The only issue was, that depending on the time of another failure, the backup tapes that were needed could potentially be stored offsite. This would require contact with the storage vendor and could potentially force us to wait until sometime the next business day for the tapes to be returned. To mitigate this possibility I setup redundant backups to disk that remained onsite. These backups would be used in the event that the needed data was on external tapes.

## Conclusion

So in hindsight, this particular failure probably could not have been prevented but it did not become a disaster. We were able to remain calm, think clearly, and find the most expedient solution to recovery. Further, we used the event to put better checks and balances in place to help detect future failures before they happened. Should that future failure happen anyways, we put measures in place, via the standby server, that would minimize the recovery time as much as possible. I am happy to report that we never needed to use the standby server.