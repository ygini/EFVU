//
//  main.h
//  ExtendedFileVaultUnlocker
//
//  Created by Yoann Gini on 26/04/2014.
//  Copyright (c) 2014 iNig-Services. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <Security/AuthorizationTags.h>
#include <Security/AuthorizationPlugin.h>

#pragma mark Defines
#define DEFAULT_ADMIN_GROUP 80

#pragma mark Type definitions
typedef struct EFVUPluginRef {
    const AuthorizationCallbacks* callbacks;
} EFVUPluginRef;


typedef enum kEFVUMechanismID {
	kEFVUMechanismIDNone,
	kEFVUMechanismIDLogin
} kEFVUMechanismID;

typedef struct EFVUMechanismRef {
    const EFVUPluginRef* plugin;
    AuthorizationEngineRef engine;
    kEFVUMechanismID mechanismId;
} EFVUMechanismRef;

#pragma mark Custom functions
static NSString* getUserName(EFVUMechanismRef* mechanism);

#pragma mark Plugin callbacks
static OSStatus mechanismCreate(AuthorizationPluginRef inPlugin, AuthorizationEngineRef inEngine, AuthorizationMechanismId mechanismId, AuthorizationMechanismRef* outMechanism);
static OSStatus mechanismInvoke(AuthorizationMechanismRef inMechanism);
static OSStatus mechanismDeactivate(AuthorizationMechanismRef inMechanism);
static OSStatus mechanismDestroy(AuthorizationMechanismRef inMechanism);

#pragma mark Plugin management
OSStatus AuthorizationPluginCreate(const AuthorizationCallbacks* callbacks, AuthorizationPluginRef* outPlugin, const AuthorizationPluginInterface** outPluginInterface);
static OSStatus pluginDestroy(AuthorizationPluginRef inPlugin);