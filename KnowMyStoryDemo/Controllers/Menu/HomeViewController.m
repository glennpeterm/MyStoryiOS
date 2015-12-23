//
//  HomeViewController.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 02/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "HomeViewController.h"
#import "viewCell.h"
#import "ProfileDetailsViewController.h"
#import "ScriptureListViewController.h"
#import "ChannelsAndSelfiesViewController.h"
#import "UserInfo.h"
#import "SignUpViewController.h"
#import "RegionViewController.h"
#import "SettingsViewController.h"
#import "YoutubeUploadViewController.h"
#import "CoachViewController.h"
#import <sys/utsname.h>
#import "GAIDictionaryBuilder.h"
@interface HomeViewController ()
{
    NSMutableArray  *_icon_array;
    UIView *videoView;
    UserInfo *user ;
}
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self)
    {
        _icon_array = [[NSMutableArray alloc] init];
        [_icon_array addObject:[UIImage imageNamed:@"icon01"]];
        [_icon_array addObject:[UIImage imageNamed:@"icon02"]];
        [_icon_array addObject:[UIImage imageNamed:@"icon03"]];
        [_icon_array addObject:[UIImage imageNamed:@"icon04"]];
        [_icon_array addObject:[UIImage imageNamed:@"icon05"]];
        [_icon_array addObject:[UIImage imageNamed:@"icon06"]];
        
    }
    
    return self;
}
- (void)viewDidAppear:(BOOL)animated
{
    [self showtutorialVideoOnLaunch];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(HideBar) name:@"exitCoachview" object: nil];

    int width, height;
    if (self.view.frame.size.width >self.view.frame.size.height) {
        width =self.view.frame.size.width;
        height = self.view.frame.size.height ;
    }else{
        height =self.view.frame.size.width;
        width = self.view.frame.size.height;
    }
    
    float iconViewWidth = (height/(2.0));
    float a = height / sqrt(3);
    
    //For showing the full height of the menu icon
    float cWidth = a - kMenuIconSize/2;
    //For showing the half height of the menu icon
    //float cWidth = a;
    
    float d = (2*cWidth);
    float baseViewX =width + (d/4);
    self.baseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, d+iconViewWidth, d+iconViewWidth)];
    self.circle_view = [[SCHCircleView alloc]initWithFrame:CGRectMake(0,0,d+iconViewWidth,d+iconViewWidth)];
    self.circle_view.backgroundColor = [UIColor clearColor];
    self.baseView.backgroundColor = [UIColor clearColor];
    
    UIImageView *menu_circleImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,self.baseView.frame.size.width-iconViewWidth+5, self.baseView.frame.size.width-iconViewWidth+5)];
    menu_circleImage.image = [UIImage imageNamed:@"menu_circle"];
    [menu_circleImage setTag:123];
    [self.baseView addSubview:menu_circleImage];
    [menu_circleImage setCenter:CGPointMake( self.baseView.frame.size.width/2, self.baseView.frame.size.height/2)];
    
    [self.baseView addSubview:self.circle_view];
    [self.circle_view setCenter:CGPointMake( self.baseView.frame.size.width/2, self.baseView.frame.size.height/2)];
    [self.view addSubview:self.baseView];
    
    _icon_array = [[NSMutableArray alloc] init];
    [_icon_array addObject:[UIImage imageNamed:@"icon01"]];
    [_icon_array addObject:[UIImage imageNamed:@"icon02"]];
    [_icon_array addObject:[UIImage imageNamed:@"icon03"]];
    [_icon_array addObject:[UIImage imageNamed:@"icon04"]];
    [_icon_array addObject:[UIImage imageNamed:@"icon05"]];
    [_icon_array addObject:[UIImage imageNamed:@"icon06"]];
    self.baseView.transform = CGAffineTransformMakeRotation(90 * M_PI / 180.0);
    _circle_view.circle_view_data_source = self;
    _circle_view.circle_view_delegate    = self;
    _circle_view.show_circle_style       = SCHShowCircleDefault;
    [_circle_view reloadData];
    
    [self.baseView setCenter:CGPointMake(baseViewX, height/2)];
    // Do any additional setup after loading the view.
    
    [self setupTitleAndSubtitle];
    [self initialise];
    
    [self circleSetTitle:0];
}

