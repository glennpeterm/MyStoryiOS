//
//  ViewController.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 20/01/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "SignUpViewController.h"
#import "EditProfileViewController.h"
#import "STTwitter.h"
#import "UserInfo.h"
#import <CoreLocation/CoreLocation.h>
#import "GoogleAuthentication.h"
//#import <GooglePlus/GooglePlus.h>
#import <TwitterKit/TwitterKit.h>
#import "ProfileDetailsViewController.h"
#import "YoutubeUploadViewController.h"
#import "ChannelsAndSelfiesViewController.h"
@interface SignUpViewController () <FBLoginViewDelegate>
{
    // GPPSignIn *signIn;
    UserInfo * info;
    //  LoadingOverlayView *overlayView;
    BOOL isUserLoggedIn;
    UIImage *fbProfilePic;
    NSString * fbProfileId;
    FBLoginView *loginview;
    ServiceType serviceTypeRequested;
    TWTRLogInButton *logInButton;
    GoogleAuthentication* authen;
    
    BOOL isGoogleLoginClicked;
    
}

@property (strong, nonatomic) id<FBGraphUser> loggedInUser;
@property (nonatomic, strong) STTwitterAPI *twitter;
@end

@implementation SignUpViewController
@synthesize isForMyProfile;
static SignUpViewController *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (SignUpViewController *)sharedInstance
{
    if (sharedInstance == nil)
    {
        //sharedInstance = [[SignUpViewController alloc] init];
    }
    
    return sharedInstance;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        sharedInstance = self;
    }
    return self;
}
- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    sharedInstance = self;
    self.termsStatement.font = kFONT_BOLD_SIZE_17;
    self.signUpTitle.font = kFONT_BOLD_SIZE_30;
    self.backBtn.titleLabel.font = kFONT_BOLD_SIZE_30;
    if (self.termsBtn.selected) {
        [self OnClickOfTermsStatement:nil];
        
    }
    self.fbLoginBtn.titleLabel.font = kBUTTON_FONT_SIZE_15;
    self.signInButton.titleLabel.font = kBUTTON_FONT_SIZE_15;
    //    self.fbLoginBtn.layer.cornerRadius = 3.0;
    isUserLoggedIn = NO;
    
    [self showTwitterLogin];
    // [self signIntoGooglePlus];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isGoogleLoginClicked = NO;
    if (self.termsBtn.selected) {
        loginview.userInteractionEnabled = YES;
        self.signInButton.userInteractionEnabled = YES;
        self.twitterLoginBtn.userInteractionEnabled = YES;
        self.fbLoginBtn.userInteractionEnabled = YES;
        self.twitterView.userInteractionEnabled = YES;
    }else{
        loginview.userInteractionEnabled = NO;
        self.signInButton.userInteractionEnabled = NO;
        self.twitterLoginBtn.userInteractionEnabled = NO;
        self.fbLoginBtn.userInteractionEnabled = NO;
        self.twitterView.userInteractionEnabled = NO;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    isUserLoggedIn = NO;
    
    //[self getProfilePicFromGoogleForUserID:@"109603446650888130907" completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - handle Segue Operations


- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
#pragma mark - Twitter Login

- (void)showTwitterLogin{
    
    
    
    logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession *session, NSError *error) {
        
        // play with Twitter session
        [self showOverlayView];
        
        
        NSLog(@"Username : %@",session.userName);
        
        [[[Twitter sharedInstance] APIClient] loadUserWithID:session.userID completion:^(TWTRUser *user,NSError *error){
            
            if (user) {
                
                NSLog(@"user details %@",user.name);
                
                info  = [DBHelper getLoggedInUser];
                
                NSArray *fullName = [user.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
                
                if (!info) {
                    
                    info =     [[CoreData sharedManager]newEntityForName:@"UserInfo"];
                    
                }
                
                if ([fullName objectAtIndex:0]) {
                    
                    info.firstName = fullName[0];
                    
                }
                
                if ([fullName count] > 1 && [fullName objectAtIndex:1]) {
                    
                    info.lastName = fullName[1];
                    
                }
                else
                {
                    info.lastName = @"";
                }
                
                info.emailId = user.screenName;
                
                if (user.profileImageLargeURL) {
                    
                    NSURL *fbUserPic = [NSURL URLWithString:user.profileImageLargeURL];
                    
                    NSData *data = [NSData dataWithContentsOfURL:fbUserPic];
                    
                    fbProfilePic = [UIImage imageWithData:data];
                    
                }
                
                if (fbProfilePic) {
                    
                    info.photo = [self encodeToBase64String:fbProfilePic];
                    
                }
                
                info.provider = @"Twitter";
                
                [[CoreData sharedManager]saveEntity];
                
                [self viewProfilePageForCreationOfUser];
                
            }
            else{
                [self removeOverlayView];
                [self showAlert:@"Twitter Login Failed" message:error.localizedDescription];
            }
            
            
            
            
        }];
        
        
        
        if ([[Twitter sharedInstance] session]) {
            
            //            TWTRShareEmailViewController shareEmailViewController =[[TWTRShareEmailViewController alloc]initWithCompletion:^(NSString* email, NSError* error) { NSLog(@"Email %@, Error: %@", email, error);}];
            
            //
            
            //            [self presentViewController:shareEmailViewController animated:YES completion:nil];
            
        }
        
        else {
            
        }
        
    }];
    
    logInButton.frame = CGRectMake(0, 0, 145, 38);
    
    
    // [logInButton setBackgroundImage:[UIImage imageNamed:@"login_twitter"] forState:UIControlStateNormal];
    [logInButton setBackgroundColor:[UIColor colorWithRed:71/255.0 green:186/255 blue:231/255 alpha:1.0]];
    [logInButton setTitle:@"Twitter" forState:UIControlStateNormal];
    [logInButton setImage:[UIImage imageNamed:@"twitterIcon" ] forState:UIControlStateNormal];
    
    logInButton.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    logInButton.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    logInButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    logInButton.contentVerticalAlignment =  UIControlContentVerticalAlignmentCenter;
    
    // [logInButton setImage:nil forState:UIControlStateNormal];
    // logInButton.center = CGPointMake(392, 162);
    logInButton.layer.cornerRadius = 0;
    logInButton.titleLabel.font = kBUTTON_FONT_SIZE_15;
    [self.twitterView addSubview:logInButton];
    NSArray *views = [logInButton subviews];
    for (id SubView in views)
    {
        if ([SubView isKindOfClass:[UIImageView class]])
        {
            //[(UIImageView*)SubView setBackgroundColor:[UIColor greenColor]];
        }
        else if ([SubView isKindOfClass:[UIView class]])
        {
            // [(UIView*)SubView setBackgroundColor:[UIColor redColor]];
            [SubView setHidden:YES];
        }
        
        
    }
    
    
    
}

