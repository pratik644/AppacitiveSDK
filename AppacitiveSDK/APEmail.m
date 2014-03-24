//
//  APEmail.m
//  Appacitive-iOS-SDK
//
//  Created by Pratik on 16-12-13.
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "APEmail.h"
#import "APHelperMethods.h"
#import "APNetworking.h"

#define EMAIL_PATH @"v1.0/email/"

@implementation APEmail

- (instancetype) initWithRecipients:(NSArray *)recipients subject:(NSString *)subject body:(NSString *)body {
    if(recipients != nil && recipients.count > 0 && subject != nil && body != nil) {
        self.toRecipients = recipients;
        self.subjectText = subject;
        self.bodyText = body;
    }
    return nil;
}

- (void) sendEmail {
    [self sendEmailUsingSMTPConfig:nil successHandler:nil failureHandler:nil];
}

- (void) sendEmailWithSuccessHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    [self sendEmailUsingSMTPConfig:nil successHandler:successBlock failureHandler:failureBlock];
}

- (void) sendEmailUsingSMTPConfig:(NSDictionary *)smtpConfig {
    [self sendEmailUsingSMTPConfig:smtpConfig successHandler:nil failureHandler:nil];
}

- (void) sendEmailUsingSMTPConfig:(NSDictionary *)smtpConfig successHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    NSString *path = [EMAIL_PATH stringByAppendingFormat:@"send/"];
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableDictionary *requestData = [[NSMutableDictionary alloc] init];
    if(self.toRecipients != nil)
        [requestData setObject:self.toRecipients forKey:@"to"];
    if(self.ccRecipients != nil)
        [requestData setObject:self.ccRecipients forKey:@"cc"];
    if(self.bccRecipients != nil)
        [requestData setObject:self.bccRecipients forKey:@"bcc"];
    if(self.subjectText != nil)
        [requestData setObject:self.subjectText forKey:@"subject"];
    if(self.fromSender != nil)
        [requestData setObject:self.fromSender forKey:@"from"];
    if(self.replyToEmail != nil)
        [requestData setObject:self.replyToEmail forKey:@"replyTo"];
    if(self.bodyText != nil)
        [requestData setObject:[NSDictionary dictionaryWithObjectsAndKeys:self.bodyText, @"content:", self.isHTMLBody, @"ishtml", nil] forKey:@"body"];
    if(smtpConfig != nil) {
        [requestData addEntriesFromDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:smtpConfig,@"smtp", nil]];
    }
    NSError *jsonError = nil;
    [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:requestData options:0 error:&jsonError]];
    if(jsonError != nil)
        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
    
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

- (void) sendTemplatedEmailUsingTemplate:(NSString *)templateName {
    [self sendTemplatedEmailUsingTemplate:templateName usingSMTPConfig:nil];
}

- (void) sendTemplatedEmailUsingTemplate:(NSString *)templateName successHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    [self sendTemplatedEmailUsingTemplate:templateName usingSMTPConfig:nil successHandler:successBlock failureHandler:failureBlock];
}

- (void) sendTemplatedEmailUsingTemplate:(NSString *)templateName usingSMTPConfig:(NSDictionary *)smtpConfig {
    [self sendTemplatedEmailUsingTemplate:templateName usingSMTPConfig:smtpConfig successHandler:nil failureHandler:nil];
}

- (void) sendTemplatedEmailUsingTemplate:(NSString *)templateName usingSMTPConfig:(NSDictionary *)smtpConfig successHandler:(APSuccessBlock)successBlock failureHandler:(APFailureBlock)failureBlock {
    NSString *path = [EMAIL_PATH stringByAppendingFormat:@"send/"];
    path = [HOST_NAME stringByAppendingPathComponent:path];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableDictionary *template = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     templateName,@"templatename",
                                     self.templateBody,@"data",
                                     @YES,@"ishtml",
                                     nil];
    NSMutableDictionary *requestData = [[NSMutableDictionary alloc] init];
    if(self.toRecipients != nil)
        [requestData setObject:self.toRecipients forKey:@"to"];
    if(self.ccRecipients != nil)
        [requestData setObject:self.ccRecipients forKey:@"cc"];
    if(self.bccRecipients != nil)
        [requestData setObject:self.bccRecipients forKey:@"bcc"];
    if(self.subjectText != nil)
        [requestData setObject:self.subjectText forKey:@"subject"];
    if(self.fromSender != nil)
        [requestData setObject:self.fromSender forKey:@"from"];
    if(self.replyToEmail != nil)
        [requestData setObject:self.replyToEmail forKey:@"replyTo"];
    if(self.bodyText != nil)
        [requestData setObject:template forKey:@"body"];
    if(smtpConfig != nil) {
        [requestData addEntriesFromDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:smtpConfig,@"smtp", nil]];
    }
    NSError *jsonError = nil;
    [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:requestData options:0 error:&jsonError]];
    if(jsonError != nil)
        DLog(@"\n––––––––––JSON-ERROR–––––––––\n%@",jsonError);
    APNetworking *nwObject = [[APNetworking alloc] init];
    [nwObject makeAsyncRequestWithURLRequest:urlRequest successHandler:^(NSDictionary *result) {
        if (successBlock) {
            successBlock();
        }
    } failureHandler:^(APError *error) {
		DLog(@"\n––––––––––––ERROR––––––––––––\n%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
}

+ (NSDictionary*) makeSMTPConfigurationDictionaryWithUsername:(NSString*)username password:(NSString*)password host:(NSString*)host port:(NSNumber*)port enableSSL:(BOOL)enableSSL {
    NSNumber *sslSwitch = [NSNumber numberWithBool:enableSSL];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            username, @"username",
            password, @"password",
            host, @"host",
            port, @"port",
            sslSwitch, @"enablessl",
            nil];
}

@end
