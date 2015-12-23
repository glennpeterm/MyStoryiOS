
/*
 File Name : Response.h
 Created By: Aswathy
 Created On: 31/10/12.
 Purpose: Model for  Response Info from Webservice
 Copyright (c) 2014 Payment Processing Partners, Inc. All rights reserved.

*/


#import <Foundation/Foundation.h>

@interface Response : NSObject

@property (nonatomic, assign) int statusCode;
@property (nonatomic, assign) int requestType;
@property (nonatomic, strong) NSString *messageString;
@end
