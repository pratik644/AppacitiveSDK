//
//  APFile.m
//  Appacitive-iOS-SDK
//
//  Created by Kauserali Hafizji on 10/09/12.
//  Copyright (c) 2012 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "APFile.h"
#import "Appacitive.h"
#import "APHelperMethods.h"
#import "APError.h"
#import "APConstants.h"
#import "APNetworking.h"

#define FILE_PATH @"v1.0/file/"

APResultSuccessBlock proxySuccessBlock;
APFileDownloadSuccessBlock proxyDownloadSuccessBlock;
APFailureBlock proxyFailureBlock;
NSString *requestContentType = nil;
NSMutableData *requestData = nil;
NSURL *uploadURL;
NSDictionary *uploadDict;
BOOL isDownloadData = NO;

@implementation APFile

#pragma mark - Uplaod file methods

+ (void) uploadFileWithName:(NSString *)name data:(NSData *)fileData validUrlForTime:(NSNumber *)minutes {
    [self uploadFileWithName:name data:fileData validUrlForTime:minutes contentType:nil successHandler:nil failureHandler:nil];
}

+ (void) uploadFileWithName:(NSString *)name data:(NSData *)fileData validUrlForTime:(NSNumber *)minutes contentType:(NSString *)contentType {
    [self uploadFileWithName:name data:fileData validUrlForTime:minutes contentType:contentType successHandler:nil failureHandler:nil];
}

+ (void) uploadFileWithName:(NSString *)name data:(NSData *)fileData validUrlForTime:(NSNumber *)minutes contentType:(NSString *)contentType successHandler:(APResultSuccessBlock)successBlock {
    [self uploadFileWithName:name data:fileData validUrlForTime:minutes contentType:contentType successHandler:successBlock failureHandler:nil];
}

+ (void) uploadFileWithName:(NSString *)name data:(NSData *)fileData validUrlForTime:(NSNumber *)minutes contentType:(NSString *)contentType successHandler:(APResultSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://apis.appacitive.com/v1.0/file/uploadurl?contenttype=%@&filename=%@&expires=%@",contentType,name,minutes]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"GET";
    if([[[UIDevice currentDevice] systemVersion] intValue] >=7 ) {
        NSURLSession *urlSession = [APNetworking getSharedURLSession];
        [[urlSession dataTaskWithRequest:urlRequest
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
                                       NSDictionary *fetchUploadUrlResponse = responseJSON;
                                       NSURL *fileUploadURL = [NSURL URLWithString:[fetchUploadUrlResponse objectForKey:@"url"]];
                                       NSMutableURLRequest *fileUploadRequest = [NSMutableURLRequest requestWithURL:fileUploadURL];
                                       [fileUploadRequest setHTTPMethod:@"PUT"];
                                       NSString *stringContentType = @"application/octet-stream";
                                       if (contentType) {
                                           stringContentType = contentType;
                                       }
                                       [fileUploadRequest addValue:stringContentType forHTTPHeaderField: @"Content-Type"];
                                       NSMutableData *body = [NSMutableData data];
                                       [body appendData:[NSData dataWithData:fileData]];
                                       [fileUploadRequest setHTTPBody:body];
                                       [[urlSession uploadTaskWithRequest:fileUploadRequest fromData:body completionHandler:^(NSData *data, NSURLResponse *res, NSError *error) {
                                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
                                           if ([httpResponse statusCode] == 200 && successBlock != nil) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   successBlock(responseJSON);
                                               });
                                           }
                                           if(error!=nil) {
                                               DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                                               if (failureBlock != nil) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       failureBlock((APError*)error);
                                                   });
                                               }
                                           }
                                       }] resume];
                                   } else {
                                       DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                                       if (failureBlock != nil) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               failureBlock(error);
                                           });
                                       }
                                   }                            } else {
                                       DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@", jsonError);
                                       if (failureBlock != nil) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               failureBlock((APError*) error);
                                           });
                                       }
                                   }
                           } else {
                               DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                               if (failureBlock != nil) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       failureBlock((APError*) error);
                                   });
                               }
                           }
                       }] resume];
    } else {
        NSMutableDictionary *headerParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [Appacitive getApiKey], APIkeyHeaderKey,
                                             [Appacitive environmentToUse], EnvironmentHeaderKey,
                                             @"application/json", @"Content-Type",
                                             nil];
        [urlRequest setAllHTTPHeaderFields:headerParams];
        
        //Using Async method
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if(!error) {
                NSError *jsonError = nil;
                NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if(!jsonError) {
                    APError *error = [APHelperMethods checkForErrorStatus:responseJSON];
                    BOOL isErrorPresent = (error != nil);
                    if (!isErrorPresent) {
                        NSDictionary *fetchUploadUrlResponse = responseJSON;
                        NSURL *fileUploadURL = [NSURL URLWithString:[fetchUploadUrlResponse objectForKey:@"url"]];
                        NSMutableURLRequest *fileUploadRequest = [NSMutableURLRequest requestWithURL:fileUploadURL];
                        [fileUploadRequest setHTTPMethod:@"PUT"];
                        NSString *stringContentType = @"application/octet-stream";
                        if (contentType) {
                            stringContentType = contentType;
                        }
                        [fileUploadRequest addValue:stringContentType forHTTPHeaderField: @"Content-Type"];
                        NSMutableData *body = [NSMutableData data];
                        [body appendData:[NSData dataWithData:fileData]];
                        [fileUploadRequest setHTTPBody:body];
                        [NSURLConnection sendAsynchronousRequest:fileUploadRequest queue:queue completionHandler:^(NSURLResponse *res, NSData *data, NSError *connectionError) {
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
                            if ([httpResponse statusCode] == 200 && successBlock != nil) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    successBlock(responseJSON);
                                });
                            }
                            if(error!=nil) {
                                DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                                if (failureBlock != nil) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        failureBlock((APError*)error);
                                    });
                                }
                            }
                        }];
                    } else {
                        DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                        if (failureBlock != nil) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                failureBlock(error);
                            });
                        }
                    }                            } else {
                        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@", jsonError);
                        if (failureBlock != nil) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                failureBlock((APError*) error);
                            });
                        }
                    }
            } else {
                DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                if (failureBlock != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failureBlock((APError*) error);
                    });
                }
            }
        }];
        
