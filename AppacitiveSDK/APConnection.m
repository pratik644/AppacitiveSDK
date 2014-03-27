//
//  APConnection.m
//  Appacitive-iOS-SDK
//
//  Created by Kauserali Hafizji on 03/09/12.
//  Copyright (c) 2012 Appacitive Software Pvt. Ltd.. All rights reserved.
//

#import "APConnection.h"
#import "APObject.h"
#import "APError.h"
#import "APHelperMethods.h"
#import "APNetworking.h"
#import "APGraphNode.h"

@implementation APConnection

#define CONNECTION_PATH @"v1.0/connection/"

#pragma mark - Initialization methods

+ (instancetype) connectionWithRelationType:(NSString*)relationType {
    return [[APConnection alloc] initWithRelationType:relationType];
}

- (instancetype) initWithRelationType:(NSString*)relationType {
    self = [super init];
    if(self) {
        self.relationType = relationType;
    }
    return self;
}

#pragma mark - Create connection methods

- (void) create {
    [self createConnectionWithSuccessHandler:nil failureHandler:nil];
}

- (void) createConnectionWithFailureHandler:(APFailureBlock)failureBlock {
    [self createConnectionWithSuccessHandler:nil failureHandler:nil];
}

- (void) createConnectionWithSuccessHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    NSString *path = [CONNECTION_PATH stringByAppendingString:self.relationType];
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSError *jsonError = nil;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:[self parameters] options:kNilOptions error:&jsonError];
    if(jsonError != nil)
        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
    [urlRequest setHTTPBody:requestBody];
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

- (void) createConnectionWithObjectA:(APObject*)objectA objectB:(APObject*)objectB {
    [self createConnectionWithObjectA:objectA objectB:objectB successHandler:nil failureHandler:nil];
}

- (void) createConnectionWithObjectA:(APObject*)objectA objectB:(APObject*)objectB failureHandler:(APFailureBlock)failureBlock {
    [self createConnectionWithObjectA:objectA objectB:objectB successHandler:nil failureHandler:failureBlock];
}

- (void) createConnectionWithObjectA:(APObject*)objectA objectB:(APObject*)objectB successHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    if(objectA.objectId != nil)
        self.objectAId = objectA.objectId;
    else
        self.objectA = objectA;
    
    if(objectB.objectId != nil)
        self.objectBId = objectB.objectId;
    else
        self.objectB = objectB;
        
    self.labelA = objectA.type;
    self.labelB = objectB.type;
    
    [self createConnectionWithSuccessHandler:successBlock failureHandler:failureBlock];
}

- (void) createConnectionWithObjectA:(APObject*)objectA objectB:(APObject*)objectB labelA:(NSString*)labelA labelB:(NSString*)labelB {
    [self createConnectionWithObjectA:objectA objectB:objectB labelA:labelA labelB:labelB successHandler:nil failureHandler:nil];
}

- (void) createConnectionWithObjectA:(APObject*)objectA objectB:(APObject*)objectB labelA:(NSString*)labelA labelB:(NSString*)labelB failureHandler:(APFailureBlock)failureBlock {
    [self createConnectionWithObjectA:objectA objectB:objectB labelA:labelA labelB:labelB successHandler:nil failureHandler:failureBlock];
}

- (void) createConnectionWithObjectA:(APObject*)objectA objectB:(APObject*)objectB labelA:(NSString*)labelA labelB:(NSString*)labelB successHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    NSString *path = [CONNECTION_PATH stringByAppendingString:self.relationType];
    
    if(objectA.objectId != nil)
        self.objectAId = objectA.objectId;
    else
        self.objectA = objectA;
    
    if(objectB.objectId != nil)
        self.objectBId = objectB.objectId;
    else
        self.objectB = objectB;
    
    self.labelA = labelA;
    self.labelB = labelB;
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSError *jsonError = nil;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:[self parameters] options:kNilOptions error:&jsonError];
    if(jsonError != nil)
        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
    [urlRequest setHTTPBody:requestBody];
    [urlRequest setHTTPMethod:@"PUT"];
    [self updateSnapshot];
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock != nil) {
            [self setPropertyValuesFromDictionary:result];
            if([[result[@"connection"][@"__endpointa"] allKeys] containsObject:@"object"]) {
                if([result[@"connection"][@"__endpointa"][@"label"] isEqualToString:labelA]) {
                    [objectA setPropertyValuesFromDictionary:result[@"connection"][@"__endpointa"][@"object"]];
                }
                else if([result[@"connection"][@"__endpointa"][@"label"] isEqualToString:labelB]) {
                    [objectB setPropertyValuesFromDictionary:result[@"connection"][@"__endpointa"][@"object"]];
                }
            }
            if([[result[@"connection"][@"__endpointb"] allKeys] containsObject:@"object"]) {
                if([result[@"connection"][@"__endpointb"][@"label"] isEqualToString:labelA]) {
                    [objectA setPropertyValuesFromDictionary:result[@"connection"][@"__endpointb"][@"object"]];
                }
                else if([result[@"connection"][@"__endpointa"][@"label"] isEqualToString:labelB]) {
                    [objectB setPropertyValuesFromDictionary:result[@"connection"][@"__endpointa"][@"object"]];
                }
            }
            successBlock();
        }
    } failureHandler:^(APError *error) {
        DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

- (void) createConnectionWithObjectAId:(NSString *)objectAId objectBId:(NSString *)objectBId labelA:(NSString *)labelA labelB:(NSString *)labelB {
    [self createConnectionWithObjectAId:objectAId objectBId:objectBId labelA:labelA labelB:labelB successHandler:nil failureHandler:nil];
}

- (void) createConnectionWithObjectAId:(NSString *)objectAId objectBId:(NSString *)objectBId labelA:(NSString *)labelA labelB:(NSString *)labelB failureHandler:(APFailureBlock)failureBlock {
    [self createConnectionWithObjectAId:objectAId objectBId:objectBId labelA:labelA labelB:labelB successHandler:nil failureHandler:failureBlock];
}

- (void) createConnectionWithObjectAId:(NSString *)objectAId objectBId:(NSString *)objectBId labelA:(NSString *)labelA labelB:(NSString *)labelB successHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    NSString *path = [CONNECTION_PATH stringByAppendingString:self.relationType];
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSError *jsonError = nil;
    self.objectAId = objectAId;
    self.objectBId = objectBId;
    self.labelA = labelA;
    self.labelB = labelB;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:[self parameters] options:kNilOptions error:&jsonError];
    if(jsonError != nil)
        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
    [urlRequest setHTTPBody:requestBody];
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

