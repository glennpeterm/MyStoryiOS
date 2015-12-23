//
//  DVViewController.m
//  Youtube
//
//  Created by Ilya Puchka on 26.11.12.
//  Copyright (c) 2012 Denivip. All rights reserved.
//

#import "YoutubeUploadViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMOAuth2Authentication.h"
#import "SignUpViewController.h"

#import "GTLYouTube.h"
#import "GoogleAuthentication.h"

#import "UIImageView+AFNetworking.h"
#import "AFImageRequestOperation.h"
#import "GTMHTTPUploadFetcher.h"
#import "ChannelsAndSelfiesViewController.h"
#import "WizardViewController.h"
#import "GAIDictionaryBuilder.h"

#define kKeychainItemName @"Youtube API Test: Google Key"

//LIVE

#define kClienID @"435539599006-rvlci29d4uk5vvheeqrtac4cpjgvf6ga.apps.googleusercontent.com"
#define kClientSecret @"NoyEaPOo5yT4JkBPlUkfJ4DA"
#define kYoutubeDeveloperKey @"AIzaSyDTZki2Bd-Q3XRwSu6WzO-HHUJ3wZVSplQ"



//TESTING

//#define kClienID @"673583809303-4d69icclnvh3smjdabt65aea63pn3ok7.apps.googleusercontent.com"
//#define kClientSecret @"eyxJ17unxCldd3IPHZSwv_Iz"
//#define kYoutubeDeveloperKey @"AIzaSyAi9_A1QRamD9Ajz-GhtMhD_RMcwn6t6Qw"

//#define kClienID @"166613528581-bedfhdkdavfk8p5u3ca737gjnfcn7tji.apps.googleusercontent.com"
//#define kClientSecret @"LQlUBHl5QqvuPmYi8ceEVDel"
//#define kYoutubeDeveloperKey (@"AIzaSyAwiPzxND6vluazjmuLCzSCGDHxcOCXmF4")
enum YoutubeAPICallsSections {
    YoutubeAPICallsSectionMyChannel,
    YoutubeAPICallsSectionMyPlaylists,
    YoutubeAPICallsSectionMySubscriptions,
    YoutubeAPICallsSectionMyFavoriteVideos,
    YoutubeAPICallsSectionMyUploadedVideos,
    YoutubeAPICallsVideoUpload,
    YoutubeAPICallsSectionsCount
};

@interface YoutubeUploadViewController ()
{
    GTLServiceTicket *_uploadFileTicket;
    NSURL *_uploadLocationURL;
}
@property (nonatomic, strong) GTLServiceYouTube *youtubeService;
@property (nonatomic, strong) UIBarButtonItem *signButton;
@property (nonatomic, strong) UIBarButtonItem *activityItem;

@property (nonatomic, strong) GTLYouTubeChannel *currentUserChannel;
@property (nonatomic, strong) NSArray *currentUserPlaylists;
@property (nonatomic, strong) NSArray *currentUserSubscriptions;
@property (nonatomic, strong) NSArray *currentUserFavorites;
@property (nonatomic, strong) NSArray *currentUserUploads;

@property (nonatomic) BOOL gotPlaylists;
@property (nonatomic) BOOL gotFavorites;
@property (nonatomic) BOOL gotSubscriptions;
@property (nonatomic) BOOL gotChannel;
@property (nonatomic) BOOL gotUploads;

@property (nonatomic, strong) NSString * titleInfo;
@property (nonatomic, strong) NSString * descText;
@property (nonatomic, strong) NSString * tagText;

- (IBAction)signButtonTapped:(id)sender;
//- (IBAction)getChannelsTapped:(id)sender;

@end

@implementation YoutubeUploadViewController
@synthesize uploadedFileName;
@synthesize titleText,descText,tagText;
@synthesize progressView;


static YoutubeUploadViewController *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (YoutubeUploadViewController *)sharedInstance
{
    if (sharedInstance == nil)
    {
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"bundle:nil];
        sharedInstance = [sb instantiateViewControllerWithIdentifier:@"YoutubeUploadViewController"];
        
        //sharedInstance = [[WizardViewController alloc] init];
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




- (UIBarButtonItem *)signButton
{
    return [[UIBarButtonItem alloc] initWithTitle:self.isSignedIn?@"Sign out":@"Sign in" style:UIBarButtonItemStyleBordered target:self action:@selector(signButtonTapped:)];
    
}

- (UIBarButtonItem *)activityItem
{
    if (!_activityItem) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 35, 20)];
        _activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        [activityIndicator startAnimating];
    }
    return _activityItem;
}

- (GTLServiceYouTube *)youtubeService
{
    if (!_youtubeService) {
        _youtubeService = [[GTLServiceYouTube alloc] init];
        _youtubeService.retryEnabled = YES;
        _youtubeService.APIKey = kYoutubeDeveloperKey;
    }
    return _youtubeService;
}

- (void)setCurrentUserChannel:(GTLYouTubeChannel *)currentUserChannel
{
    _currentUserChannel = currentUserChannel;
    
    self.gotChannel = (currentUserChannel != nil);
    self.gotFavorites = self.gotPlaylists = self.gotUploads = self.gotSubscriptions = NO;
    self.currentUserFavorites = self.currentUserPlaylists = self.currentUserSubscriptions = self.currentUserUploads = nil;
    
    //    if (currentUserChannel) {
    //
    //        [self.tableView beginUpdates];
    //
    //        [self getUserFavoritesOnCompletion:NULL];
    //        [self getUserUploadsVideosOnCompletion:NULL];
    //        [self getSubscriptionsOnCompletion:NULL];
    //        [self getPlaylistsOnCompletion:NULL];
    //    }
    
}

- (void)setGotChannel:(BOOL)gotChannel
{
    if (_gotChannel ^ gotChannel) {
        _gotChannel = gotChannel;
        if (gotChannel) {
            [self updateTableViewIfNeeded];
        }
        else {
            // [self.tableView reloadData];
        }
    }
}

