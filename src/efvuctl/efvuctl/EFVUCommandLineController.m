	//
	//  EFVUCommandLineController.m
	//  efvuctl
	//
	//  Created by Yoann Gini on 26/04/2014.
	//  Copyright (c) 2014 iNig-Services. All rights reserved.
	//

#import "EFVUCommandLineController.h"
#import <efvu/EFVUVolumeManager.h>
#include <unistd.h>
#import <pwd.h>
#import <membership.h>
#import <uuid/uuid.h>

#define CURRENT_MARKETING_VERSION		"0.1"

@interface EFVUCommandLineController ()

@property BOOL enumerateVolumes;
@property NSString *mountPoint;
@property NSString *addVolume;
@property NSString *forgetVolume;
@property NSString *password;
@property NSString *unlockEfvuVolume;
@property BOOL listEfvuVolumes;
@property NSString *showEfvu;
@property NSString *try;
@property BOOL version;
@property BOOL help;

@end

@implementation EFVUCommandLineController

#pragma mark - Help, version and arguments management
- (void)printUsage:(FILE *)stream;
{
    ddfprintf(stream, @"Usage: %@ [OPTIONS]\n", DDCliApp);
}

- (void)printVersion;
{
    ddprintf(@"%@ version %s\n", DDCliApp, CURRENT_MARKETING_VERSION);
}

- (void)printHelp;
{
    [self printUsage: stdout];
	[self printVersion];
    printf("\n"
           "  -e, --enumerate-volumes       List all FileVault 2 available volume (must be mounted)\n"
           "  -m, --mount-point <UUID>      Display the current mount point for volume with specific UUID\n"
           "  -a, --add-volume <UUID>       Add the specified volume with current mount point to the EFVU database\n"
		   "  -f, --forget-volume <UUID>    Remove the specified volume from the EFVU database\n"
           "  -p, --password <password>     The volume password (will be asked by a secure input if not provided by command line option)\n"
		   "  -u, --unlock-volume <UUID>    Try to unlock and mount volume with informations available in the EFVU database\n"
  		   "  -l, --list-volumes            Show all volumes available in the EFVU database\n"
   		   "  -s, --show <UUID>             Show all informations available in the EFVU database for the specified volume\n"
   		   "  -t, --try <shortname>         Check if the specified user depend on a EFVU volume and display related informations\n"
           "  -v, --version                 Display version and exit\n"
           "  -h, --help                    Display this help and exit\n"
           "\n");
}


- (void)application:(DDCliApplication *)app willParseOptions:(DDGetoptLongParser *)optionsParser;
{
    [optionsParser addOptionsFromArray:@[
										 [DDGetOptOption optionType:DDGetoptNoArgument withLongName:@"enumerate-volumes" andShortCommand:'e'],
										 [DDGetOptOption optionType:DDGetoptRequiredArgument withLongName:@"mount-point" andShortCommand:'m'],
										 [DDGetOptOption optionType:DDGetoptRequiredArgument withLongName:@"add-volume" andShortCommand:'a'],
										 [DDGetOptOption optionType:DDGetoptRequiredArgument withLongName:@"forget-volume" andShortCommand:'f'],
										 [DDGetOptOption optionType:DDGetoptRequiredArgument withLongName:@"password" andShortCommand:'p'],
										 [DDGetOptOption optionType:DDGetoptRequiredArgument withLongName:@"unlock-efvu-volume" andShortCommand:'u'],
										 [DDGetOptOption optionType:DDGetoptNoArgument withLongName:@"list-efvu-volumes" andShortCommand:'l'],
										 [DDGetOptOption optionType:DDGetoptRequiredArgument withLongName:@"show-efvu" andShortCommand:'s'],
										 [DDGetOptOption optionType:DDGetoptRequiredArgument withLongName:@"try" andShortCommand:'t'],
										 [DDGetOptOption optionType:DDGetoptNoArgument withLongName:@"version" andShortCommand:'v'],
										 [DDGetOptOption optionType:DDGetoptNoArgument withLongName:@"help" andShortCommand:'h'],
										 ]];
}

#pragma mark - Main process

