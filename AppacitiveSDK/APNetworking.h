//
//  APNetworking.h
//  Appacitive-iOS-SDK
//
//  Created by Pratik on 31-12-13.
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "APResponseBlocks.h"

#define HOST_NAME @"https://apis.appacitive.com"

/**
 The APNetworking class is the networking API for the appacitive SDK that allows the SDK to make network requests to the Appacitive API and receive a response from the server. 
 @note All the network requests are asynchronous.
 */

@interface APNetworking : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    APResultSuccessBlock proxySuccessBlock;
    APFailureBlock proxyFailureBlock;
}
/**
 Method to get a shared NSURLSession for network data tasks.
 
 @return NSURLSession object
 */
+ (NSURLSession*) getSharedURLSession;

/**
 Method to make a network request
 
 @param urlRequest NSURLRequest object for the request that needs to be made.
 @param requestSuccessBlock Block invoked when the network request operation is successful.
 @param requestFailureBlock Block invoked when the network request operation is unsuccessful.
 */
- (void) makeAsyncRequestWithURLRequest:(NSMutableURLRequest*)urlRequest successHandler:(APResultSuccessBlock)requestSuccessBlock failureHandler:(APFailureBlock)requestFailureBlock;

@end
