//
//  TopicService.m
//  KnowMyStoryDemo
//
//  Created by Abdusha on 10/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "TopicService.h"

@interface TopicService ()
{
    ServiceType serviceTypeRequested;
}
@end
@implementation TopicService
- (void)initServiceForTopic:(ServiceType)serviceType target:(id)delegate{
    if(self)
    {
        serviceTypeRequested = serviceType;
        self.jsonParserObject = [[TopicParser alloc]init];
               NSString *url = [self createUrlForService];
        //NSLog(@"URL : %@",url);
        NSDictionary *requestBody = [self createRequestBody];
        
        if(url.length)
        {
            
            BOOL status =  [self initRequest:url withBody:requestBody andDelegate:delegate];
            if(status)
            {
                NSLog(@"Request for topic list successfull");
            }
            else
            {
                NSLog(@"Failed topic list request");
            }
            
        }
        
    }

}


- (NSDictionary *)createRequestBody{
    NSMutableDictionary *loginDict = [[NSMutableDictionary alloc]init];
    [loginDict setObject:[[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0] forKey:@"language"];
    
    return loginDict;
}

- (NSString *)createUrlForService{
    NSString* baseUrl = BASE_URL;
    if (serviceTypeRequested  == ServiceTypeTopicList) {
        
        if ( baseUrl != nil ){
            
            NSString* createUserAPI = [NSString stringWithFormat:@"%@",TOPIC_LIST];
            
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
        if (serviceTypeRequested == ServiceTypeTopicList) {
            result = [self.jsonParserObject parseTopicParserViewResponse:response];
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
    //NSLog(@"scripture Dealloc");
    
}

@end
