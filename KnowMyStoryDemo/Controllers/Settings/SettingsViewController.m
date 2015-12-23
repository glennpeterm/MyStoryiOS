//
//  SettingsViewController.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 13/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "SettingsViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SignUpViewController.h"
#import "AboutMyStoryViewController.h"

#define NUM_TOP_ITEMS 2
#define NUM_SUBITEMS 6

#define kABOUT_US_TEXT @"Nowadays a variety of software, including text editors and plug-ins, can generate semi-random \"lorem-like text\", which often has little or nothing in common with the canonical adaptations other than looking like (and often being) jumbled Latin"

#define kCREDITS_TEXT @"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."

@interface SettingsViewController()
{
    
}
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialise];
    
}

- (void)initialise
{
    
    int screenWidth =self.view.frame.size.width;
    int screenHeight = self.view.frame.size.height ;
    
    if (screenWidth < screenHeight)
    {
        screenHeight =self.view.frame.size.width;
        screenWidth = self.view.frame.size.height;
    }
    
    self.shadowImage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowImage.layer.shadowOffset = CGSizeMake(0, 1);
    self.shadowImage.layer.shadowOpacity = 1;
    self.shadowImage.layer.shadowRadius = 1.4;
    self.shadowImage.clipsToBounds = NO;
    
    self.settingsTitle.font = kFONT_BOLD_SIZE_30;
    self.abtTheAppBtn.titleLabel.font = kFONT_BUTTON_SIZE_15;
    self.rateTheAppBtn.titleLabel.font = kFONT_BUTTON_SIZE_15;
    self.termsAndConditionsBtn.titleLabel.font = kFONT_BUTTON_SIZE_15;
    self.privacyPolicyBtn.titleLabel.font = kFONT_BUTTON_SIZE_15;
    self.logoutBtn.titleLabel.font = kFONT_BUTTON_SIZE_15;
    self.rightofCompnyBtn.titleLabel.font = kFONT_BUTTON_SIZE_15;
    UserInfo *user = [DBHelper getLoggedInUser];
    
    if (user && user.emailId != nil)
    {
        self.logoutBtn.hidden = NO;
    }
    else
    {
        self.logoutBtn.hidden = YES;
    }
    
    self.buildInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 21)];
    self.buildInfo.font = kFONT_ABEL_SIZE_14;
    self.buildInfo.text = [NSString stringWithFormat:@"Version: %@ Build: %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    [self.buildInfo setCenter:CGPointMake(screenWidth/2, screenHeight - self.buildInfo.frame.size.height/2)];
    [self.view addSubview:self.buildInfo];
}
#pragma mark -Button actions

- (IBAction)onPrivacyPolicyBtnClicked:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://mystory.buzz/privacypolicy"];
    //NSURL *url = [NSURL URLWithString:@"http://mystory.buzz/privacypolicy"];
    
    if (![[UIApplication sharedApplication] openURL:url])
    {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
    
}

- (IBAction)onCopyRightBtnClicked:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://mystory.buzz/copyright"];
    
    if (![[UIApplication sharedApplication] openURL:url])
    {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
    
}

- (IBAction)onTermsNConditionsBtnClicked:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://mystory.buzz/termsofservice"];
    
    if (![[UIApplication sharedApplication] openURL:url])
    {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}

- (IBAction)onAboutMyStoryBtnClicked:(id)sender
{
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"
                                                  bundle:nil];
    AboutMyStoryViewController *aboutVC=[sb instantiateViewControllerWithIdentifier:@"AboutMyStoryViewController"] ;
    [self presentViewController:aboutVC animated:NO completion:nil];
}

- (IBAction)onRateUsButtonClicked:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id990162296"];
    //itms-apps://itunes.apple.com/app/id990162296
    //http://itunes.apple.com/app/id990162296
    
    if (![[UIApplication sharedApplication] openURL:url])
    {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
    
    
}
- (IBAction)onLogoutButtonClicked:(id)sender

{
    [self deleteUser];
    //[[SignUpViewController sharedInstance]logoUT];
    [self showAlertWithMessage:@"User Logged Out Successfully"];
    
}
- (IBAction)onHomeButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{}];
}

#pragma mark - Logout

- (void)deleteUser
{
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserInfo"];
    result = [[CoreData sharedManager]executeCoreDataFetchRequest:fetchRequest];
    for (UserInfo *user in result)
    {
        [[[CoreData sharedManager] managedObjectContext] deleteObject:user];
    }
    [[CoreData sharedManager]saveEntity];
}
#pragma mark - Alert
- (void)showAlertWithMessage:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: kALERT_TITLE
                                                        message: message
                                                       delegate: self
                                              cancelButtonTitle: kALERT_OK_BUTTON
                                              otherButtonTitles: nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.logoutBtn.hidden = YES;
}
@end
