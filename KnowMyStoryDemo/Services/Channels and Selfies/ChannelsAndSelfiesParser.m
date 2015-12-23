//
//  ChannelsAndSelfiesParser.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 10/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "ChannelsAndSelfiesParser.h"

@implementation ChannelsAndSelfiesParser

- (id)parseChannelsANdSelfiesViewResponse:(id)response{
     id resultInfo =[self parseResponse:response];
    return resultInfo;
}
@end
