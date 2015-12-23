//
//  UserInfo.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 21/01/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * dob;
@property (nonatomic, retain) NSString * emailId;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSString * provider;
@property (nonatomic, retain) NSString * providerInfo;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * zipCode;
@property (nonatomic, retain) NSString * profilePicId;

@end
