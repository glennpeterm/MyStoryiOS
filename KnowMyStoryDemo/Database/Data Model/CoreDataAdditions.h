
/**************************************************************************************
 *  File Name      : CoreDataAdditions.h
 *  Project Name   : <Generic>
 *  Description    : N/A
 *  Version        : 1.0
 *  Created by     : Aswathy Bose
 *  Created on     : 6/4/14
 *  Copyright (c) 2014 Fingent Technology Solutions (P) Ltd. All rights reserved.
 ***************************************************************************************/

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

#define kManagedObjectContextKey @"NSManagedObjectContextForThreadKey"

#define CoreDataLog(s, ...) NSLog(@"CoreData : %@", [NSString stringWithFormat: s, ##__VA_ARGS__])
//#define CoreDataLog(s, ...)

@interface CoreDataAdditions : NSObject

@property (nonatomic, retain)   NSString *dataModelName;

@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

#pragma mark - ManagedObjectContext Methods

//to save entity.
- (BOOL)saveEntity;
//return an entity description for given name.
-(id)entityForName:(NSString *)entityName;
//create a new entity for given name.
-(id)newEntityForName:(NSString *)entityName;
//to remove the managed object from in-memory.
- (void)refreshObject:(NSManagedObject *)managedObject;
//to get managedobject context for main thread.
-(NSManagedObjectContext*)managedObjectContextForMain;

@end
