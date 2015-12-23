//
//  ChannelsAndSelfiesService.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 10/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "BaseService.h"
#import "ChannelsAndSelfiesParser.h"

@interface ChannelsAndSelfiesService : BaseService

@property (nonatomic, strong)ChannelsAndSelfiesParser *jsonParserObject;

- (void)initServiceForChannelsAndSelfies:(ServiceType)serviceType target:(id)delegate;
@end