- (IBAction)onTwitterLoginButtonClicked:(id)sender {
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:k_TWITTER_CONSUMER_KEY
                                                 consumerSecret:k_TWITTER_CONSUMER_SECREAT];
    
    
    
    [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        NSLog(@"-- url: %@", url);
        NSLog(@"-- oauthToken: %@", oauthToken);
        
        
        [[UIApplication sharedApplication] openURL:url];
        
        
        
    } authenticateInsteadOfAuthorize:NO
                    forceLogin:@(YES)
                    screenName:nil
                 oauthCallback:@"knowmystory://twitter_access_tokens/"
                    errorBlock:^(NSError *error) {
                        NSLog(@"-- error: %@", error);
                        
                    }];
    
}
#pragma mark - handle Segue Operations
- (void)handleTermsBtn{
    
}
- (IBAction)OnClickOfTermsStatement:(id)sender {
    self.termsBtn.selected = !self.termsBtn.selected;
    if (self.termsBtn.selected) {
        loginview.userInteractionEnabled = YES;
        self.signInButton.userInteractionEnabled = YES;
        self.twitterLoginBtn.userInteractionEnabled = YES;
        self.fbLoginBtn.userInteractionEnabled = YES;
        self.twitterView.userInteractionEnabled = YES;
    }else{
        loginview.userInteractionEnabled = NO;
        self.signInButton.userInteractionEnabled = NO;
        self.twitterLoginBtn.userInteractionEnabled = NO;
        self.fbLoginBtn.userInteractionEnabled = NO;
        self.twitterView.userInteractionEnabled = NO;
    }
    
}
- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    NSLog(@"verify : %@",verifier);
    
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        
        [_twitter getUserInformationFor:screenName successBlock:^(NSDictionary * user) {
            NSLog(@"%@",user);
            info  = [DBHelper getLoggedInUser];
            NSArray *fullName = [[user objectForKey:@"name"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
            if (!info) {
                info =     [[CoreData sharedManager]newEntityForName:@"UserInfo"];
            }
            if ([fullName objectAtIndex:0]) {
                info.firstName = fullName[0];
            }
            if ([fullName objectAtIndex:1]) {
                info.lastName = fullName[1];
            }
            info.emailId = screenName;
            if ([user objectForKey:@"profile_image_url"]) {
                NSURL *fbUserPic = [NSURL URLWithString:[user objectForKey:@"profile_image_url"]];
                NSData *data = [NSData dataWithContentsOfURL:fbUserPic];
                fbProfilePic = [UIImage imageWithData:data];
            }
            if (fbProfilePic) {
                info.photo = [self encodeToBase64String:fbProfilePic];
            }
            info.provider = @"Twitter";
            [[CoreData sharedManager]saveEntity];
            [self viewProfilePageForCreationOfUser];
            //  [self performSegueWithIdentifier:@"viewProfile" sender:self];
        }
                             errorBlock:^(NSError *error) {
            NSLog(@"error user info ");
        }];
        
        
        
        
    } errorBlock:^(NSError *error) {
        
        
        NSLog(@"-- error%@", [error localizedDescription]);
    }];
    
}
#pragma mark  - Google Sign In


