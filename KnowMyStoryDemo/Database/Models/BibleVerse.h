//
//  BibleVerse.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 26/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BibleVerse : NSManagedObject

@property (nonatomic, retain) NSString * bible_name;
@property (nonatomic, retain) NSNumber * book_order;
@property (nonatomic, retain) NSString * chapter;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSNumber * verse;

@end
