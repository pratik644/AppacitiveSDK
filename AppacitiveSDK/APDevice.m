//
//  APDevice.m
//  Appacitive-iOS-SDK
//
//  Created by Pratik on 23-12-13.
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "APDevice.h"
#import "APHelperMethods.h"
#import "APNetworking.h"
#import "Appacitive.h"
#import "APConstants.h"
#import "APUser.h"

#define DEVICE_PATH @"v1.0/device/"

@implementation APDevice
static NSDictionary* headerParams;

+ (NSDictionary*)getHeaderParams
{
    headerParams = [NSDictionary dictionaryWithObjectsAndKeys:
                    [Appacitive getApiKey], APIkeyHeaderKey,
                    [Appacitive environmentToUse], EnvironmentHeaderKey,
                    [APUser currentUser].userToken, UserAuthHeaderKey,
                    @"application/json", @"Content-Type",
                    nil];
    return headerParams;
}

#pragma mark - Initialization methods
- (instancetype) init {
    return self = [super initWithTypeName:@"device"];
}

- (instancetype)initWithDeviceToken:(NSString *)deviceToken deviceType:(NSString *)deviceType {
    self = [super initWithTypeName:@"device"];
    if(deviceType != nil)
        self.deviceType = deviceType;
    if(deviceToken != nil)
        self.deviceToken = deviceToken;
    self.type = @"device";
    return self;
}

#pragma mark - Register methods
- (void) registerDevice {
    [self registerDeviceWithSuccessHandler:nil failureHandler:nil];
}

- (void) registerDeviceWithFailureHandler:(APFailureBlock)failureBlock {
    [self registerDeviceWithSuccessHandler:nil failureHandler:failureBlock];
}

- (void) registerDeviceWithSuccessHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    NSString *path = HOST_NAME;
    path = [path stringByAppendingPathComponent:DEVICE_PATH];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/register",path]];
    NSMutableDictionary *bodyDict = [self postParameters];
    [bodyDict addEntriesFromDictionary:[self createRequestBody]];
    NSError *jsonError = nil;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:bodyDict options:kNilOptions error:&jsonError];
    if(jsonError != nil)
        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPBody:requestBody];
    [urlRequest setAllHTTPHeaderFields:[APDevice getHeaderParams]];
    [urlRequest setHTTPMethod:@"PUT"];
    [self updateSnapshot];
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock != nil) {
            [self setPropertyValuesFromDictionary:result];
            successBlock();
        }
    } failureHandler:^(APError *error) {
		DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

#pragma mark - Save methods
- (void) saveObject {
    [self saveObjectWithSuccessHandler:nil failureHandler:nil];
}

- (void) saveObjectWithFailureHandler:(APFailureBlock)failureBlock {
    [self saveObjectWithSuccessHandler:nil failureHandler:failureBlock];
}

- (void) saveObjectWithSuccessHandler:(APResultSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    [self registerDeviceWithSuccessHandler:successBlock failureHandler:failureBlock];
}

#pragma mark - Fetch methods
- (void) fetch {
    [self fetchWithSuccessHandler:nil failureHandler:nil];
}

- (void) fetchWithFailureHandler:(APFailureBlock)failureBlock {
    [self fetchWithSuccessHandler:nil failureHandler:failureBlock];
}

- (void) fetchWithSuccessHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    [self fetchWithPropertiesToFetch:nil successHandler:successBlock failureHandler:failureBlock];
}

- (void) fetchWithPropertiesToFetch:(NSArray*)propertiesToFetch successHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    NSString *path = [DEVICE_PATH stringByAppendingFormat:@"%@", self.objectId];
    
     if(propertiesToFetch != nil || propertiesToFetch.count > 0)
        path = [path stringByAppendingFormat:@"?fields=%@",[propertiesToFetch componentsJoinedByString:@","]];
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [self updateSnapshot];
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        [self setPropertyValuesFromDictionary:result];
        if (successBlock != nil) {
            successBlock();
        }
    } failureHandler:^(APError *error) {
        if(failureBlock != nil) {
            failureBlock(error);
        }
    }];
    
}

#pragma mark - Update methods
- (void) updateObject {
    [self updateObjectWithRevisionNumber:nil successHandler:nil failureHandler:nil];
}

- (void) updateObjectWithFailureHandler:(APFailureBlock)failureBlock {
    [self updateObjectWithRevisionNumber:nil successHandler:nil failureHandler:failureBlock];
}

- (void) updateObjectWithSuccessHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    [self updateObjectWithRevisionNumber:nil successHandler:successBlock failureHandler:failureBlock];
}

