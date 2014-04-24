//
//  Keychain.m
//  Unlock
//
//  Created by Justin Ridgewell on 8/5/11.
//

#import "EFVUKeychain.h"
#import <Security/Security.h>
#import <CocoaSyslog.h>

@interface EFVUKeychain ()
- (NSDictionary*)queryForAllItemsWithService:(NSString*)service;
- (NSDictionary*)queryForItemWithAccount:(NSString*)account andService:(NSString*)service;
@end

@implementation EFVUKeychain

#pragma mark - Public API

- (NSDictionary*)volumeUUIDsWithPasswordForService:(NSString*)service
{
	NSMutableDictionary* volumeUUIDsWithPassword = [[NSMutableDictionary alloc] init];
		
	CFTypeRef attributes = NULL;
	NSDictionary *keychainItemQuery = [self queryForAllItemsWithService:service];
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(keychainItemQuery), (CFTypeRef*) &attributes);
	
	if (status == errSecSuccess) {
		NSArray *matchingSecItems = (__bridge_transfer NSArray *)attributes;
		NSString* volumeUUIDString = nil;
		NSString* password = nil;
		
		for (NSDictionary *secItemInfo in matchingSecItems) {
			volumeUUIDString = (NSString*) [secItemInfo objectForKey:kSecAttrAccount];
			password = [[NSString alloc] initWithData:[secItemInfo objectForKey:kSecValueData]
											 encoding:NSUTF8StringEncoding];
			
			[volumeUUIDsWithPassword setObject:password forKey:volumeUUIDString];
			
		}
		
	} else {
		[[CocoaSyslog sharedInstance] messageLevel2Critical:@"SecItemCopyMatching returned %d!", status];
	}

	return volumeUUIDsWithPassword;
}

#pragma mark - Internal API

- (NSDictionary*)queryForAllItemsWithService:(NSString*)service
{
	return @{(id)kSecClass: (id)kSecClassGenericPassword,
			 (id)kSecAttrService: service,
			 (id)kSecMatchLimit: (id)kSecMatchLimitAll,
			 (id)kSecReturnAttributes: (id)kCFBooleanTrue,
			 (id)kSecReturnRef: (id)kCFBooleanTrue,
			 (id)kSecReturnData: (id)kCFBooleanTrue};
}

- (NSDictionary*)queryForItemWithAccount:(NSString*)account andService:(NSString*)service
{
	return @{(id)kSecClass: (id)kSecClassGenericPassword,
			 (id)kSecAttrAccount: account,
			 (id)kSecAttrService: service,
			 (id)kSecReturnData: (id)kCFBooleanTrue};
}

@end
