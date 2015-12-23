//
//  Country.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 27/01/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Country : NSManagedObject

@property (nonatomic, retain) NSString * countryId;
@property (nonatomic, retain) NSString * countryName;

@end