- (int)application:(DDCliApplication *)app runWithArguments:(NSArray *)arguments;
{
	int returnValue = EXIT_FAILURE;
    
	if (self.enumerateVolumes == NO
		&& self.mountPoint == nil
		&& self.addVolume == nil
		&& self.forgetVolume == nil
		&& self.password == nil
		&& self.unlockEfvuVolume == nil
		&& self.listEfvuVolumes == NO
		&& self.showEfvu == nil
		&& self.try == nil
		&& self.version == NO
		&& self.help == NO) { // No options
		[self printHelp];
        returnValue = EX_USAGE;
	}
	
	else if (self.enumerateVolumes == NO
			 && self.mountPoint == nil
			 && self.addVolume == nil
			 && self.forgetVolume == nil
			 && self.password == nil
			 && self.unlockEfvuVolume == nil
			 && self.listEfvuVolumes == NO
			 && self.showEfvu == nil
		&& self.try == nil
			 && self.version == NO
			 && self.help == YES) { // Help requested
		[self printHelp];
        returnValue = EXIT_SUCCESS;
	}
	
	else if (self.enumerateVolumes == NO
			 && self.mountPoint == nil
			 && self.addVolume == nil
			 && self.forgetVolume == nil
			 && self.password == nil
			 && self.unlockEfvuVolume == nil
			 && self.listEfvuVolumes == NO
			 && self.showEfvu == nil
		&& self.try == nil
			 && self.version == YES
			 && self.help == NO) { // Version requested
		[self printVersion];
        returnValue = EXIT_SUCCESS;
	}
	
	else if (self.enumerateVolumes == YES
			 && self.mountPoint == nil
			 && self.addVolume == nil
			 && self.forgetVolume == nil
			 && self.password == nil
			 && self.unlockEfvuVolume == nil
			 && self.listEfvuVolumes == NO
			 && self.showEfvu == nil
		&& self.try == nil
			 && self.version == NO
			 && self.help == NO) { // List all FileVault 2 mounted volumes
		returnValue = [self discoverFileVault2Volumes];
	}
	
	else if (self.enumerateVolumes == NO
			 && self.mountPoint != nil
			 && self.addVolume == nil
			 && self.forgetVolume == nil
			 && self.password == nil
			 && self.unlockEfvuVolume == nil
			 && self.listEfvuVolumes == NO
			 && self.showEfvu == nil
		&& self.try == nil
			 && self.version == NO
			 && self.help == NO) { // Show actual mount point for volume with specified UUID.
		returnValue = [self displayMountPointForVolumeWithUUIDString:self.mountPoint];
	}
	
	else if (self.enumerateVolumes == NO
			 && self.mountPoint == nil
			 && self.addVolume != nil
			 && self.forgetVolume == nil
			 && self.unlockEfvuVolume == nil
			 && self.listEfvuVolumes == NO
			 && self.showEfvu == nil
		&& self.try == nil
			 && self.version == NO
			 && self.help == NO) { // Add specified volume to EFVU database
		returnValue = [self addEFVURecordForVolumeWithUUIDString:self.addVolume];
	}
	
	else if (self.enumerateVolumes == NO
			 && self.mountPoint == nil
			 && self.addVolume == nil
			 && self.forgetVolume != nil
			 && self.password == nil
			 && self.unlockEfvuVolume == nil
			 && self.listEfvuVolumes == NO
			 && self.showEfvu == nil
		&& self.try == nil
			 && self.version == NO
			 && self.help == NO) { // Remove specified volume from EFVU database
		returnValue = [self removeEFVURecordForVolumeWithUUIDString:self.forgetVolume];
	}
	
	else if (self.enumerateVolumes == NO
			 && self.mountPoint == nil
			 && self.addVolume == nil
			 && self.forgetVolume == nil
			 && self.password == nil
			 && self.unlockEfvuVolume != nil
			 && self.listEfvuVolumes == NO
			 && self.showEfvu == nil
		&& self.try == nil
			 && self.version == NO
			 && self.help == NO) { // Try to unlock and mount volume specified via UUID from EFVU database
		returnValue = [self tryUnlockVolumeWithUUIDString:self.unlockEfvuVolume];
	}
	
	else if (self.enumerateVolumes == NO
			 && self.mountPoint == nil
			 && self.addVolume == nil
			 && self.forgetVolume == nil
			 && self.password == nil
			 && self.unlockEfvuVolume == nil
			 && self.listEfvuVolumes == YES
			 && self.showEfvu == nil
		&& self.try == nil
			 && self.version == NO
			 && self.help == NO) { // List volume in EFVU database
		returnValue = [self listAllEFVUEntries];
	}
	
	else if (self.enumerateVolumes == NO
			 && self.mountPoint == nil
			 && self.addVolume == nil
			 && self.forgetVolume == nil
			 && self.password == nil
			 && self.unlockEfvuVolume == nil
			 && self.listEfvuVolumes == NO
			 && self.showEfvu != nil
			 && self.try == nil
			 && self.version == NO
			 && self.help == NO) { // Show EFVU informations for a specific volume
		returnValue = [self showInformationsForVolumeWithUUIDString:self.showEfvu];
	}
	
	else if (self.enumerateVolumes == NO
			 && self.mountPoint == nil
			 && self.addVolume == nil
			 && self.forgetVolume == nil
			 && self.password == nil
			 && self.unlockEfvuVolume == nil
			 && self.listEfvuVolumes == NO
			 && self.showEfvu == nil
			 && self.try != nil
			 && self.version == NO
			 && self.help == NO) { // Try the system with specified username but don't mount anything
		returnValue = [self checkEFVUDatabaseAgainstUser:self.try];
	}
	
	else {
		[self printHelp];
        returnValue = EXIT_FAILURE;
	}
	
    return returnValue;
}

