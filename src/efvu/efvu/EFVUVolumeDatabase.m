//
//  EFVUVolumeDatabase.m
//  efvu
//
//  Created by Yoann Gini on 26/04/2014.
//  Copyright (c) 2014 iNig-Services. All rights reserved.
//

#import "EFVUVolumeDatabase.h"

@interface EFVUVolumeDatabase ()

@end

@implementation EFVUVolumeDatabase

#pragma mark - Object lifecycle
+ (instancetype)sharedInstance
{
	static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [self new];
	});
	
	return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - Public API

- (void)addVolumeUUID:(NSUUID*)uuid forMountPoint:(NSString*)mountPoint
{
	
}

@end
