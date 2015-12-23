//
//  DBHelper.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 28/01/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"
#import "BibleBooks.h"
#import "OfflineBible.h"
#import "BibleVerse.h"
#import "Country.h"
#import "Language.h"
@interface DBHelper : NSObject


+(BOOL)isUserLoggedIn;

+(NSArray *)getCountryList;
+(UserInfo *)getLoggedInUser;
+(NSArray *)getCountryListInOrder;
+(NSArray *)checkUserInfoInDB;
+(NSString *)getEmailIdOfLoggedInUser;
+(NSArray *)getBibleBookNames;
+(NSArray *)getOfflineBible;
+(NSArray *)getBibleVerse;
+(NSArray *)getLanguageList;


+(NSArray *)getFilteredBibleVerse : (NSString *)chapterNumber withBookOrder :(NSString *)bookOrder;
+(NSArray *)getFilteredCountryList : (NSString *)searchString;
+(NSArray *)getFilteredBibleVersesList : (NSString *)searchString;
+(NSArray *)getFilteredLanguageList : (NSString *)searchString;
+(Country *)getCountryOfLetter:(NSString *)selectedLetter;
+(Language *)getlanguageOfLetter:(NSString *)selectedLetter;
+(NSString *)getLanguageCodeOfLanguage:(NSString *)selectedLanguage;
@end
