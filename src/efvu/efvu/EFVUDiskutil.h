//
//  Diskutil.h
//  Unlock
//
//  Created by Justin Ridgewell on 8/6/11.
//

@interface EFVUDiskutil : NSObject

+ (void)unlockVolume:(NSUUID*)uuid withPassphrase:(NSString*)passphrase;

@end
