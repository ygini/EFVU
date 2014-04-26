//
//  EFVUVolumeManager.h
//  efvu
//
//  Created by Yoann Gini on 24/04/2014.
//  Copyright (c) 2014 iNig-Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EFVUVolumeManager : NSObject

/**
 *  List all FileVault 2 connected volume and return the UUID list
 *
 *  @return a list of NSUUID object representing each FileVault 2 volume
 */
+ (NSArray*)volumeUUIDs;

/**
 *  Get the actual mount point for a specific FileVault 2 volume UUID
 *
 *  @param uuid volume UUID
 *
 *  @return the actual mount path for requested UUID
 */
+ (NSString*)mountPointForVolumeWithUUID:(NSUUID*)uuid;

/**
 *  Get the volume name for a specific FileVault 2 volume UUID
 *
 *  @param uuid volume UUID
 *
 *  @return the actual mount path for requested UUID
 */
+ (NSString*)volumeNameForVolumeWithUUID:(NSUUID*)uuid;

/**
 *  Get the device identifier for a specific FileVault 2 volume UUID
 *
 *  @param uuid volume UUID
 *
 *  @return The device identifier for requested UUID
 */
+ (NSString*)deviceIdentifierForVolumeWithUUID:(NSUUID*)uuid;


/**
 *  Register the specificed UUID and password in the EFVU database.
 *  The password will be saved in the system keychain and the UUID in a system wild 
 *  database with the corresponding mount point.
 *
 *  @param uuid     volume UUID
 *  @param password volume password
 */
+ (void)registerVolumeWithUUID:(NSUUID*)uuid andPassword:(NSString*)password;

/**
 *  Remove all information (uuid, mount point and password) for specified
 *  UUID.
 *
 *  @param uuid volume UUID
 */
+ (void)forgetVolumeWithUUID:(NSUUID*)uuid;

/**
 *  Unlock and mount volume specified by UUID
 *
 *  @param uuid volume UUID
 */
+ (void)unlockVolumeWithUUID:(NSUUID*)uuid;


/**
 *  List all registered volume UUID
 *
 *  @return an array of NSUUID
 */
+ (NSArray*)registeredVolumeUUIDs;

/**
 *  Return the registered mount point for a specific volume.
 *  This will not return the actual mount point but the registered one.
 *
 *  @param uuid volume UUID
 *
 *  @return the registered mount point for specific volume
 */
+ (NSString*)registeredMountPointForVolumeWithUUID:(NSUUID*)uuid;

@end