- (void) updateObjectWithRevisionNumber:(NSNumber*)revision successHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    NSString *path = [[NSString alloc] init];
    if(revision != nil)
        path = [DEVICE_PATH stringByAppendingFormat:@"%@?revision=%@", self.objectId,revision];
    else
        path = [DEVICE_PATH stringByAppendingFormat:@"%@", self.objectId];
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSError *jsonError = nil;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:[self postParametersUpdate] options:kNilOptions error:&jsonError];
    if(jsonError != nil)
        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
    [urlRequest setHTTPBody:requestBody];
    [self updateSnapshot];
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        [self setPropertyValuesFromDictionary:result];
        if(successBlock != nil) {
            successBlock(self);
        }
    } failureHandler:^(APError *error) {
        
        if(failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

#pragma mark - Delete methods
- (void) deleteObject {
    [self deleteObjectWithSuccessHandler:nil failureHandler:nil];
}

- (void) deleteObjectWithFailureHandler:(APFailureBlock)failureBlock {
    [self deleteObjectWithSuccessHandler:nil failureHandler:failureBlock deleteConnectingConnections:NO];
}

- (void) deleteObjectWithSuccessHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    [self deleteObjectWithSuccessHandler:successBlock failureHandler:failureBlock deleteConnectingConnections:NO];
}

- (void) deleteObjectWithConnectingConnections {
    [self deleteObjectWithSuccessHandler:nil failureHandler:nil deleteConnectingConnections:YES];
}

- (void) deleteObjectWithConnectingConnections:(APFailureBlock)failureBlock {
    [self deleteObjectWithSuccessHandler:nil failureHandler:failureBlock deleteConnectingConnections:YES];
}

- (void) deleteObjectWithConnectingConnectionsSuccessHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    [self deleteObjectWithSuccessHandler:successBlock failureHandler:failureBlock deleteConnectingConnections:YES];
}

- (void) deleteObjectWithSuccessHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock deleteConnectingConnections:(BOOL)deleteConnections {
    NSString *path = [[NSString alloc] init];
    path = [DEVICE_PATH stringByAppendingFormat:@"%@",self.objectId];

    if(deleteConnections == YES) {
        path = [path stringByAppendingString:@"?deleteconnections=true"];
    } else {
        path = [path stringByAppendingString:@"?deleteconnections=false"];
    }
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"DELETE"];
    [urlRequest setAllHTTPHeaderFields:[APDevice getHeaderParams]];
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if(successBlock != nil) {
            successBlock();
        }
    } failureHandler:^(APError *error) {
        if(failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

#pragma mark - Private methods
- (NSMutableDictionary*) createRequestBody {
    NSMutableDictionary *requestBody = [[NSMutableDictionary alloc] init];
    if (self.deviceToken)
        [requestBody setObject:self.deviceToken forKey:@"devicetoken"];
    if(self.deviceType)
        [requestBody setObject:self.deviceType forKey:@"devicetype"];
    if(self.deviceLocation)
        [requestBody setObject:self.deviceLocation forKey:@"location"];
    if(self.channels)
        [requestBody setObject:self.channels forKey:@"channels"];
    if(self.timeZone)
        [requestBody setObject:self.timeZone forKey:@"timezone"];
    if(self.isActive)
        [requestBody setObject:self.isActive forKey:@"isactive"];
    return requestBody;
}

- (void) setPropertyValuesFromDictionary:(NSDictionary*) dictionary {
    
    NSMutableDictionary *object = [[NSMutableDictionary alloc] init];
    
    if([[dictionary allKeys] containsObject:@"device"])
        object = [dictionary[@"device"] mutableCopy];
    
    else object = [dictionary mutableCopy];
    
    _deviceToken = object[@"devicetoken"];
    [object removeObjectForKey:@"devicetoken"];
    self.deviceLocation = object[@"location"];
    [object removeObjectForKey:@"location"];
    self.deviceType = object[@"devicetype"];
    [object removeObjectForKey:@"devicetype"];
    self.isActive = object[@"isactive"];
    [object removeObjectForKey:@"isactive"];
    self.channels = object[@"channels"];
    [object removeObjectForKey:@"channels"];
    self.badge = object[@"badge"];
    [object removeObjectForKey:@"badge"];
    
    self.createdBy = (NSString*) object[@"__createdby"];
    _objectId = object[@"__id"];
    _lastModifiedBy = (NSString*) object[@"__lastmodifiedby"];
    _revision = (NSNumber*) object[@"__revision"];
    self.typeId = object[@"__typeid"];
    _utcDateCreated = [APHelperMethods deserializeJsonDateString:object[@"__utcdatecreated"]];
    _utcLastUpdatedDate = [APHelperMethods deserializeJsonDateString:object[@"__utclastupdateddate"]];
    _attributes = [object[@"__attributes"] mutableCopy];
    self.tags = object[@"__tags"];
    self.type = object[@"__type"];
    _properties = [APHelperMethods arrayOfPropertiesFromJSONResponse:object].mutableCopy;
    
    [self updateSnapshot];
}

- (NSMutableDictionary*) postParameters {
    
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    
    if (self.objectId)
        postParams[@"__id"] = self.objectId;
    if (self.attributes)
        postParams[@"__attributes"] = self.attributes;
    if (self.createdBy)
        postParams[@"__createdby"] = self.createdBy;
    if (self.revision)
        postParams[@"__revision"] = self.revision;
    if (self.type)
        postParams[@"__type"] = self.type;
    if (self.tags)
        postParams[@"__tags"] = self.tags;
    
    if (self.deviceToken)
        postParams[@"devicetoken"] = self.deviceToken;
    if (self.deviceType)
        postParams[@"devicetype"] = self.deviceType;
    if (self.deviceLocation)
        postParams[@"devicelocation"] = self.deviceLocation;
    if (self.channels)
        postParams[@"channels"] = self.channels;
    if (self.isActive)
        postParams[@"isActive"] = self.isActive;
    if (self.timeZone)
        postParams[@"timezone"] = self.timeZone;
    if (self.badge)
        postParams[@"badge"] = self.tags;
    
    for(NSDictionary *prop in self.properties) {
        [prop enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            [postParams setObject:obj forKey:key];
            *stop = YES;
        }];
    }
    return postParams;
}

- (NSMutableDictionary*) postParametersUpdate {
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];

    if (self.attributes && [self.attributes count] > 0)
        for(id key in self.attributes) {
            if(![[[_snapShot objectForKey:@"__attributes"] allKeys] containsObject:key])
                [postParams[@"__attributes"] setObject:[self.attributes objectForKey:key] forKey:key];
            else if([[_snapShot objectForKey:@"__attributes"] objectForKey:key] != [self.attributes objectForKey:key])
                [postParams[@"__attributes"] setObject:[self.attributes objectForKey:key] forKey:key];
        }
    
    for(NSDictionary *prop in self.properties) {
        [prop enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            if(![[_snapShot allKeys] containsObject:key])
                [postParams setObject:obj forKey:key];
            else if([_snapShot objectForKey:key] != [prop objectForKey:key])
                [postParams setObject:obj forKey:key];
            *stop = YES;
        }];
    }
    
    if (self.deviceLocation != nil && self.deviceLocation != [_snapShot objectForKey:@"devicelocation"])
        postParams[@"devicelocation"] = self.deviceLocation;
    if (self.deviceToken != nil && self.deviceToken != [_snapShot objectForKey:@"devicetoken"])
        postParams[@"devicetoken"] = self.deviceToken;
    if (self.deviceType != nil && self.deviceType != [_snapShot objectForKey:@"devicetype"])
        postParams[@"devicetype"] = self.deviceType;
    if(self.channels != nil && [self.channels count] >0  && self.channels != [_snapShot objectForKey:@"channels"])
        postParams[@"channels"] = self.channels;
    if (self.timeZone != nil && self.timeZone != [_snapShot objectForKey:@"timezone"])
        postParams[@"timezone"] = self.timeZone;
    if(self.isActive != nil && self.isActive != [_snapShot objectForKey:@"isactive"])
        postParams[@"isactive"] = self.isActive;
    
    if (self.tagsToAdd != nil && [self.tagsToAdd count] > 0)
        postParams[@"__addtags"] = [self.tagsToAdd allObjects];
    if (self.tagsToRemove !=nil && [self.tagsToRemove count] > 0)
        postParams[@"__removetags"] = [self.tagsToRemove allObjects];
    
    return postParams;
}

- (void) updateSnapshot {
    if(_snapShot == nil)
        _snapShot = [[NSMutableDictionary alloc] init];
    
    if(self.deviceToken)
        _snapShot[@"devicetoken"] = self.deviceToken;
    if(self.deviceType)
        _snapShot[@"devicetype"] = self.deviceType;
    if(self.deviceLocation)
        _snapShot[@"devicelocation"] = self.deviceLocation;
    if(self.channels)
        _snapShot[@"channels"] = self.channels;
    if(self.timeZone)
        _snapShot[@"timezone"] = self.timeZone;
    if(self.isActive)
        _snapShot[@"isactive"] = self.isActive;
    
    if(self.attributes)
        _snapShot[@"__attributes"] = [self.attributes mutableCopy];
    if(self.tags)
        _snapShot[@"__tags"] = [self.tags mutableCopy];
    if(self.properties)
        _snapShot[@"__properties"] = [self.properties mutableCopy];
}

@end