- (IBAction)onGoogleLoginClicked:(id)sender {
    
    [self showOverlayView];
    isGoogleLoginClicked = YES;
    authen = [[GoogleAuthentication alloc]initWithScope:@"https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/plus.me"
                                               clientID: GOOGLE_APP_ID clientSecret:GOOGLE_APP_SECREAT keychainItemName:@"google_credent" completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
                                                   // self.navigationItem.rightBarButtonItem = nil;
                                                   
                                                   if (!error) {
                                                       // [self showOverlayView];
                                                       NSLog(@"%@",auth.parameters);
                                                       
                                                       
                                                       info  = [DBHelper getLoggedInUser];
                                                       if (!info) {
                                                           info =     [[CoreData sharedManager]newEntityForName:@"UserInfo"];
                                                       }
                                                       info.emailId = [auth.parameters objectForKey:@"email"];
                                                       info.provider = @"Google";
                                                       info.providerInfo = @"Google";
                                                       NSString *subString = [info.emailId substringWithRange: NSMakeRange(0, [info.emailId rangeOfString: @"@"].location)];
                                                       info.firstName = subString;
                                                       info.lastName = @"";
                                                       info.photo = @"";
                                                       fbProfilePic = nil;
                                                       NSLog(@"Firstname : %@",subString);
                                                       
                                                       
                                                       //Abdu 07 May
                                                       //For Profile pic , but no profile pic is set in google it will returning default pic from google
                                                       // 1
                                                       [self getProfilePicFromGoogleForUserID:[auth.parameters objectForKey:@"userID"] completion:^(NSURL *googlePicUrl, NSError *error)
                                                       {
                                                           if (googlePicUrl)
                                                           {
                                                               NSData *data = [NSData dataWithContentsOfURL:googlePicUrl];
                                                               fbProfilePic = [UIImage imageWithData:data];
                                                               
                                                               if (fbProfilePic)
                                                               {
                                                                   info.photo = [self encodeToBase64String:fbProfilePic];
                                                               }
                                                           }
                                                           
                                                           [[CoreData sharedManager]saveEntity];
                                                           [self viewProfilePageForCreationOfUser];
                                                       }];
                                                       
                                                       
                                                       //[[CoreData sharedManager]saveEntity];
                                                       //[self viewProfilePageForCreationOfUser];
                                                       
                                                   }
                                                   else {
                                                       
                                                       [self removeOverlayView];
                                                       
                                                       NSLog(@"Authentication error: %@", error);
                                                       NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
                                                       if ([responseData length] > 0) {
                                                           // show the body of the server's authentication failure response
                                                           NSString *str = [[NSString alloc] initWithData:responseData
                                                                                                 encoding:NSUTF8StringEncoding];
                                                           NSLog(@"%@", str);
                                                       }
                                                       if (error.code!=1000 || error.code!=1001) {
                                                           [self showAlert:@"Login error" message:error.localizedDescription];
                                                       }
                                                       
                                                       
                                                   }
                                                   
                                                   // [self updateUI];
                                                   
                                               }];
    
    
    authen.view.backgroundColor = [UIColor clearColor];
    
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:authen animated:NO completion:nil];
    
    
}
-(void)getProfilePicFromGoogleForUserID:(NSString *)userID completion:(void(^)(NSURL *googlePicUrl, NSError *error))completion
{
    NSError *error;
    NSURL *aUrl;
    NSMutableURLRequest *request;
    if (!userID) {
        if (completion)
            completion(nil, error);
        return;
    }
    
    //https://www.googleapis.com/plus/v1/people/115950284...320?fields=image&key={YOUR_API_KEY}
    //https://www.googleapis.com/plus/v1/people/109603446650888130907?fields=image&key={YOUR_API_KEY}
    //aUrl        = [NSURL URLWithString:[NSString stringWithFormat:@"http://picasaweb.google.com/data/entry/api/user/%@?alt=json",userID]];    //1
    aUrl        = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/plus/v1/people/%@?fields=image&key=%@",userID,GOOGLE_PLUS_API_KEY]];
    request     = [NSMutableURLRequest requestWithURL:aUrl
                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                      timeoutInterval:30];
    /*request     = [NSMutableURLRequest requestWithURL:aUrl
                                          cachePolicy:NSURLRequestReturnCacheDataDontLoad
                                      timeoutInterval:30];*/
    [request setHTTPMethod:@"GET"];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         if(error)
         {
             NSLog(@"sendAsynchronousRequest error :%@",error);
         }
         if (!data) {
             if (completion)
                 completion(nil, error);
             return;
         }
         
         NSError *parseError = nil;
         NSDictionary *returnDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
         KMSDebugLog(@"returnDict :%@",returnDict);
         
         
         
         
         NSURL *googlePicUrl = nil;
         /*if(returnDict) //1
         {
             NSMutableString *avatarURlStr = [NSMutableString stringWithString:[[[returnDict objectForKey:@"entry"] objectForKey:@"gphoto$thumbnail"] objectForKey:@"$t"]];
             [avatarURlStr replaceOccurrencesOfString:@"s64-c" withString:@"s200-c" options:0 range:NSMakeRange(0, [avatarURlStr length])];
             KMSDebugLog(@"avatarURlStr :%@",avatarURlStr);
             googlePicUrl = [NSURL URLWithString:avatarURlStr];
         }*/
         
         
         if(!parseError && returnDict) //2
         {
             @try
             {
                 NSMutableString *avatarURlStr = [NSMutableString stringWithString:[[returnDict objectForKey:@"image"] objectForKey:@"url"]];
                 [avatarURlStr replaceOccurrencesOfString:@"sz=50" withString:@"sz=200" options:0 range:NSMakeRange(0, [avatarURlStr length])];
                 KMSDebugLog(@"avatarURlStr :%@",avatarURlStr);
                 googlePicUrl = [NSURL URLWithString:avatarURlStr];
             }
             @catch (NSException *exception)
             {
                 KMSDebugLog(@"googlePlusProfilePic exception:%@", exception.reason);
             }
             
        
         }
         
         if (completion)
         {
             completion(googlePicUrl, parseError);
         }
     }];
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isGoogleLoginClicked) {
        [authen dismissViewControllerAnimated:NO completion:nil];
        isGoogleLoginClicked = NO;
    }
}
#pragma mark - FB Login
- (IBAction)onFBLoginBtnClicked:(id)sender {
    [self showOverlayView];
    [FBSession openActiveSessionWithReadPermissions:@[@"publish_stream", @"email"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         if (error) {
             [self removeOverlayView];
             if (error.code != 2) {
                 [self showAlert:@"Login Failed" message:error.localizedDescription];
             }
             
             // error
             
         }else {
             if (FBSession.activeSession.isOpen) {
                 [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary *user, NSError *error) {
                     if (!error) {
                         NSLog(@"user %@",user);
                         NSString *emailId=[user objectForKey:@"email"];
                         if (emailId.length >0) {
                             info  = [DBHelper getLoggedInUser];
                             if (!info)
                             {
                                 info =     [[CoreData sharedManager]newEntityForName:@"UserInfo"];
                             }
                             NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [user objectForKey:@"id"]];
                             NSURL *fbUserPic = [NSURL URLWithString:userImageURL];
                             NSData *data = [NSData dataWithContentsOfURL:fbUserPic];
                             fbProfilePic = [UIImage imageWithData:data];
                             info.emailId = [user objectForKey:@"email"];
                             info.firstName =[user objectForKey:@"first_name"];
                             info.lastName = [user objectForKey:@"last_name"];
                             info.gender = [user objectForKey:@"gender"];
                             info.dob = [user objectForKey:@"birthday"];
                             
                             
                             
                             info.profilePicId = [user objectForKey:@"id"];
                             info.provider = @"FB";
                             if (fbProfilePic)
                             {
                                 info.photo = [self encodeToBase64String:fbProfilePic];
                             }
                             
                             [[CoreData sharedManager]saveEntity];
                             [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:NO] forKey:IS_USER__TO_BE_CREATED];
                         }
                         
                     }
                     if (!isUserLoggedIn)
                     {
                         if (info.emailId)
                         {
                             [self viewProfilePageForCreationOfUser];
                         }else{
                             [self removeOverlayView];
                             [self logoUT];
                             [self showAlert:@"Login failed" message:@"Facebook Login failed"];
                         }
                         
                     }
                 }];
             }
         }
     }];
}


