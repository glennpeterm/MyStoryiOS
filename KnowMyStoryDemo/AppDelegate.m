//
//  AppDelegate.m
//  KnowMyStoryDemo
//
//  Created by Abdusha on 12/15/14.
//  Copyright (c) 2014 Fingent. All rights reserved.
//

#import "AppDelegate.h"
#import "AVCamViewController.h"
#import "WizardViewController.h"
#import "BGMusicViewController.h"
#import "AVPlayerDemoPlaybackViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import "GTMHTTPFetcherLogging.h"
#import "Country.h"
#import "SignUpViewController.h"
#import "BibleBooks.h"
#import "OfflineBible.h"
#import "Language.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"didFinishLaunchingWithOptions");
    [self addAnalytics];

    [self.window setBackgroundColor:[UIColor whiteColor]];
    
     [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [Fabric with:@[TwitterKit]];
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    ActivityLoadingViewController *activityView = [sb instantiateViewControllerWithIdentifier:@"ActivityLoadingViewController"];
    [activityView configureActivityView];
    
    WizardViewController *wizardVC = [sb instantiateViewControllerWithIdentifier:@"WizardViewController"];
    [wizardVC readProjectData];
    
    
    [self loadDatabaseWithPrepopulatedInfo];
    
    return YES;
}
#pragma Google analytics
-(void)addAnalytics
{
    // 1
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    \
    // 2
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    
    // 3
    [GAI sharedInstance].dispatchInterval = 20;
    
    // 4
    
    //id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-67875818-1"]; //Fingent ID
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-68280984-1"]; // One hope ID
    //id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-68554886-1"]; // mystory.fingent@gmail.com Account

    tracker.allowIDFACollection = YES;
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSLog(@"URL SCHEME %@",[url scheme]);
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:IS_USER__TO_BE_CREATED];
    
    if([[url scheme] isEqualToString:@"com.fingent.knowmystorydemo"]){
        
        //        return [GPPURLHandler handleURL:url
        //                      sourceApplication:sourceApplication
        //                             annotation:annotation];
    }else if ([[url scheme] hasPrefix:@"fb"]){
        
        return [FBAppCall handleOpenURL:url
                      sourceApplication:sourceApplication
                        fallbackHandler:^(FBAppCall *call) {
                            NSLog(@"In fallback handler");
                        }];
    }
//    if ([[url scheme] isEqualToString:@"knowmystory"]){
//        NSDictionary *d = [self parametersDictionaryFromQueryString:[url query]];
//        
//        NSString *token = d[@"oauth_token"];
//        NSString *verifier = d[@"oauth_verifier"];
//        
//        SignUpViewController *signUpVC = [SignUpViewController sharedInstance];
//        [signUpVC setOAuthToken:token oauthVerifier:verifier];
//        
//    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    if ([[WizardViewController sharedInstance] isInWizardController])
    {
         //NSLog(@"applicationWill :%d",[[AVPlayerDemoPlaybackViewController sharedInstance]] );
        [[[WizardViewController sharedInstance] previewPlayerContainerView] setHidden:YES];
        [[[WizardViewController sharedInstance] trimContainerView] setHidden:YES];
        [[AVCamViewController sharedInstance] stopCamera];
        [[AVPlayerDemoPlaybackViewController sharedInstance] hideAndStopViewActions];
        [[BGMusicViewController sharedInstance] stopBackgroundMusic];
    }
    
    //[[AVCamViewController sharedInstance] stopCamera];
    //[[BGMusicViewController sharedInstance] stopBackgroundMusic];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSLog(@"applicationDidBecomeActive");
    if ([[WizardViewController sharedInstance] isInWizardController])
    {
        [[WizardViewController sharedInstance] configureScreen];
    }
    //[[WizardViewController sharedInstance] configureScreen];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationWillTerminate");
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.fingent.KnowMyStoryDemo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"KnowMyStoryDemo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"KnowMyStoryDemo.sql"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Memory management methods
-(void)clearApplicationCaches
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [self clearApplicationCaches];
}

