---
layout: post
title: "Using the bpod Gem"
description: "Describes how to install the bpod gem and have it change your wallaper each day."
category: HowTo
tags: [Ruby, macOS]
image:
  feature: layout-posts.jpg
comments: false
---

This post will discuss installing the **bpod** gem on a macOS desktop and then scheduling it to change your desktop picture each day to the [Bing](http://www.bing.com) home page image.

<!-- more -->

## Installing the Gem

First we need to install the [bpod](https://rubygems.org/gems/bpod) gem. Normally you would just execute the command below.

```
$ gem install bpod
```

### RVM / rbenv Instructions

If you are using either the [*Ruby Version Manager*](https://rvm.io) (i.e. rvm) or [*rbenv*](https://github.com/rbenv/rbenv) to manage your Ruby installation then there are some additional steps that must be completed first. Later in this article we will be using *launchd* to schedule the daily execution of the gem's functionality. In order for all of the components to be available to launchd, there are some additional steps that must be completed.

#### RVM

If you are using RVM then you will need to setup an RVM [*Named Gemset*](https://rvm.io/gemsets/basics) first. This is easy to do and the steps below demonstrate creating a gemset named *bpod*.

```
$ rvm gemset create bpod
$ rvm gemset use bpod
$ gem install bpod
$ gem install os
```
The commands listed above, first create a new gemset named *bpod*. Then we use the second command to make the bpod gemset the active one. Once the gemset has been activated then we can install the *bpod* and *os* gems into it.

#### rbenv

If on the other hand you are using rbenv, then you will need to install the *bpod* gem into your global gemset. For the purposes of this example, I am assuming that you are using ruby 2.3.3.

```
$ rbenv install 2.3.3
$ rbenv global 2.3.3
$ gem install bpod
$ gem install os
$ rbenv which bpod
/Users/USERNAME/Developer/homebrew/var/rbenv/versions/2.3.3/bin/bpod
```

> Note the output from the last command. The location of the *bpod* command tool will depend on where your rbenv installation is stored. The default install would place it in your *~/.rbenv* folder. In my case, I have set the  *RBENV_ROOT* environment variable to */Users/USERNAME/Developer/homebrew/var/rbenv* to relocate it under my, *also relocated*, [homebrew](http://brew.sh) folder. Make note of whatever is returned here as you will need it later when creating the property list file needed for launchd.

## Running the Gem Manually

Regardless of which method you use to install the gem, it will add a *bpod* command line program into your path. The command below is used to display the available options.

```
$ bpod --help
Usage: bpod [options]
    -i, --image-folder FOLDER     Full file path where images will be stored.
    -r, --region-code REGION      Region code for Bing market area, for example en-US.
    -d, --download-image          Download the image of the day.
    -f, --force-download          Download image even if not within download window.
    -s, --set-wallpaper           Set desktop wallpaper using latest downloaded image
    -v, --verbose                 Display messages about which actions are occurring.
    -h, -?, --help                Display usage information
```

> If you used the RVM installation method, you will need to activate the gemset that contains the *bpod* gem first.

The command has sensible defaults, so you can simply just execute **bpod**. It will download the latest picture of the day from Bing and store it in a *bpod* folder in your *Pictures* folder. It will then automatically set your desktop wallpaper to the downloaded picture.

## Scheduling the Gem

On macOS, you can use the *launchd* daemon to automatically execute the gem once a day to download and change the wallpaper.

> The homepage image on Bing does not change automatically at midnight so the launchd script should actually use a local time after 4:00 AM.

The basic way to interact with *launchd* is via a property list (i.e. .plist file) and the **launchctl** command line utility.

You can create a property list using just a basic text editor. You should use a string that is unique for your service name denoted by the *Label* property. Also under the *ProgramArguments* array you will need to replace *USERNAME* with your macOS login name. The *StartCalendarInterval* is currently set to 4:00 AM in the example below.

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>com.example.bpod</string>
        <key>ProgramArguments</key>
        <array>
            <string>/Users/USERNAME/.rvm/wrappers/ruby-2.2.3@bpod/ruby</string>
            <string>/Users/USERNAME/.rvm/gems/ruby-2.2.3@bpod/bin/bpod</string>
            <string>--verbose</string>
            <string>--set-wallpaper</string>
            <string>--download-image</string>
        </array>
        <key>StandardOutPath</key>
        <string>/dev/null</string>
        <key>StandardErrorPath</key>
        <string>/dev/null</string>
        <key>RunAtLoad</key>
        <true/>
        <key>StartCalendarInterval</key>
        <dict>
            <key>Hour</key>
            <integer>4</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
    </dict>
</plist>
```

> The wrapper name may need to be updated as well. If you have been following along with the example you should have an existing wrapper that references the *bpod* gemset you created earlier. If you execute "ls $rvm_path/wrappers" you can then look for the name of the wrapper that ends in '@bpod'. You want to make sure that the *ruby-2.2.3@bpod* text in the example below is changed to the version that exists on your system.

Open a command prompt, change to your personal *Launch Agent* folder, copy the plist file from your Desktop, and then install it via *launchctl*.

```
$ cd ~/Library/LaunchAgents
$ cp ~/Desktop/com.example.bpod.plist
$ launchctl load com.example.bpod.plit
```

### Alterations when using rbenv

The launchctl plist file is basically the same, the only section that needs to updated is the part that loads the *bpod* command line program.

Replace the following two lines used for the *rvm* version:

```
<array>
<string>/Users/USERNAME/.rvm/wrappers/ruby-2.2.3@bpod/ruby</string>
<string>/Users/USERNAME/.rvm/gems/ruby-2.2.3@bpod/bin/bpod</string>
...no changes here...
<array>
```
with the following single line for *rbenv*:

```
<array>
<string>/Users/USERNAME/Developer/homebrew/var/rbenv/versions/2.3.3/bin/bpod</string>
...no changes here...
</array>
```

### Making Changes

If you want to change the functioning of the service, you first modify the plist. Then you need to unload and reload the service using *launchctl*.

```
$ cd ~/Library/LaunchAgents
$ vi com.example.bpod.plist
$ launchctl unload com.example.bpod.plist
$ launchctl load com.example.bpod.plist
```

> If you decide to stop running the gem as a scheduled task, you can just execute the *launchctl unload* command.

## Overview

In this post, you learned how to install the *bpod* gem, including special instructions to follow if you were using RVM or rbenv to manage your ruby installations. You then learned about simple command line usage of the gem's command line interface (CLI). Finally, you learned how you could schedule the gem to run each day under *launchd* to automatically change your desktop once a day.