#pragma mark - FBLoginViewDelegate
- (void)logoUT{
    [FBSession.activeSession close];
    [FBSession.activeSession  closeAndClearTokenInformation];
}

#pragma mark - Button Actions

- (IBAction)onHomeBtnClicked:(id)sender {
    [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
}
- (IBAction)onBackBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{}];
    
}
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // first get the buttons set for login mode
    
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    self.loggedInUser = user;
    if (!isUserLoggedIn)
    {
        // here we use helper properties of FBGraphUser to dot-through to first_name and
        // id properties of the json response from the server; alternatively we could use
        // NSDictionary methods such as objectForKey to get values from the my json object
        
        
        
        // [self getProfilePic];
        
        
        
    }
    
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    // test to see if we can use the share dialog built into the Facebook application
    self.loggedInUser = nil;
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    // see https://developers.facebook.com/docs/reference/api/errors/ for general guidance on error handling for Facebook API
    // our policy here is to let the login view handle errors, but to log the results
    NSLog(@"FBLoginView encountered an error=%@", error);
}

#pragma mark -

// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void)performPublishAction:(void(^)(void))action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    action();
                                                } else if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission denied"
                                                                                                        message:@"Unable to get permission to post"
                                                                                                       delegate:nil
                                                                                              cancelButtonTitle:@"OK"
                                                                                              otherButtonTitles:nil];
                                                    [alertView show];
                                                }
                                            }];
    } else {
        action();
    }
    
}
// UIAlertView helper for post buttons
- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error {
    
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertTitle = @"Error";
        // Since we use FBRequestConnectionErrorBehaviorAlertUser,
        // we do not need to surface our own alert view if there is an
        // an fberrorUserMessage unless the session is closed.
        if (error.fberrorUserMessage && FBSession.activeSession.isOpen) {
            alertTitle = nil;
            
        } else {
            // Otherwise, use a general "connection problem" message.
            alertMsg = @"Operation failed due to a connection problem, retry later.";
        }
    } else {
        NSDictionary *resultDict = (NSDictionary *)result;
        alertMsg = [NSString stringWithFormat:@"Successfully posted '%@'.", message];
        NSString *postId = [resultDict valueForKey:@"id"];
        if (!postId) {
            postId = [resultDict valueForKey:@"postId"];
        }
        if (postId) {
            alertMsg = [NSString stringWithFormat:@"%@\nPost ID: %@", alertMsg, postId];
        }
        alertTitle = @"Success";
    }
    
    if (alertTitle) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                            message:alertMsg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