- (void)setGotFavorites:(BOOL)gotFavorites
{
    if (_gotFavorites ^ gotFavorites) {
        _gotFavorites = gotFavorites;
        if (gotFavorites) {
            [self updateTableViewIfNeeded];
        }
    }
}

- (void)setGotPlaylists:(BOOL)gotPlaylists
{
    if (_gotPlaylists ^ gotPlaylists) {
        _gotPlaylists = gotPlaylists;
        if (gotPlaylists) {
            [self updateTableViewIfNeeded];
        }
    }
}

- (void)setGotSubscriptions:(BOOL)gotSubscriptions
{
    if (_gotSubscriptions ^ gotSubscriptions) {
        _gotSubscriptions = gotSubscriptions;
        if (gotSubscriptions) {
            [self updateTableViewIfNeeded];
        }
    }
}

- (void)setGotUploads:(BOOL)gotUploads
{
    if (_gotUploads^ gotUploads) {
        _gotUploads = gotUploads;
        if (gotUploads) {
            [self updateTableViewIfNeeded];
        }
    }
}

- (void)updateTableViewIfNeeded
{
    if (self.gotChannel &&
        self.gotFavorites &&
        self.gotPlaylists &&
        self.gotSubscriptions &&
        self.gotUploads) {
        
        self.navigationItem.rightBarButtonItem = nil;
        //  [self.tableView endUpdates];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedInstance = self;
    
    /*
     [self registerKeyboardNotifications];
     // Do any additional setup after loading the view, typically from a nib.
     
     self.navigationItem.backBarButtonItem =
     [[UIBarButtonItem alloc] initWithTitle:@"Back"
     style:UIBarButtonItemStyleBordered
     target:nil
     action:nil];
     
     */
    [self InitialiseView];
}

-(void)InitialiseView
{
    
    
//    GTMOAuth2Authentication * newAuth = [[GTMOAuth2Authentication alloc]init];
//    
//    newAuth.clientID = kClienID;
//    
//    newAuth.clientSecret = kClientSecret;
//    
//    newAuth.redirectURI = @"urn:ietf:wg:oauth:2.0:oob";
//    
//    newAuth.tokenURL = [NSURL URLWithString:@"https://accounts.google.com/o/oauth2/token"];
//    
//    newAuth.userEmail =@"";
//    
//    NSMutableDictionary *newParams = [[NSMutableDictionary alloc]init];
//    
//    // [newParams setObject:@"ya29.8wATuW5MbLjOI1xqE0mKL3Ku4FxFi7MZnWyWcrLa7ZsvNIRewBD73ysAyjOXh161h8HJBjXQfMPvdA" forKey:@"access_token"];
//    
//    
//    
//    [newParams setObject:@"ya29.OAHHm_5Qxo1qgvpjmRwYjuri3VsuZ3QeppkkSxkvIPPNZyrqWyVJqBGFvp22NjQoX1ySYfmD5Hw2UQ" forKey:@"access_token"];
//    
//    
//    
//    // [newParams setObject:@"4/AUwOAASswMn0j5Np7OVyc845COR5wKv7RTeJgHvDhlQ" forKey:@"code"];
//    
//    [newParams setObject:@"4/fT1GOImGm0Lgv5NEI9iLIQUqYDxGHLIoFM3CSbU1s90" forKey:@"code"];
//    
//    
//    
//    [newParams setObject:@"mystory.fingent@gmail.com" forKey:@"email"];
//    
//    [newParams setObject:[NSNumber numberWithBool:YES] forKey:@"isVerified"];
//    
//    //  [newParams setObject:@"1/VZzMgmmMCN829xjPpdi0nG_HHfjCgoyKztAEyCKhWL0" forKey:@"refresh_token"];
//    
//    [newParams setObject:@"1/NXQNY-GyLTOS1YjCq4C5ApoltiHXuwGFHnu0zAYBgswMEudVrK5jSpoR30zcRFq6" forKey:@"refresh_token"];
//    
//    [newParams setObject:@"Bearer" forKey:@"token_type"];
//    
//    [newParams setObject:@"Google" forKey:@"serviceProvider"];
//    
//    [newParams setObject:@"https://www.googleapis.com/auth/youtube https://www.googleapis.com/auth/userinfo.email" forKey:@"scope"];
//    
//    [newParams setObject:@"eyJhbGciOiJSUzI1NiIsImtpZCI6ImRhNTIyZjNiNjY3NzdmZjZhZjYzNDYwZDJiNTQ5YWQ0M2I2NjYwZDYifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiaWQiOiIxMDQ5NjA4NjY4Njg2NTI0MzM3MzAiLCJzdWIiOiIxMDQ5NjA4NjY4Njg2NTI0MzM3MzAiLCJhenAiOiIxNjY2MTM1Mjg1ODEtZm1sZ25oMXIyc2U5NjdoM2pxNWFncGFxMW0yaTE2b2cuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJlbWFpbCI6ImFzd2F0aHlib3NlMTNAZ21haWwuY29tIiwiYXRfaGFzaCI6IjIwT0JwZWd3UDdJQ1ptV1FadVZlb3ciLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXVkIjoiMTY2NjEzNTI4NTgxLWZtbGduaDFyMnNlOTY3aDNqcTVhZ3BhcTFtMmkxNm9nLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwidG9rZW5faGFzaCI6IjIwT0JwZWd3UDdJQ1ptV1FadVZlb3ciLCJ2ZXJpZmllZF9lbWFpbCI6dHJ1ZSwiY2lkIjoiMTY2NjEzNTI4NTgxLWZtbGduaDFyMnNlOTY3aDNqcTVhZ3BhcTFtMmkxNm9nLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiaWF0IjoxNDIwNTE4NTE3LCJleHAiOjE0MjA1MjI0MTd9.puXvZ7v5CmsiRlH5voGU0eOO03BNHL1bKBUGm-T2Ovxk-PO2AeeFof14dhfucu48qgybqbADVi6Q7McAkGFKhJjJZ6KXtOo38hZjm_w1Y5-_3tU5M6eoHfT9fkKYwQGdfibzsfi9qktwqnQR5pUUahxzPJRrxHISf1HMklklxH4" forKey:@"id_token"];
//    
//    [newParams setObject:@"3599" forKey:@"expires_in"];
//    
//    
//    
//    newAuth.parameters = newParams;
//    
    
    //
    GTMOAuth2Authentication * newAuth = [[GTMOAuth2Authentication alloc]init];
    newAuth.clientID = kClienID;
    newAuth.clientSecret = kClientSecret;
    newAuth.redirectURI = @"urn:ietf:wg:oauth:2.0:oob";
    newAuth.tokenURL = [NSURL URLWithString:@"https://accounts.google.com/o/oauth2/token"];
    newAuth.userEmail =@"";
    NSMutableDictionary *newParams = [[NSMutableDictionary alloc]init];
    // [newParams setObject:@"ya29.8wATuW5MbLjOI1xqE0mKL3Ku4FxFi7MZnWyWcrLa7ZsvNIRewBD73ysAyjOXh161h8HJBjXQfMPvdA" forKey:@"access_token"];
    
    [newParams setObject:@"ya29.ZAHgeuapwYdP6C8anJ-6gUTCOLhq4GuIup7lhR4QxCKj_fc7UNCnjYR1LgNjTbNl8LUvOHZJsmKYhg" forKey:@"access_token"];
    
    // [newParams setObject:@"4/AUwOAASswMn0j5Np7OVyc845COR5wKv7RTeJgHvDhlQ" forKey:@"code"];
   // [newParams setObject:@"4/fT1GOImGm0Lgv5NEI9iLIQUqYDxGHLIoFM3CSbU1s90" forKey:@"code"];
    [newParams setObject:@"4/9U_ShOZ0dTTf1eJy8yBGPp3HBPHrsaOWsT4rRLhFR2k" forKey:@"code"];
    
    [newParams setObject:@"mystory@onehope.net" forKey:@"email"];
    [newParams setObject:[NSNumber numberWithBool:YES] forKey:@"isVerified"];
    //  [newParams setObject:@"1/VZzMgmmMCN829xjPpdi0nG_HHfjCgoyKztAEyCKhWL0" forKey:@"refresh_token"];
    [newParams setObject:@"1/JFmRt2fUmJTk-R_yyCLxHmrDVoq2BJ93rF1Q_A-vJmQMEudVrK5jSpoR30zcRFq6" forKey:@"refresh_token"];
    [newParams setObject:@"Bearer" forKey:@"token_type"];
    [newParams setObject:@"Google" forKey:@"serviceProvider"];
    [newParams setObject:@"https://www.googleapis.com/auth/youtube https://www.googleapis.com/auth/userinfo.email" forKey:@"scope"];
    [newParams setObject:@"eyJhbGciOiJSUzI1NiIsImtpZCI6ImRhNTIyZjNiNjY3NzdmZjZhZjYzNDYwZDJiNTQ5YWQ0M2I2NjYwZDYifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiaWQiOiIxMDQ5NjA4NjY4Njg2NTI0MzM3MzAiLCJzdWIiOiIxMDQ5NjA4NjY4Njg2NTI0MzM3MzAiLCJhenAiOiIxNjY2MTM1Mjg1ODEtZm1sZ25oMXIyc2U5NjdoM2pxNWFncGFxMW0yaTE2b2cuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJlbWFpbCI6ImFzd2F0aHlib3NlMTNAZ21haWwuY29tIiwiYXRfaGFzaCI6IjIwT0JwZWd3UDdJQ1ptV1FadVZlb3ciLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXVkIjoiMTY2NjEzNTI4NTgxLWZtbGduaDFyMnNlOTY3aDNqcTVhZ3BhcTFtMmkxNm9nLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwidG9rZW5faGFzaCI6IjIwT0JwZWd3UDdJQ1ptV1FadVZlb3ciLCJ2ZXJpZmllZF9lbWFpbCI6dHJ1ZSwiY2lkIjoiMTY2NjEzNTI4NTgxLWZtbGduaDFyMnNlOTY3aDNqcTVhZ3BhcTFtMmkxNm9nLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiaWF0IjoxNDIwNTE4NTE3LCJleHAiOjE0MjA1MjI0MTd9.puXvZ7v5CmsiRlH5voGU0eOO03BNHL1bKBUGm-T2Ovxk-PO2AeeFof14dhfucu48qgybqbADVi6Q7McAkGFKhJjJZ6KXtOo38hZjm_w1Y5-_3tU5M6eoHfT9fkKYwQGdfibzsfi9qktwqnQR5pUUahxzPJRrxHISf1HMklklxH4" forKey:@"id_token"];
    [newParams setObject:@"3599" forKey:@"expires_in"];
    
    newAuth.parameters = newParams;
    
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                 clientID:kClienID
                                                             clientSecret:kClientSecret];
    
    self.youtubeService.authorizer = newAuth;
    
    [self updateUI];
    //self.uploadedFileName = @"04_Aerial.mp4";
    [self authUserIfNeeded];
    //[self configureView];
}
-(void)configureView
{
    
    [self uploadVideoToYoutube];
}