- (void)initialise{
    
    
    
    // confirmation popup
    self.yourStoryText.font = kFONT_BOLD_SIZE_17;
    self.finishUrStoryText.font = kFONT_BOLD_SIZE_20;
    self.finishNowBtn.titleLabel.font = kFONT_BUTTON_SIZE_15;
    self.finishLaterBtn.titleLabel.font = kFONT_BUTTON_SIZE_15;
    self.deleteNStartOverBtn.titleLabel.font = kFONT_BUTTON_SIZE_15;
    
    [self.view bringSubviewToFront:self.confirmation_popUp];
    self.deleteInfoText.font= kFONT_BOLD_SIZE_17;
    self.deleteTitle.font = kFONT_BOLD_SIZE_20;
    self.noBtn.titleLabel.font = kFONT_BUTTON_SIZE_15;
    self.yesBtn.titleLabel.font = kFONT_BUTTON_SIZE_15;
    
}
-(void) setupTitleAndSubtitle
{
    
    int screenWidth =self.view.frame.size.width;
    int screenHeight = self.view.frame.size.height ;
    
    if (screenWidth < screenHeight)
    {
        screenHeight =self.view.frame.size.width;
        screenWidth = self.view.frame.size.height;
    }
    
    UIView *menuCircle = [self.baseView viewWithTag:123];
    int titleLabelHeight = 40;
    int freeWidth = self.baseView.frame.origin.x + menuCircle.frame.origin.x - kMenuIconSize/2;
    int titleWidth = freeWidth - 20;
    int titleMaxWidth = 450;
    
    if (titleWidth > titleMaxWidth)
    {
        titleWidth = titleMaxWidth;
    }
    
    self.titleInfo = [[UILabel alloc] init];
    [self.titleInfo setFrame:CGRectMake(0,0, titleWidth , titleLabelHeight)];
    [self.titleInfo setCenter:CGPointMake(freeWidth/2, screenHeight/2)];
    [self.titleInfo setAdjustsFontSizeToFitWidth:YES];
    [self.titleInfo setMinimumScaleFactor:0.8];
    [self.titleInfo setFont:kFONT_BOLD_SIZE_52];
    [self.titleInfo setTextColor:ORANGE_COLOR];
    [self.view addSubview:self.titleInfo];
    
    self.coachMarkTggle_button = [[UIButton alloc] init];
    [self.coachMarkTggle_button setFrame:CGRectMake(4,screenHeight-40,46,30)];
    [self.coachMarkTggle_button addTarget:self
                                   action:@selector(coachMarkTggle_button_pressed:)
                         forControlEvents:UIControlEventTouchUpInside];
    [self.coachMarkTggle_button setImage:[UIImage imageNamed:@"grey_circle_help"]  forState:UIControlStateNormal];
    [self.coachMarkTggle_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.coachMarkTggle_button.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:13]];
    [self.view addSubview:self.coachMarkTggle_button];
    
    int subTitleLabelHeight = 20;
    self.subTitleInfo = [[UILabel alloc] init];
    [self.subTitleInfo setFrame:CGRectMake(self.titleInfo.frame.origin.x+5, self.titleInfo.frame.origin.y + titleLabelHeight + 10 , titleWidth , subTitleLabelHeight)];
    [self.subTitleInfo setAdjustsFontSizeToFitWidth:YES];
    [self.subTitleInfo setMinimumScaleFactor:0.8];
    [self.subTitleInfo setFont:kFONT_ABEL_SIZE_13];
    [self.subTitleInfo setTextColor:LIGHT_GREY];
    [self.view addSubview:self.subTitleInfo];
    
    
}
-(void)HideBar
{
    if(self.coachMarkTggle_button.hidden == YES)
    {
        self.coachMarkTggle_button.hidden = NO;
    }
}
-(IBAction)coachMarkTggle_button_pressed:(id)sender
{
    self.coachMarkTggle_button.hidden = YES;
    [self coachViewToggler];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pressed:(id)sender
{
    [_circle_view reloadData];
}
#pragma coachMark Toggler Function
-(void) coachViewToggler
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *modelName = [NSString stringWithCString:systemInfo.machine
                                             encoding:NSUTF8StringEncoding];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CoachViewController *coachView = [storyboard instantiateViewControllerWithIdentifier:@"CoachViewController"];
    coachView.modalPresentationStyle = UIModalPresentationCustom;
    
    if([modelName isEqualToString:@"iPhone4,1"]){
        
        NSLog(@"IPHONE 4S");
        self.coachImageListArray = [NSArray arrayWithObjects:@"004s.jpg",@"014s.jpg", @"024s.jpg",@"034s.jpg",@"044s.jpg",@"054s.jpg",@"064s.jpg",@"074s.jpg",@"084s.jpg",@"094s.jpg",@"104s.jpg",@"114s.jpg", nil];

    } else {
        
        self.coachImageListArray = [NSArray arrayWithObjects:@"00.jpg",@"01.jpg", @"02.jpg",@"03.jpg",@"04.jpg",@"05.jpg",@"06.jpg",@"07.jpg",@"08.jpg",@"09.jpg",@"10.jpg",@"11.jpg", nil];
    }
    
    coachView.coachImageListArray = self.coachImageListArray;
    [self presentViewController:coachView animated:NO completion:nil];
    
}

