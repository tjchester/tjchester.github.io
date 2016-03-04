---
layout: post
title: "Fixing Windows Update Error 0x80072F8F"
description: "The posts discusses a method of addressing Windows Update error 0x80072F8F stemming from SSL certificate problems in the context non-domain joined machines."
category: TechNote
tags: [Windows Server, WSUS, SCCM, Windows Update]
image: 
  feature: layout-posts.jpg
comments: false
---

The posts discusses a method of addressing Windows Update error 0x80072F8F in the context of SCCM and non-domain joined machines.

<!-- more -->

I recently came across an issue using SCCM to push Windows Updates to our non-domain joined servers residing in the DMZ. The strange part was that this was previously working. When I attempted to run the Windows Update check to our SCCM server the following error was displayed:

![Windows Update Error](/images/posts/fixing-windows-update-error-80072F8F-001.png)

The built-in *Get help with this error* was unsuccessful so a quick search of the internet identified this article at [Technet](http://blogs.technet.com/b/win7/archive/2011/11/08/windows-update-error-80072f8f.aspx). This article stated that the the error code meant **ERROR\_INTERNET\_DECODING\_FAILED**, and indicated a time mismatch between the update server and the target computer. This led to an error verifying the SSL certificate and in turn triggered the error I was seeing. Other posts on the internet seemed to confirm the same theory. The problem was that the target server and the SCCM server both had the correct time zone and time settings.

My next line of thinking was that possibly the internal firewall rules had been changed for the DMZ servers. From the target server I opened a web browser session to the SCCM server (e.g. https://wsus_server:8531). I was greeted by the following page, which identified the problem as an untrusted certifcate.

![Untrusted Certificate Warning](/images/posts/fixing-windows-update-error-80072F8F-002.png)
  
The untrusted certificate identified it as being distributed from the internal AD Certificate Authority. I next compared this certificate information against the same certificate on one of the domain joined servers. This comparison confirmed that the original certificate had expired and a new one had been issued, but it had not been pushed to the non-domain servers.

Using the Certificate Manager MMC plugin (certmgr.msc) I exported the certificate from an domain joined server and copied the certificate file to the DMZ server. Then on the DMZ server I double-clicked it to invoke the Certificate Import Wizard. I selected *Automatically select the certificate store based on the type of certificate* option and successfully imported the certificate.

Now with the newly imported certificate, I re-opened the web browser to the SCCM server, and surprisingly, was once again greeted with the *There is a problem with this website's security certificate* error. I still believed the original issue was related to the SSL certificate so back to the internet I went. This time I came across this [MSDN article](http://blogs.msdn.com/b/saurabh_singh/archive/2007/11/07/you-get-a-security-alert-when-you-try-to-access-an-ssl-enabled-web-site-when-certificate-has-been-issued-by-an-internal-root-ca.aspx). The article seemed to indicate that while the certificate had been exported successfully the certificate chain was broken.

Based on the steps in the article, I opened the Certificate Management snap-in on the **domain joined** server:

1. Start the Microsoft Management Console (i.e. mmc.exe)
2. From the **File** menu select **Add/Remove Snap-In...**
3. Select **Certificates** from the *Available snap-ins* and click **Add**
4. Select **Computer account** from the *Certificates snap-in* dialog and click **Next**
5. Select **Local computer** and click **Finish**
6. Click **OK** on the *Add or Remove Snap-ins* dialog
7. Expand the **Trusted Root Certification Authorities** folder
8. Select the **Certificates** folder
9. Highlight the **\<Domain\> Corporate Root CA1** certificate
10. Right-click this certificate and select **All Tasks** then **Export...**

At this point the **Export Certificate Wizard** will open up.

On the initial wizard page just click the **Next** button.

![Certificate Export Wizard Page 1](/images/posts/fixing-windows-update-error-80072F8F-005.png)

On the *Export File Format* settings page, select the **Cryptographic Message Syntax Standard - PKCS #7 Certificates (.P7B)** option and make sure that the **Include all certificates in the certification path if possible** option is selected as well. 

![Certificate Export Wizard Page 2](/images/posts/fixing-windows-update-error-80072F8F-006.png)

On the *File to Export* settings page, specify a path and file name for the exported certificate.

![Certificate Export Wizard Page 3](/images/posts/fixing-windows-update-error-80072F8F-007.png)

On the the *Completing the Certificate Export Wizard* page, just click the **Finish** button.

![Certificate Export Wizard Page 4](/images/posts/fixing-windows-update-error-80072F8F-008.png)

A window appeared stating *The export was successful*, and I clicked the **OK** button to close the dialog. Next I copied the exported certificate file (i.e *.p7b) file to the DMZ server.

On the DMZ server, I right-clicked the certificate file and selected **Install Certificate**. This started the **Import Certificate Wizard**.

On the initial wizard page, just click the **Next** button.

![Certificate Import Wizard Page 1](/images/posts/fixing-windows-update-error-80072F8F-010.png)

On the *Certificate Store* settings page, select the **Place all certificates in the following store** option and then click the **Browse...** button.

![Certificate Import Wizard Page 2](/images/posts/fixing-windows-update-error-80072F8F-011.png)

When the *Select Certificate Store* page opens, first click the **Show physical stores** option, expand the selection tree under the **Trusted Root Certification Authorities** container, select **Local Computer**, and then click **OK**. 

![Certificate Import Wizard Page 3](/images/posts/fixing-windows-update-error-80072F8F-012.png)

Back on the *Certificate Store* page, *Trusted Root Certification Authorities\\Local Computer* is now filled in as the certificate store. Click **Next** to continue. 

![Certificate Import Wizard Page 4](/images/posts/fixing-windows-update-error-80072F8F-013.png)

On the the *Completing the Certificate Export Wizard* page, just click the **Finish** button.

![Certificate Import Wizard Page 5](/images/posts/fixing-windows-update-error-80072F8F-014.png)

A dialog appeared stating *The import was successful* and I clicked **OK** to close it out. Finally, I opened a web browser to the SCCM server as I had originally done. This time I was not presented with the untrusted certificate warning. Since this looked promising, I went to Windows Update in the Control Panel and told it to check for updates. After a few moments I was presented with the message below which indicated that everything was working again.

![Windows Update Now Working](/images/posts/fixing-windows-update-error-80072F8F-020.png)

So in conclusion, the *0x80072F8F* error is related to an SSL certificate issue due to a time mismatch or a broken certificate chain. This article focused on the latter issue which was resolved by first exporting the certificate, including the certificate chain, from an internal server. Then the certificate was copied to and imported into the DMZ server, specifically the local computer's trusted certificate physical store. Lastly, it was verified that the web browser and Windows Update errors were not occurring anymore.  