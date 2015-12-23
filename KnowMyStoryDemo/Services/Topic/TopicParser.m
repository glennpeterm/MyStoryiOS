//
//  TopicParser.m
//  KnowMyStoryDemo
//
//  Created by Abdusha on 10/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "TopicParser.h"

@implementation TopicParser

- (id)parseTopicParserViewResponse:(id)response{
     id resultInfo =[self parseResponse:response];
    return resultInfo;
}
@end
