//
//  EFVUCoreStorage.h
//  efvu
//
//  Based on Diskutil from Unlock project created by Justin Ridgewell on 8/6/11.
//  Refactored and extended by Yoann Gini on 24/4/14.
//

#import "EFVUCoreStorage.h"

#import <CocoaSyslog.h>

#define kEFVUCoreStorageInfoHeader		@"Core Storage Properties:"

@interface EFVUCoreStorage ()

+ (NSString*)executeCoreStorageCommand:(NSString*)csCommand withArguments:(NSArray*)arguments;
+ (NSDictionary*)parseCoreStorageInfoResult:(NSString*)csInfoString;

@end

@implementation EFVUCoreStorage

#pragma mark - Public API

+ (void)unlockVolume:(NSUUID*)uuid withPassword:(NSString*)password
{
	[[CocoaSyslog sharedInstance] messageLevel5Notice:@"Unlocking volume %@", uuid];
	
	[self executeCoreStorageCommand:@"unlockVolume" withArguments:@[[uuid UUIDString],
																	@"-passphrase",
																	password
																	]];
}

+ (NSDictionary*)informationForVolumeWithIdentfier:(NSString*)volumeIdentifier
{
	NSString *commandOutput = [self executeCoreStorageCommand:@"info" withArguments:@[volumeIdentifier]];
	
	return [self parseCoreStorageInfoResult:commandOutput];
}

+ (BOOL)volumeIdentifierIsAnEncryptedDisk:(NSString*)volumeIdentifier
{
	if (volumeIdentifier) {
		NSDictionary *volumeInformation = [self parseCoreStorageInfoResult:[self executeCoreStorageCommand:@"info"
																							 withArguments:@[volumeIdentifier]]];
		
		NSString *encryptionState = [volumeInformation objectForKey:kEFVUCoreStorageLVFEncryptionType];
		if (encryptionState) {
			if ([encryptionState isEqualToString:@"None"]) {
				return NO;
			}
			else {
				return YES;
			}
		}
		else {
			return [self volumeIdentifierIsAnEncryptedDisk:[volumeInformation objectForKey:kEFVUCoreStorageParentLVFUUID]];
		}
	}
	else {
		return NO;
	}
}

#pragma mark - Private API

+ (NSString*)executeCoreStorageCommand:(NSString*)csCommand withArguments:(NSArray*)arguments
{
	NSString *csOutputString = nil;
	NSMutableArray *csArgs = [NSMutableArray arrayWithObjects:@"cs", csCommand, nil];
	[csArgs addObjectsFromArray:arguments];
	
	NSTask *csTask = [NSTask new];
	[csTask setLaunchPath:@"/usr/sbin/diskutil"];
	[csTask setArguments:csArgs];
	[csTask setStandardOutput:[NSPipe pipe]];
	[csTask launch];
	[csTask waitUntilExit];
	

	NSData *csOutputData = [[[csTask standardOutput] fileHandleForReading] availableData];
	
	if ([csOutputData length] > 0) {
		csOutputString = [[NSString alloc] initWithData:csOutputData encoding:NSUTF8StringEncoding];
	}
	else {
		[[CocoaSyslog sharedInstance] messageLevel4Warning:@"No data returned by diskutil cs %@", csCommand];
	}
	return csOutputString;
}

+ (NSDictionary*)parseCoreStorageInfoResult:(NSString*)csInfoString
{
	NSMutableDictionary *volumeInformations = [NSMutableDictionary new];
	NSMutableString *internalCsInfoString = [csInfoString mutableCopy];
	[internalCsInfoString replaceOccurrencesOfString:kEFVUCoreStorageInfoHeader
										  withString:@""
											 options:NSLiteralSearch
											   range:(NSRange){0, [kEFVUCoreStorageInfoHeader length]}];
	
	if ([csInfoString length] > 0) {
		NSScanner *infoScanner = [NSScanner scannerWithString:internalCsInfoString];
		
		NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@":\n"];
		
		NSString *keyString = nil, *valueString = nil;
		
		while (![infoScanner isAtEnd]) {
			[infoScanner scanUpToCharactersFromSet:separatorSet intoString:&keyString];
			[infoScanner setScanLocation:[infoScanner scanLocation]+1];
			[infoScanner scanUpToCharactersFromSet:separatorSet intoString:&valueString];
			[infoScanner setScanLocation:[infoScanner scanLocation]+1];
			
			if (keyString && valueString) {
				[volumeInformations setObject:valueString forKey:keyString];
				keyString = valueString = nil;
			}
		}

	}
	return volumeInformations;
}

@end
