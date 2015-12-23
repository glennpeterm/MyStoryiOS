//
//  YoutubeUploadService.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 28/01/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "BaseService.h"
#import "YoutubeUploadParser.h"
@interface YoutubeUploadService : BaseService


@property (nonatomic, strong)YoutubeUploadParser *jsonParserObject;

- (void)initService:(ServiceType)serviceType withUploadedData:(NSMutableDictionary * )uploadedData target:(id)delegate;
@end
