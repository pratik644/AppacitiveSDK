//
//  APNetworking.m
//  Appacitive-iOS-SDK
//
//  Created by Pratik on 31-12-13.
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "APNetworking.h"
#import "Appacitive.h"
#import "APConstants.h"
#import "APHelperMethods.h"

@implementation APNetworking

static NSURLSession *sharedURLSession = nil;
static NSDictionary *headerParams = nil;

+ (NSURLSession*) getSharedURLSession {
    if(sharedURLSession != nil)
        return sharedURLSession;
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    headerParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    [Appacitive getApiKey], APIkeyHeaderKey,
                    [Appacitive environmentToUse], EnvironmentHeaderKey,
                    @"application/json", @"Content-Type",
                    nil];
    sessionConfig.HTTPAdditionalHeaders = headerParams;
    sessionConfig.allowsCellularAccess = YES;
    sessionConfig.timeoutIntervalForRequest = 30.0;
    sessionConfig.timeoutIntervalForResource = 60.0;
    sessionConfig.URLCache = NSURLCacheStorageAllowed;
    sessionConfig.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    sharedURLSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    return sharedURLSession;
}

- (void) makeAsyncRequestWithURLRequest:(NSMutableURLRequest*)urlRequest successHandler:(APResultSuccessBlock)requestSuccessBlock failureHandler:(APFailureBlock)requestFailureBlock {
    [urlRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    if([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
        if(!sharedURLSession) {
            [APNetworking getSharedURLSession];
        }
        [[sharedURLSession dataTaskWithRequest:urlRequest
                             completionHandler:^(NSData *data,
                                                 NSURLResponse *response,
                                                 NSError *error) {
                                 if(!error) {
                                     NSError *jsonError = nil;
                                     NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                     if(!jsonError) {
                                         APError *error = [APHelperMethods checkForErrorStatus:responseJSON];
                                         BOOL isErrorPresent = (error != nil);
                                         if (!isErrorPresent) {
                                             if(requestSuccessBlock)
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     requestSuccessBlock(responseJSON);
                                                 });
                                         } else {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 DLog(@"\n––––––––––RESPONSE–––––––––––\n%@", response.description);
                                                 DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                                                 if(urlRequest.HTTPBody != nil)
                                                     DLog(@"\n––––––––––––BODY–––––––––––––\n%@", [NSJSONSerialization JSONObjectWithData:urlRequest.HTTPBody options:kNilOptions error:nil]);
                                                 if(requestFailureBlock)
                                                     requestFailureBlock(error);
                                             });
                                         }
                                     } else {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             DLog(@"\n––––––––––RESPONSE–––––––––––\n%@", response.description);
                                             DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@", jsonError);
                                             if(urlRequest.HTTPBody != nil)
                                                 DLog(@"\n––––––––––––BODY–––––––––––––\n%@", [NSJSONSerialization JSONObjectWithData:urlRequest.HTTPBody options:kNilOptions error:nil]);
                                             
                                             if (requestFailureBlock != nil)
                                                 requestFailureBlock((APError*)jsonError);
                                         });
                                     }
                                 } else {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         DLog(@"\n––––––––––RESPONSE–––––––––––\n%@", response.description);
                                         DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                                         if(urlRequest.HTTPBody != nil)
                                             DLog(@"\n––––––––––––BODY–––––––––––––\n%@", [NSJSONSerialization JSONObjectWithData:urlRequest.HTTPBody options:kNilOptions error:nil]);
                                         if (requestFailureBlock != nil)
                                             requestFailureBlock((APError*)error);
                                     });
                                 }
                             }]
         resume];
    } else {
        [urlRequest setValue:[Appacitive getApiKey] forHTTPHeaderField:APIkeyHeaderKey];
        [urlRequest setValue:[Appacitive environmentToUse] forHTTPHeaderField:EnvironmentHeaderKey];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if(!error) {
                NSError *jsonError = nil;
                NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if(!jsonError) {
                    APError *error = [APHelperMethods checkForErrorStatus:responseJSON];
                    BOOL isErrorPresent = (error != nil);
                    if (!isErrorPresent) {
                        if(requestSuccessBlock)
                            dispatch_async(dispatch_get_main_queue(), ^{
                                requestSuccessBlock(responseJSON);
                            });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            DLog(@"\n––––––––––RESPONSE–––––––––––\n%@", response.description);
                            DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                            if(urlRequest.HTTPBody != nil)
                                DLog(@"\n––––––––––––BODY–––––––––––––\n%@", [NSJSONSerialization JSONObjectWithData:urlRequest.HTTPBody options:kNilOptions error:nil]);
                            if(requestFailureBlock)
                                requestFailureBlock(error);
                        });
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DLog(@"\n––––––––––RESPONSE–––––––––––\n%@", response.description);
                        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@", jsonError);
                        if(urlRequest.HTTPBody != nil)
                            DLog(@"\n––––––––––––BODY–––––––––––––\n%@", [NSJSONSerialization JSONObjectWithData:urlRequest.HTTPBody options:kNilOptions error:nil]);
                        
                        if (requestFailureBlock != nil)
                            requestFailureBlock((APError*)jsonError);
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    DLog(@"\n––––––––––RESPONSE–––––––––––\n%@", response.description);
                    DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                    if(urlRequest.HTTPBody != nil)
                        DLog(@"\n––––––––––––BODY–––––––––––––\n%@", [NSJSONSerialization JSONObjectWithData:urlRequest.HTTPBody options:kNilOptions error:nil]);
                    if (requestFailureBlock != nil)
                        requestFailureBlock((APError*)error);
                });
            }
        }];
    }
}

@end
