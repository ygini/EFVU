//
//  Keychain.m
//  Unlock
//
//  Created by Justin Ridgewell on 8/5/11.
//  Refactored by Yoann Gini on 24/4/14.
//

#import "EFVUKeychain.h"
#import <Security/Security.h>
#import <CocoaSyslog.h>

@interface EFVUKeychain ()
+ (NSDictionary*)keychainQueryForAllItems;
+ (NSDictionary*)keychainQueryForItemWithAccount:(NSString*)account;
@end

@implementation EFVUKeychain

#pragma mark - Public API

+ (NSDictionary*)allVolumeUUIDsWithPassword
{
	NSMutableDictionary* volumeUUIDsWithPassword = [[NSMutableDictionary alloc] init];
		
	CFTypeRef attributes = NULL;
	NSDictionary *keychainItemQuery = [self keychainQueryForAllItems];
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(keychainItemQuery), (CFTypeRef*) &attributes);
	
	if (status == errSecSuccess) {
		NSArray *matchingSecItems = (__bridge_transfer NSArray *)attributes;
		NSString* volumeUUIDString = nil;
		NSString* password = nil;
		
		for (NSDictionary *secItemInfo in matchingSecItems) {
			volumeUUIDString = (NSString*) [secItemInfo objectForKey:kSecAttrAccount];
			password = [[NSString alloc] initWithData:[secItemInfo objectForKey:kSecValueData]
											 encoding:NSUTF8StringEncoding];
			
			[volumeUUIDsWithPassword setObject:password forKey:[[NSUUID alloc] initWithUUIDString:volumeUUIDString]];
			
		}
		
	} else {
		[[CocoaSyslog sharedInstance] messageLevel2Critical:@"SecItemCopyMatching returned %d!", status];
	}

	return volumeUUIDsWithPassword;
}

+ (NSString*)passwordForVolumeWithUUID:(NSUUID*)uuid
{
	NSString* password = nil;
	CFTypeRef attributes = NULL;
	NSDictionary *keychainItemQuery = [self keychainQueryForItemWithAccount:[uuid UUIDString]];
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(keychainItemQuery), (CFTypeRef*) &attributes);
	
	if (status == errSecSuccess) {
		NSDictionary *secItemInfo = (__bridge_transfer NSDictionary *)attributes;
		password = [[NSString alloc] initWithData:[secItemInfo objectForKey:kSecValueData]
										 encoding:NSUTF8StringEncoding];
	} else {
		[[CocoaSyslog sharedInstance] messageLevel2Critical:@"SecItemCopyMatching returned %d!", status];
	}
	return password;
}

+ (void)setPassword:(NSString*)password forVolumeWithUUID:(NSUUID*)uuid
{
		// Always remove the old value and then, add the new one if a password is provided.
	[self deletePasswordForVolumeWithUUID:uuid];
	if (password) {
		NSData* passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
		NSMutableDictionary *secItemInfo = [NSMutableDictionary dictionaryWithDictionary:[self keychainQueryForItemWithAccount:[uuid UUIDString]]];
		[secItemInfo setObject:passwordData forKey:kSecValueData];
		
		OSStatus status = SecItemAdd((__bridge CFDictionaryRef) secItemInfo, NULL);
		if (status != errSecSuccess) {
			[[CocoaSyslog sharedInstance] messageLevel2Critical:@"SecItemAdd returned %d!", status];
		}
	}
}

+ (void)deletePasswordForVolumeWithUUID:(NSUUID*)uuid
{
	NSDictionary* keychainItemQuery = [self keychainQueryForItemWithAccount:[uuid UUIDString]];
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef) keychainItemQuery);
	if (status != errSecSuccess) {
		[[CocoaSyslog sharedInstance] messageLevel2Critical:@"SecItemDelete returned %d!", status];
	}
}

#pragma mark - Internal API

+ (NSDictionary*)keychainQueryForAllItems
{
	return @{(id)kSecClass: (id)kSecClassGenericPassword,
			 (id)kSecAttrService: kEFVUServiceID,
			 (id)kSecMatchLimit: (id)kSecMatchLimitAll,
			 (id)kSecReturnAttributes: (id)kCFBooleanTrue,
			 (id)kSecReturnRef: (id)kCFBooleanTrue,
			 (id)kSecReturnData: (id)kCFBooleanTrue};
}

+ (NSDictionary*)keychainQueryForItemWithAccount:(NSString*)account
{
	return @{(id)kSecClass: (id)kSecClassGenericPassword,
			 (id)kSecAttrAccount: account,
			 (id)kSecAttrService: kEFVUServiceID,
			 (id)kSecReturnAttributes: (id)kCFBooleanTrue,
			 (id)kSecReturnRef: (id)kCFBooleanTrue,
			 (id)kSecReturnData: (id)kCFBooleanTrue};
}

@end