- (void)showAlert:(NSString *)title message:(NSString *)message
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
                                                    message: message
                                                   delegate: self
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    [alert show];
}
- (void)showAlertWithMessage:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: kALERT_TITLE
                                                        message: message
                                                       delegate: self
                                              cancelButtonTitle: kALERT_OK_BUTTON
                                              otherButtonTitles: nil];
    
    [alertView show];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.message isEqualToString:@"User is not active"]) {
        UIViewController *vc = self.presentingViewController.presentingViewController;
        [self dismissViewControllerAnimated:NO completion:^{}];
        [vc dismissViewControllerAnimated:NO completion:^{}];
    }
    if ([alertView.message isEqualToString:@"User not created successfully"]) {
        [self deleteUser];
        UIViewController *vc = self.presentingViewController.presentingViewController;
        [self dismissViewControllerAnimated:NO completion:^{}];
        [vc dismissViewControllerAnimated:NO completion:^{}];
    }
}
- (void)deleteUser{
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserInfo"];
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    for (UserInfo *user in result) {
        [[[CoreData sharedManager] managedObjectContext] deleteObject:user];
    }
}
#pragma mark  -  Overlay View Management

- (void)showOverlayView
{
    
    [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:ACTIVITY_LOADING_TEXT_SIGNING_IN showProgress:NO onController:self];
}

- (void)removeOverlayView
{
    
    [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];
}

#pragma mark - Service Calls

