---
layout: post
title: "How To Add Drivers to a Windows Deployment Image"
description: "Describes how to add system specific drivers to a deployment image on a Windows Deployment Server."
category: HowTo
tags: [Windows Server, DISM]
image: 
  feature: layout-posts.jpg
comments: false
---

This post describes the procedure for opening a Windows image and incorporating vendor specific drivers in it for the purposes of deploying that image on new equipment.

<!-- more -->

The list below identifies some abbreviations that will be used in this document:

- DISM – Deployment Image Servicing and Management Tool
- WDS – Windows Deployment Services
- WIM – Windows Image File

The procedure for adding drivers to an existing image will be done within the context of an example. In this example we will modify the Windows 2008 Server R2 Standard Edition image to contain the network drivers for a Dell PowerEdge R720 server. Let us assume that the network drivers have already been downloaded and unpack from Dell’s website and are located in the D:\DellR720_Drivers\network folder on the Windows Deployment Services server.

NOTE: The Deployment Imaging Servicing and Management Tool (DISM) is located in the C:\Program Files\Windows AIK\Tools\Servicing folder. Generally you can launch the “Deployment Tools Command Prompt” from the “Microsoft Windows AIK” folder on the Start menu so that the necessary tools are properly added your environment Path.

> IMPORTANT: The example procedure walks you through modifying the Boot image which contains the Windows Setup program. Once you have completed modifying the Boot image you must modify the Install image in order for the server to have network connectivity after the installation. The reason is that the PXE boot code will load the boot.wim from the WDS server to recognize the hardware for the setup program. The Setup program will then download the install.wim file from the WDS server and write it to the target server. If you only modify the boot.wim then the OS will install but it will fail to recognize the hardware on first boot if you forget to modify the install.wim file as well.
 
#### Step 1 – Use WDS Console to Export Windows Boot Image ####

This step exports the Windows Image out of the Windows Deployment server so that it can be modified.

1.	Open the **Windows Deployment Services** management console from the Start menu
2.	Select the **Boot Images** container
3.	In the right-hand window, select the **Windows Server 2008 R2 Setup (x64)** image
4.	From the **Action** menu select **Export Image**
5.	Select a folder to export the boot.wim file *(For this example we will select D:\)*

#### Step 2 – Create Mount Point for Exported Windows Image ####

This step creates a folder where the previously exported Windows Image (WIM) file can be mounted.

1.	Create a Windows Explorer folder (For this example we will create D:\MountPoint)

#### Step 3 – Use DISM Tool to Mount Exported Image ####

This step mounts the exported WIM file so that it appears as a regular directory hierarchy.

    dism /Mount-Wim /WimFile:d:\boot.wim /MountDir:d:\MountPoint /name:"Microsoft Windows 2008 R2 Setup (x64)"
    
#### Step 4 – Use DISM Tool to Import Drivers ####
This step adds the downloaded network drivers into the image file. This step can be repeated any number of times with different driver directories such as for RAID controllers, display drivers, etc.

    dism /image:D:\MountPoint /Add-Driver /driver:D:\DellR720_Drivers\network\production\W2K8-x64

#### Step 5 – Use DISM Tool to Commit Changes and Unmount Image ####

This step unmounts the modified image and commits our changes to it.

    dism /Unmount-Wim /MountDir:D:\MountPoint /Commit

#### Step 6 – Use WDS Console to Import Modified Windows Image #### 

This step imports the modified Windows Image back into the Windows Deployment server replacing the one that was already there.

1.	Open the **Windows Deployment Services** management console from the Start menu
2.	Select the **Boot Images** container
3.	In the right-hand window, select the **Windows Server 2008 R2 Setup (x64)** image
4.	From the **Action** menu select **Replace Image**
5.	Select a folder to import the boot.wim file *(For this example we will select D:\)*

> NOTE: Repeat procedure to modify the **Installation Image** (install.wim)

 
## DISM Tool Command Reference ##

    Deployment Image Servicing and Management tool
    Version: 6.1.7600.16385
    
    
    DISM.exe [dism_options] {WIM_command} [<WIM_arguments>]
    DISM.exe {/Image:<path_to_offline_image> | /Online} [dism_options]
     {servicing_command} [<servicing_arguments>]
    
    DESCRIPTION:
    
      DISM enumerates, installs, uninstalls, configures, and updates features
      and packages in Windows images. The commands that are available depend
      on the image being serviced and whether the image is offline or running.
    
    WIM COMMANDS:
    
      /Get-MountedWimInfo - Displays information about mounted WIM images.
      /Get-WimInfo- Displays information about images in a WIM file.
      /Commit-Wim - Saves changes to a mounted WIM image.
      /Unmount-Wim- Unmounts a mounted WIM image.
      /Mount-Wim  - Mounts an image from a WIM file.
      /Remount-Wim- Recovers an orphaned WIM mount directory.
      /Cleanup-Wim- Deletes resources associated with mounted WIM
    images that are corrupt.
    
    IMAGE SPECIFICATIONS:
    
      /Online - Targets the running operating system.
      /Image  - Specifies the path to the root directory of an
    offline Windows image.
    
    DISM OPTIONS:
    
      /English- Displays command line output in English.
      /Format - Specifies the report output format.
      /WinDir - Specifies the path to the Windows directory.
      /SysDriveDir- Specifies the path to the system-loader file named
    BootMgr.
      /LogPath- Specifies the logfile path.
      /LogLevel   - Specifies the output level shown in the log (1-4).
      /NoRestart  - Suppresses automatic reboots and reboot prompts.
      /Quiet  - Suppresses all output except for error messages.
      /ScratchDir - Specifies the path to a scratch directory.
    
    For more information about these DISM options and their arguments, specify an
    option immediately before /?.
    
      Examples:
    DISM.exe /Mount-Wim /?
    DISM.exe /ScratchDir /?
    DISM.exe /Image:C:\test\offline /?
    DISM.exe /Online /?

## Troubleshooting ##

### Error – PXE-E53 No boot filename received ###

When attempting to boot the target server using PXE boot you receive a no boot filename received error. This usually indicates that the Windows Deployment Services service on the PXE server is not started or needs to be restarted. After confirming the service is running, try to PXE boot the target server again.

![Image of No Boot Filename Error](/images/posts/how-to-add-drivers-to-a-windows-deployment-image-troubleshooting-01.png)
 
### Error – WdsClient A matching Network Card Driver Found ###

After the PXE boot image has been downloaded to the target server and the Windows Deployment Service client program starts you receive a no matching network card drive found error. This indicates that the selected Windows image does not have the proper network card drivers for the target server. First download the proper network drivers from the vendor’s website and then follow the instructions in this document to include them in the target Windows image.

![Image of Network Card Driver Not Found Error](/images/posts/how-to-add-drivers-to-a-windows-deployment-image-troubleshooting-02.png)
