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

@implementation EFVUVolumeManager

+ (NSArray*)volumeUUIDs
{
	return [EFVUCoreStorage allLogicalVolume];
}

+ (NSString*)mountPointForVolumeWithUUID:(NSUUID*)uuid
{
	NSString *diskIdentifier = [self deviceIdentifierForVolumeWithUUID:uuid];
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

+ (NSString*)volumeNameForVolumeWithUUID:(NSUUID*)uuid
{
	NSDictionary *volumeInfos = [EFVUCoreStorage informationForVolumeWithIdentfier:uuid];
	return [volumeInfos objectForKey:kEFVUCoreStorageVolumeName];
}

+ (NSString*)deviceIdentifierForVolumeWithUUID:(NSUUID*)uuid
{
	NSDictionary *volumeInfos = [EFVUCoreStorage informationForVolumeWithIdentfier:uuid];
	return [volumeInfos objectForKey:kEFVUCoreStorageDeviceIdentifier];
}

+ (void)registerVolumeWithUUID:(NSUUID*)uuid andPassword:(NSString*)password
{
	
}

@end