- (void) createConnectionWithObjectA:(APObject*)objectA objectBId:(NSString*)objectBId labelA:(NSString*)labelA labelB:(NSString*)labelB {
    [self createConnectionWithObjectA:objectA objectBId:objectBId labelA:labelA labelB:labelB successHandler:nil failureHandler:nil];
}

- (void) createConnectionWithObjectA:(APObject *)objectA objectBId:(NSString *)objectBId labelA:(NSString *)labelA labelB:(NSString *)labelB failureHandler:(APFailureBlock)failureBlock {
    [self createConnectionWithObjectA:objectA objectBId:objectBId labelA:labelA labelB:labelB successHandler:nil failureHandler:failureBlock];
}

- (void) createConnectionWithObjectA:(APObject *)objectA objectBId:(NSString *)objectBId labelA:(NSString *)labelA labelB:(NSString *)labelB successHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    __block NSString *path = [CONNECTION_PATH stringByAppendingString:self.relationType];
    
    self.objectA = objectA;
    self.objectBId = objectBId;
    self.labelA = labelA;
    self.labelB = labelB;
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSError *jsonError = nil;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:[self parameters] options:kNilOptions error:&jsonError];
    if(jsonError != nil)
        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
    [urlRequest setHTTPBody:requestBody];
    [urlRequest setHTTPMethod:@"PUT"];
    [self updateSnapshot];
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock != nil) {
            [self setPropertyValuesFromDictionary:result];
            if([[result[@"connection"][@"__endpointa"] allKeys] containsObject:@"object"])
                if([result[@"connection"][@"__endpointa"][@"label"] isEqualToString:labelA])
                    [objectA setPropertyValuesFromDictionary:result[@"connection"][@"__endpointa"][@"object"]];
            if([[result[@"connection"][@"__endpointb"] allKeys] containsObject:@"object"])
                 if([result[@"connection"][@"__endpointb"][@"label"] isEqualToString:labelA])
                    [objectA setPropertyValuesFromDictionary:result[@"connection"][@"__endpointb"][@"object"]];
            
            successBlock();
        }
    } failureHandler:^(APError *error) {
        DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

- (void) createConnectionWithObjectAId:(NSString*)objectAId objectB:(APObject*)objectB labelA:(NSString*)labelA labelB:(NSString*)labelB {
    [self createConnectionWithObjectAId:objectAId objectB:objectB labelA:labelA labelB:labelB successHandler:nil failureHandler:nil];
}

- (void) createConnectionWithObjectAId:(NSString*)objectAId objectB:(APObject*)objectB labelA:(NSString*)labelA labelB:(NSString*)labelB failureHandler:(APFailureBlock)failureBlock {
    [self createConnectionWithObjectAId:objectAId objectB:objectB labelA:labelA labelB:labelB successHandler:nil failureHandler:failureBlock];
}

- (void) createConnectionWithObjectAId:(NSString*)objectAId objectB:(APObject*)objectB labelA:(NSString*)labelA labelB:(NSString*)labelB successHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    __block NSString *path = [CONNECTION_PATH stringByAppendingString:self.relationType];
    
    self.objectAId = objectAId;
    self.objectB = objectB;
    self.labelA = labelA;
    self.labelB = labelB;
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSError *jsonError = nil;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:[self parameters] options:kNilOptions error:&jsonError];
    if(jsonError != nil)
        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
    [urlRequest setHTTPBody:requestBody];
    [urlRequest setHTTPMethod:@"PUT"];
    [self updateSnapshot];
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock != nil) {
            [self setPropertyValuesFromDictionary:result];
            
            if([[result[@"connection"][@"__endpointa"] allKeys] containsObject:@"object"])
                if([result[@"connection"][@"__endpointa"][@"label"] isEqualToString:labelB])
                    [objectB setPropertyValuesFromDictionary:result[@"connection"][@"__endpointa"][@"object"]];
            if([[result[@"connection"][@"__endpointb"] allKeys] containsObject:@"object"])
                if([result[@"connection"][@"__endpointb"][@"label"] isEqualToString:labelB])
                    [objectB setPropertyValuesFromDictionary:result[@"connection"][@"__endpointb"][@"object"]];
            
            successBlock();
        }
    } failureHandler:^(APError *error) {
        DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

#pragma mark - Update connection methods

- (void) updateConnection {
    [self updateConnectionWithRevisionNumber:nil successHandler:nil failureHandler:nil];
}

- (void) updateConnectionWithFailureHandler:(APFailureBlock)failureBlock {
    [self updateConnectionWithRevisionNumber:nil successHandler:nil failureHandler:failureBlock];
}

- (void) updateConnectionWithSuccessHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    [self updateConnectionWithRevisionNumber:nil successHandler:successBlock failureHandler:failureBlock];
}

