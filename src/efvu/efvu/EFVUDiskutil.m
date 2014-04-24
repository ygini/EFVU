//
//  Diskutil.m
//  Unlock
//
//  Created by Justin Ridgewell on 8/6/11.
//

#import "EFVUDiskutil.h"

#import <CocoaSyslog.h>

@implementation EFVUDiskutil

+ (void)unlockVolume:(NSUUID*)uuid withPassphrase:(NSString*)passphrase {
	NSMutableArray* args = [NSMutableArray array];
	[args addObject:@"cs"];
	[args addObject:@"unlockVolume"];
	[args addObject:[uuid UUIDString]];
	[args addObject:@"-passphrase"];
	[args addObject:passphrase];

	[[CocoaSyslog sharedInstance] messageLevel5Notice:@"Unlocking volume %@", uuid];
    [[NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil" arguments:args] waitUntilExit];
}

@end
