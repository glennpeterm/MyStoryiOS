
/*
  File Name   : LoginWebService.h
  Created by  : Aswathy Bose
  Created  on : 12/24/13.
  Copyright (c) 2013 Payment Processing Partners, Inc. All rights reserved.
*/

#import "BaseService.h"
#import "LoginParser.h"

#import "UserInfo.h"

@interface LoginWebService : BaseService

@property (nonatomic, strong)LoginParser *jsonParserObject;
- (void)initService:(ServiceType)serviceType body:(UserInfo *)loginInfo target:(id)delegate;
- (void)initServiceForCountryList:(ServiceType)serviceType target:(id)delegate;
@end