- (void) updateConnectionWithRevisionNumber:(NSNumber*)revision successHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    NSString *path = [[NSString alloc] init];
    if(revision != nil)
        path = [CONNECTION_PATH stringByAppendingFormat:@"%@/%@?revision=%@", self.relationType, self.objectId.description,revision];
    else
        path = [CONNECTION_PATH stringByAppendingFormat:@"%@/%@", self.relationType, self.objectId.description];
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSError *jsonError = nil;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:[self postParamertersUpdate] options:kNilOptions error:&jsonError];
    if(jsonError != nil)
        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
    [urlRequest setHTTPBody:requestBody];
    [urlRequest setHTTPMethod:@"POST"];
    
    [self updateSnapshot];
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        [self setPropertyValuesFromDictionary:result];
        if (successBlock != nil) {
            successBlock();
        }
    } failureHandler:^(APError *error) {
		DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

#pragma mark - Fetch connection methods

- (void) fetchConnection {
    [self fetchConnectionWithSuccessHandler:nil failureHandler:nil];
}

- (void) fetchConnectionWithFailureHandler:(APFailureBlock)failureBlock {
    [self fetchConnectionWithSuccessHandler:nil failureHandler:failureBlock];
}

- (void) fetchConnectionWithSuccessHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    [self fetchConnectionWithPropertiesToFetch:nil successHandler:successBlock failureHandler:failureBlock];
}

- (void) fetchConnectionWithPropertiesToFetch:(NSArray*)propertiesToFetch successHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    NSString *path = [CONNECTION_PATH stringByAppendingFormat:@"%@/%@", self.relationType, self.objectId.description];
    
     if(propertiesToFetch != nil || propertiesToFetch.count > 0)
        path = [path stringByAppendingFormat:@"?fields=%@",[propertiesToFetch componentsJoinedByString:@","]];
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    
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

#pragma mark - Delete methods

- (void) deleteConnection {
    [self deleteConnectionWithSuccessHandler:nil failureHandler:nil];
}

- (void) deleteConnectionWithFailureHandler:(APFailureBlock)failureBlock {
    [self deleteConnectionWithSuccessHandler:nil failureHandler:failureBlock];
}

- (void) deleteConnectionWithSuccessHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    NSString *path = [CONNECTION_PATH stringByAppendingFormat:@"%@/%@", self.relationType, self.objectId];
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"DELETE"];
    
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock != nil) {
            successBlock();
        }
    } failureHandler:^(APError *error) {
		DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

#pragma mark - Add properties method

- (void) addPropertyWithKey:(NSString*) keyName value:(id) object {
    if (!self.properties) {
        _properties = [NSMutableArray array];
    }
    [_properties addObject:@{keyName: object}];
}

#pragma mark - Add attributes method

- (void) addAttributeWithKey:(NSString*) keyName value:(id) object {
    if (!self.attributes) {
        _attributes = [NSMutableDictionary dictionary];
    }
    [_attributes setObject:object forKey:keyName];
}

- (void) updateAttributeWithKey:(NSString*) keyName value:(id) object {
    [_attributes setObject:object forKey:keyName];
}

- (void) removeAttributeWithKey:(NSString*) keyName {
    [_attributes setObject:[NSNull null] forKey:keyName];
}

#pragma mark - Update properties method

- (void) updatePropertyWithKey:(NSString*) keyName value:(id) object {
    [self.properties enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dict = (NSMutableDictionary *)obj;
        if ([dict objectForKey:keyName] != nil) {
            [dict setObject:object forKey:keyName];
            *stop = YES;
        }
    }];
}

