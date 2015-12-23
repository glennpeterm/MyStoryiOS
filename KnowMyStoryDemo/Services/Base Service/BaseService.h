
// File Name: BaseService.h
// Created By: Aswathy
// Created On: 19/09/12.
// Purpose: Base Web Service Class for CIP
// Copyright (c) 2014 Payment Processing Partners, Inc. All rights reserved.

#import <Foundation/Foundation.h>
//#import "SBJson.h"
#import "ServiceProtocol.h"



@interface BaseService : NSOperation < NSURLConnectionDataDelegate,ServiceProtocol >
{
    
}
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, assign) NSString *requestType;
@property (nonatomic, assign) id delegateObject;

-(BOOL)initRequest:(NSString *)url withDelegate:(id)delegate;
-(BOOL)initRequest:(NSString *)url withBody:(id)body andDelegate:(id)delegate;
-(void)responseSuccessfulNotification:(id)response;
-(void)responseFailedNotification:(id)response;
-(void)processRequest;
-(void) setURL:(NSString *)url;
- (void)networkError:(id)delegate;
@end
 