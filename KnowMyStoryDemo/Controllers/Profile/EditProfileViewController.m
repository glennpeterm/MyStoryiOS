//
//  EditProfileViewController.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 20/01/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "EditProfileViewController.h"
#import "Country.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ProfileDetailsViewController.h"
#import "ChannelsAndSelfiesViewController.h"

@interface EditProfileViewController()
{
    
    NSMutableArray *countryList;
    NSArray *sectionTitles;
    UITextField * currentlyEditingTextField;
    
    
}
@end
@implementation EditProfileViewController
@synthesize loginInformation;
@synthesize fbProfilePic;


- (void)viewDidLoad{
    [super viewDidLoad];
    KMSDebugLog();
    // for handling view on keyboard up and down
    [self registerKeyboardNotifications];
    sectionTitles =  @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    self.dateOfbirth.hidden = YES;
    [self initialiseView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    KMSDebugLog();
    [self showOverlayViewWithMessage:@""];
    self.profileInfoScrollView.contentOffset = CGPointMake(0, 0);
}
- (void)viewDidAppear:(BOOL)animated{
    KMSDebugLog();
    [super viewDidAppear:animated];
    countryList = [[NSMutableArray alloc]initWithArray:[DBHelper getCountryListInOrder]];
    [self.tableView reloadData];
    [self initialize];
    [self.userGender setTintColor:ORANGE_COLOR];
    [self performSelector:@selector(removeOverlayView) withObject:nil afterDelay:0.5];
}

- (void)viewDidLayoutSubviews
{
    self.profileInfoScrollView.contentSize = self.profileContentView.frame.size;
}
- (void)initialiseView
{
    self.shadowImage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowImage.layer.shadowOffset = CGSizeMake(0, 1);
    self.shadowImage.layer.shadowOpacity = 1;
    self.shadowImage.layer.shadowRadius = 1.4;
    self.shadowImage.clipsToBounds = NO;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.firstName.leftView = paddingView;
    self.firstName.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *lastNamepaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.lastName.leftView = lastNamepaddingView;
    self.lastName.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *phoneNopaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.phoneNoText.leftView = phoneNopaddingView;
    self.phoneNoText.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *addresspaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.addressText.leftView = addresspaddingView;
    self.addressText.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *citypaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.cityText.leftView = citypaddingView;
    self.cityText.leftViewMode = UITextFieldViewModeAlways;
    
    self.stateText.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.stateText.leftViewMode = UITextFieldViewModeAlways;
    
    
    UIView *countrypaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.countryText.leftView = countrypaddingView;
    self.countryText.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *zippaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.zipCodeText.leftView = zippaddingView;
    self.zipCodeText.leftViewMode = UITextFieldViewModeAlways;
    
    self.saveButton.titleLabel.font = kFONT_BUTTON_SIZE_15;
    self.emailID.font = kFONT_BOLD_SIZE_15;
    self.profileTitle.font = kFONT_BOLD_SIZE_30;;
    self.firstName.font = kFONT_BOLD_SIZE_15;
    self.lastName.font = kFONT_BOLD_SIZE_15;
    self.phoneNoText.font =kFONT_BOLD_SIZE_15;
    self.addressText.font = kFONT_BOLD_SIZE_15;
    self.cityText.font = kFONT_BOLD_SIZE_15;
    self.stateText.font = kFONT_BOLD_SIZE_15;
    self.countryText.font =kFONT_BOLD_SIZE_15;
    self.zipCodeText.font = kFONT_BOLD_SIZE_15;
    self.genderTitle.font = kFONT_BOLD_SIZE_15;
    self.dob.titleLabel.font = kFONT_BOLD_SIZE_15;
    self.editProfilePic.titleLabel.font = kFONT_BUTTON_SIZE_15;
    
    self.profileImage.layer.borderWidth =.5;
    self.profileImage.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.profileImage.contentMode = UIViewContentModeScaleAspectFit;
    
    //Abdu 08 April 15
    self.userGender.layer.cornerRadius = 0.0;
    self.userGender.layer.borderColor = ORANGE_COLOR.CGColor;
    self.userGender.layer.borderWidth = 2;
    
}
-(void)dismissKeyboard
{
    [self.view endEditing:YES];
    if (currentlyEditingTextField)
    {
        [self.profileInfoScrollView scrollRectToVisible:currentlyEditingTextField.frame animated:YES];
    }
    
}
-(void)initialize{
    NSArray *users = [self getUserinfoFromDB];
    if ([users count]>0)
    {
        // setting firstname, lastname, dob,gender of the logged in user
        
        self.loginInformation = [users objectAtIndex:0];
        self.firstName.text = self.loginInformation.firstName;
        self.lastName.text = self.loginInformation.lastName;
        self.emailID.text = self.loginInformation.emailId;
        if ([self.loginInformation.gender hasPrefix:@"f"])
        {
            [self.userGender setSelectedSegmentIndex:1];
        }
        else
        {
            [self.userGender setSelectedSegmentIndex:0];
        }
        if (self.loginInformation.dob.length >0 && ![self.loginInformation.dob isEqualToString:@"0000-00-00"])
        {
            [self.dob setTitle:self.loginInformation.dob forState:UIControlStateNormal];
        }
        if (self.loginInformation.photo.length >0)
        {
            if (self.fbProfilePic)
            {
                self.profileImage.image =  self.fbProfilePic;
            }
            else if ([self.loginInformation.photo hasPrefix:@"http"])
            {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.loginInformation.photo]];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                
                self.profileImage.image = image;
            }
            else
            {
                
                self.profileImage.image = [self getdecodedImage:self.loginInformation.photo];
            }
            self.fbProfilePic =self.profileImage.image;
        }
        else
        {
            self.profileImage.image =[UIImage imageNamed:@"defauls_profile.png"];
        }
        
        self.phoneNoText.text = self.loginInformation.phoneNumber;
        self.addressText.text = self.loginInformation.address;
        self.cityText.text = self.loginInformation.city;
        self.stateText.text = self.loginInformation.state;
        self.countryText.text = self.loginInformation.country;
        self.zipCodeText.text = self.loginInformation.zipCode;
        
    }
    if(self.isNewMember)
    {
        self.resetButton.hidden = YES;
        [self.saveButton setTitle:@"Create" forState:UIControlStateNormal];
    }
    else
    {
        self.resetButton.hidden = NO;
        [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    }
}