#pragma mark - Delete property

- (void) removePropertyWithKey:(NSString*) keyName {
    [self.properties enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dict = (NSMutableDictionary *)obj;
        if ([dict objectForKey:keyName] != nil) {
            [dict setObject:[NSNull null] forKey:keyName];
            *stop = YES;
        }
    }];
}

#pragma mark - Retrieve property

- (instancetype) getPropertyWithKey:(NSString*) keyName {
    __block id property;
    [self.properties enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dict = (NSMutableDictionary *)obj;
        if ([dict objectForKey:keyName] != nil) {
            property = [dict objectForKey:keyName];
            *stop = YES;
        }
    }];
    return property;
}

#pragma mark - Methods to add/remove tags

- (void) addTag:(NSString*)tag
{
    if(tag != nil)
    {
        [self.tagsToAdd addObject:[tag lowercaseString]];
    }
}

- (void) removeTag:(NSString*)tag
{
    if(tag != nil)
    {
        [self.tagsToRemove addObject:[tag lowercaseString]];
        [self.tagsToAdd minusSet:self.tagsToRemove];
    }
}

#pragma mark - Private methods


- (void) setPropertyValuesFromDictionary:(NSDictionary*) dictionary {
    NSDictionary *connection = [[NSDictionary alloc] init];
    if([[dictionary allKeys] containsObject:@"connection"])
        connection = dictionary[@"connection"];
    else
        connection = dictionary;
    _objectAId = (NSString*)connection[@"__endpointa"][@"objectid"];
    _objectBId = (NSString*)connection[@"__endpointb"][@"objectid"];
    _createdBy = (NSString*) connection[@"__createdby"];
    _objectId = (NSString*) connection[@"__id"];
    _labelA = (NSString*) connection[@"__endpointa"][@"label"];
    _labelB = (NSString*) connection[@"__endpointb"][@"label"];
    _typeA = (NSString*) connection[@"__endpointa"][@"type"];
    _typeB = (NSString*) connection[@"__endpointb"][@"type"];
    _lastModifiedBy = (NSString*) connection[@"__lastmodifiedby"];
    _relationId = (NSString*) connection[@"__relationid"];
    _relationType = (NSString*) connection[@"__relationtype"];
    _revision = (NSNumber*) connection[@"__revision"];
    _tags = connection[@"__tags"];
    _utcDateCreated = [APHelperMethods deserializeJsonDateString:connection[@"__utcdatecreated"]];
    _utcLastModifiedDate = [APHelperMethods deserializeJsonDateString:connection[@"__utclastupdateddate"]];
    
    _attributes = [connection[@"__attributes"] mutableCopy];
    _properties = [APHelperMethods arrayOfPropertiesFromJSONResponse:connection].mutableCopy;
    
    [self updateSnapshot];
}

- (NSMutableDictionary*) parameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (self.objectAId) {
        if (!parameters[@"__endpointa"]) {
            parameters[@"__endpointa"] = [NSMutableDictionary dictionary];
        }
        parameters[@"__endpointa"][@"objectid"] = [NSString stringWithFormat:@"%@", self.objectAId];
    }
    
    if (self.objectBId) {
        if (!parameters[@"__endpointb"]) {
            parameters[@"__endpointb"] = [NSMutableDictionary dictionary];
        }
        parameters[@"__endpointb"][@"objectid"] = [NSString stringWithFormat:@"%@", self.objectBId];
    }
    
    if (self.objectA) {
        if (!parameters[@"__endpointa"]) {
            parameters[@"__endpointa"] = [NSMutableDictionary dictionary];
        }
        parameters[@"__endpointa"][@"object"] = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.objectA.type,@"__type", nil];
        for(NSDictionary* dict in self.objectA.properties) {
            [parameters[@"__endpointa"][@"object"] addEntriesFromDictionary:dict];
         }
    }
    
    if (self.objectB) {
        if (!parameters[@"__endpointb"]) {
            parameters[@"__endpointb"] = [NSMutableDictionary dictionary];
        }
        parameters[@"__endpointb"][@"object"] = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.objectB.type,@"__type", nil];
        for(NSDictionary* dict in self.objectB.properties) {
            [parameters[@"__endpointb"][@"object"] addEntriesFromDictionary:dict];
        }
    }
    
    if (self.attributes)
        parameters[@"__attributes"] = self.attributes;
    
    if (self.createdBy)
        parameters[@"__createdby"] = self.createdBy;
    
    for(NSDictionary *prop in self.properties) {
        [prop enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            [parameters setObject:obj forKey:key];
            *stop = YES;
        }];
    }
    
    if (self.labelA) {
        if (!parameters[@"__endpointa"]) {
            parameters[@"__endpointa"] = [NSMutableDictionary dictionary];
        }
        parameters[@"__endpointa"][@"label"] = self.labelA;
    }
    
    if (self.labelB) {
        if (!parameters[@"__endpointb"]) {
            parameters[@"__endpointb"] = [NSMutableDictionary dictionary];
        }
        parameters[@"__endpointb"][@"label"] = self.labelB;
    }
    
    if (self.typeA) {
        if (!parameters[@"__endpointa"]) {
            parameters[@"__endpointa"] = [NSMutableDictionary dictionary];
        }
        parameters[@"__endpointa"][@"type"] = self.typeA;
    }
    
    if (self.typeB) {
        if (!parameters[@"__endpointb"]) {
            parameters[@"__endpointb"] = [NSMutableDictionary dictionary];
        }
        parameters[@"__endpointb"][@"type"] = self.typeB;
    }
    
    if (self.relationType)
        parameters[@"__relationtype"] = self.relationType;
    
    if (self.revision)
        parameters[@"__revision"] = self.revision;
    
    if (self.tags)
        parameters[@"__tags"] = self.tags;
    return parameters;
}

