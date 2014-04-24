//
//  Keychain.h
//  Unlock
//
//  Created by Justin Ridgewell on 8/5/11.
//  Refactored by Yoann Gini on 24/4/14.
//

@interface EFVUKeychain : NSObject

/**
 *  Return all registered password in system keychain organized per UUID
 *
 *  @return a NSDictionary with NSUUID as key and password as value
 */
+ (NSDictionary*)allVolumeUUIDsWithPassword;


/**
 *  Register a password for a specific UUID in system keychain
 *
 *  @param password password to register
 *  @param uuid     volume UUID
 */
+ (void)setPassword:(NSString*)password forVolumeWithUUID:(NSUUID*)uuid;

/**
 *  Retrive stored password for specific UUID in system keychain
 *
 *  @param uuid volume UUID
 *
 *  @return The password
 */
+ (NSString*)passwordForVolumeWithUUID:(NSUUID*)uuid;

/**
 *  Delete a registered password for a specific UUID in system keychain
 *
 *  @param uuid volume UUID
 */
+ (void)deletePasswordForVolumeWithUUID:(NSUUID*)uuid;

@end