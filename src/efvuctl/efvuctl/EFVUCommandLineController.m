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
@property BOOL verbose;
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
           "  -V, --verbose                 Increase verbosity\n"
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
										 [DDGetOptOption optionType:DDGetoptNoArgument withLongName:@"verbose" andShortCommand:'V'],
										 [DDGetOptOption optionType:DDGetoptNoArgument withLongName:@"version" andShortCommand:'v'],
										 [DDGetOptOption optionType:DDGetoptNoArgument withLongName:@"help" andShortCommand:'h'],
										 ]];
}

#pragma mark - Main process

- (int)application:(DDCliApplication *)app runWithArguments:(NSArray *)arguments;
{
	int returnValue = EXIT_SUCCESS;
	
	NSLog(@"Reaming arguments %ld", [arguments count]);
    
	if (self.enumerateVolumes == NO
		&& self.mountPoint == nil
		&& self.addVolume == nil
		&& self.forgetVolume == nil
		&& self.password == nil
		&& self.unlockEfvuVolume == nil
		&& self.listEfvuVolumes == NO
		&& self.showEfvu == nil
		&& self.verbose == NO
		&& self.version == NO
		&& self.help == NO) { // No options
		
		ddfprintf(stderr, @"At least one argument is required!\n");
        [self printUsage: stderr];
        ddfprintf(stderr, @"Try `%@ --help' for more information.\n",
                  DDCliApp);
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
			 && self.version == NO
			 && self.help == NO) { // Add specified volume to EFVU database
		returnValue = [self addEFVURecordForVolumeWithUUID:self.addVolume];
	}
	
	else if (self.enumerateVolumes == NO
			 && self.mountPoint == nil
			 && self.addVolume == nil
			 && self.forgetVolume != nil
			 && self.password == nil
			 && self.unlockEfvuVolume == nil
			 && self.listEfvuVolumes == NO
			 && self.showEfvu == nil
			 && self.version == NO
			 && self.help == NO) { // Remove specified volume from EFVU database
		
	}
	
	else if (self.enumerateVolumes == NO
			 && self.mountPoint == nil
			 && self.addVolume == nil
			 && self.forgetVolume == nil
			 && self.password == nil
			 && self.unlockEfvuVolume != nil
			 && self.listEfvuVolumes == NO
			 && self.showEfvu == nil
			 && self.version == NO
			 && self.help == NO) { // Try to unlock and mount volume specified via UUID from EFVU database
		
	}
	
	else if (self.enumerateVolumes == NO
			 && self.mountPoint == nil
			 && self.addVolume == nil
			 && self.forgetVolume == nil
			 && self.password == nil
			 && self.unlockEfvuVolume == nil
			 && self.listEfvuVolumes == YES
			 && self.showEfvu == nil
			 && self.verbose == NO
			 && self.version == NO
			 && self.help == NO) { // List volume in EFVU database
		
	}
	
	else if (self.enumerateVolumes == NO
			 && self.mountPoint == nil
			 && self.addVolume == nil
			 && self.forgetVolume == nil
			 && self.password == nil
			 && self.unlockEfvuVolume == nil
			 && self.listEfvuVolumes == NO
			 && self.showEfvu != nil
			 && self.verbose == NO
			 && self.version == NO
			 && self.help == NO) { // Show EFVU informations for a specific volume
		
	}
	
	else {
		
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
		volumeName = [EFVUVolumeManager volumeNameForVolumeWithUUID:uuid];
		mountPath = [EFVUVolumeManager mountPointForVolumeWithUUID:uuid];
		deviceIdentifier = [EFVUVolumeManager deviceIdentifierForVolumeWithUUID:uuid];
		if (!mountPath) {
			mountPath = @"Not mounted";
		}
		ddprintf(@"\t%@, %@, %@, %@\n", [uuid UUIDString], deviceIdentifier, volumeName, mountPath);
	}
	
	return EXIT_SUCCESS;
}

- (int)displayMountPointForVolumeWithUUIDString:(NSString*)uuidString
{
	NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
	
	if (uuid) {
		NSString *mountPath = [EFVUVolumeManager mountPointForVolumeWithUUID:uuid];
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

- (int)addEFVURecordForVolumeWithUUID:(NSUUID*)uuid
{
	NSString *mountPath = [EFVUVolumeManager mountPointForVolumeWithUUID:uuid];
	
	if (mountPath) {
		[self requestVolumePasswordIfNeeded];
		if ([self.password length] > 0) {
			[EFVUVolumeManager registerVolumeWithUUID:uuid andPassword:self.password];
			return EXIT_SUCCESS;
		}
		ddfprintf(stderr, @"No password provided!\n");
		return EXIT_FAILURE;
	}
	
	else {
		ddfprintf(stderr, @"The requested volume isn't mounted!\n");
		return EXIT_FAILURE;
	}
}

@end
