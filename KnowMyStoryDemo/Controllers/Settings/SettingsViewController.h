//
//  SettingsViewController.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 13/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *settingsTitle;
@property (weak, nonatomic) IBOutlet UIImageView *shadowImage;

@property (weak, nonatomic) IBOutlet UIButton *abtTheAppBtn;
@property (weak, nonatomic) IBOutlet UIButton *rateTheAppBtn;
@property (weak, nonatomic) IBOutlet UIButton *termsAndConditionsBtn;
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightofCompnyBtn;

@property (strong, nonatomic) UILabel *buildInfo;

- (IBAction)onPrivacyPolicyBtnClicked:(id)sender;
- (IBAction)onCopyRightBtnClicked:(id)sender;
- (IBAction)onTermsNConditionsBtnClicked:(id)sender;
- (IBAction)onAboutMyStoryBtnClicked:(id)sender;
- (IBAction)onRateUsButtonClicked:(id)sender;
- (IBAction)onLogoutButtonClicked:(id)sender;
- (IBAction)onHomeButtonClicked:(id)sender;

@end