#pragma mark -
#pragma mark - SCHCircleViewDataSource

- (CGFloat)radiusOfCircleView:(SCHCircleView *)circle_view{
    
    float height = self.view.frame.size.height;
    
    // iOS 7 fix : Abdu 16 April 15
    if (height > self.view.frame.size.width)
    {
        height = self.view.frame.size.width;
    }
    
    float a = height / sqrt(3);
    
    //For showing the full height of the menu icon
    float d = a - kMenuIconSize/2;
    //For showing the half height of the menu icon
    //float d = a;
    
    //return self.view.frame.size.height/2;
    return d;
}

- (CGPoint)centerOfCircleView:(SCHCircleView *)circle_view
{
    return CGPointMake(((self.baseView.frame.size.height/2)  ), self.baseView.frame.size.width/2);
}

- (NSInteger)numberOfCellInCircleView:(SCHCircleView *)circle_view
{
    return _icon_array.count;
}

- (SCHCircleViewCell *)circleView:(SCHCircleView *)circle_view cellAtIndex:(NSInteger)index_circle_cell
{
    viewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"viewCell" owner:nil options:nil] lastObject];
    
    [cell.image_view setImage:[_icon_array objectAtIndex:index_circle_cell]];
    cell.image_view.transform = CGAffineTransformMakeRotation( -90 *M_PI /180);
    return cell;
}