- (void)startServiceForUpdatingUser:(UserInfo *)infos{
    
    
    [self showOverlayView];
    serviceTypeRequested = ServiceTypeCreateUser;
    
    
    LoginWebService * loginInfoServiceObj = [[LoginWebService alloc]init];
    [loginInfoServiceObj initService:serviceTypeRequested body:infos  target:self];
    [loginInfoServiceObj start];
}

- (void)startServiceForViewProfile {
    [self showOverlayView];
    if (!info.emailId) {
        info =[DBHelper getLoggedInUser];
        if (!info) {
            info =     [[CoreData sharedManager]newEntityForName:@"UserInfo"];
            info.emailId = [self.loggedInUser objectForKey:@"email"];
            [[NSUserDefaults standardUserDefaults]setObject:[self.loggedInUser objectForKey:@"email"] forKey:@"Email"];
            [[CoreData sharedManager]saveEntity];
        }
    }
    NSLog(@"1 emailid %@",info.emailId);
    serviceTypeRequested = ServiceTypeGetDetailsOfUser;
    LoginWebService *loginService = [[LoginWebService alloc]init];
    NSLog(@"2 emailid %@",info.emailId);
    UserInfo *loginUser= [DBHelper getLoggedInUser];
    NSLog(@"3 email %@",loginUser.emailId);
    [loginService initService:ServiceTypeGetDetailsOfUser body:info target:self];
    [loginService start];
    
}

#pragma mark -  Service Class Delegate Methods
-(void)serviceSuccessful:(id)response
{
    [self removeOverlayView];
    info =[DBHelper getLoggedInUser];
    
    if (isForMyProfile) {
        
        self.isForMyProfile = NO;
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"
                                                      bundle:nil];
        ProfileDetailsViewController *profileVC = [ProfileDetailsViewController sharedInstance];
        if (!profileVC)
        {
            profileVC =[sb instantiateViewControllerWithIdentifier:@"ProfileDetailsViewController"];
        }
        if ([info.provider isEqualToString:@"FB"]||[info.provider isEqualToString:@"Google"]) {
            [self logoUT];
        }else if([info.provider isEqualToString: @"Twitter"]){
            
            [[Twitter sharedInstance]logOut];
        }
        
        [self presentViewController:profileVC animated:NO completion:nil];
    }
    else if (self.isForMySelfies)
    {
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"
                                                      bundle:nil];
        
        ChannelsAndSelfiesViewController *profileVC =[sb instantiateViewControllerWithIdentifier:@"ChannelsAndSelfiesViewController"];
        [profileVC setIsChannels:NO];
        if ([info.provider isEqualToString:@"FB"]) {
            [self logoUT];
        }
        [self presentViewController:profileVC animated:NO completion:nil];
        
        isUserLoggedIn = NO;
        
    }
    else
    {
        if ([info.isActive boolValue])
        {
            //UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"bundle:nil];
            
            //YoutubeUploadViewController *youtubeUploadVC = [sb instantiateViewControllerWithIdentifier:@"YoutubeUploadViewController"];
            
            // [self dismissViewControllerAnimated:NO completion:nil];
            if ([info.provider isEqualToString:@"FB"]) {
                [self logoUT];
            }
            [self presentViewController:[YoutubeUploadViewController sharedInstance] animated:NO completion:nil];
            [[YoutubeUploadViewController sharedInstance] uploadVideoToYoutube];
            isUserLoggedIn = NO;
        }
        else{
            isUserLoggedIn = YES;
            [self showAlertWithMessage:@"User is not active"];
        }
        
    }
    
    
    NSLog(@"success");
}

-(void)serviceFailed:(id)response {
    
    [self removeOverlayView];
    if ([response isKindOfClass:[NSString class]]) {
        NSString *failureMessage = (NSString*)response;
        if (serviceTypeRequested == ServiceTypeCreateUser) {
            [self deleteUser];
            [self showAlert:@"Login Failure" message:@"User not created successfully"];
        }
        if ([failureMessage isEqualToString:@"User not found"]) {
            [self startServiceForUpdatingUser:info];
        }
    }else{
        [self showAlertWithMessage:NO_SERVER_RESPONSE];
    }
}
- (void)networkError{
    
    [self removeOverlayView];
    [self showAlertWithMessage:kSERVICE_NETWORK_NOT_AVAILABLE_MSG];
}

- (void)isTheUserANewMenber{
    
    isUserLoggedIn = YES;
    [self startServiceForViewProfile];
}
-(void)viewProfilePageForCreationOfUser
{
    [self isTheUserANewMenber];
    
}
@end
