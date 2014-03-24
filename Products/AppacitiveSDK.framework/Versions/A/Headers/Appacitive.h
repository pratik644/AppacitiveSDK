//
//  Appacitive.h
//  Appacitive-iOS-SDK
//
//  Created by Kauserali Hafizji on 29/08/12.
//  Copyright (c) 2012 Appacitive Software Pvt. All rights reserved.
//
#import "APDevice.h"
/**
 Appacitive is the entry point to use the Appacitive SDK.
 Here you set your Appacitive application APIKey and your Appacitive application environment, which will be used to make all network requests to Appacitive back end.
 */
@interface Appacitive: NSObject

@property (nonatomic, readwrite) BOOL enableDebugForEachRequest;

/**
 Returns the current ApiKey
 */
+ (NSString*) getApiKey;

/**
 Sets the APIkey
 @param apiKey APIKey to be used for the app. You can obtain this key from the Appacitive portal.
 */
+ (void) initWithAPIKey:(NSString*)apiKey;

/**
 By default the environment is set to sandbox. To change to live set the enableLiveEnvironment property of the Appacitive object.
 @return The environment to use
 */
+ (NSString*) environmentToUse;

/**
 Method to set application environment to live
 @param answer Whether you want to use live environment.
 */
+ (void) useLiveEnvironment:(BOOL)answer;

/**
 Everythime you call the initWithAPIKey method, it creates a default APDevice object that corresponds to teh deviece the app is installed in. This methods return a refence to the current default APDevice object.
 @return The current default APDevice object.
 */
+ (APDevice*) getCurrentAPDevice;


@end
