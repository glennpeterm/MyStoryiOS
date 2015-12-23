//
//  AboutMyStoryViewController.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 02/03/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "AboutMyStoryViewController.h"

@interface AboutMyStoryViewController ()

@end

#define kABOUT_US_TEXT @"My Story is a simple way to share the story of how God has impacted your life and explore the stories of others.\n\nRecord a video telling your story, select a scripture that has impacted you, and share the finished story with others letting them know that God has changed your life.\n\nMy Story integrates with MyStory.buzz  so that you can publish your story on a platform filled with stories of God's impact in the world. It also integrates with social media platforms and allows you to share publicly or privately with friends you\'d like to encourage. "

@implementation AboutMyStoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialiseView];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews
{
    [self.aboutScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 350)];
}

- (void)initialiseView
{
    self.shadowImage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowImage.layer.shadowOffset = CGSizeMake(0, 1);
    self.shadowImage.layer.shadowOpacity = 1;
    self.shadowImage.layer.shadowRadius = 1.4;
    self.shadowImage.clipsToBounds = NO;
    
    self.aboutText.font =kFONT_BOLD_SIZE_17;
    self.aboutText.text = kABOUT_US_TEXT;
    self.aboutTitleBtn.titleLabel.font= kFONT_BOLD_SIZE_30;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Button Actions

- (IBAction)onBackBtnClicked:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{}];
    
}

- (IBAction)onOneHopeLogoClicked:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://onehope.net"];
    if (![[UIApplication sharedApplication] openURL:url])
    {
        KMSDebugLog(@"%@%@",@"Failed to open url:",[url description]);
    }
    
}
@end