#pragma mark - Internal methods

- (void)requestVolumePasswordIfNeeded
{
	if (self.password == nil) {
		char *password = getpass("Volume Password: ");
		self.password = [NSString stringWithUTF8String:password];
	}
}

#pragma mark - Routing methods

- (int)discoverFileVault2Volumes
{
	NSArray *volumeUUIDs = [EFVUVolumeManager volumeUUIDs];
	
	NSString *volumeName = nil;
	NSString *mountPath = nil;
	NSString *deviceIdentifier = nil;
	ddprintf(@"List of volume founded (Volume UUID, Disk Identifier, Volume Name, Current Mount Point):\n");
	for (NSUUID *uuid in volumeUUIDs) {
		volumeName = [EFVUVolumeManager currentVolumeNameForVolumeWithUUID:uuid];
		if (!volumeName) {
			volumeName = @"Unavailable";
		}
		
		mountPath = [EFVUVolumeManager currentMountPointForVolumeWithUUID:uuid];
		if (!mountPath) {
			mountPath = @"Not mounted";
		}
		
		deviceIdentifier = [EFVUVolumeManager currentDeviceIdentifierForVolumeWithUUID:uuid];
		if (!deviceIdentifier) {
			deviceIdentifier = @"Unavailable";
		}
		
		ddprintf(@"\t%@, %@, %@, %@\n", [uuid UUIDString], deviceIdentifier, volumeName, mountPath);
	}
	
	return EXIT_SUCCESS;
}

- (int)displayMountPointForVolumeWithUUIDString:(NSString*)uuidString
{
	NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
	
	if (uuid) {
		NSString *mountPath = [EFVUVolumeManager currentMountPointForVolumeWithUUID:uuid];
		if (mountPath) {
			ddprintf(@"%@\n", mountPath);
			return EXIT_SUCCESS;
		}
		else {
			ddfprintf(stderr, @"UUID not recognized!\n");
			return EXIT_FAILURE;
		}
	}
	else {
		ddfprintf(stderr, @"Invalid UUID format!\n");
		return EXIT_FAILURE;
	}
}

- (int)addEFVURecordForVolumeWithUUIDString:(NSString*)uuidString
{
	NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
	
	if (uuid) {
		NSString *mountPath = [EFVUVolumeManager currentMountPointForVolumeWithUUID:uuid];
		if (mountPath) {
			[self requestVolumePasswordIfNeeded];
			if ([self.password length] > 0) {
				BOOL success = [EFVUVolumeManager registerVolumeWithUUID:uuid andPassword:self.password];
				if (success) {
					ddprintf(@"Password saved but not tested. Reboot and try to unlock it with %@ -u %@\n", DDCliApp, [uuid UUIDString]);
					ddprintf(@"(Long story short, there is no CoreStorage command allowing you to lock an unlocked volume)\n");
					return EXIT_SUCCESS;
				}
				else {
					ddprintf(@"Error when adding entry. Please, check that the mount path %@ isn't already used\n", mountPath);
					return EXIT_FAILURE;
				}
			}
			else {
				ddfprintf(stderr, @"No password provided!\n");
				return EXIT_FAILURE;
			}
		}
		else {
			ddfprintf(stderr, @"The requested volume isn't mounted!\n");
			return EXIT_FAILURE;
		}
	}
	else {
		ddfprintf(stderr, @"Invalid UUID format!\n");
		return EXIT_FAILURE;
	}
}

- (int)removeEFVURecordForVolumeWithUUIDString:(NSString*)uuidString
{
	NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
	
	if (uuid) {
		NSString *mountPath = [EFVUVolumeManager registeredMountPointForVolumeWithUUID:uuid];
		if (mountPath) {
			BOOL success = [EFVUVolumeManager forgetVolumeWithUUID:uuid];
			if (success) {
				return EXIT_SUCCESS;
			}
			else {
				ddprintf(@"Error when removing entry.\n", mountPath);
				return EXIT_FAILURE;
			}
		}
		else {
			ddfprintf(stderr, @"The requested volume isn't in EFVU database!\n");
			return EXIT_FAILURE;
		}
	}
	else {
		ddfprintf(stderr, @"Invalid UUID format!\n");
		return EXIT_FAILURE;
	}
}