- (UIImage *)getdecodedImage:(NSString *)base64String
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}
#pragma mark - Keyboard Notifications

- (void)registerKeyboardNotifications
{
    //to handle view according to keyboard movement
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardDidShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void)unregisterKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) keyboardWillHide:(NSNotification *)note
{
    [self adjusProfileViewFrame:NO];
}

-(void) keyboardWillShow:(NSNotification *)note
{
    [self adjusProfileViewFrame:YES];
}
- (void)adjusProfileViewFrame:(BOOL)isKeyBoardAppeared
{
    //adjusting view according to keyboard visibility
    KMSDebugLog(@"adjusProfileViewFrame :%d ",isKeyBoardAppeared);
    if (isKeyBoardAppeared)
    {
        //[self.profileInfoScrollView setContentSize:CGSizeMake(self.profileInfoScrollView.frame.size.width, 750)];
    }
    else
    {
        // [self.profileInfoScrollView setContentSize:CGSizeMake(self.profileInfoScrollView.frame.size.width, 560)];
        [self.profileInfoScrollView setContentSize:self.profileContentView.frame.size];
        [self dismissKeyboard];
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    if ((!self.countryInfolist.isHidden) && (CGRectContainsPoint(self.countryBaseView.frame, touchLocation) == NO))
    {
        [self hideCountryList];
        return;
    }
    
    if (self.dob.hidden)
    {
        [self onSelectingDate:nil];
    }
    
    if(![touch.view isEqual:[UITextField class]])
    {
        [self dismissKeyboard];
    }
}

#pragma mark- TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return sectionTitles;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([currentlyEditingTextField isEqual:self.countryText])
    {
        NSString *selectedLetter = [sectionTitles objectAtIndex:index];
        int moveToIndex = 0;
        Country *countryObj = [DBHelper getCountryOfLetter:selectedLetter];
        if (countryObj)
        {
            moveToIndex = [countryList indexOfObject:countryObj];
            /*
             moveToIndex will have the location of the first occurence of the search letter.
             Get the indexPath from the location and call scrollToRowAtIndexPath to scroll to the cell with the
             text starting with the search letter.
             */
            NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:moveToIndex inSection:0];
            
            [self.tableView scrollToRowAtIndexPath:selectedPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        else
        {
            moveToIndex = 0;
        }
    }
    return [sectionTitles indexOfObject:title];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [countryList count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    Country *count= [countryList objectAtIndex:indexPath.row];
    if ([self.countryText.text isEqualToString:count.countryName])
    {
        cell.accessoryType  = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = count.countryName;
    return cell;
    
}
#pragma mark- tableview delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Country *count= [countryList objectAtIndex:indexPath.row];
    self.countryText.text = count.countryName;
    [self hideCountryList];
    [self.tableView reloadData];
}

// tell the picker the width of each row for a given component
#pragma mark - Handle CountryList
- (void)showCountryList
{
    self.countryInfolist.hidden = NO;
    // self.countryText.hidden = YES;
}
- (void)hideCountryList
{
    KMSDebugLog(@"hideCountryList");
    self.countryInfolist.hidden = YES;
    //self.countryText.hidden = NO;
}
#pragma mark - Fetching from DB
- (NSArray *)getUserinfoFromDB
{
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserInfo"];
    result = [[CoreData sharedManager] executeCoreDataFetchRequest:fetchRequest];
    return result;
}

#pragma mark - UITextField Delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.countryText])
    {
        [self showCountryList];
        [self.view endEditing:YES];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentlyEditingTextField =textField;
    // adjusting the view according to the editing textfield, so that the editing textfield is present in the visible area
    self.dateOfbirth.hidden = YES;
    self.dob.hidden = NO;
    if ([textField isEqual:self.countryText])
    {
        [self showCountryList];
        // self.profileInfoScrollView.contentOffset = CGPointMake(0, self.saveButton.frame.origin.y);
        [self.view endEditing:YES];
    }
    else
    {
        [self hideCountryList];
        self.profileInfoScrollView.contentOffset = CGPointMake(0, textField.frame.origin.y-textField.frame.size.height -10);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.countryText])
    {
        NSString *substring = [NSString stringWithString:textField.text];
        substring = [substring stringByReplacingCharactersInRange:range withString:string];
        [self searchAutocompleteEntriesWithSubstring:substring];
    }
    return YES;
}
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring
{
    if ([countryList count] >0)
    {
        [countryList removeAllObjects];
    }
    if (substring.length == 0)
    {
        countryList = [[NSMutableArray alloc]initWithArray:[DBHelper getCountryListInOrder]];
    }
    else
    {
        countryList =[[NSMutableArray alloc]initWithArray: [DBHelper getFilteredCountryList:substring]];
    }
    [self.tableView reloadData];
}
-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    // on clicking the return button on keyboard , managing the focus the next editable field.
    if ([textField isEqual:self.firstName])
    {
        [self.lastName becomeFirstResponder];
    }
    else if([textField isEqual:self.lastName])
    {
        [self.lastName resignFirstResponder];
    }
    else if ([textField isEqual:self.phoneNoText])
    {
        [self.addressText becomeFirstResponder];
    }
    else if ([textField isEqual:self.addressText])
    {
        [self.cityText becomeFirstResponder];
    }
    else if ([textField isEqual:self.cityText])
    {
        [self.stateText becomeFirstResponder];
    }
    else if ([textField isEqual:self.stateText])
    {
        [self.countryText becomeFirstResponder];
        [self.countryText resignFirstResponder];
    }
    else if ([textField isEqual:self.countryText])
    {
        [self hideCountryList];
        [self.zipCodeText becomeFirstResponder];
    }
    else if ([textField isEqual:self.zipCodeText])
    {
        // to dismiss the keyboard on done button click
        [self.zipCodeText resignFirstResponder];
        //self.profileInfoScrollView.contentOffset = CGPointMake(0,0);
        
    }
    else
    {
        // to dismiss the keyboard
        [textField resignFirstResponder];
        //self.profileInfoScrollView.contentOffset = CGPointMake(0,0);
    }
    
    return YES;
}
- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    return YES;
}
#pragma mark  - Button Actions

