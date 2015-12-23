//
//  ScriptureSearchParser.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 06/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "ScriptureSearchParser.h"

@implementation ScriptureSearchParser
- (id)parseScriptureSearchResponse:(id)response{
   
    
    NSError *someError;
    id dictResponse  = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&someError];
    NSLog(@"dict response : %@", dictResponse);
    return dictResponse;
}
@end
