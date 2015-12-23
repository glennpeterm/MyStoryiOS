//
//  ScriptureSearchService.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 06/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "ScriptureSearchService.h"


@interface ScriptureSearchService ()
{
    ServiceType serviceTypeRequested;
    BibleBooks *selectedbible;
    BibleVerse *selectedverse;
    
    NSString *bibleQuery;
}
@end
@implementation ScriptureSearchService
- (void)initService:(ServiceType)serviceType withBibleInfo:(BibleBooks * )bibleInfo  andVerseInfo:(BibleVerse *) selectedVerse target:(id)delegate{
    if(self)
    {
        serviceTypeRequested = serviceType;
        self.jsonParserObject = [[ScriptureSearchParser alloc]init];
        selectedbible = bibleInfo;
        selectedverse = selectedVerse;
        NSString *url = [self createUrlForService];
        NSLog(@"URL : %@",url);
        NSLog(@"Body : %@",bibleInfo);
      
        if(url.length)
        {
            
            BOOL status =  [self initRequest:url withDelegate:delegate];
            if(status)
                NSLog(@"Request for creating user  successfully");
            else
            {
                NSLog(@"Failed to  creating user  successfully");
            }
            
        }
        
    }

}
- (void)initService:(ServiceType)serviceType   withSearchText:(NSString *)searchText target:(id)delegate{
    if(self)
    {
        serviceTypeRequested = serviceType;
        self.jsonParserObject = [[ScriptureSearchParser alloc]init];
        
        bibleQuery = searchText;
        NSString *url = [self createUrlForService];
        NSLog(@"URL : %@",url);
       
        
        if(url.length)
        {
            
            BOOL status =  [self initRequest:url withDelegate:delegate];
            if(status)
                NSLog(@"Request for creating user  successfully");
            else
            {
                NSLog(@"Failed to  creating user  successfully");
            }
            
        }
        
    }

}
- (NSString *)createUrlForService{
    NSString* baseUrl = BASE_BIBLE_URL;
    if (serviceTypeRequested  == ServiceTypeScriptureSearch) {
        
        if ( baseUrl != nil ){
            
            NSString* createUserAPI = [NSString stringWithFormat:SCRIPTURE_SEARCH,BIBLE_KEYWORD,selectedbible.dam_id,selectedbible.book_id,selectedverse.chapter,selectedverse.verse];
            
            return [baseUrl stringByAppendingString:createUserAPI];
        }
        
    }else if (serviceTypeRequested == ServiceTypeScriptureForKeyword){
        if ( baseUrl != nil ){
            
            NSString* createUserAPI = [NSString stringWithFormat:SCRIPTURE_SEARCH_FOR_KEYWORD,BIBLE_KEYWORD,bibleQuery];
            
            return [baseUrl stringByAppendingString:createUserAPI];
        }
    }
    return nil;

}


-(void)responseSuccessfulNotification:(id)response
{
    id result = nil;
    if(response != nil)
    {
         if (serviceTypeRequested ==ServiceTypeScriptureSearch || serviceTypeRequested == ServiceTypeScriptureForKeyword ) {
             result = [self.jsonParserObject parseScriptureSearchResponse:response];
             if (result) {
                 if (result == nil || [result count] == 0) {
                     NSLog(@"Empty Array found while parsing");
                     [super responseFailedNotification:result];

                 } else {
                     [super responseSuccessfulNotification:result];

                 }
             }else{
                  [super responseFailedNotification:result];
             }
         }
        
    }
    else
    {
        [super responseFailedNotification:result];
    }
}

-(void)responseFailedNotification:(id)response
{
    NSError * error =  (NSError *)response;
    NSString * errorResponse = [error localizedDescription];
    [super responseFailedNotification:errorResponse];
}

- (void)dealloc
{
    NSLog(@"scripture Dealloc");
    
}

@end
