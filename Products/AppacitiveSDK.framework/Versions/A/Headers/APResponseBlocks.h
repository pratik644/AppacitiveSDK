//
//  APResponseBlocks.h
//  Appacitive-iOS-SDK
//
//  Created by Kauserali Hafizji on 29/08/12.
//  Copyright (c) 2012 Appacitive Software Pvt. Ltd. All rights reserved.
//

@class APError, APUser, UIImage, APDevice, APGraphNode;

/**
 Success block that returns nothing.
 */
typedef void (^APSuccessBlock)();

/**
 Block parameter expected for a success response which returns an 'NSDictionary'.
 */
typedef void (^APResultSuccessBlock)(NSDictionary *result);

/**
 Block parmaeter expected for a success response which returns an 'NSArray'.
 */
typedef void (^APObjectsSuccessBlock)(NSArray *objects);

/**
 Block parameter expected for a success response which returns a 'NSData'.
 */
typedef void (^APFileDownloadSuccessBlock)(NSData *data);

/**
 Block parameter expected for a failure response which returns a 'AYError'.
 */
typedef void (^APFailureBlock)(APError *error);

/**
 Block parameter expected for a success response which returns a 'APUser'.
 */
typedef void (^APUserSuccessBlock)(APUser* user);

/**
 Block parameter expected for image download
 */
typedef void (^APImageBlock) (UIImage* fetchedImage, NSURL* url, BOOL isInCache);

/**
 Block paramter expected for a success response which returns a 'APGraphNode'.
 */
typedef void (^APGraphNodeSuccessBlock)(APGraphNode* node);

