//
//  ProfileDetailsViewController.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 03/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *shadowImage;
@property (weak, nonatomic) IBOutlet UILabel *userInfo;
@property (weak, nonatomic) IBOutlet UILabel *emailIdtext;
@property (weak, nonatomic) IBOutlet UILabel *addressInfo;
@property (weak, nonatomic) IBOutlet UILabel *mobileInfotext;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIButton *editProfileBtn;
@property (weak, nonatomic) IBOutlet UILabel *profileTitle;

@property (weak, nonatomic) IBOutlet UIImageView *mobileIcon;
@property (weak, nonatomic) IBOutlet UIImageView *locationIcon;
@property (weak, nonatomic) IBOutlet UIView *notlogedInView;
@property (weak, nonatomic) IBOutlet UILabel *noUserText;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

#pragma mark Singleton Methods
+ (ProfileDetailsViewController *)sharedInstance;

- (IBAction)onEditProfileBtnClicked:(id)sender;
- (IBAction)onHomeButtonClicked:(id)sender;
- (IBAction)onLogoutButtonClicked:(id)sender;


@end
