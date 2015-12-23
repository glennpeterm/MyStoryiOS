//
//  DBHelper.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 28/01/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "DBHelper.h"
#import "UserInfo.h"

#import "Country.h"
@implementation DBHelper

+(NSArray *)getCountryListInOrder{
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Country"];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"countryName" ascending:YES], nil]];
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    return result;
    
}

+(NSArray *)getCountryList{
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Country"];
    
    
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    return result;
    
}
+ (NSString *)getLanguageCodeOfLanguage:(NSString *)selectedLanguage{
    NSString *code = @"";
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Language"];
    
    
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"language == [c] %@",selectedLanguage];
    NSArray *filteredUsers = [result filteredArrayUsingPredicate:predicate];
    if ([filteredUsers count]>0) {
        Language *langobj = [filteredUsers objectAtIndex:0];
        return langobj.code;
    }
    return code;
}
+(Language *)getlanguageOfLetter:(NSString *)selectedLetter{
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Language"];
    
    
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"language BEGINSWITH[c] %@",selectedLetter];
    NSArray *filteredUsers = [result filteredArrayUsingPredicate:predicate];
    if ([filteredUsers count]>0) {
        Language *langobj = [filteredUsers objectAtIndex:0];
        return langobj;
    }
    
    return nil;
}
+(Country *)getCountryOfLetter:(NSString *)selectedLetter{
    
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Country"];
    
    
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"countryName BEGINSWITH[c] %@",selectedLetter];
    NSArray *filteredUsers = [result filteredArrayUsingPredicate:predicate];
    if ([filteredUsers count]>0) {
        Country *countryobj = [filteredUsers objectAtIndex:0];
        return countryobj;
    }
    
    return nil;
}
+(NSArray *)getFilteredCountryList : (NSString *)searchString{
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Country"];
    
    
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"countryName contains[c] %@", searchString];
    NSArray *filteredUsers = [result filteredArrayUsingPredicate:predicate];
    return filteredUsers;
    
}
+(NSArray *)checkUserInfoInDB {
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserInfo"];
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    return result;
    
}
+(BOOL)isUserLoggedIn{
    UserInfo *user = [DBHelper getLoggedInUser];
    if (user) {
        return YES;
    }
    return NO;
}
+(UserInfo *)getLoggedInUser {
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserInfo"];
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    if ([result count]!=0) {
        UserInfo *user = [result objectAtIndex:0];
        NSLog(@"email id : %@", user.emailId);
        
        
        
        return user;
    }
    return nil;
}
+(NSString *)getEmailIdOfLoggedInUser {
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserInfo"];
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    if ([result count]!=0) {
        UserInfo *user = [result objectAtIndex:0];
        return user.emailId;
    }
    return nil;
}

+(NSArray *)getBibleBookNames{
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BibleBooks"];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"book_order" ascending:YES], nil]];
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    return result;
}
+(NSArray *)getOfflineBible{
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"OfflineBible"];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"uniqueId" ascending:YES], nil]];
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    return result;
    
}

+(NSArray *)getBibleVerse{
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BibleVerse"];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"verse" ascending:YES], nil]];
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    return result;
    
}

+(NSArray *)getFilteredBibleVerse : (NSString *)chapterNumber withBookOrder :(NSString *)bookOrder{
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BibleVerse"];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"verse" ascending:YES], nil]];
    
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chapter == %@ && book_order == %@", chapterNumber,bookOrder];
    NSArray *filteredUsers = [result filteredArrayUsingPredicate:predicate];
    return filteredUsers;
    
}
+(NSArray *)getFilteredBibleVersesList : (NSString *)searchString{
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"OfflineBible"];
    
    
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"verse_text contains[c] %@", searchString];
    NSArray *filteredUsers = [result filteredArrayUsingPredicate:predicate];
    return filteredUsers;
    
}
+(NSArray *)getLanguageList{
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Language"];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"language" ascending:YES], nil]];
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    return result;
}

+(NSArray *)getFilteredLanguageList : (NSString *)searchString{
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Language"];
    
    
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"language contains[c] %@", searchString];
    NSArray *filteredUsers = [result filteredArrayUsingPredicate:predicate];
    return filteredUsers;
    
}
@end
