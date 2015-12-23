//
//  TopicService.h
//  KnowMyStoryDemo
//
//  Created by Abdusha on 10/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "BaseService.h"
#import "TopicParser.h"

@interface TopicService : BaseService

@property (nonatomic, strong)TopicParser *jsonParserObject;

- (void)initServiceForTopic:(ServiceType)serviceType target:(id)delegate;
@end
