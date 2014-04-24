//
//  Keychain.h
//  Unlock
//
//  Created by Justin Ridgewell on 8/5/11.
//

@interface EFVUKeychain : NSObject

- (NSDictionary*)volumeUUIDsWithPasswordForService:(NSString*)service;

@end