- (NSDictionary *)parametersDictionaryFromQueryString:(NSString *)queryString {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    
    for(NSString *s in queryComponents) {
        NSArray *pair = [s componentsSeparatedByString:@"="];
        if([pair count] != 2) continue;
        
        NSString *key = pair[0];
        NSString *value = pair[1];
        
        md[key] = value;
    }
    
    return md;
}

#pragma mark - Load database with Prepopulated data

- (void)loadDatabaseWithPrepopulatedInfo{
    // for country list
    NSArray* result = [DBHelper getCountryList];
    if ([result count] == 0) {
        [self loadDatabaseWithCountryList];
        
    }
    // bible book names and chapters
    NSArray *biblebooks = [DBHelper getBibleBookNames];
    if ([biblebooks count] == 0) {
        [self loadDatabaseWithBibleBooks];
        
    }
    
    // for offline bible verses
    NSArray* offlineBibles = [DBHelper getOfflineBible];
    if ([offlineBibles count] == 0) {
        [self loadDatabaseWithOfflineBible];
        
    }
    // for verse number according to bible chapter
    NSArray *bibleVerse = [DBHelper getBibleVerse];
    if ([bibleVerse count] == 0) {
        [self loadDatabaseWithBibleVerse];
    }
    // for languages
    NSArray *languagelist = [DBHelper getLanguageList];
    if ([languagelist count] == 0) {
        [self loadDatabaseWithLanguages];
    }
}
#pragma mark - Country List for auto resposne
- (void)loadDatabaseWithCountryList{
    
    NSString *initialDataFile = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"];
    NSError *readJsonError = nil;
    NSArray *initialData = [NSJSONSerialization
                            JSONObjectWithData:[NSData dataWithContentsOfFile:initialDataFile]
                            options:kNilOptions
                            error:&readJsonError];
    
    if(!initialData) {
        NSLog(@"Could not read JSON file: %@", readJsonError);
        abort();
    }
    [initialData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Country * failedBankInfo = [[CoreData sharedManager]newEntityForName:@"Country"];
        failedBankInfo.countryName = [obj objectForKey:@"name"];
        failedBankInfo.countryId = [NSString stringWithFormat:@"%d",[[obj objectForKey:@"country_id"]integerValue]];
        
    }];
    [[CoreData sharedManager]saveEntity];
    
    
    
    
}

#pragma mark - Bible Book names

- (void)loadDatabaseWithBibleBooks{
    
    NSString *initialDataFile = [[NSBundle mainBundle] pathForResource:@"bible_books" ofType:@"json"];
    NSError *readJsonError = nil;
    NSArray *initialData = [NSJSONSerialization
                            JSONObjectWithData:[NSData dataWithContentsOfFile:initialDataFile]
                            options:kNilOptions
                            error:&readJsonError];
    
    if(!initialData) {
        NSLog(@"Could not read JSON file: %@", readJsonError);
        abort();
    }
    [initialData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BibleBooks * bibleBook = [[CoreData sharedManager]newEntityForName:@"BibleBooks"];
        
        
        bibleBook.uniqueId = [NSString stringWithFormat:@"%d",[[obj objectForKey:@"id"]integerValue]];
        bibleBook.dam_id = [obj objectForKey:@"dam_id"];//[NSString stringWithFormat:@"%d",[[obj objectForKey:@"dam_id"]integerValue]];
        bibleBook.bible_type = [obj objectForKey:@"bible_type"];
        bibleBook.book_id = [obj objectForKey:@"book_id"];//[NSString stringWithFormat:@"%d",[[obj objectForKey:@"book_id"]integerValue]];
        bibleBook.book_name = [obj objectForKey:@"book_name"];
        bibleBook.book_order =[NSNumber numberWithInt: [[obj objectForKey:@"book_order"]doubleValue]];
        bibleBook.number_of_chapters = [NSString stringWithFormat:@"%d",[[obj objectForKey:@"number_of_chapters"]integerValue]];
        bibleBook.chapters = [obj objectForKey:@"chapters"];
        bibleBook.bible_name = [obj objectForKey:@"bible_name"];
        bibleBook.language = [obj objectForKey:@"language"];
        
    }];
    [[CoreData sharedManager]saveEntity];
    
    
}

