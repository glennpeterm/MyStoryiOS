
/**************************************************************************************
 *  File Name   : CoreData.m
 *  Created By  : Aswathy
 *  Created On  : 6/4/14.
 *  Purpose     : Manage CoreData .
 *  Copyright (c) 2014 Fingent Technology Solutions (P) Ltd. All rights reserved.
 **************************************************************************************/

#import "CoreData.h"


@implementation CoreData

static CoreData *sharedObject;

+(CoreData *) sharedManager
{
    if(!sharedObject)
    {
        sharedObject = [[CoreData alloc]init];
        sharedObject.dataModelName = @"KnowMyStoryModel";
    }
    return sharedObject;
}


- (NSArray *) executeCoreDataFetchRequest:(NSFetchRequest *)fetchRequest
{
    NSArray *results = nil;
    if(fetchRequest && [fetchRequest isKindOfClass:[NSFetchRequest class]])
    {
        NSError *error = nil;
        results = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        if (error)
            NSLog(@"Failed fetch operation: %@",[error description]);
        else
            NSLog(@"Successful operation");
        fetchRequest = nil;
    }
    return results;
}


@end