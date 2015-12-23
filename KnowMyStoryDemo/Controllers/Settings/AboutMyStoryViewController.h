//
//  AboutMyStoryViewController.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 02/03/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutMyStoryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *aboutTitle;
@property (weak, nonatomic) IBOutlet UIImageView *shadowImage;
@property (weak, nonatomic) IBOutlet UIScrollView *aboutScrollView;
@property (weak, nonatomic) IBOutlet UIButton *aboutTitleBtn;
@property (weak, nonatomic) IBOutlet UITextView *aboutText;
- (IBAction)onBackBtnClicked:(id)sender;
- (IBAction)onOneHopeLogoClicked:(id)sender;

@end