#pragma mark -
#pragma mark - SCHCircleViewDelegate
- (void)circleSetTitle:(int)index
{
    if (index==0) {
        self.titleInfo.text = @"Tell Your Story";
        self.subTitleInfo.text =  @"Share the good news of how God has changed your life.";
        self.titleInfo.text = [self.titleInfo.text uppercaseString];
        self.subTitleInfo.text =[self.subTitleInfo.text uppercaseString];
        
    }
    if (index==1) {
        self.titleInfo.text = @"My Stories";
        self.subTitleInfo.text =  @"Here is where all the stories you have told are kept.";
        self.titleInfo.text = [self.titleInfo.text uppercaseString];
        self.subTitleInfo.text =[self.subTitleInfo.text uppercaseString];
        
        
    }
    if (index==2) {
        self.titleInfo.text = @"Watch";
        self.subTitleInfo.text =  @"See how awesome God is through stories from all over the world.";
        self.titleInfo.text = [self.titleInfo.text uppercaseString];
        self.subTitleInfo.text =[self.subTitleInfo.text uppercaseString];
        
    }
    
    if (index==3) {
        self.titleInfo.text = @"Tutorial Video";
        self.subTitleInfo.text =  @"Learn what My Story is all about and how to use the app.";
        self.titleInfo.text = [self.titleInfo.text uppercaseString];
        self.subTitleInfo.text =[self.subTitleInfo.text uppercaseString];
        
    }
    if (index==4) {
        self.titleInfo.text = @"My Profile";
        self.subTitleInfo.text =  @"Share your profile, picture and personality to reflect your story.";
        self.titleInfo.text = [self.titleInfo.text uppercaseString];
        self.subTitleInfo.text =[self.subTitleInfo.text uppercaseString];
    }
    
    
    if (index==5) {
        self.titleInfo.text = @"Information";
        self.subTitleInfo.text =  @"Learn more about us and the technical stuff.";
        self.titleInfo.text = [self.titleInfo.text uppercaseString];
        self.subTitleInfo.text =[self.subTitleInfo.text uppercaseString];
        
        
    }
    
}
- (void)touchEndCircleViewCell:(SCHCircleViewCell *)cell indexOfCircleViewCell:(NSInteger)index
{
    if (index == 0)
    {
        if ([[WizardViewController sharedInstance] haveExistingStory])
        {
            self.confirmation_popUp.hidden = NO;
            self.confirmDeletePopUp.hidden = YES;
        }
        else
        {
            [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:@"Loading..." showProgress:NO onController:self];
            
            [self presentViewController:[WizardViewController sharedInstance] animated:NO completion:^(void)
             {
                 [[WizardViewController sharedInstance] startStory];
                 [self sendAnalytics];

                 self.confirmation_popUp.hidden = YES;
                 [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];
             }];
        }
        
        
    }
    if (index == 1)
    {
        user = [DBHelper getLoggedInUser];
        if (user)
        {
            UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"
                                                          bundle:nil];
            
            ChannelsAndSelfiesViewController *profileVC =[sb instantiateViewControllerWithIdentifier:@"ChannelsAndSelfiesViewController"];
            [profileVC setIsChannels:NO];
            
            [self presentViewController:profileVC animated:NO completion:nil];
        }
        else
        {
            UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"
                                                          bundle:nil];
            if (sb)
            {
                SignUpViewController *profileVC= [SignUpViewController sharedInstance];
                if(profileVC.termsBtn.selected)
                {
                    [profileVC OnClickOfTermsStatement:nil];
                }
                if (!profileVC)
                {
                    profileVC  =[sb instantiateViewControllerWithIdentifier:@"SignUp"];
                }
                [profileVC setIsForMySelfies:YES];
                
                [self presentViewController:profileVC animated:NO completion:nil];
            }
            
            
        }
        
        
    }
    if (index == 2)
    {
        
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"
                                                      bundle:nil];
        ChannelsAndSelfiesViewController *profileVC =[sb instantiateViewControllerWithIdentifier:@"ChannelsAndSelfiesViewController"];
        
        [profileVC setIsChannels:YES];
        [self presentViewController:profileVC animated:NO completion:nil];
        
    }
    if (index == 3)
    {
        [self playTutorialVideoWithControls:YES];
        
        
    }
    if (index == 4)
    {
        user = [DBHelper getLoggedInUser];
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"
                                                      bundle:nil];
        if (user)
        {
            ProfileDetailsViewController *profileVC = [ProfileDetailsViewController sharedInstance];
            if (!profileVC)
            {
                profileVC =[sb instantiateViewControllerWithIdentifier:@"ProfileDetailsViewController"];
            }
            [self presentViewController:profileVC animated:NO completion:nil];
        }
        else
        {
            if (sb)
            {
                SignUpViewController *profileVC= [SignUpViewController sharedInstance];
                if(profileVC.termsBtn.selected)
                {
                    [profileVC OnClickOfTermsStatement:nil];
                }
                if (!profileVC)
                {
                    profileVC  =[sb instantiateViewControllerWithIdentifier:@"SignUp"];
                }
                [profileVC setIsForMyProfile:YES];
                [self presentViewController:profileVC animated:NO completion:nil];
            }
            
        }
        
    }
    if (index == 5)
    {
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"
                                                      bundle:nil];
        SettingsViewController *settingVC =[sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        [self presentViewController:settingVC animated:NO completion:nil];
        
    }
}
-(void) sendAnalytics {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Tell my story"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Telling Your Story"
                                                          action:@"Start recording new story"
                                                           label:@"User click on check button  in the title screen"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
    
}
#pragma mark -  Show Tutorial Video
- (void)showtutorialVideoOnLaunch
{
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"HasLaunchedOnce"] boolValue]) {
        
        [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithBool:YES] forKey:@"HasLaunchedOnce"];
        
        
        [self playTutorialVideoWithControls:NO];
        
        [self performSelector:@selector(showCoachmarkView) withObject:nil afterDelay:2];
        
    }
}
- (void)playTutorialVideoWithControls:(BOOL)isControlsEnabled
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *moviePath = [bundle pathForResource:VIDEO_TUTORIAL_ENG ofType:@"mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:moviePath])
    {
        NSURL *movieURL = [NSURL fileURLWithPath:moviePath] ;
        MPMoviePlayerViewController *player =[[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
        [player.moviePlayer prepareToPlay];
        player.moviePlayer.controlStyle = MPMovieControlStyleNone;
        [player.view setFrame: self.view.bounds];  // player's frame must match parent's
        
        
        if (isControlsEnabled)
        {
            [self performSelector:@selector(changeStyle:) withObject:player afterDelay:1];
        }
        else
        {
            UIButton *skipButton =[[UIButton alloc] initWithFrame:CGRectMake(player.view.frame.size.width - 110, 10, 100, 40)];
            [skipButton setTitle:@"SKIP" forState:UIControlStateNormal];
            [[skipButton titleLabel] setFont:kBUTTON_FONT_SIZE_15];
            [skipButton setAlpha:0.70f];
            [skipButton.layer setBorderColor:[UIColor whiteColor].CGColor];
            [skipButton.layer setBorderWidth:2.0];
            [skipButton setBackgroundColor:[UIColor blackColor]];
            [skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [skipButton addTarget:player.moviePlayer action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
            [player.view addSubview:skipButton];
        }
        [self presentMoviePlayerViewControllerAnimated: player];
        [player.moviePlayer play];
        
        KMSDebugLog(@"Tutorial Video File exists in BUNDLE");
    }
    else
    {
        KMSDebugLog(@"Tutorial Video File not found");
    }
    
}

- (IBAction)changeStyle:(MPMoviePlayerViewController*)player{
    player.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
}

#pragma mark - AlertView
- (void)showAlertWithMessage:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: kALERT_TITLE
                                                        message: message
                                                       delegate: nil
                                              cancelButtonTitle: kALERT_OK_BUTTON
                                              otherButtonTitles: nil];
    
    [alertView show];
    
    
}


#pragma mark -  Button Actions

- (IBAction)onDeleteNStartOverBtnClicked:(id)sender
{
    self.confirmDeletePopUp.hidden = NO;
    
}

- (IBAction)onFinishLaterBtnClicked:(id)sender
{
    self.confirmation_popUp.hidden = YES;
    
}

- (IBAction)onFinishNowBtnClicked:(id)sender
{
    
    [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:@"Loading..." showProgress:NO onController:self];
    
    [self presentViewController:[WizardViewController sharedInstance] animated:NO completion:^(void)
     {
         [[WizardViewController sharedInstance] startStory];
         self.confirmation_popUp.hidden = YES;
         [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];
     }];
    
}

- (IBAction)onConfirmDeleteBtnClicked:(id)sender
{
    
    [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:@"Loading..." showProgress:NO onController:self];
    [self presentViewController:[WizardViewController sharedInstance] animated:NO completion:^(void)
     {
         [[WizardViewController sharedInstance] deleteAndStartNewStory];
         self.confirmDeletePopUp.hidden = YES;
         self.confirmation_popUp.hidden = YES;
         [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];
     }];
}

- (IBAction)onCancelDeleteBtnClicked:(id)sender
{
    self.confirmDeletePopUp.hidden = YES;
}


-(void)showCoachmarkView
{
    if (self.coachmarksView == nil)
    {
        int screenWidth =self.view.frame.size.width;
        int screenHeight = self.view.frame.size.height;
        
        if (screenWidth < screenHeight)
        {
            screenHeight =self.view.frame.size.width;
            screenWidth = self.view.frame.size.height;
        }
        
        self.coachmarksView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        
        UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        [overlayView setBackgroundColor:ORANGE_COLOR];
        [overlayView setAlpha:0.9];
        [self.coachmarksView addSubview:overlayView];
        
        UIView *menuCircle = [self.baseView viewWithTag:123];
        UIImageView *coachmarkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coachmark_arrow.png"]];
        [coachmarkImageView setCenter:CGPointMake(self.baseView.frame.origin.x + coachmarkImageView.frame.size.width + menuCircle.frame.origin.x, screenHeight/2)];
        [self.coachmarksView addSubview:coachmarkImageView];
        
        int coachmarkLabelHeight = 40;
        UILabel *coachmarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, screenHeight/2 - coachmarkLabelHeight/2, coachmarkImageView.frame.origin.x - 20 , coachmarkLabelHeight)];
        [coachmarkLabel setTextAlignment:NSTextAlignmentCenter];
        [coachmarkLabel setText:@"Swipe UP or DOWN to access the features"];
        [coachmarkLabel setTextColor:[UIColor whiteColor]];
        [coachmarkLabel setFont:kFONT_ABEL_SIZE_24];
        [coachmarkLabel setAdjustsFontSizeToFitWidth:YES];
        [coachmarkLabel setMinimumScaleFactor:0.6];
        [self.coachmarksView addSubview:coachmarkLabel];
        
        UIButton *coachmarkCloseButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,100,30)];
        [coachmarkCloseButton setCenter:CGPointMake(coachmarkLabel.center.x, coachmarkLabel.center.y + 40)];
        [coachmarkCloseButton setTitle:@"GOT IT" forState:UIControlStateNormal];
        [coachmarkCloseButton.titleLabel setFont:kBUTTON_FONT_SIZE_15];
        [coachmarkCloseButton setBackgroundColor:[UIColor whiteColor]];
        [coachmarkCloseButton setTitleColor:ORANGE_COLOR forState:UIControlStateNormal];
        [coachmarkCloseButton addTarget:self action:@selector(hideCoachMarksBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.coachmarksView addSubview:coachmarkCloseButton];
        
        [self.view addSubview:self.coachmarksView];
    }
    
}

- (IBAction)hideCoachMarksBtnClicked:(id)sender
{
    
    if (self.coachmarksView != nil)
    {
        [self.coachmarksView setHidden:YES];
        [self.coachmarksView removeFromSuperview];
        self.coachmarksView= nil;
        
    }
    
}


@end