#pragma mark - Bible Offline
- (void)loadDatabaseWithOfflineBible{
    
    NSString *initialDataFile = [[NSBundle mainBundle] pathForResource:@"bible_offline" ofType:@"json"];
    NSError *readJsonError = nil;
    NSArray *initialData = [NSJSONSerialization
                            JSONObjectWithData:[NSData dataWithContentsOfFile:initialDataFile]
                            options:kNilOptions
                            error:&readJsonError];
    
    if(!initialData) {
        NSLog(@"Could not read JSON file: %@", readJsonError);
        abort();
    }
    [initialData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        OfflineBible * bibleBook = [[CoreData sharedManager]newEntityForName:@"OfflineBible"];
        
        bibleBook.uniqueId = [NSString stringWithFormat:@"%d",[[obj objectForKey:@"id"]integerValue]];
        bibleBook.bible_type = [obj objectForKey:@"bible_type"];
        bibleBook.book_name = [obj objectForKey:@"book_name"];
        bibleBook.chapter =  [NSString stringWithFormat:@"%d",[[obj objectForKey:@"chapter"]integerValue]];
        bibleBook.verse = [NSString stringWithFormat:@"%d",[[obj objectForKey:@"verse"]integerValue]];
        bibleBook.verse_text = [obj objectForKey:@"verse_text"];
        
    }];
    [[CoreData sharedManager]saveEntity];
    
}

#pragma mark - Bible verses
- (void)loadDatabaseWithBibleVerse{
    
    NSString *initialDataFile = [[NSBundle mainBundle] pathForResource:@"bible_verse" ofType:@"json"];
    NSError *readJsonError = nil;
    NSArray *initialData = [NSJSONSerialization
                            JSONObjectWithData:[NSData dataWithContentsOfFile:initialDataFile]
                            options:kNilOptions
                            error:&readJsonError];
    
    if(!initialData) {
        NSLog(@"Could not read JSON file: %@", readJsonError);
        abort();
    }
    [initialData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        BibleVerse * bibleBook = [[CoreData sharedManager]newEntityForName:@"BibleVerse"];
        
        bibleBook.uniqueId = [NSString stringWithFormat:@"%d",[[obj objectForKey:@"id"]integerValue]];
        bibleBook.bible_name = [obj objectForKey:@"bible_name"];
        bibleBook.book_order = [NSNumber numberWithInt: [[obj objectForKey:@"book_order"]doubleValue]];
        bibleBook.chapter = [NSString stringWithFormat:@"%d",[[obj objectForKey:@"chapter"]integerValue]];
        bibleBook.verse = [NSNumber numberWithInt:[[obj objectForKey:@"verse"]integerValue]];
        
        
        bibleBook.language = [obj objectForKey:@"language"];
        
    }];
    [[CoreData sharedManager]saveEntity];
    
    
}
- (void)loadDatabaseWithLanguages{
    
    NSString *initialDataFile = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"json"];
    NSError *readJsonError = nil;
    NSArray *initialData = [NSJSONSerialization
                            JSONObjectWithData:[NSData dataWithContentsOfFile:initialDataFile]
                            options:kNilOptions
                            error:&readJsonError];
    
    if(!initialData) {
        NSLog(@"Could not read JSON file: %@", readJsonError);
        abort();
    }
    [initialData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        Language * languageSample = [[CoreData sharedManager]newEntityForName:@"Language"];
        
        languageSample.bible_version = [obj objectForKey:@"bible_version"];
        languageSample.language = [obj objectForKey:@"language"];
        languageSample.code = [obj objectForKey:@"code"];
        
    }];
    [[CoreData sharedManager]saveEntity];
    
}


- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}


@end
