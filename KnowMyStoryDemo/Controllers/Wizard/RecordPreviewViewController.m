
//
//  RecordPreviewViewController.m
//  KnowMyStoryDemo
//
//  Created by Abdusha on 12/17/14.
//  Copyright (c) 2014 Fingent. All rights reserved.
//

#import "RecordPreviewViewController.h"
#import "WizardViewController.h"
#import "AVPlayerDemoPlaybackViewController.h"
#import "MergeViewController.h"
#import "SignUpViewController.h"
#import "YoutubeUploadViewController.h"
#import "AVCamViewController.h"

@interface RecordPreviewViewController ()

@end

@implementation RecordPreviewViewController

static RecordPreviewViewController *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (RecordPreviewViewController *)sharedInstance
{
    if (sharedInstance == nil)
    {
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

#pragma mark - View Life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    sharedInstance = self;
    
}
-(void)viewWillDisappear:(BOOL)animated
{
}

-(void)InitialiseView
{
    self.saveTimer = nil;
    [self configureView];
}

-(void)configureView
{
    
    if ([[AVCamViewController sharedInstance] backgroundCompressingID])
    {
        [self rerecordButtonPressed:nil];
        return;
    }
    
    
    if ([[WizardViewController sharedInstance] currentScreenSequenceIndex] == WizardStepUpload)
    {
        [self.reRecordButton setHidden:YES];
        [self.trimButton setHidden:YES];
        [self.uploadButton setHidden:NO];
        [self.saveButton setHidden:NO];
        [self.saveButton setEnabled:YES];
        [self.nextButton setHidden:YES];
        
        BOOL isMerged = [[[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"isMerged"] boolValue];
        
        
        if (isMerged)
        {
            NSString *videoURL = [[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"OutputURL"];
            [self playVideoPreviewWithURL:[NSURL URLWithString:videoURL]];
        }
        else
        {
            if ([[MergeViewController sharedInstance] backgroundMergingID])
            {
                [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:ACTIVITY_LOADING_TEXT_MERGING showProgress:YES onController:[WizardViewController sharedInstance]];
            }
            else
            {
                [[MergeViewController sharedInstance] mergeAllVideoswithCompletionHandler:^(NSError* error)
                 {
                     NSString *videoURL = [[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"OutputURL"];
                     [self playVideoPreviewWithURL:[NSURL URLWithString:videoURL]];
                 }
                 ];
            }
            
        }
        
    }
    else
    {
        [self.uploadButton setHidden:YES];
        [self.saveButton setHidden:YES];
        [self.reRecordButton setHidden:NO];
        [self.trimButton setHidden:NO];
        [self.nextButton setHidden:NO];
        
        NSString *currentScreen = [[WizardViewController sharedInstance] getCurrentScreenName];
        NSString *videoURL = [[[[WizardViewController sharedInstance] currentProjectDict] objectForKey:currentScreen] objectForKey:@"videoPath"];
        [self playVideoPreviewWithURL:[NSURL URLWithString:videoURL]];
        
    }
    
    
    [self.nextButton setUserInteractionEnabled:YES];
}
-(void)hideAndStopViewActions
{
    [self stopVideoPreview];
}

-(void)playVideoPreviewWithURL:(NSURL *)videoURL
{
    self.videoURL = videoURL;
    [self playVideoPreview];
    
}
-(void)playVideoPreview
{
    
    //thumbnail url with the same name of video
    NSURL *thumbURL = [self.videoURL URLByDeletingPathExtension];
    thumbURL = [thumbURL URLByAppendingPathExtension:@"png"];

    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[thumbURL path]])
    {
        NSLog(@"thumb file Exists At Path : %@",[thumbURL path]);
    }
    else
    {
        NSLog(@"thumb file Not Exists At Path : %@",[thumbURL path]);
    }

    UIImage *thumbImage = [UIImage imageWithContentsOfFile:[thumbURL path]];
    [self.thumbnailPreviewImageView setImage:thumbImage];
    
    
}

-(void) stopVideoPreview
{
    //[self.mvPlayer stop];
}

#pragma mark - Button Press Methods

- (IBAction)nextButtonPressed:(id)sender
{
    [self.nextButton setUserInteractionEnabled:NO];
    [[WizardViewController sharedInstance] nextButtonPressed:nil];
}
- (IBAction)homeButtonPressed:(id)sender
{
    [self hideAndStopViewActions];
    [self dismissViewControllerAnimated:NO completion:^{}];
}

- (IBAction)rerecordButtonPressed:(id)sender
{
    [[WizardViewController sharedInstance] rerecordCurrentVideo];
}
- (IBAction)trimButtonPressed:(id)sender
{
    [[WizardViewController sharedInstance] showTrimView];
    [[AVPlayerDemoPlaybackViewController sharedInstance] prepareForTrimPreviewWithURL:self.videoURL];
}

- (IBAction)previewButtonPressed:(id)sender {
    
    [[[WizardViewController sharedInstance] previewPlayerContainerView] setHidden:NO];
    [[AVPlayerDemoPlaybackViewController sharedInstance] prepareForRecordPreviewWithURL:self.videoURL];
   
}
- (IBAction)uploadButtonPressed:(id)sender
{
    if (![[WizardViewController sharedInstance] haveDataForKey:@"Topics"])
    {
        [self showAlertWithMessage:@"Please select a topic"];

    }
    else if(![DBHelper isUserLoggedIn])
    {
         [self showLoginPage];
    }
    else
    {
        
        
        [self presentViewController:[YoutubeUploadViewController sharedInstance] animated:NO completion:nil];
        [[YoutubeUploadViewController sharedInstance] uploadVideoToYoutube];
    }
}

- (IBAction)saveButtonPressed:(id)sender
{
    [self startSaving];
}

-(void)startSaving
{
    [self.saveButton setEnabled:NO];
    [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:ACTIVITY_LOADING_TEXT_SAVING showProgress:NO onController:[WizardViewController sharedInstance]];
    self.saveTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                      target:self
                                                    selector:@selector(finishSaving)
                                                    userInfo:nil
                                                     repeats:NO];
    
}


#pragma mark - Alert
- (void)showAlertWithMessage:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: kALERT_TITLE
                                                        message: message
                                                       delegate: self
                                              cancelButtonTitle: @"Cancel"
                                              otherButtonTitles: @"Goto Topics screen", nil];
    
    [alertView show];
    
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 1)
    {
        // do something here...
        [[WizardViewController sharedInstance] setWizardForcedSelectionIndex:WizardStepUpload];
        [[WizardViewController sharedInstance] configureScreenForIndex:WizardStepTitle];
    }
}


-(void)finishSaving
{
    [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];
    [self clearVerseTimer];
    
    [self dismissViewControllerAnimated:NO completion:^{}];
}

-(void) clearVerseTimer
{
    if (self.saveTimer)
    {
        if ([self.saveTimer isValid])
        {
            [self.saveTimer invalidate];
        }
        self.saveTimer = nil;
    }
    
}


#pragma mark - Login Page
-(void)showLoginPage
{
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"
                                                  bundle:nil];
        SignUpViewController *signUpVC = [SignUpViewController sharedInstance];
        
        if (!signUpVC)
        {
            signUpVC  =[sb instantiateViewControllerWithIdentifier:@"SignUp"];
        }
        if(signUpVC.termsBtn.selected){
            [signUpVC OnClickOfTermsStatement:nil];
        }
        [signUpVC setIsForMySelfies:NO];
        [signUpVC setIsForMyProfile:NO];
        [self presentViewController:signUpVC animated:NO completion:nil];
    
}

- (void)didReceiveMemoryWarning {
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

@end
