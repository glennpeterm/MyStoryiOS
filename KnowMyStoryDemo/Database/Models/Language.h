//
//  Language.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 23/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Language : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * bible_version;

@end
