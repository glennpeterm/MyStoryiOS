
/*
 File Name: Response.h
 Created By: Aswathy
 Created On: 31/10/12.
 Purpose: Model for  Response Info from Webservice
 Copyright (c) 2014 Payment Processing Partners, Inc. All rights reserved.

*/

#import "Response.h"

@implementation Response
@synthesize statusCode;
@synthesize requestType;
@synthesize messageString;

-(id) init
{
    self = [super init];
    if(self)
    {
        statusCode = 0;
        requestType = 0;
    }
    return self;
}


-(void) dealloc
{
}
@end
