//
//  TestViewController.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 04/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelsAndSelfiesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webViewTest;

@property (assign, nonatomic)BOOL isChannels;

- (IBAction)onHomeButtonClicked:(id)sender;

@end
