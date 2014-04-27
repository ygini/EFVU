//
//  EFVUVolumeDatabase.m
//  efvu
//
//  Created by Yoann Gini on 26/04/2014.
//  Copyright (c) 2014 iNig-Services. All rights reserved.
//

#import "EFVUVolumeDatabase.h"
#import <fmdb/FMDatabase.h>
#import <CocoaSyslog.h>

@interface EFVUVolumeDatabase ()
@property FMDatabase *database;
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
        [self initialSQLiteCheckup];
    }
    return self;
}


- (void)dealloc
{
    [self SQLiteCleanup];
}

#pragma mark - SQLite Database management

- (NSString*)sqliteFileName
{
	return [NSString stringWithFormat:@"%@.db.sqlite", kEFVUServiceID];
}

- (NSString*)sqlitePath
{
	return [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES) lastObject]
			 stringByAppendingPathComponent:@"Preferences"]
			stringByAppendingPathComponent:[self sqliteFileName]];
}

- (void)initialSQLiteCheckup
{
	NSString *sqlitePath = [self sqlitePath];
	BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:sqlitePath];
	
	if (!fileExist ) {
		[self createSQLiteDatabaseAthPath:sqlitePath];
	}
	else {
		self.database = [FMDatabase databaseWithPath:sqlitePath];
		[self.database open];
	}
}

- (void)SQLiteCleanup
{
	[self.database close];
}

- (void)createSQLiteDatabaseAthPath:(NSString*)sqlitePath
{
	self.database = [FMDatabase databaseWithPath:sqlitePath];
	[self.database open];
	[self.database executeUpdate:@"CREATE TABLE volumes(uuid TEXT, name TEXT, mount_point TEXT, UNIQUE(uuid, mount_point) ON CONFLICT ABORT)"];
}

#pragma mark - Public API

- (BOOL)addVolumeUUID:(NSUUID*)uuid forMountPoint:(NSString*)mountPoint andName:(NSString*)name
{
	[self deleteVolumeWithUUID:uuid];
	BOOL success = [self.database executeUpdate:@"INSERT INTO volumes (uuid, name, mount_point) VALUES (?, ?, ?)", [uuid UUIDString], name, mountPoint];
	
	if (!success) {
		[[CocoaSyslog sharedInstance] messageLevel2Critical:@"Unable to save volume informations in EFVU database, most likely an already registered mount point"];
	}
	
	return success;
}

- (NSString*)mountPointForVolumeUUID:(NSUUID*)uuid
{
	FMResultSet *result = [self.database executeQuery:@"SELECT mount_point FROM volumes WHERE uuid == ?", [uuid UUIDString]];
	[result next];
	
	return [result stringForColumn:@"mount_point"];
}

- (NSString*)volumeNameForVolumeUUID:(NSUUID*)uuid
{
	FMResultSet *result = [self.database executeQuery:@"SELECT name FROM volumes WHERE uuid == ?", [uuid UUIDString]];
	[result next];
	
	return [result stringForColumn:@"name"];
}

- (NSUUID*)UUIDForMountPoint:(NSString*)mountPoint
{
	FMResultSet *result = [self.database executeQuery:@"SELECT uuid FROM volumes WHERE mount_point == ?", mountPoint];
	[result next];
	
	return [[NSUUID alloc] initWithUUIDString:[result stringForColumn:@"uuid"]];
}

- (BOOL)deleteVolumeWithUUID:(NSUUID*)uuid
{
	return [self.database executeUpdate:@"DELETE FROM volumes WHERE uuid == ?", [uuid UUIDString]];
}

- (NSArray*)allUUIDs
{
	FMResultSet *result = [self.database executeQuery:@"SELECT uuid FROM volumes"];
	NSMutableArray *uuids = [NSMutableArray new];
	
	while ([result next]) {
		[uuids addObject:[[NSUUID alloc] initWithUUIDString:[result stringForColumn:@"uuid"]]];
	}
	
	return uuids;
}

@end
