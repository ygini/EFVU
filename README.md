Extended FileVault Unlocker
=========

https://github.com/ygini/Unlock


## Description

EFVU is a fork of the original Unlock project by Justin Ridgewell.
The two projects allows the system to unlock and mount Core Storage encrypted volumes to make them available during the login process. 

The difference between EFVU and Unlock is in the way to do it.

Unlock is a simple launch deamon made to unlock all available volumes at the boot time.

EFVU is a more complexe system who act as a SecurityAgentPlugins. It need to be registered as a mechanism for the authorisation right system.login.console. When a user log in, the plugin check if the home folder is located on a mount point registered in the EFVU database. If it's the case, EFVU retreive the volume password in the system keychain and unlock the volume. If the user isn't on a EFVU volume, nothing is done.

## Why?

As a system administrator, I need to keep my network simple to manage and secure.

One of this option to keep it simple to manage is to install the system on a volume and keep users home folder on a other. This allow me to deploy a new image on the system volume without any change on the user home folder.

For the secure part, FileVault 2 is a really good move. But when used for full disk encryption, OS X can only decrypt the boot volume. It can't handle secondary volume.

If a user home folder is located on a secondary encrypted volume, you need a way to unlock the volume before the login. By login on a local session, using Unlock or EFVU.

## Actual state

EFVU is still in development at this time. The project is publicly available for contribution and debug purpose but must not be used in prodcution or on system with real data.

### What's work
* efvuctl command line tool to interact with the EFVU database
* ExtendedFileVaultUnlocker plugin to unlock the home folder volume if needed at the login time.

### Referenced problems
* impossible to relock a unlocked volume due to a bug on diskutil
* when a volume is locked and a user login on a other volume, he see the CSUserAgent message asking for the volume password, he can dissmiss it, but he can't dissmiss it for ever. The message come back at each login time.