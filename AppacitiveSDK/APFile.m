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

+ (void) getUploadURLForFileWithName:(NSString *)name urlExpiresAfter:(NSNumber *)minutes contentType:(NSString*)contentType successHandler:(APURLSuccessBlock)successBlock {
    [self getUploadURLForFileWithName:name urlExpiresAfter:minutes contentType:contentType successHandler:successBlock failureHandler:nil];
}

+ (void) getUploadURLForFileWithName:(NSString *)name urlExpiresAfter:(NSNumber *)minutes contentType:(NSString*)contentType successHandler:(APURLSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
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
                                       dispatch_async(dispatch_get_main_queue() , ^{
                                           successBlock(fileUploadURL);
                                       });
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
                        dispatch_async(dispatch_get_main_queue() , ^{
                            successBlock(fileUploadURL);
                        });
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
    }
}

+ (void) uploadFileWithName:(NSString *)name data:(NSData *)fileData urlExpiresAfter:(NSNumber *)minutes {
    [self uploadFileWithName:name data:fileData urlExpiresAfter:minutes contentType:nil successHandler:nil failureHandler:nil];
}

+ (void) uploadFileWithName:(NSString *)name data:(NSData *)fileData urlExpiresAfter:(NSNumber *)minutes contentType:(NSString *)contentType {
    [self uploadFileWithName:name data:fileData urlExpiresAfter:minutes contentType:contentType successHandler:nil failureHandler:nil];
}

+ (void) uploadFileWithName:(NSString *)name data:(NSData *)fileData urlExpiresAfter:(NSNumber *)minutes contentType:(NSString *)contentType successHandler:(APResultSuccessBlock)successBlock {
    [self uploadFileWithName:name data:fileData urlExpiresAfter:minutes contentType:contentType successHandler:successBlock failureHandler:nil];
}

+ (void) uploadFileWithName:(NSString *)name data:(NSData *)fileData urlExpiresAfter:(NSNumber *)minutes contentType:(NSString *)contentType successHandler:(APResultSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
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
    }
}

#pragma mark - Download file methods

+ (void) downloadFileWithName:(NSString*)name urlExpiresAfter:(NSNumber*)minutes successHandler:(APFileDownloadSuccessBlock) successBlock {
    [self downloadFileWithName:name urlExpiresAfter:minutes successHandler:successBlock failureHandler:nil];
}


+ (void) downloadFileWithName:(NSString*)name urlExpiresAfter:(NSNumber*)minutes successHandler:(APFileDownloadSuccessBlock) successBlock failureHandler:(APFailureBlock)failureBlock {
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

+ (void) getDownloadURLForFileWithName:(NSString *)name urlExpiresAfter:(NSNumber*)minutes successHandler:(APURLSuccessBlock)successBlock {
    [self getDownloadURLForFileWithName:name urlExpiresAfter:minutes successHandler:successBlock failureHandler:nil];
}

+ (void) getDownloadURLForFileWithName:(NSString *)name urlExpiresAfter:(NSNumber*)minutes successHandler:(APURLSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
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
                        dispatch_async(dispatch_get_main_queue(), ^{
                            successBlock([NSURL URLWithString:[dictionary objectForKey:@"uri"]]);
                        });
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
                        dispatch_async(dispatch_get_main_queue(), ^{
                            successBlock([NSURL URLWithString:[dictionary objectForKey:@"uri"]]);
                        });
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

@end
