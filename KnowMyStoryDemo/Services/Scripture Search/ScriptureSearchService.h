//
//  ScriptureSearchService.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 06/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "BaseService.h"
#import "ScriptureSearchParser.h"
#import "BibleBooks.h"
#import "BibleVerse.h"
#import "OfflineBible.h"

@interface ScriptureSearchService : BaseService


@property (nonatomic, strong)ScriptureSearchParser *jsonParserObject;

- (void)initService:(ServiceType)serviceType withBibleInfo:(BibleBooks * )bibleInfo  andVerseInfo:(BibleVerse *) selectedVerse target:(id)delegate;
- (void)initService:(ServiceType)serviceType  withSearchText:(NSString *)searchText target:(id)delegate;
@end
