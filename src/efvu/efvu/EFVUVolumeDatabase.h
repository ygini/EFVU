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

- (BOOL)addVolumeUUID:(NSUUID*)uuid forMountPoint:(NSString*)mountPoint andName:(NSString*)name;

- (NSString*)mountPointForVolumeUUID:(NSUUID*)uuid;
- (NSString*)volumeNameForVolumeUUID:(NSUUID*)uuid;
- (NSUUID*)UUIDForMountPoint:(NSString*)mountPoint;

- (BOOL)deleteVolumeWithUUID:(NSUUID*)uuid;

- (NSArray*)allUUIDs;

@end
