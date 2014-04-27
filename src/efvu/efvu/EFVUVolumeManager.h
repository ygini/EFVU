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
+ (NSString*)currentMountPointForVolumeWithUUID:(NSUUID*)uuid;

/**
 *  Get the volume name for a specific FileVault 2 volume UUID
 *
 *  @param uuid volume UUID
 *
 *  @return the actual mount path for requested UUID
 */
+ (NSString*)currentVolumeNameForVolumeWithUUID:(NSUUID*)uuid;

/**
 *  Get the device identifier for a specific FileVault 2 volume UUID
 *
 *  @param uuid volume UUID
 *
 *  @return The device identifier for requested UUID
 */
+ (NSString*)currentDeviceIdentifierForVolumeWithUUID:(NSUUID*)uuid;


/**
 *  Register the specificed UUID and password in the EFVU database.
 *  The password will be saved in the system keychain and the UUID in a system wild 
 *  database with the corresponding mount point.
 *
 *  @param uuid     volume UUID
 *  @param password volume password
 *
 *  @return return NO if we are unable to save password in keychain or volume information in EFVU database (check your syslog).
 */
+ (BOOL)registerVolumeWithUUID:(NSUUID*)uuid andPassword:(NSString*)password;

/**
 *  Remove all information (uuid, mount point and password) for specified
 *  UUID.
 *
 *  @param uuid volume UUID
 */
+ (BOOL)forgetVolumeWithUUID:(NSUUID*)uuid;

/**
 *  Unlock and mount volume specified by UUID
 *
 *  @param uuid volume UUID
 */
+ (BOOL)unlockVolumeWithUUID:(NSUUID*)uuid;


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

/**
 *  Return the registered volume name for a specific volume.
 *  This will not return the volume name point but the registered one.
 *
 *  @param uuid volume UUID
 *
 *  @return the registered volume name for specific volume
 */
+ (NSString*)registeredVolumeNameForVolumeWithUUID:(NSUUID*)uuid;


/**
 *  Look after a volume UUID from a requested path.
 *  The system will look in the EFVUDatabase if a registered 
 *  mount path can offer access to the requested folder
 *  and return the corresponding UUID or nil.
 *
 *  @param folderPath The requested folder
 *
 *  @return The associated volume UUID or nil
 */
+ (NSUUID*)findRegisteredVolumeUUIDProvidingFolderPath:(NSString*)folderPath;

/**
 *  Check if the EFVU keychain has a password for the specified volume UUID.
 *
 *  @param uuid Volume UUID
 *
 *  @return Yes or No, we have a secret for this volume
 */
+ (BOOL)hasPasswordForVolumeWithUUID:(NSUUID*)uuid;

@end