- (NSMutableDictionary*) postParamertersUpdate {
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
    
    if (self.tagsToAdd)
        postParams[@"addtags"] = [self.tagsToAdd allObjects];
    
    if (self.tagsToRemove)
        postParams[@"removetags"] = [self.tagsToRemove allObjects];
    
    return postParams;
}

- (void) updateSnapshot {
    if(_snapShot == nil)
        _snapShot = [[NSMutableDictionary alloc] init];
    
    if(self.attributes)
        _snapShot[@"__attributes"] = [self.attributes mutableCopy];
    if(self.tags)
        _snapShot[@"__tags"] = [self.tags mutableCopy];
    if(self.properties)
        _snapShot[@"__properties"] = [self.properties mutableCopy];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"ObjectAId:%@, ObjectBId:%@, Attributes:%@, CreatedBy:%@, Connection Id:%@, LabelA:%@, LabelB:%@, LastUpdatedBy:%@, Properties:%@, RelationId:%@, Relation Type:%@, Revision:%d, Tags:%@, UtcDateCreated:%@, UtcLastUpdatedDate:%@", self.objectAId, self.objectBId, self.attributes, self.createdBy, self.objectId, self.labelA, self.labelB, self.lastModifiedBy, self.properties, self.relationId, self.relationType, [self.revision intValue], self.tags ,self.utcDateCreated, self.utcLastModifiedDate];
}
@end

@implementation APConnections

#define CONNECTION_PATH @"v1.0/connection/"

#pragma mark - Search methods

+ (void) searchAllConnectionsWithRelationType:(NSString*)relationType successHandler:(APPagedResultSuccessBlock)successBlock {
    [APConnections searchAllConnectionsWithRelationType:relationType successHandler:successBlock failureHandler:nil];
}

+ (void) searchAllConnectionsWithRelationType:(NSString*)relationType successHandler:(APPagedResultSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    [APConnections searchAllConnectionsWithRelationType:relationType withQuery:nil successHandler:successBlock failureHandler:failureBlock];
}

