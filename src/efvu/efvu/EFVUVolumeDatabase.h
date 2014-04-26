//
//  EFVUVolumeDatabase.h
//  efvu
//
//  Created by Yoann Gini on 26/04/2014.
//  Copyright (c) 2014 iNig-Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EFVUVolumeDatabase : NSObject

/**
 *  For performance management on the EFVU SQLite backend database
 *  we use a sharedInstance.
 *
 *  @return the shared instance for database operations
 */
+ (instancetype)sharedInstance;

- (void)addVolumeUUID:(NSUUID*)uuid forMountPoint:(NSString*)mountPoint;

- (NSString*)mountPointForVolumeUUID:(NSUUID*)uuid;
- (NSUUID*)UUIDForMountPoint:(NSString*)mountPoint;

- (void)deleteVolumeWithUUID:(NSUUID*)uuid;
- (void)deleteVolumeWithMountPoint:(NSString*)mountPoint;

@end
