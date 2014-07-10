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
	[csTask setStandardError:[NSPipe pipe]];
	[csTask launch];
	[csTask waitUntilExit];
		
	NSData *csOutputData = [[[csTask standardOutput] fileHandleForReading] availableData];
	
	if ([csOutputData length] > 0) {
		csOutputString = [[NSString alloc] initWithData:csOutputData encoding:NSUTF8StringEncoding];
	}
	else {
		[[CocoaSyslog sharedInstance] messageLevel4Warning:@"No data returned by diskutil cs %@", csCommand];
	}
	
	csOutputData = [[[csTask standardError] fileHandleForReading] availableData];
	if ([csOutputData length] > 0) {
		NSString *errorString = [[NSString alloc] initWithData:csOutputData encoding:NSUTF8StringEncoding];
		[[CocoaSyslog sharedInstance] messageLevel3Error:@"Error message returned by diskutil cs\n%@", errorString];
	}
	
	return csOutputString;
}

+ (NSDictionary*)parseCoreStorageInfoResult:(NSString*)csInfoString
{
	NSMutableDictionary *volumeInformations = [NSMutableDictionary new];

	if ([csInfoString length] > 0) {
		NSMutableString *internalCsInfoString = [csInfoString mutableCopy];
		[internalCsInfoString replaceOccurrencesOfString:kEFVUCoreStorageInfoHeader
											  withString:@""
												 options:NSLiteralSearch
												   range:(NSRange){0, [kEFVUCoreStorageInfoHeader length]}];
		
		if ([internalCsInfoString length] > 0) {
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
	}

	return volumeInformations;
}

#pragma mark - Public API

+ (void)unlockVolume:(NSUUID*)uuid withPassword:(NSString*)password
{
	if ([uuid isKindOfClass:[NSUUID class]] && [password length] > 0) {
		[[CocoaSyslog sharedInstance] messageLevel5Notice:@"Unlocking volume %@", [uuid UUIDString]];
		[[CocoaSyslog sharedInstance] messageLevel7Debug:@"Unlocking volume %@ with password %@", [uuid UUIDString], password];
		
		[self executeCoreStorageCommand:@"unlockVolume" withArguments:@[[uuid UUIDString],
																		@"-passphrase",
																		password
																		]];

	}
}

+ (NSDictionary*)informationForVolumeWithIdentfier:(NSUUID*)volumeIdentifier
{
	if ([volumeIdentifier isKindOfClass:[NSUUID class]]) {
		NSString *commandOutput = [self executeCoreStorageCommand:@"info" withArguments:@[[volumeIdentifier UUIDString]]];
		
		return [self parseCoreStorageInfoResult:commandOutput];
	}
	return nil;
}

+ (BOOL)volumeIdentifierIsAnEncryptedDisk:(NSUUID*)volumeIdentifier
{
	if ([volumeIdentifier isKindOfClass:[NSUUID class]]) {
		NSDictionary *volumeInformation = [self parseCoreStorageInfoResult:[self executeCoreStorageCommand:@"info"
																							 withArguments:@[[volumeIdentifier UUIDString]]]];
		
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

+ (NSArray*)allLogicalVolume
{
	NSMutableArray *finalList = [NSMutableArray new];
	NSString *listOutput = [self executeCoreStorageCommand:@"list"
											 withArguments:nil];
	
	NSArray *listOutputByLines = [listOutput componentsSeparatedByString:@"\n"];
	
	for (NSString *line in listOutputByLines) {
		if ([line rangeOfString:@"Logical Volume"].location != NSNotFound) {
			if ([line rangeOfString:@"Logical Volume Group"].location == NSNotFound
				&& [line rangeOfString:@"Logical Volume Family"].location == NSNotFound) {
				[finalList addObject:[[NSUUID alloc] initWithUUIDString:[[line componentsSeparatedByString:@" "] lastObject]]];
			}
		}
	}
	
	return finalList;
}

@end
