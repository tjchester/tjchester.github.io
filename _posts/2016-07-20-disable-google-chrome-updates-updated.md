---
layout: post
title: "Disable Google Chrome Updates [Updated]"
description: "Describes how to install a local group policy file from Google to disable Chrome's automatic updating."
category: TechNote
tags: [Group Policy, Google Chrome]
image: 
  feature: layout-posts.jpg
comments: false
---

An update to the original article, [**Disable Google Chrome Updates**](/technote/disable-google-chrome-updates/). In this article we look at using the Administative Template in ADMX format for Windows 7 and later. The previously referenced article used the Administrative Template in ADM format for versions of Windows prior to Windows 7.

<!-- more -->

Google publishes information on how to disable the automatic updating of Chrome on Windows machines via group policy. That information is not easily to locate on Google's site, so this article will distill that information into an easily referenced procedure.

In general, allowing Google Chrome to automatically update itself is a good security practice to follow. There are situations, however, where it is undesirable to do so. One specific example is where there are other installed third-party components that require rebuilding after a new Chrome release occurs. For instance, there is a dependency between the Selenium unit test tool and the Chrome web driver. If the Chrome update occurs on a continuous integration server prior to Selenium updating its interface code it could potentially halt the executing of unit tests on the build server.

See Also: 

- [Turning Off Auto Updates in Google Chrome](http://www.chromium.org/administrators/turning-off-auto-updates)
- [Google Update for Work](https://support.google.com/chrome/a/answer/6350036)
- [Managing Group Policy ADMX Files Step-by-Step Guide](https://msdn.microsoft.com/en-us/library/bb530196.aspx)

## Procedure ##

>This procedure assumes that you will be performing Local Group policy changes to a single server and that you have already downloaded the administrative template that Google has created. That template file is contained in [googleupdateadmx.zip](http://dl.google.com/update2/enterprise/googleupdateadmx.zip).
>
>Unpack the downloaded zip file into a work folder. 
>
- Copy **GoogleUpdate.admx** into the *C:\\Windows\\PolicyDefinitions\\* folder.
- Copy **GoogleUpdate.adml** into the *C:\\Windows\\PolicyDefinitions\\en-us\\* folder.

The first step is to open up the Microsoft Management Console (i.e. mmc.exe).

![](/images/posts/disable-google-chrome-update-updated-01.png)

From the **File** menu select **Add/Remove Snap-Ins...**. Scroll down the list of *Available snap-ins*, highlight **Group Policy Object**, and then click the **Add >** button.

![](/images/posts/disable-google-chrome-update-updated-02.png)

When you are asked to select the *Group Policy Object*, select **Local Computer**, and then click the **Finish** button.

![](/images/posts/disable-google-chrome-update-updated-03.png)

Back on the *Add or Remove Snap-ins* dialog, click the **OK** button.

![](/images/posts/disable-google-chrome-update-updated-04.png)

Expand the *Local Computer Policy* tree object and then the *Computer Configuration* object. Expand the **Administrative Templates** tree node to expose the **Google** node. Expand the **Google** node and double-click the **Applications** node in the right-hand pane.

![](/images/posts/disable-google-chrome-update-updated-05.png)

In the right-hand pane, double-click the **Update policy override default** option at the bottom.

![](/images/posts/disable-google-chrome-update-updated-06.png)

Set this policy to **Disabled** and click the **OK** button.

![](/images/posts/disable-google-chrome-update-updated-07.png)

In the left-hand pane, highlight the **Google Chrome** application.

![](/images/posts/disable-google-chrome-update-updated-08.png)

Double-click the **Update policy override** setting in the right-hand pane. Set this policy to **Enabled** and set the policy dropdown to **Updates disabled**. Click the **OK** button to close the dialog.

![](/images/posts/disable-google-chrome-update-updated-09.png)

The last step is to refresh group policy on the local computer via the following command:

```
gpupdate /force
```

In the final image below we can see that updating has indeed been disabled.

![](/images/posts/disable-google-chrome-update-10.png)

> NOTE: When you first goto the Chrome About page it will display *Updating...* making it seem that the update is still occurring. It will spin for a predetermined timeout (a few minutes) and then display the error shown.

### Appendix A: Registry Settings

Setting the options as described above results in the creation of a keys and values within the Windows registry. The following lines below can be saved to a *.reg* and imported into the Registry using the reg tool to accomplish a similar task.

```
Windows Registry Editor Version 5.00
 
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google]
 
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Update]
"AutoUpdateCheckPeriodMinutes"=dword:00000000
"Update{8A69D345-D564-463C-AFF1-A69D9E530F96}"=dword:00000000
"UpdateDefault"=dword:00000000
```

> NOTE: The GUID that appears in the second registry key is the application id that identifies the "Google Chrome" browser. Other Google products that use the update mechanism will have a different identifier.

