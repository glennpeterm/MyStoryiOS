//
//  ChannelsAndSelfiesService.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 10/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "ChannelsAndSelfiesService.h"
#import "UserInfo.h"

@interface ChannelsAndSelfiesService ()
{
    ServiceType serviceTypeRequested;
  
}
@end
@implementation ChannelsAndSelfiesService
- (void)initServiceForChannelsAndSelfies:(ServiceType)serviceType target:(id)delegate{
    if(self)
    {
        serviceTypeRequested = serviceType;
        self.jsonParserObject = [[ChannelsAndSelfiesParser alloc]init];
               NSString *url = [self createUrlForService];
        NSLog(@"URL : %@",url);
        NSDictionary *requestBody = [self createRequestBody];
        
        if(url.length)
        {
            
            BOOL status =  [self initRequest:url withBody:requestBody andDelegate:delegate];
            if(status)
                NSLog(@"Request for creating user  successfully");
            else
            {
                NSLog(@"Failed to  creating user  successfully");
            }
            
        }
        
    }

}


- (NSDictionary *)createRequestBody{
    NSMutableDictionary *loginDict = [[NSMutableDictionary alloc]init];
    [loginDict setObject:[[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0] forKey:@"language"];
    if (serviceTypeRequested  == ServiceTypeMySelfiesView) {
        UserInfo *loggedInuser = [DBHelper getLoggedInUser];
         if (loggedInuser.emailId) { [loginDict setObject:loggedInuser.emailId forKey:@"email"];}
    }
    return loginDict;
}

- (NSString *)createUrlForService{
    NSString* baseUrl = BASE_URL;
    if (serviceTypeRequested  == ServiceTypeChannelsView) {
        
        if ( baseUrl != nil ){
            
            NSString* createUserAPI = [NSString stringWithFormat:@"%@",CHANNELS_VIEW];
            
            return [baseUrl stringByAppendingString:createUserAPI];
        }
        
    }else if (serviceTypeRequested  == ServiceTypeMySelfiesView) {
        
        if ( baseUrl != nil ){
            
            NSString* createUserAPI = [NSString stringWithFormat:@"%@",MY_SELFIES_VIEW];
            
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
        if (serviceTypeRequested ==ServiceTypeChannelsView ||serviceTypeRequested ==ServiceTypeMySelfiesView ) {
            result = [self.jsonParserObject parseChannelsANdSelfiesViewResponse:response];
            if (result) {
                if ([result isKindOfClass:[Response class]]) {
                    Response *failureResponse =(Response *)result;
                    [super responseFailedNotification:failureResponse.messageString];
                }else{
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
