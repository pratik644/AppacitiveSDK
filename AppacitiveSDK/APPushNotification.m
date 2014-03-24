//
//  APPush.m
//  Appacitive-iOS-SDK
//
//  Created by Pratik on 23-01-14.
//  Copyright (c) 2014 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "APPushNotification.h"
#import "APHelperMethods.h"
#import "APNetworking.h"
#import "APGraphNode.h"

#define PUSH_PATH @"v1.0/push/"

#pragma mark - APPushNotification Interface

@implementation APPushNotification

- (instancetype) initWithMessage:(NSString*)message {
    if(message != nil) {
        _message = message;
        return self;
    }
    return nil;
}

- (void) sendPush {
    [self sendPushWithSuccessHandler:nil failureHandler:nil];
}

- (void) sendPushWithSuccessHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    
    NSString *path = [HOST_NAME stringByAppendingPathComponent:PUSH_PATH];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"DELETE"];
    
    
    NSMutableDictionary *poDict = [[NSMutableDictionary alloc] init];
    if(self.platformOptions) {
        if(self.platformOptions.iosOptions != nil){
            [poDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:self.platformOptions.iosOptions.soundFile, @"soundfile", nil] forKey:@"ios"];
        }
        if(self.platformOptions.androidOptions != nil){
            [poDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:self.platformOptions.androidOptions.title, @"title", nil] forKey:@"android"];
        }
        if(self.platformOptions.windowsPhoneOptions != nil){
            if(self.platformOptions.windowsPhoneOptions.notification.class == [ToastNotification class]) {
                [poDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   @"toast", @"notificationtype",
                                   ((ToastNotification*)self.platformOptions.windowsPhoneOptions.notification).path, @"navigatepath",
                                   ((ToastNotification*)self.platformOptions.windowsPhoneOptions.notification).text1, @"text1",
                                   ((ToastNotification*)self.platformOptions.windowsPhoneOptions.notification).text2, @"text2",
                                   nil]
                           forKey:@"wp"];
            }
            if(self.platformOptions.windowsPhoneOptions.notification.class == [RawNotification class]) {
                [poDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   @"raw", @"notificationtype",
                                   ((RawNotification*)self.platformOptions.windowsPhoneOptions.notification).rawData, @"data",
                                   nil]
                           forKey:@"wp"];
            }
            if(self.platformOptions.windowsPhoneOptions.notification.class == [TileNotification class]) {
                if(((TileNotification*)self.platformOptions.windowsPhoneOptions.notification).wp8Tile.wpTileType == kWPTileTypeFlip) {
                    FlipTile *fliptile= ((FlipTile*)((TileNotification*)self.platformOptions.windowsPhoneOptions.notification).wp8Tile);
                    [poDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                       @"tile", @"notificationtype",
                                       @"flip", @"tiletemplate",
                                       fliptile.frontTitle, @"title",
                                       fliptile.frontCount, @"count",
                                       fliptile.frontBackgroundImage, @"backgroundimage",
                                       fliptile.smallBackgroundImage, @"smallbackgroundimage",
                                       fliptile.wideBackgroundImage, @"widebackgroundimage",
                                       fliptile.backTitle, @"backtitle",
                                       fliptile.backBackgroundImage, @"backbackgroundimage",
                                       fliptile.wideBackgroundImage, @"widebackbackgroundimage",
                                       fliptile.backContent, @"backcontent",
                                       fliptile.wideBackContent, @"widebackcontent",
                                       nil]
                               forKey:@"wp"];
                    
                }
                if(((TileNotification*)self.platformOptions.windowsPhoneOptions.notification).wp8Tile.wpTileType == kWPTileTypeCyclic) {
                    CyclicTile *cyclicTile= ((CyclicTile*)((TileNotification*)self.platformOptions.windowsPhoneOptions.notification).wp8Tile);
                    FlipTile *cyclicWP75Tile= ((FlipTile*)((TileNotification*)self.platformOptions.windowsPhoneOptions.notification).wp75Tile);
                    FlipTile *cyclicWP7Tile= ((FlipTile*)((TileNotification*)self.platformOptions.windowsPhoneOptions.notification).wp7Tile);
                    
                    [poDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                       @"tile", @"notificationtype",
                                       @"cycle", @"tiletemplate",
                                       cyclicTile.images[0], @"cycleimage1",
                                       cyclicTile.images[1], @"cycleimage2",
                                       cyclicTile.images[2], @"cycleimage3",
                                       cyclicTile.images[3], @"cycleimage4",
                                       cyclicTile.images[4], @"cycleimage5",
                                       cyclicTile.images[5], @"cycleimage6",
                                       cyclicTile.images[7], @"cycleimage7",
                                       cyclicTile.images[7], @"cycleimage8",
                                       cyclicTile.images[8], @"cycleimage9",
                                       nil]
                               forKey:@"wp"];
                    
                    if (cyclicWP75Tile != nil) {
                        [[poDict objectForKey:@"wp"] setObject:
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          @"tile", @"notificationtype",
                          @"flip", @"tiletemplate",
                          cyclicWP75Tile.frontTitle, @"title",
                          cyclicWP75Tile.frontCount, @"count",
                          cyclicWP75Tile.frontBackgroundImage, @"backgroundimage",
                          cyclicWP75Tile.smallBackgroundImage, @"smallbackgroundimage",
                          cyclicWP75Tile.wideBackgroundImage, @"widebackgroundimage",
                          cyclicWP75Tile.backTitle, @"backtitle",
                          cyclicWP75Tile.backBackgroundImage, @"backbackgroundimage",
                          cyclicWP75Tile.wideBackgroundImage, @"widebackbackgroundimage",
                          cyclicWP75Tile.backContent, @"backcontent",
                          cyclicWP75Tile.wideBackContent, @"widebackcontent",
                          nil] forKey:@"wp75"];
                    }
                    
                    if (cyclicWP7Tile != nil)
                        [[poDict objectForKey:@"wp"] setObject:
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          @"flip", @"tiletemplate",
                          cyclicWP7Tile.frontTitle, @"title",
                          cyclicWP7Tile.frontCount, @"count",
                          cyclicWP7Tile.frontBackgroundImage, @"backgroundimage",
                          nil] forKey:@"wp7"];
                }
                
                if(((TileNotification*)self.platformOptions.windowsPhoneOptions.notification).wp8Tile.wpTileType == kWPTileTypeIconic) {
                    IconicTile *iconicTile= ((IconicTile*)((TileNotification*)self.platformOptions.windowsPhoneOptions.notification).wp8Tile);
                    FlipTile *iconicWP75Tile= ((FlipTile*)((TileNotification*)self.platformOptions.windowsPhoneOptions.notification).wp75Tile);
                    FlipTile *iconicWP7Tile= ((FlipTile*)((TileNotification*)self.platformOptions.windowsPhoneOptions.notification).wp7Tile);
                    
                    [poDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                       @"tile", @"notificationtype",
                                       @"iconic", @"tiletemplate",
                                       iconicTile.frontTitle, @"cycleimage1",
                                       iconicTile.iconImage, @"cycleimage2",
                                       iconicTile.smallIconImage, @"cycleimage3",
                                       iconicTile.backgroundColor, @"cycleimage4",
                                       iconicTile.wideContent1, @"cycleimage5",
                                       iconicTile.wideContent2, @"cycleimage6",
                                       iconicTile.wideContent3, @"cycleimage7",
                                       nil]
                               forKey:@"wp"];
                    if (iconicWP75Tile != nil) {
                        [[poDict objectForKey:@"wp"] setObject:
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          @"tile", @"notificationtype",
                          @"flip", @"tiletemplate",
                          iconicWP75Tile.frontTitle, @"title",
                          iconicWP75Tile.frontCount, @"count",
                          iconicWP75Tile.frontBackgroundImage, @"backgroundimage",
                          iconicWP75Tile.smallBackgroundImage, @"smallbackgroundimage",
                          iconicWP75Tile.wideBackgroundImage, @"widebackgroundimage",
                          iconicWP75Tile.backTitle, @"backtitle",
                          iconicWP75Tile.backBackgroundImage, @"backbackgroundimage",
                          iconicWP75Tile.wideBackgroundImage, @"widebackbackgroundimage",
                          iconicWP75Tile.backContent, @"backcontent",
                          iconicWP75Tile.wideBackContent, @"widebackcontent",
                          nil] forKey:@"wp75"];
                    }
                    
                    if (iconicWP7Tile != nil)
                        [[poDict objectForKey:@"wp"] setObject:
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          @"flip", @"tiletemplate",
                          iconicWP7Tile.frontTitle, @"title",
                          iconicWP7Tile.frontCount, @"count",
                          iconicWP7Tile.frontBackgroundImage, @"backgroundimage",
                          nil] forKey:@"wp7"];
                }
            }
        }
    }
    
    if(self.data == nil)
        self.data = [[NSMutableDictionary alloc] init];
    
    [self.data setObject:self.message forKey:@"alert"];
    
    if(self.badge != nil)
        [self.data setObject:self.badge forKey:@"badge"];
    
    NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc] init];
    [bodyDict setObject:[NSNumber numberWithBool:self.isBroadcast] forKey:@"broadcast"];
    
    [bodyDict setObject:self.data forKey:@"data"];
    if(self.query != nil)
        [bodyDict setObject:self.query forKey:@"query"];
    if(self.channels != nil)
        [bodyDict setObject:self.channels forKey:@"channels"];
    if(self.platformOptions != nil)
        [bodyDict setObject:poDict forKey:@"platformoptions"];
    if(self.expireAfter != nil)
        [bodyDict setObject:self.expireAfter forKey:@"expireafter"];
    
    NSError *jsonError;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyDict options:kNilOptions error:&jsonError];
    
    if(jsonError != nil)
        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
    
    [urlRequest setHTTPBody:bodyData];
    [urlRequest setHTTPMethod:@"POST"];
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock != nil) {
            successBlock();
        }
    } failureHandler:^(APError *error) {
        if(failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

@end





#pragma mark - IOSOptions Interface

@implementation IOSOptions

- (instancetype) initWithSoundFile:(NSString*)soundFile {
    if(soundFile != nil)
        _soundFile = soundFile;
    return self;
}

@end





#pragma mark - AndroidOptions Interface

@implementation AndroidOptions

- (instancetype) initWithTitle:(NSString*)title {
    if(title != nil)
        _title = title;
    return self;
}

@end





#pragma mark - WPTile Interface

@implementation WPTile

- (instancetype) initWithTileNotificationType:(WPTileType)wpTileType {
    _wpTileType = wpTileType;
    return self;
}

@end





#pragma mark - FlipTile Interface

@implementation FlipTile

- (instancetype) init {
    return self = [super initWithTileNotificationType:kWPTileTypeFlip];
}

@end






#pragma mark - IconicTile

@implementation IconicTile

- (instancetype) init {
    return self = [super initWithTileNotificationType:kWPTileTypeIconic];
}

@end





#pragma mark - CyclicTile Interface

@implementation CyclicTile

- (instancetype) initWithFrontTitle:(NSString*)frontTitle images:(NSArray*)images {
    _frontTitle = frontTitle;
    for(int i=0; i<9; i++)
        _images[i] = images[i];
    return self;
}

- (instancetype) init {
    return self = [super initWithTileNotificationType:kWPTileTypeFlip];
}

@end







#pragma mark - WPNotification Interface

@implementation WPNotification

- (instancetype) initWithNotificationType:(WPNotificationType)wpNotificationType {
    _wpNotificationType = wpNotificationType;
    return self;
}

@end




#pragma mark - ToastNotification Interface

@implementation ToastNotification

- (instancetype) init {
    return self = [super initWithNotificationType:kWPNotificationTypeToast];
}

- (instancetype) initWithText1:(NSString*)text1 text2:(NSString*)text2 path:(NSString*)path {
    self = [super initWithNotificationType:kWPNotificationTypeToast];
    if (text1 != nil && text2 != nil && path != nil) {
        _text1 = text1;
        _text2 = text2;
        _path = path;
    }
    return self;
}

@end





#pragma mark - WPTileNotification Interface

@implementation TileNotification

- (instancetype) init {
    return self = [super initWithNotificationType:kWPNotificationTypeTile];
}

- (TileNotification*) createNewFlipTile:(FlipTile*)tile  {
    if (tile != nil) {
        _wp75Tile = tile;
        _wp7Tile = tile;
        _wp8Tile = tile;
    }
    return self;
}

- (TileNotification*) createNewIconicTile:(IconicTile*)tile  flipTileForWP75AndBelow:(FlipTile*)flipTile{
    if (tile != nil)
        _wp8Tile = tile;
    _wp75Tile = flipTile;
    _wp7Tile = flipTile;
    return self;
}

- (TileNotification*) createNewCyclicTile:(IconicTile*)tile flipTileForWP75AndBelow:(FlipTile*)flipTile {
    if (tile != nil )
        _wp8Tile = tile;
    _wp75Tile = flipTile;
    _wp7Tile = flipTile;
    return self;
}

- (void) setWp75Tile:(WPTile *)wp75Tile {
    if (wp75Tile != nil && wp75Tile.wpTileType != kWPTileTypeFlip)
        _wp75Tile = nil;
    _wp75Tile = wp75Tile;
}

- (void) setWp7Tile:(WPTile *)wp7Tile {
    if (wp7Tile != nil && wp7Tile.wpTileType != kWPTileTypeFlip)
        _wp7Tile = nil;
    _wp7Tile = wp7Tile;
}

@end




#pragma mark - RawNotification Interface

@implementation RawNotification

- (instancetype) init {
    return self = [super initWithNotificationType:kWPNotificationTypeRaw];
}

@end




#pragma mark - WindowsPhoneOptions Interface

@implementation WindowsPhoneOptions

- (instancetype) initWithToastNotification:(ToastNotification*)notification {
    if(notification != nil)
        _notification = notification;
    return self;
}

- (instancetype) initWithTileNotification:(TileNotification*)notification {
    if(notification != nil)
        _notification = notification;
    return self;
}

- (instancetype) initWithRawNotification:(RawNotification*)notification {
    if(notification != nil)
        _notification = notification;
    return self;
}

@end




#pragma mark - APPlatformOptions Interface

@implementation APPlatformOptions


@end



