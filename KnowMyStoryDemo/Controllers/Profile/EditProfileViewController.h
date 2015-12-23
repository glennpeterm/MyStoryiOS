//
//  ProfileViewController.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 20/01/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LoginWebService.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UserInfo.h"

@interface EditProfileViewController : UIViewController<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *shadowImage;
@property (weak, nonatomic) IBOutlet UIView *profileContentView;

@property (weak, nonatomic) IBOutlet UIView *datePickerView;
@property (strong, nonatomic) UserInfo *loginInformation;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UILabel *emailID;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePic;
@property (weak, nonatomic) IBOutlet UISegmentedControl *userGender;
@property (weak, nonatomic) IBOutlet UIButton *dob;
@property (weak, nonatomic) IBOutlet UIDatePicker *dateOfbirth;
@property (weak, nonatomic) IBOutlet UIScrollView *profileInfoScrollView;
@property (weak, nonatomic) IBOutlet UITextField *addressText;
@property (weak, nonatomic) IBOutlet UITextField *cityText;
@property (weak, nonatomic) IBOutlet UITextField *stateText;
@property (weak, nonatomic) IBOutlet UITextField *phoneNoText;
@property (weak, nonatomic) IBOutlet UITextField *countryText;
@property (weak, nonatomic) IBOutlet UITextField *zipCodeText;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImage *fbProfilePic;
@property (nonatomic, assign)BOOL isNewMember;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *profileTitle;
@property (weak, nonatomic) IBOutlet UILabel *genderTitle;
@property (weak, nonatomic) IBOutlet UIView *countryInfolist;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *editProfilePic;
@property (weak, nonatomic) IBOutlet UIPickerView *countryPicker;
@property (weak, nonatomic) IBOutlet UIView *countryBaseView;


- (IBAction)onCloseButtonclicked:(id)sender;

- (IBAction)onEditProfilePicButtonClick:(id)sender;

- (IBAction)onHomeButtonClicked:(id)sender;
- (IBAction)onDOBButtonClicked:(id)sender;
- (IBAction)onSelectingDate:(id)sender;

- (IBAction)onSaveButtonClicked:(id)sender;
- (IBAction)onResetButtonClicked:(id)sender;
@end
