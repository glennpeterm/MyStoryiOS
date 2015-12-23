//
//  YoutubeUploadService.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 28/01/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "YoutubeUploadService.h"
@interface YoutubeUploadService()
{
   
    ServiceType serviceTypeRequested;
      
}
@end
@implementation YoutubeUploadService
@synthesize jsonParserObject;

- (void)initService:(ServiceType)serviceType withUploadedData:(NSMutableDictionary * )uploadedData target:(id)delegate{
    if(self)
    {
        serviceTypeRequested = serviceType;
        jsonParserObject = [[YoutubeUploadParser alloc]init];
        NSString *url = [self createUrlandBodyForService];
        NSLog(@"URL : %@",url);
         NSLog(@"Body : %@",uploadedData);
        if(url.length)
        {
            
            BOOL status =  [self initRequest:url withBody:uploadedData andDelegate:delegate];
            if(status)
                NSLog(@"Request for creating user  successfully");
            else
            {
                NSLog(@"Failed to  creating user  successfully");
            }
            
        }

    }
}
-(NSString *)createUrlandBodyForService
{
    NSString* baseUrl = BASE_URL;
    if (serviceTypeRequested  == ServiceTypeYoutubeResponseUpload) {
        
        if ( baseUrl != nil ){
            
            NSString* createUserAPI = [NSString stringWithFormat:YOUTUBE_UPLOAD];
            
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
        if (serviceTypeRequested ==ServiceTypeYoutubeResponseUpload ) {
            result = [jsonParserObject parseUploadResponse:response];
            
        }
        if (result) {
            if ([result isKindOfClass:[Response class]]) {
                Response *failureResponse =(Response *)result;
                [super responseFailedNotification:failureResponse.messageString];
            }else {
                [super responseSuccessfulNotification:result];
            }
        }else{
            [super responseFailedNotification:result];
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
    NSLog(@"login Dealloc");
    
}

@end
