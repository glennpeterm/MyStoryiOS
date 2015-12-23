//
//  ProfileDetailsViewController.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 03/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "ProfileDetailsViewController.h"
#import "UserInfo.h"
#import "EditProfileViewController.h"

@interface ProfileDetailsViewController ()
{
    NSString *address;
    UIView *backView;
}
@end

@implementation ProfileDetailsViewController
static ProfileDetailsViewController *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (ProfileDetailsViewController *)sharedInstance
{
    if (sharedInstance == nil)
    {
        //sharedInstance = [[ProfileDetailsViewController alloc] init];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    sharedInstance = self;
    [self initialise];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showOverlayViewWithMessage:@""];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initialiseView];
    [self performSelector:@selector(removeOverlayView) withObject:nil afterDelay:0.5];
}

- (void)initialise
{
    self.shadowImage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowImage.layer.shadowOffset = CGSizeMake(0, 1);
    self.shadowImage.layer.shadowOpacity = 1;
    self.shadowImage.layer.shadowRadius = 1.4;
    self.shadowImage.clipsToBounds = NO;
    
    self.profileImage.layer.borderWidth =.5;
    self.profileImage.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.profileImage.contentMode = UIViewContentModeScaleAspectFit;
    
    self.editProfileBtn.titleLabel.font = kFONT_BUTTON_SIZE_15;
    self.userInfo.font = kFONT_BOLD_SIZE_20;
    self.profileTitle.font = kFONT_BOLD_SIZE_30;
    self.addressInfo.font = kFONT_BOLD_SIZE_10;
    self.mobileInfotext.font = kFONT_BOLD_SIZE_10;
    self.logoutBtn.titleLabel.font = kFONT_BUTTON_SIZE_15;
    
}

- (void)initialiseView
{
    
    UserInfo *user = [DBHelper getLoggedInUser];
    if (user  && user.emailId != nil)
    {
        self.notlogedInView.hidden = YES;
        if (user.dob.length >0 && ![user.dob isEqualToString:@"0000-00-00"])
        {
            NSString *bday = [self ageFromBirthDate:user.dob];
            if (![bday isEqualToString:@""])
            {
                self.userInfo.text = [NSString stringWithFormat:@"%@ %@ (%@)",user.firstName,user.lastName,bday];
            }
            else
            {
                self.userInfo.text = [NSString stringWithFormat:@"%@ %@",user.firstName,user.lastName];
            }
            
        }
        
        self.userInfo.text = [NSString stringWithFormat:@"%@ %@",user.firstName,user.lastName];
        self.emailIdtext.text = user.emailId;
        if (user.photo.length > 0)
        {
            if ([user.photo hasPrefix:@"http"])
            {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:user.photo]];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                self.profileImage.image = image;
            }
            else
            {
                self.profileImage.image = [self getdecodedImage:user.photo];
            }
        }
        else
        {
            self.profileImage.image =[UIImage imageNamed:@"defauls_profile.png"];
        }
        address = @"";
        if (user.address.length >0)
        {
            address = user.address;
        }
        if (user.city.length >0)
        {
            if (address.length >0)
            {
                address = [self appendText:user.city];
            }
            else
            {
                address = user.address;
            }
        }
        if (user.state.length >0)
        {
            if (address.length >0)
            {
                address = [self appendText:user.state];
            }
            else
            {
                address = user.state;
            }
        }
        if (user.country.length >0)
        {
            if (address.length >0)
            {
                address = [self appendText:user.country];
            }
            else
            {
                address = user.country;
            }
        }
        if (user.zipCode.length >0)
        {
            if (address.length >0)
            {
                address = [self appendText:user.zipCode];
            }
            else
            {
                address = user.zipCode;
            }
            
        }
        self.addressInfo.text = address;
        if (address.length==0)
        {
            self.locationIcon.hidden = YES;
        }
        else
        {
            self.locationIcon.hidden = NO;
        }
        if (user.phoneNumber.length >0)
        {
            self.mobileInfotext.hidden = NO;
            self.mobileInfotext.text =  user.phoneNumber;
            self.mobileIcon.hidden = NO;
        }
        else
        {
            self.mobileInfotext.hidden = YES;
            self.mobileIcon.hidden = YES;
        }
        
    }
    else
    {
        self.notlogedInView.hidden = NO;
        self.noUserText.font = kFONT_BUTTON_SIZE_15;
        
    }
}

#pragma mark - Address
- (NSString *)appendText:(NSString *)appendAddressInfo
{
    return [NSString stringWithFormat:@"%@, %@",address,appendAddressInfo];
}

#pragma mark - decode profile image
- (UIImage *)getdecodedImage:(NSString *)base64String
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

#pragma mark -  age from birth day
- (NSString *) ageFromBirthDate:(NSString *)birthDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *myDate = [dateFormatter dateFromString: birthDate];
    if ([[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:myDate toDate:[NSDate date] options:0] year] == 0)
    {
        return @"";
    }
    return [NSString stringWithFormat:@"%d yrs", [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:myDate toDate:[NSDate date] options:0] year]];
}
#pragma mark  -  Overlay View Management

- (void)showOverlayViewWithMessage:(NSString *)message
{
    [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:message showProgress:NO onController:self];
}

- (void)removeOverlayView
{
    [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];
}

#pragma mark -  Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - Button Actions

- (IBAction)onEditProfileBtnClicked:(id)sender
{
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"
                                                  bundle:nil];
    EditProfileViewController *profileVC =[sb instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    [profileVC setIsNewMember:NO];
    [self presentViewController:profileVC animated:NO completion:nil];
}

- (IBAction)onHomeButtonClicked:(id)sender
{
    [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)onLogoutButtonClicked:(id)sender
{
    [self deleteUser];
    [self showAlertWithMessage:@"User Logged Out Successfully"];
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
    [[CoreData sharedManager] saveEntity];
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
    [self onHomeButtonClicked:nil];
}
@end