-(void)uploadVideoToYoutube
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    //self.uploadedFileName = @"04_Aerial.mp4";
    WizardViewController *wizardVC = [WizardViewController sharedInstance];
    BOOL isUploadedToYoutube =   [[wizardVC.currentProjectDict objectForKey:@"isUploaded"]boolValue];
    if (isUploadedToYoutube) {
        // if uploading to ur server failed then just syn with our server
        [self showOverlayView];
        [self startServiceToUploadYoutubeResponse];
    }else{
        // if uploading to ur server failed then just syn with our server
        NSURL *finalVideoURL = [NSURL URLWithString:[[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"OutputURL"]];
        
        self.uploadedFileName=[finalVideoURL path];
        
        self.progressView = [[ProgressBarView alloc]initWithFrame:self.view.frame];
        self.progressView.progressDelegate =  self;
        [self.view addSubview:self.progressView];
        [self uploadVideoFile];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Keyboard Notifications

/*
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
 
 if (!isKeyBoardAppeared) {
 self.uploadScrollView.contentOffset = CGPointMake(0, 0);
 }
 
 }
 */

#pragma mark - Button Actions
- (IBAction)chooseFileButtonClicked:(id)sender {
//    if([UIImagePickerController isSourceTypeAvailable:
//        UIImagePickerControllerSourceTypePhotoLibrary]) {
//        
//        UIImagePickerController *picker= [[UIImagePickerController alloc] init];
//        picker.delegate = self;
//        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
//        
//        
//        [self presentViewController:picker animated:NO completion:nil];
//    }
}

- (IBAction)uploadBtnClicked:(id)sender {
    self.progressView = [[ProgressBarView alloc]initWithFrame:self.view.frame];
    self.progressView.progressDelegate =  self;
    [self.view addSubview:self.progressView];
    [self uploadVideoFile];
}
- (void)dismissCustomAlert{
    [self.progressView removeFromSuperview];
//    [self showOverlayView];
}
- (void)signButtonTapped:(id)sender {
    if (![self isSignedIn]) {
        [self authUserIfNeeded];
    }
    else {
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
        self.youtubeService.authorizer = nil;
        self.currentUserChannel = nil;
        self.gotChannel = NO;
        [self updateUI];
    }
}

- (NSString *)signedInUsername
{
    GTMOAuth2Authentication *auth = self.youtubeService.authorizer;
    BOOL isSignedIn = auth.canAuthorize;
    if (isSignedIn) {
        return auth.userEmail;
    } else {
        return nil;
    }
}

- (BOOL)isSignedIn {
    NSString *name = [self signedInUsername];
    return (name != nil);
}


#pragma mark - ImagePicker Delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:NO completion:Nil];
    
    NSURL *movieUrl = [info objectForKey:UIImagePickerControllerMediaURL];
    NSString *localUrl = [movieUrl path];
    self.uploadedFileName = localUrl;
    
}

/// Handle cancel from image picker/camera.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:Nil];
}

