//
//  ChannelsAndSelfiesViewController.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 04/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "ChannelsAndSelfiesViewController.h"
#import "ChannelsAndSelfiesService.h"
#import "UserInfo.h"
#import "SignUpViewController.h"

@interface ChannelsAndSelfiesViewController ()

@end

@implementation ChannelsAndSelfiesViewController
@synthesize isChannels;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showOverlayView];
    
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startServiceForChannelsAndSelfiesList];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark  -  Overlay View Management

- (void)showOverlayView
{
    [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:ACTIVITY_LOADING_TEXT_LOADING showProgress:NO onController:self];
}

- (void)removeOverlayView
{
    [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark -  Button Actions

- (IBAction)onHomeButtonClicked:(id)sender
{
    UIViewController *vc = self.presentingViewController.presentingViewController;
    if ([vc isKindOfClass:[SignUpViewController class]])
    {
        vc =self.presentingViewController.presentingViewController.presentingViewController;
    }
    
    if ([vc isKindOfClass:[WizardViewController class]])
    {
        vc =self.presentingViewController.presentingViewController.presentingViewController;
        [vc dismissViewControllerAnimated:NO completion:nil];

    } else {
        [self dismissViewControllerAnimated:NO completion:nil];

    }

    if (vc)
    {
        [vc dismissViewControllerAnimated:NO completion:nil];
    }
    
    
}
#pragma mark - Webview Delegates

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self removeOverlayView];
}

//Abdu 12 June 2015
/*- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
 if ([[[request URL] scheme] isEqual:@"mailto"]) {
 [[UIApplication sharedApplication] openURL:[request URL]];
 return NO;
 }
 return YES;
 }*/

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    
    NSLog(@"StartLoadWithRequest :%@",[inRequest URL]);
     //NSLog(@"StartLoadWithRequest scheme :%@",[[inRequest URL] ]);
    NSString *requestURLStr = [[inRequest URL] absoluteString];
    
    if ([[[inRequest URL] scheme] isEqual:@"mailto"])
    {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    else if ( inType == UIWebViewNavigationTypeLinkClicked)
     {
         if ([requestURLStr containsString:FACEBOOK_SHARE_URL] || [requestURLStr containsString:TWITTER_SHARE_URL])
         {
             [[UIApplication sharedApplication] openURL:[inRequest URL]];
             return NO;
         }
     
     }
    
    return YES;
}

#pragma mark - Alert

- (void)showAlertWithMessage:(NSString *)message
{
    
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@""
                                                  message:message delegate:self
                                        cancelButtonTitle:kALERT_OK_BUTTON
                                        otherButtonTitles: nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self onHomeButtonClicked:nil];
}
#pragma mark  - SERVICE CALLS
- (void)startServiceForChannelsAndSelfiesList
{
    ServiceType serviceTypeRequest = ServiceTypeChannelsView;
    if (self.isChannels)
    {
        serviceTypeRequest = ServiceTypeChannelsView;
    }
    else
    {
        serviceTypeRequest = ServiceTypeMySelfiesView;
    }
    ChannelsAndSelfiesService *channelService = [[ChannelsAndSelfiesService alloc]init];
    [channelService initServiceForChannelsAndSelfies:serviceTypeRequest target:self];
    [channelService start];
}

#pragma mark - Service calls and Delegates

- (void)serviceSuccessful:(id)response
{
    if ([response isKindOfClass:[NSString class]])
    {
        NSString *urlStr = (NSString *)response;
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webViewTest setScalesPageToFit:YES];
        [self.webViewTest loadRequest:request];
    }
}
- (void)serviceFailed:(id)response
{
    [self removeOverlayView];
    if ([response isKindOfClass:[NSString class]])
    {
        NSString *failureMsg = (NSString *)response;
        
        if ([failureMsg isEqualToString:@"Video not found"])
        {
            failureMsg = @"You have not uploaded your selfie video yet, once it’s uploaded you will be able to find it here";
        }
        [self showAlertWithMessage:failureMsg];
        
    }
    else
    {
        [self showAlertWithMessage:NO_SERVER_RESPONSE];
    }
}
-(void)networkError
{
    [self removeOverlayView];
    [self showAlertWithMessage:kSERVICE_NETWORK_NOT_AVAILABLE_MSG];
}

@end
