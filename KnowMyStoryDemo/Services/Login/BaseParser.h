
/*
  File Name   : BaseParser.h
  Created by  : Aswathy Bose
  Created on  : 1/6/14.
  Copyright (c) 2014 Payment Processing Partners, Inc. All rights reserved.
*/

#import <Foundation/Foundation.h>
//s#import "SBJson.h"


@interface BaseParser : NSObject

-(id)parseResponse:(id)response;
@end
