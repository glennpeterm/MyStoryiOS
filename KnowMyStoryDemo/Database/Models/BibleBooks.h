//
//  BibleBooks.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 26/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BibleBooks : NSManagedObject

@property (nonatomic, retain) NSString * bible_name;
@property (nonatomic, retain) NSString * bible_type;
@property (nonatomic, retain) NSString * book_id;
@property (nonatomic, retain) NSString * book_name;
@property (nonatomic, retain) NSNumber * book_order;
@property (nonatomic, retain) NSString * chapters;
@property (nonatomic, retain) NSString * dam_id;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * number_of_chapters;
@property (nonatomic, retain) NSString * uniqueId;

@end
