
/*
  File Name   : BaseParser.m
  Created by  : Aswathy Bose
  Created on  : 1/6/14.
  Copyright (c) 2014 Payment Processing Partners, Inc. All rights reserved.
*/

#import "BaseParser.h"



@implementation BaseParser

-(id)parseResponse:(id)response{
    
    BOOL status = FALSE;
    NSError *someError;
     NSMutableDictionary *dictResponse  = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&someError];
    
    NSMutableDictionary * parsedResponse = nil;
    if([dictResponse objectForKey:@"Success"])
    {
        status = [[dictResponse objectForKey:@"Success"]boolValue];
    }
    if([dictResponse objectForKey:@"StatusCode"])
    {
        if([[dictResponse objectForKey:@"StatusCode"]intValue] == SERVICE_SUCCESSFUL){
            status = YES;
        }
    }

    else
    {
        parsedResponse = nil;
    }
    if(status)
    {
         if([dictResponse objectForKey:@"url"]){
             parsedResponse = [dictResponse objectForKey:@"url"];
         }
        if([dictResponse objectForKey:@"Result"]){
            
            parsedResponse = [dictResponse objectForKey:@"Result"];
        }
    }
    else
    {
        
        if([dictResponse objectForKey:@"Status"]){
            
          Response *failureRespons =  [self parseFailureResponse: dictResponse];
           
          return failureRespons;
            
            
        }
        else
        {
            parsedResponse = nil;
        }
        
        
    }

    
    return parsedResponse;
}

-(Response *)parseFailureResponse:(NSMutableDictionary *)response{
    
    Response *failureResponse = [[Response alloc]init];
//    if([[response objectForKey:@"StatusCode"]intValue] == SERVICE_PARAMETER_MISSING){
       failureResponse.statusCode=[[response objectForKey:@"StatusCode"]intValue] ;
       failureResponse.messageString =[response objectForKey:@"Status"];
       
//    }
//    else if([[response objectForKey:@"StatusCode"]intValue] == SERVICE_PAGENOTFOUND){
//        failureResponse.statusCode=[[response objectForKey:@"StatusCode"]intValue] ;
//        failureResponse.messageString =[response objectForKey:@"Status"];
//    }
    return failureResponse;
}
@end
