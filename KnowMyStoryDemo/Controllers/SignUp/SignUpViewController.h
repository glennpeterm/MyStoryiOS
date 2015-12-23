//
//  ViewController.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 20/01/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
//#import <GooglePlus/GooglePlus.h>
#import <TwitterKit/TwitterKit.h>

@interface SignUpViewController : UIViewController//<GPPSignInDelegate>

//@property (weak, nonatomic) IBOutlet GPPSignInButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *signUpTitle;
@property (weak, nonatomic) IBOutlet UILabel *termsStatement;
@property (weak, nonatomic) IBOutlet UIButton *termsBtn;
//@property (weak, nonatomic) IBOutlet UIButton *twitterLoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *fbLoginBtn;
@property (strong, nonatomic) IBOutlet UIView *twitterView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (nonatomic, assign)BOOL isForMySelfies;
@property (nonatomic, assign)BOOL isForMyProfile;

#pragma mark Singleton Methods
+ (SignUpViewController *)sharedInstance;
- (void)startServiceForUpdatingUser:(UserInfo *)infos;
- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier;
- (IBAction)onTwitterLoginButtonClicked:(id)sender ;
- (IBAction)OnClickOfTermsStatement:(id)sender;
- (void)logoUT;
- (IBAction)onBackBtnClicked:(id)sender;
@property (weak, nonatomic) IBOutlet TWTRLogInButton *twitterLoginBtn;
- (IBAction)onHomeBtnClicked:(id)sender;

- (IBAction)onGoogleLoginClicked:(id)sender;
- (IBAction)onFBLoginBtnClicked:(id)sender;
@end

