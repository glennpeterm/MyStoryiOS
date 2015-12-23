//
//  OfflineBible.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 06/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface OfflineBible : NSManagedObject

@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSString * bible_type;
@property (nonatomic, retain) NSString * book_name;
@property (nonatomic, retain) NSString * chapter;
@property (nonatomic, retain) NSString * verse;
@property (nonatomic, retain) NSString * verse_text;

@end
