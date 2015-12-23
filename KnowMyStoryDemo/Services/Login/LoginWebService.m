
/*
 File Name   : LoginWebService.m
 Created by  : Aswathy Bose
 Created  on : 12/24/13.
 Copyright (c) 2013 Payment Processing Partners, Inc. All rights reserved.
 */

#import "LoginWebService.h"
#import "UserInfo.h"

@interface LoginWebService()
{
    //LoginInfo *createUserInfo;
    UserInfo *createUserInfo;
    ServiceType serviceTypeRequested;
    NSString * usernames;
    NSString * password;
    
}
@end
@implementation LoginWebService
@synthesize jsonParserObject;

- (void)initServiceForCountryList:(ServiceType)serviceType target:(id)delegate{
    
    if(self)
    {
        serviceTypeRequested = serviceType;
        jsonParserObject = [[LoginParser alloc]init];
        NSString *url = [self createUrlandBodyForService];
        NSLog(@"URL : %@",url);
        if(url.length)
        {
            
            BOOL status =  [self initRequest:url withBody:[[NSMutableDictionary alloc]init] andDelegate:delegate];
            if(status)
                NSLog(@"Request for creating user  successfully");
            else
            {
                NSLog(@"Failed to  creating user  successfully");
            }
            
        }
    }
    
}

- (void)initService:(ServiceType)serviceType body:(UserInfo *)loginInfo target:(id)delegate{
    
    serviceTypeRequested = serviceType;
    jsonParserObject = [[LoginParser alloc]init];
    createUserInfo = loginInfo;
    NSMutableDictionary *requestBody = [self createRequestBody];
    NSString *url = [self createUrlandBodyForService];
    NSLog(@"URL : %@",url);
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

- (NSMutableDictionary *)createRequestBody
{
    
    NSMutableDictionary *loginDict = [[NSMutableDictionary alloc]init];
    if (serviceTypeRequested == ServiceTypeCreateUser|| serviceTypeRequested == ServiceTypeUpdateUser) {
        
        if (createUserInfo.firstName) { [loginDict setObject:createUserInfo.firstName forKey:@"first_name"];}
        if (createUserInfo.lastName) { [loginDict setObject:createUserInfo.lastName forKey:@"last_name"];}
        if (createUserInfo.emailId) { [loginDict setObject:createUserInfo.emailId forKey:@"email"];}
        if (createUserInfo.gender){ [loginDict setObject:createUserInfo.gender forKey:@"gender"];}
        if (createUserInfo.dob) { [loginDict setObject:createUserInfo.dob forKey:@"dob"];}
        if (createUserInfo.address) { [loginDict setObject:createUserInfo.address forKey:@"address"];}
        if (createUserInfo.city) { [loginDict setObject:createUserInfo.city forKey:@"city"];}
        if (createUserInfo.state){  [loginDict setObject:createUserInfo.state forKey:@"state"];}
        if (createUserInfo.country)  { [loginDict setObject:createUserInfo.country forKey:@"country"];}
        if (createUserInfo.zipCode) {  [loginDict setObject:createUserInfo.zipCode forKey:@"zipcode"];}
        if (createUserInfo.photo)  { [loginDict setObject:createUserInfo.photo forKey:@"photo"];}
        if (createUserInfo.phoneNumber)  {  [loginDict setObject:createUserInfo.phoneNumber forKey:@"phone"];}
        if (createUserInfo.provider)  { [loginDict setObject:createUserInfo.provider forKey:@"provider"];}
        if (createUserInfo.provider) {   [loginDict setObject:createUserInfo.provider forKey:@"provider_info"];}
        [loginDict setObject:[[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0] forKey:@"language"];
        
        
    }else if (serviceTypeRequested == ServiceTypeGetDetailsOfUser){
        if (createUserInfo.emailId) { [loginDict setObject:createUserInfo.emailId forKey:@"email"];}
        [loginDict setObject:[[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0] forKey:@"language"];
    }
    return loginDict;
}

-(NSString *)createUrlandBodyForService
{
    NSString* baseUrl = BASE_URL;
    
    if (serviceTypeRequested  == ServiceTypeCreateUser) {
        
        if ( baseUrl != nil ){
            
            NSString* createUserAPI = [NSString stringWithFormat:CREATE_USER];
            
            return [baseUrl stringByAppendingString:createUserAPI];
        }
        
    }else  if (serviceTypeRequested == ServiceTypeUpdateUser){
        if ( baseUrl != nil ){
            
            NSString* updateUserAPI = [NSString stringWithFormat:UPDATE_USER];
            
            return [baseUrl stringByAppendingString:updateUserAPI];
        }
        
    }else  if (serviceTypeRequested == ServiceTypeGetDetailsOfUser){
        if ( baseUrl != nil ){
            
            NSString* viewUserAPI = [NSString stringWithFormat:VIEW_USER_DETAIILS];
            
            return [baseUrl stringByAppendingString:viewUserAPI];
        }
        
    }
    return nil;
}
-(void)responseSuccessfulNotification:(id)response
{
    id result = nil;
    if(response != nil)
    {
        
        if (serviceTypeRequested ==ServiceTypeCreateUser ||serviceTypeRequested == ServiceTypeUpdateUser  || serviceTypeRequested == ServiceTypeGetDetailsOfUser) {
            result = [jsonParserObject parseLoginResponse:response];
            
        }
        if (result) {
            if ([result isKindOfClass:[Response class]]) {
                Response *failureResponse =(Response *)result;
                [super responseFailedNotification:failureResponse.messageString];
            }else if ([result isKindOfClass:[UserInfo class]]){
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