- (IBAction)onCloseButtonclicked:(id)sender
{
}


- (IBAction)onHomeButtonClicked:(id)sender
{
    [self showOverlayViewWithMessage:@""];
    [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)onDOBButtonClicked:(id)sender
{
    
    // on appearing the datepicker for dismissing the keyboard
    [self.view endEditing:YES];
    // setting the scroll view to the area
    self.profileInfoScrollView.contentOffset = CGPointMake(0, self.lastName.frame.origin.y-self.lastName.frame.size.height -10);
    self.dateOfbirth.hidden = NO;
    self.dob.hidden = YES;
    self.datePickerView.hidden = NO;
}

- (IBAction)onSelectingDate:(id)sender
{
    
    //on selecting the date from the datepicker, it should hide the date picker and also the selected date should be visible as the text
    self.dob.hidden = NO;
    // we receive datepicker value as date, so formatting the string according to the required one
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    [self.dob setTitle:[dateFormatter stringFromDate:[self.dateOfbirth date]] forState:UIControlStateNormal];
    self.dateOfbirth.hidden = YES;
    self.datePickerView.hidden = YES;
}

- (IBAction)onEditProfilePicButtonClick:(id)sender
{
    UIActionSheet *actionsheet = [[UIActionSheet alloc]
                                  
                                  initWithTitle:@""
                                  
                                  delegate:self
                                  
                                  cancelButtonTitle:@"Cancel"
                                  
                                  destructiveButtonTitle:nil
                                  
                                  otherButtonTitles:@"Select Photo from Gallery", nil];
    
    [actionsheet showInView:self.view];
}

- (IBAction)onSaveButtonClicked:(id)sender
{
    [self showOverlayViewWithMessage:ACTIVITY_LOADING_TEXT_SAVING];
    // on appearing the datepicker for dismissing the keyboard
    [self.view endEditing:YES];
    // saving the data to the server and to the local db
    
    [self performSelector:@selector(startServiceForUpdatingUser:) withObject:loginInformation afterDelay:1];
}

- (void)updateUser
{
    loginInformation.firstName =_firstName.text;
    loginInformation.lastName = _lastName.text;
    loginInformation.emailId = _emailID.text;
    if (_userGender.selectedSegmentIndex == 0)
    {
        loginInformation.gender = @"male";
    }
    else
    {
        loginInformation.gender = @"female";
    }
    loginInformation.dob = _dob.titleLabel.text;
    loginInformation.address = _addressText.text;
    loginInformation.city = _cityText.text;
    loginInformation.state =_stateText.text;
    loginInformation.country =_countryText.text;
    loginInformation.zipCode = _zipCodeText.text;
    loginInformation.phoneNumber = _phoneNoText.text;
    if (self.fbProfilePic)
    {
        loginInformation.photo =  [self encodeToBase64String:self.fbProfilePic];
        
    }
    
}
- (IBAction)onResetButtonClicked:(id)sender
{
    [[CoreData sharedManager].managedObjectContext rollback];
    [self dismissViewControllerAnimated:NO completion:nil];
    // back to profile details page
}

- (void)selectPhotoFromGallery
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //Set the picker source as the camera
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //Bring in the picker view
    [self presentViewController:picker animated:NO completion:^{}];
    
}

