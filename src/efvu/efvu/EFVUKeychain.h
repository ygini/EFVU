//
//  Keychain.h
//  Unlock
//
//  Created by Justin Ridgewell on 8/5/11.
//

@interface EFVUKeychain : NSObject

+ (NSDictionary*)allVolumeUUIDsWithPassword;

+ (void)setPassword:(NSString*)password forVolumeWithUUID:(NSUUID*)uuid;
+ (NSString*)passwordForVolumeWithUUID:(NSUUID*)uuid;
+ (void)deletePasswordForVolumeWithUUID:(NSUUID*)uuid;

@end