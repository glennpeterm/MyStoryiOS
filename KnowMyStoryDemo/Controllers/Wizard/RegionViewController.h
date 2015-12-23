//
//  RegionViewController.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 27/01/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
//#import "LoginWebService.h"

@interface RegionViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
}

@property (nonatomic, assign)BOOL isNewMember;
@property (assign, nonatomic)BOOL isForSelfy;
@property (strong, nonatomic) UserInfo *loginInformation;

@property (weak, nonatomic) IBOutlet UITextField *countryText;
@property (weak, nonatomic) IBOutlet UIButton *dismissBtn;
@property (weak, nonatomic) IBOutlet UIView *countryListView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UITextField *languageText;
@property (weak, nonatomic) IBOutlet UIScrollView *regionScrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleText;

@property (weak, nonatomic) IBOutlet UIImageView *languageMandatoryMarkerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *countryMandatoryMarkerImageView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

#pragma mark Singleton Methods
+ (RegionViewController *)sharedInstance;


#pragma mark - Button actions
- (IBAction)onHomeButtonClicked:(id)sender;
- (IBAction)onNextButtonClicked:(id)sender;

-(void)configureView;
-(void)hideAndStopViewActions;

-(BOOL)isMandatoryFieldsFilled;

@end