- (int)tryUnlockVolumeWithUUIDString:(NSString*)uuidString
{
	NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
	
	if (uuid) {
		NSString *mountPath = [EFVUVolumeManager registeredMountPointForVolumeWithUUID:uuid];
		if (mountPath) {
			BOOL success = [EFVUVolumeManager unlockVolumeWithUUID:uuid];
			if (success) {
				return EXIT_SUCCESS;
			}
			else {
				ddprintf(@"Error when unlocking volume.\n", mountPath);
				return EXIT_FAILURE;
			}
		}
		else {
			ddfprintf(stderr, @"The requested volume isn't in EFVU database!\n");
			return EXIT_FAILURE;
		}
	}
	else {
		ddfprintf(stderr, @"Invalid UUID format!\n");
		return EXIT_FAILURE;
	}
}

- (int)listAllEFVUEntries
{
	NSArray *UUIDs = [EFVUVolumeManager registeredVolumeUUIDs];
	
	ddprintf(@"EFVU entries\n");
	
	NSString *mountPoint = nil;
	NSString *volumeName = nil;
	for (NSUUID *uuid in UUIDs) {
		volumeName = [EFVUVolumeManager registeredVolumeNameForVolumeWithUUID:uuid];
		mountPoint = [EFVUVolumeManager registeredMountPointForVolumeWithUUID:uuid];
		ddprintf(@"\t%@, %@, %@\n", [uuid UUIDString], volumeName, mountPoint);
	}
	
	return EXIT_SUCCESS;
}


- (int)showInformationsForVolumeWithUUIDString:(NSString*)uuidString
{
	NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
	
	if (uuid) {
		NSString *mountPath = [EFVUVolumeManager registeredMountPointForVolumeWithUUID:uuid];
		if (mountPath) {
			NSString *mountPoint = [EFVUVolumeManager registeredMountPointForVolumeWithUUID:uuid];
			NSString *volumeName = [EFVUVolumeManager registeredVolumeNameForVolumeWithUUID:uuid];
			
			ddprintf(@"%@, %@, %@\n", [uuid UUIDString], volumeName, mountPoint);
			if ([EFVUVolumeManager hasPasswordForVolumeWithUUID:uuid]) {
				ddprintf(@"Password found for volume %@\n", [uuid UUIDString]);
				return EXIT_SUCCESS;
			}
			
			else {
				ddprintf(@"No password found for volume %@!\n", [uuid UUIDString]);
				return EXIT_FAILURE;
			}
		}
		else {
			ddfprintf(stderr, @"The requested volume isn't in EFVU database!\n");
			return EXIT_FAILURE;
		}
	}
	else {
		ddfprintf(stderr, @"Invalid UUID format!\n");
		return EXIT_FAILURE;
	}
}


- (int)checkEFVUDatabaseAgainstUser:(NSString*)shortname
{
	struct passwd* info = getpwnam([shortname UTF8String]);
	if (info) {
		const char *homedir = info->pw_dir;
		NSString *homeFolder = [NSString stringWithUTF8String:homedir];
		
		if ([homeFolder length] > 0) {
			NSUUID *volumeUUID = [EFVUVolumeManager findRegisteredVolumeUUIDProvidingFolderPath:homeFolder];
			if (volumeUUID) {
				ddprintf(@"Volume found for %@ (%@)\n", shortname, homeFolder);
				
				NSString *mountPoint = [EFVUVolumeManager registeredMountPointForVolumeWithUUID:volumeUUID];
				NSString *volumeName = [EFVUVolumeManager registeredVolumeNameForVolumeWithUUID:volumeUUID];
				
				ddprintf(@"%@, %@, %@\n", [volumeUUID UUIDString], volumeName, mountPoint);
				
				if ([EFVUVolumeManager hasPasswordForVolumeWithUUID:volumeUUID]) {
					ddprintf(@"Password found for volume %@\n", [volumeUUID UUIDString]);
					return EXIT_SUCCESS;
				}
				
				else {
					ddprintf(@"No password found for volume %@!\n", [volumeUUID UUIDString]);
					return EXIT_FAILURE;
				}
				
			}
			
			else {
				ddprintf(@"%@ home folder (%@) isn't on a EFVU volume.\n", shortname, homeFolder);
				return EXIT_SUCCESS;
			}
		}
		
		else {
			ddfprintf(stderr, @"No home folder specified for %@!\n", shortname);
			return EXIT_FAILURE;
		}
	}
	
	else {
		ddfprintf(stderr, @"Invalid username!\n");
		return EXIT_FAILURE;
	}
}

@end
