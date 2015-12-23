
/**************************************************************************************
 *  File Name   : CoreData.h
 *  Created By  : Aswathy
 *  Created On  : 6/4/14.
 *  Purpose     : Manage CoreData .
 *  Copyright (c) 2014 Fingent Technology Solutions (P) Ltd. All rights reserved.
**************************************************************************************/

#import <Foundation/Foundation.h>
#import "CoreDataAdditions.h"
@interface CoreData : CoreDataAdditions

+(CoreData *) sharedManager;
- (NSArray *) executeCoreDataFetchRequest:(NSFetchRequest *)fetchRequest;

@end