//        //Using delegate methods
//        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//        proxySuccessBlock = successBlock;
//        proxyFailureBlock = failureBlock;
//        requestContentType = contentType;
//        requestData = [fileData mutableCopy];
//        [connection start];
    }
}

#pragma mark - Download file methods

+ (void) downloadFileWithName:(NSString*)name validUrlForTime:(NSNumber*)minutes successHandler:(APFileDownloadSuccessBlock) successBlock {
    [self downloadFileWithName:name validUrlForTime:minutes successHandler:successBlock failureHandler:nil];
}


+ (void) downloadFileWithName:(NSString*)name validUrlForTime:(NSNumber*)minutes successHandler:(APFileDownloadSuccessBlock) successBlock failureHandler:(APFailureBlock)failureBlock {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://apis.appacitive.com/v1.0/file/download/%@?expires=%@",name,minutes]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    if([[[UIDevice currentDevice] systemVersion] intValue] >=7 ) {
        NSURLSession *urlSession = [APNetworking getSharedURLSession];
        [[urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if(!error) {
                BOOL isErrorPresent = (error != nil);
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                NSError *jsonError = nil;
                dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if(jsonError != nil)
                    DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
                NSString *uri = [dictionary objectForKey:@"uri"];
                if(uri) {
                    if (!isErrorPresent) {
                        NSMutableURLRequest *fileDownloadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[dictionary objectForKey:@"uri"]]];
                        [fileDownloadRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
                        [fileDownloadRequest setHTTPMethod:@"GET"];
                        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
                        [sessionConfig setRequestCachePolicy:NSURLRequestReturnCacheDataElseLoad];
                        sessionConfig.allowsCellularAccess = YES;
                        sessionConfig.timeoutIntervalForRequest = 30.0;
                        sessionConfig.timeoutIntervalForResource = 60.0;
                        sessionConfig.URLCache = NSURLCacheStorageAllowed;
                        sessionConfig.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
                        NSURLSession *downloadSession = [NSURLSession sessionWithConfiguration:sessionConfig];
                        [[downloadSession downloadTaskWithRequest:fileDownloadRequest completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                            if(!error) {
                                if (successBlock) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        successBlock([NSData dataWithContentsOfURL:location]);
                                    });
                                }
                            }
                            else {
                                DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                                if(failureBlock != nil) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        failureBlock((APError*)error);
                                    });
                                }
                            }
                        }] resume];
                    } else {
                        DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                        if (failureBlock != nil) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                failureBlock((APError*)error);
                            });
                        }
                    }
                }
            } else {
                DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                if (failureBlock != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failureBlock((APError*)error);
                    });
                }
            }
        }] resume];
    } else {
        NSMutableDictionary *headerParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [Appacitive getApiKey], APIkeyHeaderKey,
                                             [Appacitive environmentToUse], EnvironmentHeaderKey,
                                             @"application/json", @"Content-Type",
                                             nil];
        [urlRequest setAllHTTPHeaderFields:headerParams];
        
