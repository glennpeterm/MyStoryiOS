
// File Name    :   BaseService.h
// Created By   :   Aswathy
// Created On   :   19/09/12.
// Purpose      :   Protocol for declaring the delegate methods required for implementing a
//                  web service client. These methods are used for callback to controller classes.
// Copyright (c) 2014 Payment Processing Partners, Inc. All rights reserved.

#import <Foundation/Foundation.h>

@protocol ServiceProtocol <NSObject>

@optional
-(void)serviceSuccessful:(id)response;
-(void)serviceFailed:(id)response;
- (void)networkError;
@end
