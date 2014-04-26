//
//  EFVUCoreStorage.h
//  efvu
//
//  Based on Diskutil from Unlock project created by Justin Ridgewell on 8/6/11.
//  Refactored and extended by Yoann Gini on 24/4/14.
//

static NSString *kEFVUCoreStorageVolumeName           = @"Volume Name";
static NSString *kEFVUCoreStorageUUID                 = @"UUID";
static NSString *kEFVUCoreStorageRole                 = @"Role";
static NSString *kEFVUCoreStorageParentLVGUUID        = @"Parent LVG UUID";
static NSString *kEFVUCoreStorageParentLVFUUID        = @"Parent LVF UUID";
static NSString *kEFVUCoreStorageLVStatus             = @"LV Status";
static NSString *kEFVUCoreStorageLVSize               = @"LV Size";
static NSString *kEFVUCoreStorageLVName               = @"LV Name";
static NSString *kEFVUCoreStorageLVConversionProgress = @"LV Conversion Progress";
static NSString *kEFVUCoreStorageDeviceIdentifier     = @"Device Identifier";
static NSString *kEFVUCoreStorageConversionStatus     = @"Conversion Status";
static NSString *kEFVUCoreStorageContentHint          = @"Content Hint";

static NSString *kEFVUCoreStorageLVFEncryptionType    = @"LVF Encryption Type";
static NSString *kEFVUCoreStorageLVFEncryptionStatus  = @"LVF Encryption Status";

@interface EFVUCoreStorage : NSObject

/**
 *  Use diskutil command line to unlock and mount a specific volume via the
 *  command `diskutil cs unlockVolume`
 *
 *  @param uuid       volume UUID
 *  @param password volume password
 */
+ (void)unlockVolume:(NSUUID*)uuid withPassword:(NSString*)password;

/**
 *  Get the information about a specific volume via the command `diskutil cs info`
 *  and return it as a NSDictionary. Constant are defined for keys.
 *
 *  @param volumeIdentifier Can be the volume UUID or the mount path
 *
 *  @return a dictionnary with all CoreStorage informations.
 */
+ (NSDictionary*)informationForVolumeWithIdentfier:(NSUUID*)volumeIdentifier;

/**
 *  Take a volume identifier (UUID or mount point) and check if it's an encrypted volume or not.
 *  This method don't check if the volume is actually unlocked or not, just if it's encrypted in the end.
 *
 *  @param volumeIdentifier volume UUID or mount point
 *
 *  @return Does the volume is encrypted? YES or NO.
 */
+ (BOOL)volumeIdentifierIsAnEncryptedDisk:(NSUUID*)volumeIdentifier;


/**
 *  List all Logical Volume available (LV, not LVG or LVF)
 *
 *  @return A NSArray of NSUUID
 */
+ (NSArray*)allLogicalVolume;

@end
