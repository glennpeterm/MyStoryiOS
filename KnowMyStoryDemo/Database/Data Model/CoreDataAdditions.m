/**************************************************************************************
 *  File Name      : CoreDataAdditions.m
 *  Project Name   : <Generic>
 *  Description    : N/A
 *  Version        : 1.0
 *  Created by     : Aswathy Bose
 *  Created on     : 6/4/14
 *  Copyright (c) 2014 Fingent Technology Solutions (P) Ltd. All rights reserved.
 ***************************************************************************************/

#import "CoreDataAdditions.h"
#import <UIKit/UIKit.h>
@interface CoreDataAdditions()  {
    
    NSString *dataStoreName;
    NSManagedObjectModel *managedObjectModel;
}

@end

#pragma mark - NSManagedObjectContext + Additions

@implementation NSManagedObjectContext (Additions)

+(NSManagedObjectContext *)newContextForPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator  {
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator: coordinator];
    [context setMergePolicy:NSOverwriteMergePolicy];
    
    return context;
}

@end

#pragma mark - CoreDataAdditions 

@implementation CoreDataAdditions

@synthesize dataModelName;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;

#pragma mark - Private Methods

-(NSString *)applicationSupportDirectory {
    
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
    NSString *applicationSupportDirectoryName = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Database",applicationName]];
    applicationName = nil;
       
    if (![[NSFileManager defaultManager] fileExistsAtPath:applicationSupportDirectoryName]) {
        NSError *error;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:applicationSupportDirectoryName withIntermediateDirectories:YES attributes:nil error:&error]) {
            CoreDataLog(@"\n Error Occured While creating Directory : %@",[error description]);
        }
    }
       
    return applicationSupportDirectoryName;
}

-(NSManagedObjectModel *)managedObjectModel    {
    
    @try {
        if (managedObjectModel != nil)  {
            return managedObjectModel;
        }
        
        if (!self.dataModelName) {
            CoreDataLog(@"\n Exception on managedObjectModel : Data Model Name Not Found.... \n Aborting......");
            abort();
        }
        
        BOOL isMultitaskingSupported = NO;
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])   {
            isMultitaskingSupported = [(id)[UIDevice currentDevice] isMultitaskingSupported];
        }
        
        if (isMultitaskingSupported)    {
            NSURL *modelURL =   [[NSBundle mainBundle] URLForResource:self.dataModelName withExtension:@"momd"];
            managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
            
        }
        else    {
            managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];     
        }
        
        return managedObjectModel;
    }
    @catch (NSException *exception) {
        CoreDataLog(@"\n Exception on managedObjectModel : %@",[exception description]);
    }
    @finally {
        
    }
    
    return nil;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator    {	
    
    @try {
        
        if (persistentStoreCoordinator != nil) {
            return persistentStoreCoordinator;
        }
        
        if (!dataStoreName) {
            NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
            dataStoreName = applicationName;
            applicationName = nil;
            CoreDataLog(@"\n Data Store Name Not Found - Set to Default Store Name : %@",dataStoreName);
        }
        
        NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationSupportDirectory] stringByAppendingPathComponent:dataStoreName]];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        
        NSError *error = nil;
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] 
                                      initWithManagedObjectModel:[self managedObjectModel]];
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                      configuration:nil
                                                                URL:storeUrl
                                                            options:options
                                                              error:&error]) {
            CoreDataLog(@"\n Error unresolved error while creating Persistent Store Coordinator \n %@, %@ \n Aborting....", error, [error userInfo]);
            abort();
        } 
        else    {
            CoreDataLog(@"\n Create a Persistent Store Coordinator Sucessfully.... \n Coordinator : %@",persistentStoreCoordinator);
        }
        
        options = nil;
        error = nil;
        storeUrl = nil;
        
        return persistentStoreCoordinator;
    }
    @catch (NSException *exception) {
        CoreDataLog(@"\n Exception on persistentStoreCoordinator : %@",[exception description]);
    }
    @finally {
        
    }
    
    return nil;
}

#pragma mark - Observers    

- (void)startObserveContext:(NSManagedObjectContext *)context   {
    //CoreDataLog(@"Start Observing Context : %@",context);
	[[NSNotificationCenter defaultCenter]   addObserver:self    
                                               selector:@selector(mergeChanges:)
                                                   name:NSManagedObjectContextDidSaveNotification
                                                 object:context];
}

- (void)stopObservingContext:(NSManagedObjectContext *)context {
    //CoreDataLog(@"Stop Observing Context : %@",context);
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSManagedObjectContextDidSaveNotification
												  object:context];
}


#pragma mark - Context

-(NSManagedObjectContext*)managedObjectContextForMain     {
    
    return managedObjectContext;
}

-(NSManagedObjectContext*)managedObjectContext  {
    
    NSManagedObjectContext *context = nil;
	
    if ([NSThread isMainThread])    {
        
        if (!managedObjectContext)  {
            
            NSManagedObjectContext *mainContext = [NSManagedObjectContext newContextForPersistentStoreCoordinator:[self persistentStoreCoordinator]];
            managedObjectContext = mainContext;
            mainContext = nil;
        }
        
        context = managedObjectContext;
	} 
	else    {
        
        //find context for this thread.
        NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
		context = [threadDictionary objectForKey:kManagedObjectContextKey];
        
        if (!context)   {
            
            //create a new context for this thread.
			context = [NSManagedObjectContext newContextForPersistentStoreCoordinator:[self persistentStoreCoordinator]];
            [context setUndoManager:nil];
            [self startObserveContext:context];
			[threadDictionary setObject:context forKey:kManagedObjectContextKey];
            
            context = nil;
            
            return [threadDictionary objectForKey:kManagedObjectContextKey];
		}
    }
	
	return context;
}

#pragma mark - Merge Methods

- (void)mergeChanges:(NSNotification *)notification {
	//merge changes into the main context on the main thread.
	[self performSelectorOnMainThread:@selector(mergeChangesOnMainThread:)
                           withObject:notification
                        waitUntilDone:NO];  
}

- (void) mergeChangesOnMainThread:(NSNotification*)notification {
	[self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification]; 
}

#pragma mark - ManagedObjectContext Methods

//to remove the managed object from in-memory.
- (void)refreshObject:(NSManagedObject *)managedObject  {
    
    @try {
        if ([self managedObjectContext])   {
            if(managedObject != nil)
                [[self managedObjectContext] refreshObject:managedObject mergeChanges:NO];
        }
    }
    @catch (NSException *exception) {
        CoreDataLog(@"Exception on refreshObject : %@",[exception description]);
    }
    @finally {
        
    }
}

//create a new entity for given name.
-(id)newEntityForName:(NSString *)entityName {
    
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self managedObjectContext]];
}

//return an entity description for given name.
-(id)entityForName:(NSString *)entityName {
    
    return [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
}

//to save entity.
- (BOOL)saveEntity  {
    BOOL sucess =   NO;
    @try    {
        
        NSError *error;
        if ([[self managedObjectContext] hasChanges]) {
            sucess = [[self managedObjectContext] save:&error];
            
            if (!sucess) {
                CoreDataLog(@"Error While Saving Entity : %@",[error description]);
                error = nil;
            }
            else    {
                CoreDataLog(@"Entities Saved sucessfully....");
            }
        }
        
        return sucess;
    }
    @catch (NSException *exception) {
        CoreDataLog(@"Exception on saveEntity : %@",[exception description]);
    }
    @finally {
        return sucess;
    }
}


@end
