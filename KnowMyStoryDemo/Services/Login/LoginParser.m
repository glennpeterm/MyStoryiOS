
/*
 
 File Name   : LoginParser.m
 Created by  : Aswathy Bose
 Created on  : 1/6/14.
 Copyright (c) 2014 Payment Processing Partners, Inc. All rights reserved.
 */

#import "LoginParser.h"
#import "Country.h"
#import "UserInfo.h"

@implementation LoginParser

-(id)parseLoginResponse:(id)response{
    id resultInfo =[self parseResponse:response];
    
    if([resultInfo isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *result = (NSDictionary *)resultInfo;
        {
            
            UserInfo *loginInfo;
            
            loginInfo = [DBHelper getLoggedInUser];
            if (!loginInfo) {
                
                
                loginInfo  = [[CoreData sharedManager]newEntityForName:@"UserInfo"];
            }
            if([result objectForKey:@"firstName"]&& ![[result objectForKey:@"firstName"]isEqual:[NSNull null]]&&[result objectForKey:@"firstName"]!=nil){
                
                loginInfo.firstName = [result objectForKey:@"firstName"];
            }
            if([result objectForKey:@"lastName"]&& ![[result objectForKey:@"lastName"]isEqual:[NSNull null]]&&[result objectForKey:@"lastName"]!=nil){
                
                loginInfo.lastName = [result objectForKey:@"lastName"];
            }
            if([result objectForKey:@"email"]&& ![[result objectForKey:@"email"]isEqual:[NSNull null]]&&[result objectForKey:@"email"]!=nil){
                
                loginInfo.emailId = [result objectForKey:@"email"];
            }
            if([result objectForKey:@"gender"]&& ![[result objectForKey:@"gender"]isEqual:[NSNull null]]&&[result objectForKey:@"gender"]!=nil){
                
                loginInfo.gender = [result objectForKey:@"gender"];
            }
            
            if([result objectForKey:@"dob"]&& ![[result objectForKey:@"dob"]isEqual:[NSNull null]]&&[result objectForKey:@"dob"]!=nil){
                
                loginInfo.dob = [result objectForKey:@"dob"];
            }
            if([result objectForKey:@"address"]&& ![[result objectForKey:@"address"]isEqual:[NSNull null]]&&[result objectForKey:@"address"]!=nil){
                
                
                loginInfo.address = [result objectForKey:@"address"];
            }
            if([result objectForKey:@"city"]&& ![[result objectForKey:@"city"]isEqual:[NSNull null]]&&[result objectForKey:@"city"]!=nil){
                
                loginInfo.city = [result objectForKey:@"city"];
            }
            if([result objectForKey:@"state"]&& ![[result objectForKey:@"state"]isEqual:[NSNull null]]&&[result objectForKey:@"state"]!=nil){
                
                loginInfo.state = [result objectForKey:@"state"];
            }
                       if([result objectForKey:@"photo"]&& ![[result objectForKey:@"photo"]isEqual:[NSNull null]]&&[result objectForKey:@"photo"]!=nil){
            
                           loginInfo.photo = [result objectForKey:@"photo"];
                       }
            if([result objectForKey:@"zipcode"]&& ![[result objectForKey:@"zipcode"]isEqual:[NSNull null]]&&[result objectForKey:@"zipcode"]!=nil){
                
                loginInfo.zipCode = [result objectForKey:@"zipcode"];
            }
            
            if([result objectForKey:@"country"]&& ![[result objectForKey:@"country"]isEqual:[NSNull null]]&&[result objectForKey:@"country"]!=nil){
                
                loginInfo.country = [result objectForKey:@"country"];
            }
            if([result objectForKey:@"phone"]&& ![[result objectForKey:@"phone"]isEqual:[NSNull null]]&&[result objectForKey:@"phone"]!=nil){
                
                loginInfo.phoneNumber = [result objectForKey:@"phone"];
            }
            if([result objectForKey:@"provider"]&& ![[result objectForKey:@"provider"]isEqual:[NSNull null]]&&[result objectForKey:@"provider"]!=nil){
                
                loginInfo.provider = [result objectForKey:@"provider"];
            }
            
            if([result objectForKey:@"provider_info"]&& ![[result objectForKey:@"provider_info"]isEqual:[NSNull null]]&&[result objectForKey:@"provider_info"]!=nil){
                
                loginInfo.providerInfo = [result objectForKey:@"provider_info"];
            }
            //           if([result objectForKey:@"authToken"]){
            //
            //               loginInfo.accesstoken = [result objectForKey:@"authToken"];
            //           }
            if([result objectForKey:@"isactive"]&& ![[result objectForKey:@"isactive"]isEqual:[NSNull null]]&&[result objectForKey:@"isactive"]!=nil){
                
                if ([[result objectForKey:@"isactive"] isEqualToString:@"active"]) {
                    loginInfo.isActive = [NSNumber numberWithBool:YES];
                }else{
                    loginInfo.isActive = [NSNumber numberWithBool:NO];
                }

            }
            if (loginInfo.emailId.length ==0) {
                loginInfo.emailId = [[NSUserDefaults standardUserDefaults]objectForKey:@"Email"];
            }
            [[CoreData sharedManager]saveEntity];
           
            return loginInfo;
            
        }
    }else if ([resultInfo isKindOfClass:[Response class]]){
        return resultInfo;
    }
    return nil;
}




@end
