//
//  EFVUVolumeManager.m
//  efvu
//
//  Created by Yoann Gini on 24/04/2014.
//  Copyright (c) 2014 iNig-Services. All rights reserved.
//

#import "EFVUVolumeManager.h"
#import "EFVUCoreStorage.h"
#include <sys/mount.h>
#import "EFVUVolumeDatabase.h"
#import "EFVUKeychain.h"

@implementation EFVUVolumeManager

+ (NSArray*)volumeUUIDs
{
	return [EFVUCoreStorage allLogicalVolume];
}

+ (NSString*)currentMountPointForVolumeWithUUID:(NSUUID*)uuid
{
	NSString *diskIdentifier = [self currentDeviceIdentifierForVolumeWithUUID:uuid];
	if (diskIdentifier) {
		struct statfs *mntbufp;
		int num_of_mnts = 0;
		int i;
		NSString *mountedDevice = nil;
		
		/* get our mount infos */
		num_of_mnts = getmntinfo(&mntbufp, MNT_WAIT);
		/* no mounts returned, something is drastically wrong. */
		if(num_of_mnts == 0) {
			[[NSException exceptionWithName:@"No mounts!" reason:@"The getmntinfo() command returned a empty list of mounts!" userInfo:nil] raise];
		}
		
		/* go though the mounts */
		for(i = 0; i < num_of_mnts; i++) {
			mountedDevice = [NSString stringWithUTF8String:mntbufp[i].f_mntfromname];
			if ([mountedDevice rangeOfString:diskIdentifier].location != NSNotFound) {
				return [NSString stringWithUTF8String:mntbufp[i].f_mntonname];;
			}
		}
	}
	
	return nil;
}

+ (NSString*)currentVolumeNameForVolumeWithUUID:(NSUUID*)uuid
{
	NSDictionary *volumeInfos = [EFVUCoreStorage informationForVolumeWithIdentfier:uuid];
	return [volumeInfos objectForKey:kEFVUCoreStorageVolumeName];
}

+ (NSString*)currentDeviceIdentifierForVolumeWithUUID:(NSUUID*)uuid
{
	NSDictionary *volumeInfos = [EFVUCoreStorage informationForVolumeWithIdentfier:uuid];
	return [volumeInfos objectForKey:kEFVUCoreStorageDeviceIdentifier];
}

+ (BOOL)registerVolumeWithUUID:(NSUUID*)uuid andPassword:(NSString*)password
{
	BOOL success = [[EFVUVolumeDatabase sharedInstance] addVolumeUUID:uuid
														forMountPoint:[self currentMountPointForVolumeWithUUID:uuid]
															  andName:[self currentVolumeNameForVolumeWithUUID:uuid]];

	if (success) {
		success = [EFVUKeychain setPassword:password forVolumeWithUUID:uuid];
	}
	return success;
}

+ (BOOL)forgetVolumeWithUUID:(NSUUID*)uuid
{
	BOOL success = [[EFVUVolumeDatabase sharedInstance] deleteVolumeWithUUID:uuid];
	
	if (success) {
		success = [EFVUKeychain deletePasswordForVolumeWithUUID:uuid];
	}
	return success;
}

+ (BOOL)unlockVolumeWithUUID:(NSUUID*)uuid
{
	NSString *currentMountPoint = [self currentMountPointForVolumeWithUUID:uuid];
	
	if ([currentMountPoint length] > 0) {
		return YES;
	}
	
	else {
		NSString *password = [EFVUKeychain passwordForVolumeWithUUID:uuid];
		
		if ([password length] > 0) {
			[EFVUCoreStorage unlockVolume:uuid withPassword:password];
			return YES;
		}
		else {
			return NO;
		}
	}
}

+ (NSArray*)registeredVolumeUUIDs
{
	return [[EFVUVolumeDatabase sharedInstance] allUUIDs];
}

+ (NSString*)registeredMountPointForVolumeWithUUID:(NSUUID*)uuid
{
	return [[EFVUVolumeDatabase sharedInstance] mountPointForVolumeUUID:uuid];
}

+ (NSString*)registeredVolumeNameForVolumeWithUUID:(NSUUID*)uuid
{
	return [[EFVUVolumeDatabase sharedInstance] volumeNameForVolumeUUID:uuid];
}


+ (NSUUID*)findRegisteredVolumeUUIDProvidingFolderPath:(NSString*)folderPath
{
	NSArray *UUIDs = [self volumeUUIDs];
	NSString *mountPath = nil;
	
	for (NSUUID* uuid in UUIDs) {
		mountPath = [self registeredMountPointForVolumeWithUUID:uuid];
		if ([mountPath length] > 1) {
			if ([folderPath rangeOfString:mountPath].location == 0) {
				return uuid;
			}
		}
	}
	
	return nil;
}

+ (BOOL)hasPasswordForVolumeWithUUID:(NSUUID*)uuid
{
	NSString *password = [EFVUKeychain passwordForVolumeWithUUID:uuid];
	
	if ([password length] > 0) {
		return YES;
	}
	
	return NO;
}

@end