#pragma mark - Image PIcker Delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //You can retrieve the actual UIImage
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    //Or you can get the image url from AssetsLibrary
    // NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    self.fbProfilePic = image;
    [picker dismissViewControllerAnimated:NO completion:^{
        self.profileImage.image = image;
    }];
}
#pragma mark - Encoding image to base 64

- (NSString *)encodeToBase64String:(UIImage *)image
{
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


#pragma mark - AlertView
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
    if ([alertView.message isEqualToString:@"User Updated Succesfully"])
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}
#pragma  mark - Action sheet delegates


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self selectPhotoFromGallery];
    }
    else if (buttonIndex == 1)
    {
        [actionSheet dismissWithClickedButtonIndex:0 animated:NO];
    }
}

- (void)showOverlayViewWithMessage:(NSString *)message
{
    [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:message showProgress:NO onController:self];
}

- (void)removeOverlayView
{
    [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];
}

#pragma mark - Service Calls
- (void)startServiceForUpdatingUser:(UserInfo *)info
{
    [self updateUser];
    ServiceType serviceTypeRequested = ServiceTypeUpdateUser;
    if (self.isNewMember)
    {
        serviceTypeRequested = ServiceTypeCreateUser;
    }
    LoginWebService * loginInfoServiceObj = [[LoginWebService alloc]init];
    [loginInfoServiceObj initService:serviceTypeRequested body:info  target:self];
    [loginInfoServiceObj start];
}

#pragma mark -  Service Class Delegate Methods
-(void)serviceSuccessful:(id)response
{
    [self removeOverlayView];
    [self showAlertWithMessage:@"User Updated Succesfully"];
    KMSDebugLog(@"success");
}

-(void)serviceFailed:(id)response
{
    [self removeOverlayView];
    if ([response isKindOfClass:[NSString class]])
    {
        NSString *failureMessage = (NSString*)response;
        
        [self showAlertWithMessage:failureMessage];
    }
    else
    {
        [self showAlertWithMessage:NO_SERVER_RESPONSE];
    }
}
- (void)networkError
{
    [self removeOverlayView];
    [self showAlertWithMessage:kSERVICE_NETWORK_NOT_AVAILABLE_MSG];
}

@end
