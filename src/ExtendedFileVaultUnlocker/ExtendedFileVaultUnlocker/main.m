	//
	//  main.c
	//  ExtendedFileVaultUnlocker
	//
	//  Created by Yoann Gini on 26/04/2014.
	//  Copyright (c) 2014 iNig-Services. All rights reserved.
	//

#import "main.h"
#import <pwd.h>
#import <membership.h>
#import <uuid/uuid.h>
#import <efvu/EFVUVolumeManager.h>

#pragma mark Custom functions

static NSString* getUserName(EFVUMechanismRef* mechanism)
{
    AuthorizationContextFlags contextFlags;
    const AuthorizationValue* userShortName;
    OSStatus status;
	
    status = mechanism->plugin->callbacks->GetContextValue(mechanism->engine, kAuthorizationEnvironmentUsername, &contextFlags, &userShortName);
    if (status) {
        return nil;
    }
    return [NSString stringWithUTF8String:(userShortName->data)];
}

#pragma mark Plugin callbacks

/**
 *  Init mechanism
 *  Check the requested mechanism ID and setup the plugin to be ready to work
 */
static OSStatus mechanismCreate(AuthorizationPluginRef inPlugin,
                                AuthorizationEngineRef inEngine,
                                AuthorizationMechanismId mechanismId,
                                AuthorizationMechanismRef* outMechanism)
{
    EFVUMechanismRef* mechanism;
	
    mechanism = calloc(1, sizeof(EFVUMechanismRef));
    mechanism->plugin = (const EFVUPluginRef*)inPlugin;
    mechanism->engine = inEngine;
	
    if (!strcmp(mechanismId, "none")) {
        mechanism->mechanismId = kEFVUMechanismIDNone;
    }
	
	else if (!strcmp(mechanismId, "login")) {
        mechanism->mechanismId = kEFVUMechanismIDLogin;
    }
	
	else {
        return errAuthorizationInternal;
    }
    *outMechanism = mechanism;
    return errAuthorizationSuccess;
}

/**
 *  Plugin invoked by Security services.
 *  We need to check if the user need our services, and try it serve him if needed
 *  Even if we don't handle real authentication mechanism, we can reply by an Authorization Denied
 *  when we are unable to mount the home folder.
 */
static OSStatus mechanismInvoke(AuthorizationMechanismRef inMechanism)
{
    EFVUMechanismRef* mechanism;
    NSString *userShortName = nil;
	
    mechanism = (EFVUMechanismRef*)inMechanism;
	
    switch (mechanism->mechanismId) {
		case kEFVUMechanismIDNone:
			break;
			
		case kEFVUMechanismIDLogin:
			userShortName = getUserName(mechanism);
			
			struct passwd* info = getpwnam([userShortName UTF8String]);
			if (info) {
				const char *homedir = info->pw_dir;
				NSString *homeFolder = [NSString stringWithUTF8String:homedir];
				
				if ([homeFolder length] > 0) {
					NSUUID *volumeUUID = [EFVUVolumeManager findRegisteredVolumeUUIDProvidingFolderPath:homeFolder];
					if (volumeUUID) {
						BOOL success = [EFVUVolumeManager hasPasswordForVolumeWithUUID:volumeUUID];
						
						if (success) {
							success = [EFVUVolumeManager unlockVolumeWithUUID:volumeUUID];
							
							if (success) {
								return mechanism->plugin->callbacks->SetResult(mechanism->engine, kAuthorizationResultAllow);
							}
							else {
								return mechanism->plugin->callbacks->SetResult(mechanism->engine, kAuthorizationResultDeny);
							}
						}						
						else {
							return mechanism->plugin->callbacks->SetResult(mechanism->engine, kAuthorizationResultDeny);
						}
						
					}
				}
			}
			break;
			
		default:
			return errAuthorizationInternal;
    }
	
    return mechanism->plugin->callbacks->SetResult(mechanism->engine, kAuthorizationResultAllow);
}

/**
 *  The system ask us to stop our work. Since we don't have any long term operation, we can reply directly.
 */
static OSStatus mechanismDeactivate(AuthorizationMechanismRef inMechanism)
{
    return 0;
}

/**
 *  Free memory used by authorization mechanism
 */
static OSStatus mechanismDestroy(AuthorizationMechanismRef inMechanism)
{
    free((EFVUMechanismRef*)inMechanism);
    return 0;
}

/**
 *  Advertized interface, used in AuthorizationPluginCreate to register the plugin.
 */
AuthorizationPluginInterface pluginInterface = {
    kAuthorizationPluginInterfaceVersion, //UInt32 version;
    pluginDestroy,
    mechanismCreate,
    mechanismInvoke,
    mechanismDeactivate,
    mechanismDestroy
};

#pragma mark Plugin management

/**
 *  Plugin creation. Can be called even if plugin mechanism isn't used in the end.
 *  So we need to be careful to what we allocate here.
 */
OSStatus AuthorizationPluginCreate(const AuthorizationCallbacks* callbacks,
                                   AuthorizationPluginRef* outPlugin,
                                   const AuthorizationPluginInterface** outPluginInterface)
{
    EFVUPluginRef* plugin;
	
    plugin = calloc(1, sizeof(EFVUPluginRef));
    plugin->callbacks = callbacks;
    *outPlugin = (AuthorizationPluginRef)plugin;
    *outPluginInterface = &pluginInterface;
    return errAuthorizationSuccess;
}

/**
 *  Free memory specific to the plugin by it self (allocated in AuthorizationPluginCreate)
 */
static OSStatus pluginDestroy(AuthorizationPluginRef inPlugin)
{
    free((EFVUPluginRef*)inPlugin);
    return 0;
}