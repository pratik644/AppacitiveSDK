//
//  APGraphQuery.m
//  Appacitive-iOS-SDK
//
//  Created by Pratik on 07-01-14.
//  Copyright (c) 2014 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "APGraphNode.h"
#import "APNetworking.h"
#import "APHelperMethods.h"
#import "APObject.h"
#import "APDevice.h"
#import "APUser.h"
#import "APConnection.h"

#define SEARCH_PATH @"v1.0/search/"

@implementation APGraphNode

static NSMutableArray *parentIdStack;
static NSMutableArray *parentTypeStack;
static NSMutableArray *nodeStack;
static NSMutableArray *childKeyStack;

#pragma mark - Get children method

- (NSArray*) getChildrenOf:(NSString*)objectId {
    
    if(objectId != nil && self != nil) {
        
        if([self.object.objectId isEqualToString:objectId])
            return [[self.map allValues] lastObject];
        
        else if ([[self.map allValues] count] > 0) {
            if ([[[self.map allValues] lastObject] count] > 0) {
                for(APGraphNode *subNode in [[self.map allValues] lastObject])
                {
                    NSArray *listOfnodes;
                    if(listOfnodes == nil)
                        listOfnodes = [[NSArray alloc] init];
                    listOfnodes = [subNode getChildrenOf:objectId];
                    return listOfnodes;
                }
            }
        }
    }
    return nil;
}

- (void) setObject:(APObject *)object {
    _object = object;
}

- (void) setMap:(NSDictionary *)map {
    _map = map;
}

- (void) setConnection:(APConnection *)connection {
    _connection = connection;
}

#pragma mark - Graph query method

+ (void) applyFilterGraphQuery:(NSString*)query usingPlaceHolders:(NSDictionary*)placeHolders successHandler:(APObjectsSuccessBlock)successBlock {
    [APGraphNode applyFilterGraphQuery:query usingPlaceHolders:placeHolders successHandler:successBlock failureHandler:nil];
}