#pragma mark - UITextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.uploadScrollView.contentOffset = CGPointMake(0, textField.frame.origin.y-textField.frame.size.height -10);
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    // on clicking the return button on keyboard , managing the focus the next editable field.
    if ([textField isEqual:self.titleText]){
        [self.descriptionText becomeFirstResponder];
    }
    else if([textField isEqual:self.descriptionText]){
        
        [self.tagsText becomeFirstResponder];
        
    }
    
    else if ([textField isEqual:self.tagsText]){
        // to dismiss the keyboard on done button click
        [self.tagsText resignFirstResponder];
        
    }
    else{
        // to dismiss the keyboard
        [textField resignFirstResponder];
    }
    
    return YES;
}


- (void)uploadVideoFile{
    
   
    WizardViewController *wizardVC = [WizardViewController sharedInstance];
  
    
    NSFileHandle *handle        = [NSFileHandle fileHandleForReadingAtPath:self.uploadedFileName];
    
    NSString *titleStr = [[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"Title"];
    titleStr = [titleStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    titleStr = [titleStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSString *descriptionStr = [[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"Description"];
    descriptionStr = [descriptionStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    descriptionStr = [descriptionStr stringByReplacingOccurrencesOfString:@">" withString:@""];
   
    
  
    

    NSString *tags = [[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"Tags"];
    tags = [tags stringByReplacingOccurrencesOfString:@"<" withString:@""];
    tags = [tags stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSArray *tagsArray = [tags componentsSeparatedByString:@","];
   
    
   
    
    if (!handle)
    {
        NSLog(@"Failed to open file for reading");
        [self showAlert:@"Upload Failed" message:@"Failed to upload the file"];
        return;
    }
    
    GTLServiceYouTube *service      = [[GTLServiceYouTube alloc] init];
    service.authorizer              = self.youtubeService.authorizer;
    
    GTLUploadParameters *params     = [GTLUploadParameters uploadParametersWithFileHandle:handle MIMEType:@"application/octet-stream"];
    
    GTLYouTubeVideoSnippet *snippet = [GTLYouTubeVideoSnippet object];
    //snippet.title                   = self.titleText.text;
    snippet.title = titleStr;
    snippet.descriptionProperty     = descriptionStr;
    snippet.tags                    = tagsArray;
    snippet.categoryId              = @"17";
    
    GTLYouTubeVideoStatus *status   = [GTLYouTubeVideoStatus object];
    //status.privacyStatus            = @"private";Unlisted
    status.privacyStatus            = @"unlisted";
    
    GTLYouTubeVideo *video          = [GTLYouTubeVideo object];
    video.snippet                   = snippet;
    video.status                    = status;
    
    GTLQueryYouTube *query          = [GTLQueryYouTube queryForVideosInsertWithObject:video part:@"snippet,status" uploadParameters:params];
    
    // Perform the upload
    GTLServiceTicket *ticket        = [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
                                       {
                                           if (error)
                                           {
                                               NSLog(@"ERROR: %@", error);
                                               [wizardVC.currentProjectDict setValue:[NSNumber numberWithBool:NO] forKey:@"isUploaded"];
                                               
                                               [self showAlert:@"My Story" message:@"Video Upload Failed. Please try to upload your video again."];
                                               return;
                                           }
                                           
                                           
                                           
                                           GTLYouTubeVideo *uploaded = (GTLYouTubeVideo *)object;
                                           GTLYouTubeThumbnail *thumbnails = [uploaded.snippet.thumbnails additionalPropertyForName:@"default"];
                                           
                                           NSLog(@"%@",thumbnails.url);
                                           NSString *thumbNailsUrl = [NSString stringWithFormat:@"%@",thumbnails.url];
                                           
                                           [wizardVC.currentProjectDict setValue:thumbNailsUrl forKey:@"YoutubeThumbNailUrl"];
                                           [wizardVC.currentProjectDict setValue:uploaded.identifier forKey:@"YoutubeId"];
                                           
                                          [wizardVC.currentProjectDict setValue:[NSNumber numberWithBool:YES] forKey:@"isUploaded"];
                                           [wizardVC saveProjectData];
                                           
                                           [self startServiceToUploadYoutubeResponse];
                                           NSLog(@"SUCCESS! %@; ", uploaded.identifier);
                                           NSLog(@"snippet : %@", video.snippet.channelId);
                                           
                                           
                                       }];
    
    ticket.uploadProgressBlock = ^(GTLServiceTicket *ticket, unsigned long long numberOfBytesRead, unsigned long long dataLength)
    {
       // NSLog(@"%lld / %lld", numberOfBytesRead, dataLength);
        float val = (float)numberOfBytesRead/(float)dataLength;
        [self.progressView setProgress:val*100.0];
    };
    //    GTLYouTubeVideoStatus *status = [GTLYouTubeVideoStatus object];
    //    status.privacyStatus = @"private";
    //
    //    // Snippet.
    //    GTLYouTubeVideoSnippet *snippet = [GTLYouTubeVideoSnippet object];
    //    snippet.title = titleText;
    //    NSString *desc = descText;
    //    if ([desc length] > 0) {
    //        snippet.descriptionProperty = desc;
    //    }
    //
    //    if ([tagText length] > 0) {
    //        snippet.tags = [tagText componentsSeparatedByString:@","];
    //    }
    ////    if ([_uploadCategoryPopup isEnabled]) {
    ////        NSMenuItem *selectedCategory = [_uploadCategoryPopup selectedItem];
    ////        snippet.categoryId = [selectedCategory representedObject];
    ////    }
    //    //snippet.categoryId              = @"17";
    //    GTLYouTubeVideo *video = [GTLYouTubeVideo object];
    //    video.status = status;
    //    video.snippet = snippet;
    //
    //    _uploadLocationURL =  [NSURL URLWithString:@"https://www.googleapis.com/youtube/v3/videos"];
    //
    //    [self uploadVideoWithVideoObject:video
    //             resumeUploadLocationURL:_uploadLocationURL];
    
    
    
}
- (NSString *)MIMETypeForFilename:(NSString *)filename
                  defaultMIMEType:(NSString *)defaultType {
    NSString *result = defaultType;
    NSString *extension = [filename pathExtension];
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (__bridge CFStringRef)extension, NULL);
    if (uti) {
        CFStringRef cfMIMEType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
        if (cfMIMEType) {
            result = CFBridgingRelease(cfMIMEType);
        }
        CFRelease(uti);
    }
    return result;
}
- (void)uploadVideoWithVideoObject:(GTLYouTubeVideo *)video
           resumeUploadLocationURL:(NSURL *)locationURL {
    // Get a file handle for the upload data.
    NSString *path = uploadedFileName;
    NSString *filename = [path lastPathComponent];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    if (fileHandle) {
        NSString *mimeType = [self MIMETypeForFilename:filename
                                       defaultMIMEType:@"video/quicktime"];
        GTLUploadParameters *uploadParameters =
        [GTLUploadParameters uploadParametersWithFileHandle:fileHandle
                                                   MIMEType:mimeType];
        uploadParameters.uploadLocationURL = locationURL;
        
        GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosInsertWithObject:video
                                                                            part:@"snippet,status"
                                                                uploadParameters:uploadParameters];
        GTLServiceYouTube *service = self.youtubeService;
        
        _uploadFileTicket = [service executeQuery:query
                                completionHandler:^(GTLServiceTicket *ticket,
                                                    GTLYouTubeVideo *uploadedVideo,
                                                    NSError *error) {
                                    // Callback
                                    _uploadFileTicket = nil;
                                    if (error == nil) {
                                        [self showAlert:@"Uploaded" message:[NSString stringWithFormat:@"Uploaded file \"%@\"",
                                                                             uploadedVideo.snippet.title]];
                                        
                                        //                                        if ([_playlistPopup selectedTag] == kUploadsTag) {
                                        //                                            // Refresh the displayed uploads playlist.
                                        //                                            [self fetchSelectedPlaylist];
                                        //                                        }
                                    } else {
                                        [self showAlert:@"Upload Failed"
                                                message:[NSString stringWithFormat:@"%@", error]];
                                    }
                                    
                                    //                                    [_uploadProgressIndicator setDoubleValue:0.0];
                                    _uploadLocationURL = nil;
                                    [self updateUI];
                                }];
        
        //        NSProgressIndicator *progressIndicator = _uploadProgressIndicator;
        //        _uploadFileTicket.uploadProgressBlock = ^(GTLServiceTicket *ticket,
        //                                                  unsigned long long numberOfBytesRead,
        //                                                  unsigned long long dataLength) {
        //            [progressIndicator setMaxValue:(double)dataLength];
        //            [progressIndicator setDoubleValue:(double)numberOfBytesRead];
        //       };
        
        // To allow restarting after stopping, we need to track the upload location
        // URL.
        //
        // For compatibility with systems that do not support Objective-C blocks
        // (iOS 3 and Mac OS X 10.5), the location URL may also be obtained in the
        // progress callback as ((GTMHTTPUploadFetcher *)[ticket objectFetcher]).locationURL
        
        //        GTMHTTPUploadFetcher *uploadFetcher = (GTMHTTPUploadFetcher *)[_uploadFileTicket objectFetcher];
        //        _uploadLocationURL = uploadFetcher.locationURL;
        //        uploadFetcher.locationChangeBlock = ^(NSURL *url) {
        //           // _uploadLocationURL = url;
        //            [self updateUI];
        //        };
        
        [self updateUI];
    } else {
        // Could not read file data.
        [self showAlert:@"File Not Found" message:[NSString stringWithFormat:@"Path: %@", path]];
    }
}
- (void)updateUI
{
    self.navigationItem.leftBarButtonItem = self.signButton;
    self.title = self.signedInUsername;
    // [self.tableView reloadData];
}

- (void)authUserIfNeeded
{
    self.navigationItem.rightBarButtonItem = self.activityItem;
    
    if (self.isSignedIn) {
        //  [self getUserChannel];
        [self updateUI];
        return;
    }
    
    self.navigationItem.rightBarButtonItem = self.activityItem;
    
    //    DVModalAuthViewController *authViewController =
    //    [[DVModalAuthViewController alloc] initWithScope:kGTLAuthScopeYouTube
    //                                               clientID:kClienID
    //                                           clientSecret:kClientSecret
    //                                       keychainItemName:kKeychainItemName
    //                                      completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
    //
    //                                          self.navigationItem.rightBarButtonItem = nil;
    //
    //                                          if (!error) {
    //                                              self.youtubeService.authorizer = auth;
    //                                                                                          // [self getUserChannel];
    //                                          }
    //                                          else {
    //
    //                                              self.youtubeService.authorizer = nil;
    //
    //                                              NSLog(@"Authentication error: %@", error);
    //                                              NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
    //                                              if ([responseData length] > 0) {
    //                                                  // show the body of the server's authentication failure response
    //                                                  NSString *str = [[NSString alloc] initWithData:responseData
    //                                                                                        encoding:NSUTF8StringEncoding];
    //                                                  NSLog(@"%@", str);
    //                                              }
    //
    //
    //                                          }
    //
    //                                          [self updateUI];
    //
    //                                      }];
    //
    //    NSString *html = @"<html><body bgcolor=white><div align=center>Loading sign-in page...</div></body></html>";
    //    authViewController.initialHTMLString = html;
    //
    //    [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:authViewController] animated:YES completion:NULL];
}


- (void)showAlert:(NSString *)title message:(NSString *)message
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
                                                    message: message
                                                   delegate: self
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIViewController *vc = self.presentingViewController;
    
    if ([alertView.title isEqualToString:@"Upload Failed"] ||[alertView.title isEqualToString:@"Youtube Upload Failed"] || [alertView.title isEqualToString:@"My Story"] ) {
        [self.progressView removeFromSuperview];
        [self dismissViewControllerAnimated:NO completion:nil];
        if ([vc isKindOfClass:[SignUpViewController  class]]) {
            [vc dismissViewControllerAnimated:NO completion:nil];
        }
    }if ([alertView.title isEqualToString:@"Video Uploaded Successfully"]) {
//        [self dismissViewControllerAnimated:NO completion:nil];
//        if ([vc isKindOfClass:[SignUpViewController  class]]) {
//            [vc dismissViewControllerAnimated:NO completion:nil];
//        }
//        [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
        [self goToMystoryScreen];
      //  [self.parentViewController dismissViewControllerAnimated:NO completion:nil];
    }
}
-(void)goToMystoryScreen {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"
                                                  bundle:nil];
    
    ChannelsAndSelfiesViewController *profileVC =[sb instantiateViewControllerWithIdentifier:@"ChannelsAndSelfiesViewController"];
    [profileVC setIsChannels:NO];
    
    [self presentViewController:profileVC animated:NO completion:nil];

}
- (void)embedYouTubeVideo:(NSString *)urlString toWebView:(UIWebView *)webView{
    NSString *embedHTML = @"\
    <html>\
    <head>\
    <style type=\"text/css\">\
    iframe {position:absolute; top:50%%; margin-top:-130px;}\
    body {background-color:#000; margin:0;}\
    </style>\
    </head>\
    <body>\
    <iframe width=\"100%%\" height=\"240px\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>\
    </body>\
    </html>";
    NSString *html = [NSString stringWithFormat:embedHTML, urlString];
    [webView loadHTMLString:html baseURL:nil];
}

#pragma mark  -  Overlay View Management

- (void)showOverlayView
{
    
    [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:ACTIVITY_LOADING_TEXT_SYNCING_WITH_SEVER showProgress:NO onController:self];
}

- (void)removeOverlayView
{
    
    [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];
}
- (NSMutableDictionary *)getDetailsToSentToServer{
    
    UserInfo *user = [DBHelper getLoggedInUser];
    
    NSString *titleStr = [[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"Title"];
    NSString *descriptionStr = [[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"Description"];
    NSString *countryStr = [[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"Country"];
    NSString *languageStr = [[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"Language"];
    NSDictionary *scripDict =  [[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"Scripture"];
    
    NSString *scriptureText = [scripDict objectForKey:@"verse"];
    NSString *bookName =[scripDict objectForKey:@"bookName"];
    NSString *bibleChapter =[scripDict objectForKey:@"chapter"];
    NSString *bibleVerseNo =[NSString stringWithFormat:@"%d",[[scripDict objectForKey:@"verseNumber"]intValue]];
    NSString *bibleName = [scripDict objectForKey:@"bible_name"];
    NSString *bookOrder = [NSString stringWithFormat:@"%d",[[scripDict objectForKey:@"book_order"]intValue]];
    NSString *book_Id  = [scripDict objectForKey:@"book_id"];
    
    
    NSString *tags = [[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"Tags"];
    NSString *languCode = [DBHelper getLanguageCodeOfLanguage:languageStr];
    
    NSString *youtubeId = [[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"YoutubeId"];
    NSString *youtubeThumbNailUrl = [[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"YoutubeThumbNailUrl"];
    
    NSString *youtubeUrl =[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",youtubeId];
    NSMutableDictionary *responseDict = [[NSMutableDictionary alloc]init];
    
    // TITLE, DESC, EMAIL, LANGUAGE,COUNTRY
    if (titleStr&& titleStr.length>0)
    {
        [responseDict setObject:titleStr forKey:@"title"];
    }
    else
    {
        [responseDict setObject:@"" forKey:@"title"];
    }
    
    if (descriptionStr&& descriptionStr.length>0)
    {
        [responseDict setObject:descriptionStr forKey:@"description"];
    }
    else
    {
        [responseDict setObject:@"" forKey:@"description"];
    }
    
    
    if (languCode&& languCode.length>0)
    {
        [responseDict setObject:languCode forKey:@"language"];
    }
    else
    {
        [responseDict setObject:@"" forKey:@"language"];
    }
    
    if (user.emailId&& user.emailId.length>0)
    {
        [responseDict setObject:user.emailId forKey:@"email"];
    }
    else
    {
        [responseDict setObject:@"" forKey:@"email"];
    }
    
    if (countryStr&& countryStr.length>0)
    {
        [responseDict setObject:countryStr forKey:@"country"];
    }
    else
    {
        [responseDict setObject:@"" forKey:@"country"];
    }
    
    
    
    
    // YOUTUBE RELATED DETAILS
    if (youtubeId&& youtubeId.length>0)
    {
        [responseDict setObject:youtubeId forKey:@"youtube_id"];
    }
    else
    {
        [responseDict setObject:@"" forKey:@"youtube_id"];
    }
    
    if (youtubeUrl&& youtubeUrl.length>0)
    {
        [responseDict setObject:youtubeUrl forKey:@"youtube_url"];
    }
    else
    {
        [responseDict setObject:@"" forKey:@"youtube_url"];
    }
    
    if (youtubeThumbNailUrl&& youtubeThumbNailUrl.length>0)
    {
        [responseDict setObject:youtubeThumbNailUrl forKey:@"youtube_thumbnail_url"];
    }
    else
    {
        [responseDict setObject:@"" forKey:@"youtube_thumbnail_url"];
    }
    
    
    // SCRIPTURE
    if (scriptureText&& scriptureText.length>0)
    {
        [responseDict setObject:scriptureText forKey:@"scripture_text"];
    }
    else
    {
        [responseDict setObject:@"" forKey:@"scripture_text"];
    }
    
    if (bookName && bookName.length>0)
    {
        [responseDict setObject:bookName forKey:@"book_name"];
    }
    else
    {
        [responseDict setObject:@"" forKey:@"book_name"];
    }
    
    if (bibleChapter && bibleChapter.length >0)
    {
        [responseDict setObject:bibleChapter forKey:@"chapter"];
    }
    else
    {
        [responseDict setObject:@"" forKey:@"chapter"];
    }
    
    if (bibleVerseNo && bibleVerseNo.length>0)
    {
        [responseDict setObject:bibleVerseNo forKey:@"verse"];
    }
    else
    {
        [responseDict setObject:@"" forKey:@"verse"];
    }
    
    if (book_Id && book_Id.length >0)
    {
        [responseDict setObject:book_Id forKey:@"book_id"];
    }
    else
    {
        [responseDict setObject:@"" forKey:@"book_id"];
    }
    
    if (bibleName && bibleName.length >0)
    {
        [responseDict setObject:bibleName forKey:@"bible_name"];
    }
    else
    {
        [responseDict setObject:@"" forKey:@"bible_name"];
    }
    if (bookOrder && bookOrder.length >0)
    {
        [responseDict setObject:bookOrder forKey:@"book_order"];
    }
    else
    {
        [responseDict setObject:@"" forKey:@"book_order"];
    }
    
    
    // TAGS
    if (tags && tags.length >0)
    {
        [responseDict setObject:tags forKey:@"tags"];
    }
    
    //TOPICS
    NSString *joinedComponents= @"";
    NSArray *topicsArray =[[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"Topics"] ;
    for (int i =0; i <[topicsArray count]; i++) {
        NSDictionary *topicDict = [topicsArray objectAtIndex:i];
        joinedComponents = [joinedComponents stringByAppendingString:[topicDict objectForKey:@"id"]];
        if (i+1!=[topicsArray count]) {
            joinedComponents = [joinedComponents stringByAppendingString:@","];
        }
    }
    
    [responseDict setObject:joinedComponents forKey:@"topics"];
    return responseDict;
    
}
#pragma mark - API methods
- (void)startServiceToUploadYoutubeResponse{
    
    NSMutableDictionary *dict =[self getDetailsToSentToServer];
    YoutubeUploadService *uploadService =[[YoutubeUploadService alloc]init];
    [uploadService initService:ServiceTypeYoutubeResponseUpload withUploadedData:dict target:self];
    [uploadService start];
}
#pragma mark -  Service Class Delegate Methods
-(void)serviceSuccessful:(id)response
{
    [self removeOverlayView];
    NSLog(@"success to server: %@",response);
    [[WizardViewController sharedInstance] deleteAndStartNewStory];
    
    //[[WizardViewController sharedInstance] dismissViewControllerAnimated:NO completion:nil];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Tell Your Story-Upload Video"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Tell Your Story"
                                                          action:@"Upload Video"
                                                           label:@"User uploads their selfie video to the website"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];

    [self showAlert:@"Video Uploaded Successfully" message:@"You can make your video private at any time in the My Stories screen."];
//    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"
//                                                  bundle:nil];
//    
//    ChannelsAndSelfiesViewController *profileVC =[sb instantiateViewControllerWithIdentifier:@"ChannelsAndSelfiesViewController"];
//    
//    [profileVC setIsChannels:NO];
//    [self presentViewController:profileVC animated:NO completion:nil];
    
    
    
}

-(void)serviceFailed:(id)response {
    
    NSLog(@"serviceFailed : %@",response);
     [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self removeOverlayView];
    [self showAlert:@"Upload Failed" message:@"Please try later"];
    if ([response isKindOfClass:[NSString class]]) {
        //  NSString *failureMessage = (NSString*)response;
        
        // [self showAlertWithMessage:failureMessage];
    }else{
        //[self showAlertWithMessage:NO_SERVER_RESPONSE];
    }
}
- (void)networkError{
     [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self removeOverlayView];
    [self showAlert:@"Upload Failed" message:kSERVICE_NETWORK_NOT_AVAILABLE_MSG];
    //[self showAlertWithMessage:kSERVICE_NETWORK_NOT_AVAILABLE_MSG];
}

//- (void)getActivity
//{
//    GTLQueryYouTube *videoQuery = [GTLQueryYouTube queryForActivitiesListWithPart:@"id, snippet, contentDetails"];
//
//    videoQuery.home = @"TRUE";
//    videoQuery.maxResults = 10;
//
//
//    [self.youtubeService executeQuery:videoQuery
//                    completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeActivityListResponse *object, NSError *error) {
//                        NSArray *activityItems = object.items;
//                        GTLYouTubeActivity *activity = activityItems.lastObject;
//                        [activityItems enumerateObjectsUsingBlock:^(GTLYouTubeActivity *activity, NSUInteger idx, BOOL *stop) {
//                            NSLog(@"activity title: %@", activity.snippet.title);
//                        }];
//                    }];
//}
//
//- (void)getUserChannel
//{
//    GTLQueryYouTube *videoQuery = [GTLQueryYouTube queryForChannelsListWithPart:@"id, snippet, contentDetails"];
//
//    videoQuery.mine = YES;
//
//    [self.youtubeService executeQuery:videoQuery
//                    completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeChannelListResponse *object, NSError *error) {
//                        self.currentUserChannel = object.items.lastObject;
//                        if (self.currentUserChannel) {
//                             [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:YoutubeAPICallsSectionMyChannel]] withRowAnimation:UITableViewRowAnimationNone];
//                        }
//
//                    }];
//
//}
//
//- (void)getChannel:(NSString *)channelId onCompletion:(void(^)(GTLYouTubeChannelListResponse *response))completion
//{
//    if (!channelId) {
//        [self getUserChannel];
//        return;
//    }
//
//    GTLQueryYouTube *videoQuery = [GTLQueryYouTube queryForChannelsListWithPart:@"id, snippet, contentDetails"];
//
//    videoQuery.identifier = channelId;
//
//    [self.youtubeService executeQuery:videoQuery
//                    completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeChannelListResponse *object, NSError *error) {
//                        if (completion) completion(object);
//                    }];
//
//}
//
//- (void)getPlaylistsOnCompletion:(void(^)(void))completion
//{
//    GTLQueryYouTube *videoQuery = [GTLQueryYouTube queryForPlaylistsListWithPart:@"id, snippet"];
//
//    videoQuery.mine = YES;
//    videoQuery.maxResults = 50;
//
//    [self.youtubeService executeQuery:videoQuery
//                    completionHandler:^(GTLServiceTicket *ticket, GTLYouTubePlaylistListResponse *object, NSError *error) {
//                        self.currentUserPlaylists = object.items;
//
//                        NSMutableArray *indexPaths = [@[] mutableCopy];
//
//                        for (int i = 0; i<self.currentUserPlaylists.count; i++) {
//                            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:YoutubeAPICallsSectionMyPlaylists]];
//                        }
//
//                        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//
//                        self.gotPlaylists = YES;
//
//                        if (completion) completion();
//
//                    }];
//}
//
//- (void)getSubscriptionsOnCompletion:(void(^)(void))completion
//{
//    GTLQueryYouTube *videoQuery = [GTLQueryYouTube queryForSubscriptionsListWithPart:@"id, snippet, contentDetails"];
//
//    videoQuery.mine = YES;
//    videoQuery.maxResults = 50;
//
//    [self.youtubeService executeQuery:videoQuery
//                    completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeSubscriptionListResponse *object, NSError *error) {
//                        self.currentUserSubscriptions = object.items;
//
//                        NSMutableArray *indexPaths = [@[] mutableCopy];
//
//                        for (int i = 0; i<self.currentUserSubscriptions.count; i++) {
//                            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:YoutubeAPICallsSectionMySubscriptions]];
//                        }
//
//                        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//
//                        self.gotSubscriptions = YES;
//
//                        if (completion) completion();
//
//                    }];
//}
//
//- (void)playVideoWithID:(NSString *)videoId
//{
//    GTLQueryYouTube *videoQuery = [GTLQueryYouTube queryForVideosListWithIdentifier:videoId
//                                                                               part:@"player"];
//
//    [self.youtubeService executeQuery:videoQuery
//                    completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeVideoListResponse *videoList, NSError *error){
//
//                        GTLYouTubeVideo *video = videoList.items.lastObject;
//
//                        DVYoutubePlayerViewController *playerViewController = [[DVYoutubePlayerViewController alloc] init];
//
//                        [self embedYouTubeVideo:video.videoSrc toWebView:playerViewController.webView];
//
//                        [self.navigationController pushViewController:playerViewController animated:YES];
//                    }];
//}
//
//- (void)getUserUploadsVideosOnCompletion:(void (^)(void))completion
//{
//    GTLQueryYouTube *videoQuery = [GTLQueryYouTube queryForPlaylistItemsListWithPart:@"id, snippet, contentDetails"];
//    
//    videoQuery.playlistId = self.currentUserChannel.contentDetails.relatedPlaylists.uploads;
//    videoQuery.maxResults = 50;
//    
//    [self.youtubeService executeQuery:videoQuery
//                    completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeVideoListResponse *object, NSError *error) {
//                        self.currentUserUploads = object.items;
//                        NSMutableArray *indexPaths = [@[] mutableCopy];
//                        
//                        for (int i = 0; i<self.currentUserUploads.count; i++) {
//                            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:YoutubeAPICallsSectionMyUploadedVideos]];
//                        }
//                        
//                        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//                        
//                        self.gotUploads = YES;
//                        
//                        if (completion) completion();
//                    }];
//
//}
//
//- (void)getUserFavoritesOnCompletion:(void (^)(void))completion
//{
//    GTLQueryYouTube *videoQuery = [GTLQueryYouTube queryForPlaylistItemsListWithPart:@"id, snippet, contentDetails"];
//    
//    videoQuery.playlistId = self.currentUserChannel.contentDetails.relatedPlaylists.favorites;
//    videoQuery.maxResults = 50;
//    
//    [self.youtubeService executeQuery:videoQuery
//                    completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeVideoListResponse *object, NSError *error) {
//                        self.currentUserFavorites = object.items;
//                        
//                        NSMutableArray *indexPaths = [@[] mutableCopy];
//                        
//                        for (int i = 0; i<self.currentUserFavorites.count; i++) {
//                            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:YoutubeAPICallsSectionMyFavoriteVideos]];
//                        }
//                        
//                        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//                        
//                        self.gotFavorites = YES;
//                        
//                        if (completion) completion();
//
//                    }];
//    
//}



@end