+ (void) searchAllConnectionsWithRelationType:(NSString*)relationType byObjectId:(NSString*)objectId withLabel:(NSString*)label withQuery:(NSString*)query successHandler:(APPagedResultSuccessBlock)successBlock {
    if(query == nil || ![[query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [self searchAllConnectionsWithRelationType:relationType withQuery:[NSString stringWithFormat:@"?objectid=%@&label=%@",objectId,label] successHandler:successBlock failureHandler:nil];
    } else {
        [self searchAllConnectionsWithRelationType:relationType withQuery:[NSString stringWithFormat:@"%@&objectid=%@&label=%@", query, objectId, label] successHandler:successBlock failureHandler:nil];
    }
}

+ (void) searchAllConnectionsWithRelationType:(NSString*)relationType byObjectId:(NSString*)objectId withLabel:(NSString*)label withQuery:(NSString*)query successHandler:(APPagedResultSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    if(query == nil || ![[query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [self searchAllConnectionsWithRelationType:relationType withQuery:[NSString stringWithFormat:@"?objectid=%@&label=%@",objectId,label] successHandler:successBlock failureHandler:failureBlock];
    } else {
        [self searchAllConnectionsWithRelationType:relationType withQuery:[NSString stringWithFormat:@"%@&objectid=%@&label=%@", query, objectId, label] successHandler:successBlock failureHandler:failureBlock];
    }
}

+ (void) searchAllConnectionsWithRelationType:(NSString*)relationType withQuery:(NSString*)query successHandler:(APPagedResultSuccessBlock)successBlock {
    [APConnections searchAllConnectionsWithRelationType:relationType withQuery:query successHandler:successBlock failureHandler:nil];
}

+ (void) searchAllConnectionsWithRelationType:(NSString*)relationType withQuery:(NSString*)query successHandler:(APPagedResultSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    NSString *path = [CONNECTION_PATH stringByAppendingFormat:@"%@/find/all", relationType];
    
    if(query != nil && ![[query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
        path = [path stringByAppendingString:query];
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock != nil) {
            NSMutableArray *objects = [[NSMutableArray alloc] init];
            for (int i=0; i< [[result objectForKey:@"connections"] count]; i++) {
                APConnection *connection = [[APConnection alloc] init];
                [connection setPropertyValuesFromDictionary:[[result objectForKey:@"connections"] objectAtIndex:i]];
                [objects addObject:connection];
            }
            successBlock(objects,[[[result objectForKey:@"paginginfo"] valueForKey:@"pagenumber"] integerValue], [[[result objectForKey:@"paginginfo"] valueForKey:@"pagesize"] integerValue], [[[result objectForKey:@"paginginfo"] valueForKey:@"totalrecords"] integerValue]);
        }
    } failureHandler:^(APError *error) {
		DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

+ (void) searchAllConnectionsWithRelationType:(NSString*)relationType fromObjectId:(NSString *)objectAId toObjectId:(NSString *)objectBId labelB:(NSString*)labelB withQuery:(NSString*)query successHandler:(APPagedResultSuccessBlock)successBlock {
    [APConnections searchAllConnectionsWithRelationType:relationType fromObjectId:objectAId toObjectId:objectBId labelB:labelB withQuery:query successHandler:successBlock failureHandler:nil];
}

+ (void) searchAllConnectionsWithRelationType:(NSString*)relationType fromObjectId:(NSString *)objectAId toObjectId:(NSString *)objectBId labelB:(NSString*)labelB withQuery:(NSString*)query successHandler:(APPagedResultSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    NSString *path = [CONNECTION_PATH stringByAppendingString:[NSString stringWithFormat:@"%@/find/%@/%@",relationType,objectAId,objectBId]];
    
    if(labelB!=nil) {
        if(query!=nil) {
            path = [path stringByAppendingFormat:@"&label=%@",[query stringByAppendingString:labelB]];
        } else {
            path = [path stringByAppendingFormat:@"?label=%@",labelB];
        }
    } else {
        if(query!=nil) {
            path = [path stringByAppendingString:query];
        }
    }
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock != nil) {
            NSMutableArray *objects = [[NSMutableArray alloc] init];
            for (int i=0; i< [[result objectForKey:@"connections"] count]; i++) {
                APConnection *connection = [[APConnection alloc] init];
                [connection setPropertyValuesFromDictionary:[[result objectForKey:@"connections"] objectAtIndex:i]];
                [objects addObject:connection];
            }
            successBlock(objects,[[[result objectForKey:@"paginginfo"] valueForKey:@"pagenumber"] integerValue], [[[result objectForKey:@"paginginfo"] valueForKey:@"pagesize"] integerValue], [[[result objectForKey:@"paginginfo"] valueForKey:@"totalrecords"] integerValue]);
        }
    } failureHandler:^(APError *error) {
		DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

+ (void) searchAllConnectionsFromObjectId:(NSString *)objectAId toObjectId:(NSString *)objectBId withQuery:(NSString*)query successHandler:(APPagedResultSuccessBlock)successBlock {
    [APConnections searchAllConnectionsFromObjectId:objectAId toObjectId:objectBId withQuery:query successHandler:successBlock failureHandler:nil];
}

+ (void) searchAllConnectionsFromObjectId:(NSString *)objectAId toObjectId:(NSString *)objectBId withQuery:(NSString*)query successHandler:(APPagedResultSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    NSString *path = [CONNECTION_PATH stringByAppendingString:[NSString stringWithFormat:@"find/%@/%@",objectAId,objectBId]];
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock != nil) {
            NSMutableArray *objects = [[NSMutableArray alloc] init];
            for (int i=0; i< [[result objectForKey:@"connections"] count]; i++) {
                APConnection *connection = [[APConnection alloc] init];
                [connection setPropertyValuesFromDictionary:[[result objectForKey:@"connections"] objectAtIndex:i]];
                [objects addObject:connection];
            }
            successBlock(objects,[[[result objectForKey:@"paginginfo"] valueForKey:@"pagenumber"] integerValue], [[[result objectForKey:@"paginginfo"] valueForKey:@"pagesize"] integerValue], [[[result objectForKey:@"paginginfo"] valueForKey:@"totalrecords"] integerValue]);
        }
    } failureHandler:^(APError *error) {
		DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

+ (void) searchAllConnectionsFromObjectId:(NSString *)objectId toObjectIds:(NSArray *)objectIds withQuery:(NSString*)query successHandler:(APPagedResultSuccessBlock)successBlock {
    [APConnections searchAllConnectionsFromObjectId:objectId toObjectIds:objectIds withQuery:query successHandler:successBlock failureHandler:nil];
}

+ (void) searchAllConnectionsFromObjectId:(NSString *)objectId toObjectIds:(NSArray *)objectIds withQuery:(NSString*)query successHandler:(APPagedResultSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    NSString *path = [CONNECTION_PATH stringByAppendingString:@"interconnects"];
    
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] init];
    postParams[@"object1id"] = [NSString stringWithFormat:@"%@",objectId];
    postParams[@"object2ids"] = objectIds;
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSError *jsonError = nil;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:postParams options:kNilOptions error:&jsonError];
    if(jsonError != nil)
        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
    [urlRequest setHTTPBody:requestBody];
    [urlRequest setHTTPMethod:@"POST"];
    
    
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock != nil) {
            NSMutableArray *objects = [[NSMutableArray alloc] init];
            for (int i=0; i< [[result objectForKey:@"connections"] count]; i++) {
                APConnection *connection = [[APConnection alloc] init];
                [connection setPropertyValuesFromDictionary:[[result objectForKey:@"connections"] objectAtIndex:i]];
                [objects addObject:connection];
            }
            successBlock(objects,[[[result objectForKey:@"paginginfo"] valueForKey:@"pagenumber"] integerValue], [[[result objectForKey:@"paginginfo"] valueForKey:@"pagesize"] integerValue], [[[result objectForKey:@"paginginfo"] valueForKey:@"totalrecords"] integerValue]);
        }
    } failureHandler:^(APError *error) {
		DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

#pragma mark - Fetch methods

+ (void) fetchConnectionWithRelationType:(NSString*)relationType connectionObjectId:(NSString*)objectId successHandler:(APObjectsSuccessBlock)successBlock {
    [APConnections fetchConnectionsWithRelationType:relationType connectionObjectIds:@[objectId] successHandler:successBlock failureHandler:nil];
}

+ (void) fetchConnectionWithRelationType:(NSString*)relationType connectionObjectId:(NSString*)objectId successHandler:(APObjectsSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    [APConnections fetchConnectionsWithRelationType:relationType connectionObjectIds:@[objectId] successHandler:successBlock failureHandler:failureBlock];
}

+ (void) fetchConnectionWithRelationType:(NSString*)relationType connectionObjectId:(NSString*)objectId propertiesToFetch:(NSArray*)propertiesToFetch successHandler:(APObjectsSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    [APConnections fetchConnectionsWithRelationType:relationType connectionObjectIds:@[objectId] propertiesToFetch:propertiesToFetch successHandler:successBlock failureHandler:failureBlock];
}

+ (void) fetchConnectionsWithRelationType:(NSString*)relationType connectionObjectIds:(NSArray*)objectIds successHandler:(APObjectsSuccessBlock)successBlock {
    [APConnections fetchConnectionsWithRelationType:relationType connectionObjectIds:objectIds successHandler:successBlock failureHandler:nil];
}

+ (void) fetchConnectionsWithRelationType:(NSString*)relationType connectionObjectIds:(NSArray*)objectIds successHandler:(APObjectsSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    [APConnections fetchConnectionsWithRelationType:relationType connectionObjectIds:objectIds propertiesToFetch:nil successHandler:successBlock failureHandler:failureBlock];
}

+ (void) fetchConnectionsWithRelationType:(NSString*)relationType connectionObjectIds:(NSArray*)objectIds propertiesToFetch:(NSArray*)propertiesToFetch successHandler:(APObjectsSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    __block NSString *path = [CONNECTION_PATH stringByAppendingFormat:@"%@/multiget/", relationType];
    
    [objectIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *string = (NSString*) obj;
        path = [path stringByAppendingFormat:@"%@", string];
        if (idx != objectIds.count - 1) {
            path = [path stringByAppendingString:@","];
        }
    }];
    
     if(propertiesToFetch != nil || propertiesToFetch.count > 0)
        path = [path stringByAppendingFormat:@"?fields=%@",[propertiesToFetch componentsJoinedByString:@","]];
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock != nil) {
            NSMutableArray *objects = [[NSMutableArray alloc] init];
            for (int i=0; i< [[result objectForKey:@"connections"] count]; i++) {
                APConnection *connection = [[APConnection alloc] init];
                [connection setPropertyValuesFromDictionary:[[result objectForKey:@"connections"] objectAtIndex:i]];
                [objects addObject:connection];
            }
            successBlock(objects);
        }
    } failureHandler:^(APError *error) {
		DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

+ (void) fetchObjectsConnectedToObjectOfType:(NSString*)objectType withObjectId:(NSString*)objectId withRelationType:(NSString*)relationType fetchConnections:(BOOL)fetchConnections successHandler:(APObjectsSuccessBlock)successBlock {
    [self fetchObjectsConnectedToObjectOfType:objectType withObjectId:objectId withRelationType:relationType fetchConnections:fetchConnections successHandler:successBlock failureHandler:nil];
}

+ (void) fetchObjectsConnectedToObjectOfType:(NSString*)objectType withObjectId:(NSString*)objectId withRelationType:(NSString*)relationType fetchConnections:(BOOL)fetchConnections successHandler:(APObjectsSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    [self fetchObjectsConnectedToObjectOfType:objectType withObjectId:objectId withRelationType:relationType fetchConnections:fetchConnections propertiesToFetch:nil successHandler:successBlock failureHandler:nil];
}

+ (void) fetchObjectsConnectedToObjectOfType:(NSString*)objectType withObjectId:(NSString*)objectId withRelationType:(NSString*)relationType fetchConnections:(BOOL)fetchConnections propertiesToFetch:(NSArray*)propertiesToFetch successHandler:(APObjectsSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    NSString *path = [[NSString  alloc] init];
    
    if(fetchConnections == YES)
        path = [CONNECTION_PATH stringByAppendingFormat:@"%@/%@/%@/find?returnedge=true", relationType, objectType, objectId];
    else
        path = [CONNECTION_PATH stringByAppendingFormat:@"%@/%@/%@/find?returnedge=false", relationType, objectType, objectId];
    
     if(propertiesToFetch != nil || propertiesToFetch.count > 0)
        path = [path stringByAppendingFormat:@"&fields=%@",[propertiesToFetch componentsJoinedByString:@","]];
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock != nil) {
            NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            filePath = [filePath stringByAppendingPathComponent:@"typeMapping.plist"];
            NSDictionary *typeMapping = [NSDictionary dictionaryWithContentsOfFile:filePath];
            NSMutableArray *nodes = [[NSMutableArray alloc] init];
            if ([result valueForKey:@"nodes"]!= [NSNull null]) {
                for (int i=0; i<[[result valueForKey:@"nodes"] count]; i++) {
                    APGraphNode *node = [[APGraphNode alloc] init];
                    NSDictionary *nodeDict = [[result valueForKey:@"nodes"] objectAtIndex:i];
                    if([[nodeDict allKeys] containsObject:@"__type"]) {
                        APObject *object = [[APObject alloc] init];
                        if([typeMapping objectForKey:[nodeDict valueForKey:@"__type"]] != nil)
                            object = [[NSClassFromString([typeMapping objectForKey:[nodeDict valueForKey:@"__type"]]) alloc] init];
                        [object setPropertyValuesFromDictionary:nodeDict];
                        node.object = object;
                    }
                    if([[nodeDict allKeys] containsObject:@"__edge"]) {
                        NSDictionary *edge = [nodeDict objectForKey:@"__edge"];
                        NSMutableDictionary *endPointA = [[NSMutableDictionary alloc] init];
                        [endPointA setObject:[nodeDict objectForKey:@"__id"] forKey:@"objectid"];
                        [endPointA setObject:[edge objectForKey:@"__label"] forKey:@"type"];
                        [endPointA setObject:[edge objectForKey:@"__label"] forKey:@"label"];
                        NSMutableDictionary *endPointB = [[NSMutableDictionary alloc] init];
                        [endPointB setObject:objectId forKey:@"objectid"];
                        [endPointB setObject:objectType forKey:@"type"];
                        [endPointB setObject:objectType forKey:@"label"];
                        NSMutableDictionary *connectionDict = [[NSMutableDictionary alloc] init];
                        [connectionDict setObject:[edge objectForKey:@"__id"] forKey:@"__id"];
                        [connectionDict setObject:[edge objectForKey:@"__relationtype"] forKey:@"__relationtype"];
                        [connectionDict setObject:[edge objectForKey:@"__relationid"] forKey:@"__relationid"];
                        [connectionDict setObject:endPointA forKey:@"__endpointa"];
                        [connectionDict setObject:endPointB forKey:@"__endpointb"];
                        node.connection = [[APConnection alloc] init];
                        [node.connection setPropertyValuesFromDictionary:connectionDict];
                    }
                    [nodes addObject:node];
                }
            }
            successBlock(nodes);
        }
    } failureHandler:^(APError *error) {
		DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

#pragma mark - Delete methods

+ (void) deleteConnectionsWithRelationType:(NSString*)relationType objectIds:(NSArray*)objectIds {
    [APConnections deleteConnectionsWithRelationType:relationType objectIds:objectIds successHandler:nil failureHandler:nil];
}

+ (void) deleteConnectionsWithRelationType:(NSString*)relationType objectIds:(NSArray*)objectIds failureHandler:(APFailureBlock)failureBlock {
    [APConnections deleteConnectionsWithRelationType:relationType objectIds:objectIds successHandler:nil failureHandler:nil];
}

+ (void) deleteConnectionsWithRelationType:(NSString*)relationType objectIds:(NSArray*)objectIds successHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    NSString *path = [CONNECTION_PATH stringByAppendingFormat:@"%@/bulkdelete", relationType];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:objectIds forKey:@"idlist"];
    
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSError *jsonError = nil;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&jsonError];
    if(jsonError != nil)
        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
    [urlRequest setHTTPBody:requestBody];
    
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock != nil) {
            successBlock();
        }
    } failureHandler:^(APError *error) {
		DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

@end