+ (void) applyFilterGraphQuery:(NSString*)query usingPlaceHolders:(NSDictionary*)placeHolders successHandler:(APObjectsSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    NSString *path = [SEARCH_PATH stringByAppendingString:[NSString stringWithFormat:@"%@/filter",query]];
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    if(placeHolders == nil) {
        placeHolders = [[NSDictionary alloc] initWithObjectsAndKeys:@" ",@" ", nil];
    }
    NSError *jsonError = nil;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:placeHolders options:kNilOptions error:&jsonError];
    if(jsonError != nil)
        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
    [urlRequest setHTTPBody:requestBody];
    
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock != nil) {
            successBlock([result objectForKey:@"ids"]);
        }
    } failureHandler:^(APError *error) {
		DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

- (void) applyProjectionGraphQuery:(NSString*)query usingPlaceHolders:(NSDictionary *)placeHolders forObjectsIds:(NSArray *)objectIds successHandler:(APGraphNodeSuccessBlock)successBlock {
    [self applyProjectionGraphQuery:query usingPlaceHolders:placeHolders forObjectsIds:objectIds  successHandler:successBlock failureHandler:nil];
}

- (void) applyProjectionGraphQuery:(NSString *)query usingPlaceHolders:(NSDictionary *)placeHolders forObjectsIds:(NSArray *)objectIds successHandler:(APGraphNodeSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    NSString *path = [SEARCH_PATH stringByAppendingString:[NSString stringWithFormat:@"%@/project",query]];
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    if(placeHolders == nil) {
        placeHolders = [[NSDictionary alloc] initWithObjectsAndKeys:@" ",@" ", nil];
    }
    NSMutableDictionary *requestData = [[NSMutableDictionary alloc] init];
    [requestData setObject:objectIds forKey:@"ids"];
    [requestData setObject:placeHolders forKey:@"placeholders"];
    NSError *jsonError = nil;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:requestData options:kNilOptions error:&jsonError];
    if(jsonError != nil)
        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
    [urlRequest setHTTPBody:requestBody];
    
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock != nil) {
            NSMutableDictionary *dict = [result mutableCopy];
            [dict removeObjectForKey:@"status"];
            NSArray *objs = [dict allValues];
            NSArray *subDicts = [[objs lastObject] valueForKey:@"values"];
            APGraphNode *node = [[APGraphNode alloc] init];
            [node parseProjectionQueryResult:subDicts];
            node = [nodeStack lastObject];
            nodeStack = nil;
            parentIdStack = nil;
            parentTypeStack = nil;
            successBlock(node);
        }
    } failureHandler:^(APError *error) {
		DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

#pragma mark - Private methods

- (void) parseProjectionQueryResult:(NSArray*)objs{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    filePath = [filePath stringByAppendingPathComponent:@"typeMapping.plist"];
    NSDictionary *typeMapping = [NSDictionary dictionaryWithContentsOfFile:filePath];
    for (NSDictionary *result in objs) {
        if(parentIdStack == nil)
            parentIdStack = [[NSMutableArray alloc] init];
        if(parentTypeStack == nil)
            parentTypeStack = [[NSMutableArray alloc] init];
        if(nodeStack == nil)
            nodeStack = [[NSMutableArray alloc] init];
        if(childKeyStack == nil)
            childKeyStack =[[NSMutableArray alloc] init];
        APGraphNode *node;
        if(node == nil) {
            node = [[APGraphNode alloc] init];
            node.map = [[NSMutableDictionary alloc] init];
        }
        if([[result allKeys] containsObject:@"__edge"]) {
            NSDictionary *edge = [result objectForKey:@"__edge"];
            NSMutableDictionary *endPointA = [[NSMutableDictionary alloc] init];
            [endPointA setObject:[result objectForKey:@"__id"] forKey:@"objectid"];
            [endPointA setObject:[edge objectForKey:@"__label"] forKey:@"type"];
            [endPointA setObject:[edge objectForKey:@"__label"] forKey:@"label"];
            NSMutableDictionary *endPointB = [[NSMutableDictionary alloc] init];
            [endPointB setObject:[parentIdStack lastObject] forKey:@"objectid"];
            [endPointB setObject:[parentTypeStack lastObject] forKey:@"type"];
            [endPointB setObject:[parentTypeStack lastObject] forKey:@"label"];
            NSMutableDictionary *connectionDict = [[NSMutableDictionary alloc] init];
            [connectionDict setObject:[edge objectForKey:@"__id"] forKey:@"__id"];
            [connectionDict setObject:[edge objectForKey:@"__relationtype"] forKey:@"__relationtype"];
            [connectionDict setObject:endPointA forKey:@"__endpointa"];
            [connectionDict setObject:endPointB forKey:@"__endpointb"];
            node.connection = [[APConnection alloc] init];
            [node.connection setPropertyValuesFromDictionary:connectionDict];
            [node.connection setPropertyValuesFromDictionary:edge];
        }
        
        if([[result allKeys] containsObject:@"__type"]) {
            APObject *object = [[APObject alloc] init];
            if([typeMapping objectForKey:[result valueForKey:@"__type"]] != nil)
                object = [[NSClassFromString([typeMapping objectForKey:[result valueForKey:@"__type"]]) alloc] init];
            [object setPropertyValuesFromDictionary:result];
            node.object = object;
            [parentIdStack addObject:object.objectId];
            [parentTypeStack addObject:object.type];
        }
        
        if([[result allKeys] containsObject:@"__children"]) {
            NSMutableArray *children = [[NSMutableArray alloc] init];
            [nodeStack addObject:node];
            
            for(NSString *key in [[result valueForKey:@"__children"] allKeys]) {
                [childKeyStack addObject:key];
                [node.map setValue:[children mutableCopy] forKey:key];
                [self parseProjectionQueryResult:[[[result valueForKey:@"__children"] objectForKey:key] valueForKey:@"values"]];
            }
            
            if([nodeStack count] > 1)
                [nodeStack removeObject:[nodeStack lastObject]];
            if([childKeyStack count] > 1)
                [childKeyStack removeObject:[childKeyStack lastObject]];
            [parentIdStack removeObject:[parentIdStack lastObject]];
            [parentTypeStack removeObject:[parentTypeStack lastObject]];
        }
        
        if([nodeStack lastObject] != nil && [nodeStack lastObject] != node) {
            [[((APGraphNode*)[nodeStack lastObject]).map valueForKey:[childKeyStack lastObject]] addObject:node];
        }
    }
}

@end