//        //Using delegate methods
//        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//        proxyDownloadSuccessBlock = successBlock;
//        proxyFailureBlock = failureBlock;
//        [connection start];
        
        //Using async class method
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if(!error) {
                BOOL isErrorPresent = (error != nil);
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                NSError *jsonError = nil;
                dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if(jsonError != nil)
                    DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
                NSString *uri = [dictionary objectForKey:@"uri"];
                if(uri) {
                    if (!isErrorPresent) {
                        NSMutableURLRequest *fileDownloadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[dictionary objectForKey:@"uri"]]];
                        [fileDownloadRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
                        [fileDownloadRequest setHTTPMethod:@"GET"];
                        [NSURLConnection sendAsynchronousRequest:fileDownloadRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                            if(!error) {
                                if (successBlock) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        successBlock(data);
                                    });
                                }
                            }
                            else {
                                DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                                if(failureBlock != nil) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        failureBlock((APError*)error);
                                    });
                                }
                            }
                        }];
                    } else {
                        DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                        if (failureBlock != nil) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                failureBlock((APError*)error);
                            });
                        }
                    }
                }
            } else {
                DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
                if (failureBlock != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failureBlock((APError*)error);
                    });
                }
            }
        }];
    }
}

#pragma mark - delete file methods

+ (void) deleteFileWithName:(NSString *)name {
    [self deleteFileWithName:name successHandler:nil failureHandler:nil];
}

+ (void) deleteFileWithName:(NSString *)name successHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://apis.appacitive.com/v1.0/delete/%@",name]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock) {
            successBlock(result);
        }
    } failureHandler:^(APError *error) {
		DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

//
//#pragma mark - NSURLConnection delegate methods
//
//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
//    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
//}
//
//- (void) connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//
//}
//
//- (void) connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//}
//
//
//- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//
//    NSError *jsonError = nil;
//    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
//    if(!jsonError) {
//        APError *error = [APHelperMethods checkForErrorStatus:responseDict];
//        BOOL isErrorPresent = (error != nil);
//        if (!isErrorPresent) {
//            if([[responseDict allKeys ]containsObject:@"url"])
//            {
//                uploadDict = responseDict;
//                NSURL *fileUploadURL = [NSURL URLWithString:[responseDict objectForKey:@"url"]];
//                uploadURL = fileUploadURL;
//                NSMutableURLRequest *fileUploadRequest = [NSMutableURLRequest requestWithURL:fileUploadURL];
//                [fileUploadRequest setHTTPMethod:@"PUT"];
//                NSString *stringContentType = @"application/octet-stream";
//                if (requestContentType) {
//                    stringContentType = requestContentType;
//                }
//                [fileUploadRequest addValue:stringContentType forHTTPHeaderField: @"Content-Type"];
//                NSMutableData *body = requestData;
//                [fileUploadRequest setHTTPBody:body];
//
//                NSURLConnection *uploadConnection = [[NSURLConnection alloc] initWithRequest:fileUploadRequest delegate:self];
//                [uploadConnection start];
//            }
//            else if([[responseDict allKeys ] containsObject:@"uri"])
//            {
//                NSURL *url = [NSURL URLWithString:[responseDict objectForKey:@"uri"]];
//                NSMutableURLRequest *downloadRequest = [NSMutableURLRequest requestWithURL:url];
//                [downloadRequest setHTTPMethod:@"GET"];
//                [downloadRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
//                NSURLConnection *downloadConnection = [[NSURLConnection alloc] initWithRequest:downloadRequest delegate:self];
//                [downloadConnection start];
//                isDownloadData = YES;
//            }
//        } else {
//            DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
//            if(proxyFailureBlock)
//                proxyFailureBlock(error);
//        }
//    } else {
//        if(isDownloadData) {
//            proxyDownloadSuccessBlock(data);
//            isDownloadData = NO;
//        } else {
//            DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@", jsonError);
//            if (proxyFailureBlock != nil) {
//                proxyFailureBlock((APError*) jsonError);
//            }
//        }
//    }
//}
//
//- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    if(error)
//        DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
//    if (proxyFailureBlock != nil) {
//        proxyFailureBlock((APError*) error);
//    }
//}
//
//- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    if(response){
//        DLog(@"\n––––––––––RESPONSE–––––––––––\n%@", response.description);
//        if(response.URL == uploadURL) {
//            proxySuccessBlock(uploadDict);
//        }
//    }
//}

@end
