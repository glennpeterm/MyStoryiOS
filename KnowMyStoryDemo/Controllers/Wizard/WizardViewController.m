//
//  WizardViewController.m
//  KnowMyStoryDemo
//
//  Created by Abdusha on 12/17/14.
//  Copyright (c) 2014 Fingent. All rights reserved.
//

#import "WizardViewController.h"
#import "AVCamViewController.h"
#import "RecordPreviewViewController.h"
#import "BGMusicViewController.h"
#import "TrimVideoViewController.h"
#import "CreateNewStoryViewController.h"
#import "AVPlayerDemoPlaybackViewController.h"
#import "DescriptionViewController.h"
#import "ScriptureListViewController.h"
#import "RegionViewController.h"
#import "GAIDictionaryBuilder.h"
#import "WizardTabButton.h"

@interface WizardViewController ()

@property (nonatomic, retain) NSString *loadingViewTextString;
@end

@implementation WizardViewController

@synthesize currentProjectDict;
@synthesize screenSequenceArray;
@synthesize currentScreenSequenceIndex;
@synthesize wizardForcedSelectionIndex;
@synthesize wizardCompletedIndex;

#define kWizardTabItemTag   2000
static WizardViewController *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (WizardViewController *)sharedInstance
{
    if (sharedInstance == nil)
    {
        //sharedInstance = [[WizardViewController alloc] init];
    }
    
    return sharedInstance;
}
+ (id)allocWithZone:(NSZone *)zone {
    KMSDebugLog();
    
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
    KMSDebugLog();
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        sharedInstance = self;
    }
    return self;
}



- (void)viewDidLoad {
    
    KMSDebugLog();
    self.isInWizardController = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    sharedInstance = self;
    [self InitialiseView];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    KMSDebugLog();
    [super viewWillAppear:animated];
    self.isInWizardController = YES;
    self.topTabScroller.contentSize = self.topTabContentView.frame.size; //sets ScrollView content size
}
-(void)viewDidAppear:(BOOL)animated
{
    KMSDebugLog();
    [super viewDidAppear:animated];
}

// iOS 7 fix : Abdu 01 April 15
- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
   self.topTabScroller.contentSize = self.topTabContentView.frame.size; //sets ScrollView content size
   
}


-(void) viewDidDisappear:(BOOL)animated
{
    KMSDebugLog();
    
    [self saveProjectData];
    self.isInWizardController = NO;
}

- (void)didReceiveMemoryWarning {
    KMSDebugLog();
    
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


#pragma mark - One time methods

-(void)InitialiseView
{
    KMSDebugLog();
    self.currentScreenSequenceIndex = WizardStepTitle;
    self.wizardCompletedIndex = WizardStepUndefined;
    self.wizardForcedSelectionIndex = WizardStepUndefined;
    self.selectedIndex = 0;
    
    [[AVCamViewController sharedInstance] setDelegate:self];
    
    screenSequenceArray = [NSArray arrayWithObjects:@"Title",@"Introduction",@"Setup",@"God Moment",@"The Word",@"Conclusion",@"Music",@"Description",@"Region",@"Upload", nil];
    
    [self setupWizardButtons];
    self.topTabScroller.contentOffset = CGPointZero;
}

-(void)setupWizardButtons
{
    for (int i = 0; i < [self.screenSequenceArray count]; i++)
    {
         WizardTabButton *topButton = (WizardTabButton *)[self.topTabContentView viewWithTag:(kWizardTabItemTag+i)];
        NSString *tabTitleString = [NSString stringWithFormat:@"%@",[self.screenSequenceArray objectAtIndex:i]];
        [topButton setTitle:tabTitleString forState:UIControlStateNormal];
        
        [topButton setupButton];
        [topButton.sequenceNumberLabel setText:[NSString stringWithFormat:@"%d",(i+1)]];
    }
    
}

#pragma mark - Screen configuration methods

-(void) configureScreenForIndex:(int)index
{
    self.currentScreenSequenceIndex = index;
    [self configureScreen];
}
-(void) configureScreen
{

    NSString *currentScreen = [self getCurrentScreenName];
    [self.currentProjectDict setValue:currentScreen forKey:@"currentScreen"];
    [self.currentProjectDict setValue:[NSNumber numberWithInt:self.currentScreenSequenceIndex] forKey:@"currentScreenIndex"];
    
    [self setSelectedIndex:self.currentScreenSequenceIndex animated:YES];
    [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];

    
}

-(void)hideAndStopViewActions
{
    
}

-(void) setupSelectedScreen
{
    NSString *currentScreen = [self getCurrentScreenName];
    KMSDebugLog(@"configureScreen - currentScreenSequenceIndex :%d currentScreen:%@",self.currentScreenSequenceIndex,currentScreen);
    [self selectButtonForIndex:self.currentScreenSequenceIndex];
    
    
    if (self.currentScreenSequenceIndex == WizardStepTitle)
    {
        [self showScreenWithId:kWizardViewTitle];
    }
    else if (self.currentScreenSequenceIndex >= WizardStepIntroduction && self.currentScreenSequenceIndex < WizardStepMusic)
    {
        
        NSString *videoURL = [[self.currentProjectDict objectForKey:currentScreen] objectForKey:@"videoPath"];
        NSError *error;
        if (videoURL && [[NSFileManager defaultManager] fileExistsAtPath:[[NSURL URLWithString:videoURL] path]])
        {
            
        }
        else
        {
            videoURL = @"";
            [self.currentProjectDict setValue:videoURL forKeyPath:[NSString stringWithFormat:@"%@.videoPath",currentScreen]];
        }
        
        if (error)
        {
            NSLog(@"FilePath Error :%@",error);
        }
        
        if (![videoURL isEqualToString:@""])
        {
            [self showScreenWithId:kWizardViewClipPreview];
        }
        else
        {
            if(self.currentScreenSequenceIndex == WizardStepVerse)
            {
                WizardViewController *wizardVC = [WizardViewController sharedInstance];
                NSString *scriptureBookName = [[wizardVC.currentProjectDict objectForKey:@"Scripture"] objectForKey:@"bookName"];
                if (!scriptureBookName || [scriptureBookName isEqualToString:@""])
                {
                    [self showScreenWithId:kWizardViewScripture];
                }
                else
                {
                    [self showScreenWithId:kWizardViewCamera];
                }
            }
            else
            {
                [self showScreenWithId:kWizardViewCamera];
            }
        }
    }
    else if(self.currentScreenSequenceIndex == WizardStepMusic)
    {
        [self showScreenWithId:kWizardViewMusic];
    }
    else if(self.currentScreenSequenceIndex == WizardStepDescription)
    {
        [self showScreenWithId:kWizardViewDescription];
    }
    else if(self.currentScreenSequenceIndex == WizardStepRegion)
    {
        [self showScreenWithId:kWizardViewRegion];
    }
    else if(self.currentScreenSequenceIndex == WizardStepUpload)
    {
        [self showScreenWithId:kWizardViewFinalPreview];
    }
    else
    {
        NSLog(@"configureScreen - Invalid index :%d",self.currentScreenSequenceIndex);
    }
}

-(NSString *)getCurrentScreenName
{
    NSString *currentScreen;
    if (self.currentScreenSequenceIndex > WizardStepUndefined)
    {
        currentScreen = [self.screenSequenceArray objectAtIndex:self.currentScreenSequenceIndex];
    }
    else
    {
        currentScreen=@"Invalid Screen";
    }
    return currentScreen;
}



#pragma mark - Button Pressed methods

-(void) rerecordCurrentVideo
{
    KMSDebugLog(@"loading camera for rerecording");
    [self showScreenWithId:kWizardViewCameraLanding];
}


- (void)nextButtonPressed:(id)sender
{
    if (self.wizardForcedSelectionIndex > WizardStepUndefined && self.wizardForcedSelectionIndex <= WizardStepUpload)
    {
        [self updateWizardTabButtonAsCompleted];
        self.currentScreenSequenceIndex = self.wizardForcedSelectionIndex;
    }
    else
    {
        [self updateWizardTabButtonAsCompleted];
        
        if (self.wizardCompletedIndex < self.currentScreenSequenceIndex)
        {
            self.wizardCompletedIndex = self.currentScreenSequenceIndex;
            [self.currentProjectDict setValue:[NSNumber numberWithInt:self.wizardCompletedIndex] forKey:@"completedStepIndex"];
        }
        
        self.currentScreenSequenceIndex++;
    }
    
    WizardTabButton *topButton = (WizardTabButton *)[self.topTabContentView viewWithTag:(kWizardTabItemTag+self.currentScreenSequenceIndex)];
    [topButton setEnabled:YES];
    [self configureScreen];
}

-(void)updateWizardTabButtonAsCompleted
{
    WizardTabButton *topButton = (WizardTabButton *)[self.topTabContentView viewWithTag:(kWizardTabItemTag+self.currentScreenSequenceIndex)];
    [topButton markAsCompleted];
}

- (IBAction)topTabButtonPressed:(WizardTabButton *)sender
{
    if (self.currentScreenSequenceIndex == WizardStepTitle && ![[CreateNewStoryViewController sharedInstance] isMandatoryFieldsFilled])
    {
        return;
    }
    else if (self.currentScreenSequenceIndex == WizardStepDescription && ![[DescriptionViewController sharedInstance] isMandatoryFieldsFilled])
    {
        return;
    }
    else if (self.currentScreenSequenceIndex == WizardStepRegion && ![[RegionViewController sharedInstance] isMandatoryFieldsFilled])
    {
        return;
    }
    
    self.wizardForcedSelectionIndex = WizardStepUndefined;
    [self configureScreenForIndex:sender.tag % kWizardTabItemTag];
}


#pragma mark - Clip capture results
-(void) capturedVideoWithURL:(NSURL *)videoURL
{
   //Abdu April 06 iOS 7 Fix
//    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8 )
//    {
//        [self updateVideoForScreenIndex:self.currentScreenSequenceIndex withVideoUrl:videoURL andCompletionHandler:^(NSError* error)
//         {
//             NSLog(@"updateVideoForScreenIndex Error :%@",error);
//             [self configureScreen];
//         }
//         ];
//    }
//    else
//    {
//        [self performSelector:@selector(UpdateVideoAndConfigureScreenForURL:) withObject:videoURL afterDelay:0.2];
//    }
    
   [self performSelector:@selector(UpdateVideoAndConfigureScreenForURL:) withObject:videoURL afterDelay:0.2];
}

-(void)UpdateVideoAndConfigureScreenForURL:(NSURL *)videoURL
{
    [self updateVideoForScreenIndex:self.currentScreenSequenceIndex withVideoUrl:videoURL andCompletionHandler:^(NSError* error)
     {
         NSLog(@"updateVideoForScreenIndex Error :%@",error);
         [self configureScreen];
     }
     ];
}

-(void)updateVideoForScreenIndex:(int)screenIndex withVideoUrl:(NSURL *)videoURL andCompletionHandler:(void (^)(NSError* error))completionHandler
{
    NSError *error =nil;
    if (screenIndex < WizardStepMusic)
    {
        NSString *currentScreen = [self getCurrentScreenName];
        NSURL *existingVideoURL = [NSURL URLWithString:[[self.currentProjectDict objectForKey:currentScreen] objectForKey:@"videoPath"]];
        if (existingVideoURL && [[NSFileManager defaultManager] fileExistsAtPath:[existingVideoURL path]])
        {
            [[NSFileManager defaultManager] removeItemAtPath:[existingVideoURL path] error:&error];
        }
        
        if (error)
        {
            NSLog(@"FilePath Error :%@",error);
        }
        
        [self.currentProjectDict setValue:[videoURL absoluteString] forKeyPath:[NSString stringWithFormat:@"%@.videoPath",currentScreen]];
        [self.currentProjectDict setValue:[NSNumber numberWithBool:NO] forKey:@"isMerged"];
    }
    else if(screenIndex == WizardStepUpload)
    {
        NSURL *existingVideoURL = [NSURL URLWithString:[self.currentProjectDict objectForKey:@"OutputURL"]];
        if (existingVideoURL && [[NSFileManager defaultManager] fileExistsAtPath:[existingVideoURL path]])
        {
            [[NSFileManager defaultManager] removeItemAtPath:[existingVideoURL path] error:&error];
        }
        
        if (error)
        {
            NSLog(@"export : previous FilePath Error :%@",error);
        }
        
        [self.currentProjectDict setValue:[videoURL absoluteString] forKey:@"OutputURL"];
        [self.currentProjectDict setValue:[NSNumber numberWithBool:YES] forKey:@"isMerged"];
        [self.currentProjectDict setValue:[NSNumber numberWithBool:NO] forKey:@"isUploaded"];
    }
    [self saveProjectData];
    
    KMSDebugLog(@"generateThumbnailsForAsset updateVideoForScreenIndex :%@",videoURL);
    
    if (videoURL && [[NSFileManager defaultManager] fileExistsAtPath:[videoURL path]])
    {
        
        KMSDebugLog(@"updateVideoForScreenIndex Captured Video File Exists at :%@",videoURL);
    }
    else
    {
         KMSDebugLog(@"updateVideoForScreenIndex Captured Video File Not Exists at :%@",videoURL);
    }
    
    //AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey : @YES}];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    [[TrimVideoViewController sharedInstance] generateThumbnailsForAsset:asset thumbnailCount:1 andCompletionHandler:^(NSArray* thumbnailsArray)
     {
         KMSDebugLog(@"thumbnailsArray count : %d",[thumbnailsArray count]);
         
         [self updateThumbnailForScreenIndex:screenIndex withVideoUrl:videoURL andCompletionHandler:^(NSError* error,NSURL *thumbURL)
          {
               KMSDebugLog(@"updateVideoForScreenIndex thumbURL : %@",thumbURL);
              if (thumbnailsArray.count > 0)
              {
                  UIImage *thumbImage = [thumbnailsArray objectAtIndex:0];
                  NSData *imageData = UIImagePNGRepresentation(thumbImage);
                  [imageData writeToFile:[thumbURL path] atomically:YES];
              }
              
              completionHandler(error);
              
          }
          ];
     }
     ];
   
    
}




-(void)updateThumbnailForScreenIndex:(int)screenIndex withVideoUrl:(NSURL *)videoURL andCompletionHandler:(void (^)(NSError* error,NSURL *thumbURL))completionHandler
{
    NSError *error =nil;
    //thumbnail url with the same name of video
    NSURL *storyURL = [videoURL URLByDeletingPathExtension];
    NSURL *thumbURL = [storyURL URLByAppendingPathExtension:@"png"];

        if (screenIndex < WizardStepMusic)
        {
            
            NSString *currentScreen = [self getCurrentScreenName];
            NSURL *existingVideoURL = [NSURL URLWithString:[[self.currentProjectDict objectForKey:currentScreen] objectForKey:@"thumbnailPath"]];
            if (existingVideoURL && [[NSFileManager defaultManager] fileExistsAtPath:[existingVideoURL path]])
            {
                [[NSFileManager defaultManager] removeItemAtPath:[existingVideoURL path] error:&error];
            }
            
            if (error) {
                KMSDebugLog(@"FilePath Error :%@",error);
            }
            
            [self.currentProjectDict setValue:[thumbURL absoluteString] forKeyPath:[NSString stringWithFormat:@"%@.thumbnailPath",currentScreen]];
        }
        else if(screenIndex == WizardStepUpload)
        {
            NSURL *existingVideoURL = [NSURL URLWithString:[self.currentProjectDict objectForKey:@"mergedVideoThumbnailPath"]];
            if (existingVideoURL && [[NSFileManager defaultManager] fileExistsAtPath:[existingVideoURL path]])
            {
                [[NSFileManager defaultManager] removeItemAtPath:[existingVideoURL path] error:&error];
            }
            
            if (error)
            {
                KMSDebugLog(@"export : previous FilePath Error :%@",error);
            }
            
            [self.currentProjectDict setValue:[thumbURL absoluteString] forKey:@"mergedVideoThumbnailPath"];
        }
        [self saveProjectData];
        completionHandler(error,thumbURL);
}

#pragma mark - Wizard scroller

- (CGFloat)scrollHeight
{
    return CGRectGetHeight(self.view.frame) - 40;
}

- (CGFloat)scrollWidth
{
    return CGRectGetWidth(self.topTabScroller.frame);
}

- (void)setSelectedIndex:(int)selectedIndex animated:(BOOL)animated
{
    KMSDebugLog(@"setSelectedIndex selectedIndex:%i abs:%d",selectedIndex,abs(self.selectedIndex - selectedIndex));
    
    if (abs(self.selectedIndex - selectedIndex) <= 1)
    {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             //only this may req
             self.topTabScroller.contentOffset = [self contentOffsetForSelectedItemAtIndex:selectedIndex];
         } completion:^(BOOL finished)
         {
             
             [self setupSelectedScreen];
        }];
    }
    else
    {
        BOOL scrollingRight = (selectedIndex > self.selectedIndex);

        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            //only this may req
            self.topTabScroller.contentOffset = [self contentOffsetForSelectedItemAtIndex:selectedIndex];
        } completion:^(BOOL finished)
        {
            [self setupSelectedScreen];
        }];
    }
    _selectedIndex = selectedIndex;
}

- (CGPoint)contentOffsetForSelectedItemAtIndex:(NSUInteger)index
{
    int tabCount = [self.screenSequenceArray count];
    if (tabCount < index || index <= 0)
    {
        return CGPointZero;
    }
    else
    {
        CGFloat totalOffset = self.topTabScroller.contentSize.width - CGRectGetWidth(self.topTabScroller.frame);
        float offsetX = index * totalOffset / (tabCount - 1);
        CGPoint ContentOffset = CGPointMake(offsetX, 0.0);
        return ContentOffset;
    }
}

-(void)selectButtonForIndex:(int)index
{
    for (int i = 0; i <= [self.screenSequenceArray count]; i++)
    {
        WizardTabButton *topButton = (WizardTabButton *)[self.topTabContentView viewWithTag:(kWizardTabItemTag+i)];
        if (i == currentScreenSequenceIndex)
        {
            [topButton setSelected:YES];
        }
        else
        {
            [topButton setSelected:NO];
        }
        
    }
}

-(void)updateWizardButtonStates
{
    for (int i = 0; i <= WizardStepUpload; i++)
    {
        WizardTabButton *topButton = (WizardTabButton *)[self.topTabContentView viewWithTag:(kWizardTabItemTag+i)];
        if (i <= self.wizardCompletedIndex)
        {
            [topButton setEnabled:YES];
            [topButton markAsCompleted];
        }
        else if (i == (self.wizardCompletedIndex +1))
        {
            [topButton setupButton];
            [topButton setEnabled:YES];
        }
        else
        {
            [topButton setupButton];
        }
    }
}
-(void)disableWizardBar
{
    [self.wizardBarOverlay setHidden:NO];
    [self.wizardBarView setUserInteractionEnabled:NO];
}

-(void)enableWizardBar
{
    [self.wizardBarOverlay setHidden:YES];
    [self.wizardBarView setUserInteractionEnabled:YES];
}



#pragma mark - Trim

-(void) showTrimView
{
    [self.previewPlayerContainerView setHidden:NO];
    [self.trimContainerView setHidden:NO];
    [[TrimVideoViewController sharedInstance] configureTrimView];
}
-(void) cancelTrimView
{
    [self.trimContainerView setHidden:YES];
    [self.previewPlayerContainerView setHidden:YES];
}



#pragma mark - Data Persistance

-(void) readProjectData
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DirPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:MY_SELFIE_DIRNAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [DirPath stringByAppendingPathComponent:PLIST_MY_SELFIE_DATA_FILE];
    if (![fileManager fileExistsAtPath:filePath])
    {
        if (![fileManager fileExistsAtPath:DirPath])
        {
            [fileManager createDirectoryAtPath:DirPath withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
        }
        NSString *templateFile = [[NSBundle mainBundle] pathForResource:PLIST_SELFIE_WIZARD_TEMPLATE_FILENAME ofType:@"plist"];
        [fileManager copyItemAtPath:templateFile toPath: filePath error:&error];
    }
    self.currentProjectDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    self.currentScreenSequenceIndex = [[self.currentProjectDict objectForKey:@"currentScreenIndex"] intValue];
    self.wizardCompletedIndex = [[self.currentProjectDict objectForKey:@"completedStepIndex"] intValue];
}


-(void) saveProjectData
{
    
    if (self.currentProjectDict && ![self.currentProjectDict isKindOfClass:[NSNull class]])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
        NSString *documentsDirectory = [paths objectAtIndex:0]; //2
        NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",MY_SELFIE_DIRNAME,PLIST_MY_SELFIE_DATA_FILE]]; //3
        [self.currentProjectDict writeToFile:path atomically:YES];
    }
}

-(void) deleteProjectData
{
    NSError *error =nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:MY_SELFIE_DIRNAME];
    if (myPathDocs && [[NSFileManager defaultManager] fileExistsAtPath:myPathDocs])
    {
        [[NSFileManager defaultManager] removeItemAtPath:myPathDocs error:&error];
    }
    if (error)
    {
        NSLog(@"FilePath Error :%@",error);
    }
    self.currentScreenSequenceIndex = WizardStepTitle;
    self.wizardCompletedIndex = WizardStepUndefined;
    self.wizardForcedSelectionIndex = WizardStepUndefined;
}
-(void) deleteAndStartNewStory
{
    [self deleteProjectData];
    [self startStory];
//    [self sendAnalytics];
}
-(void) sendAnalytics {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Tell my story"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video"
                                                          action:@"Start record"
                                                           label:@"Started recording"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
    
}
-(void) startStory
{
    [self readProjectData];
    [self updateWizardButtonStates];
    self.wizardForcedSelectionIndex = WizardStepUndefined;
    WizardTabButton *topButton = (WizardTabButton *)[self.topTabContentView viewWithTag:(kWizardTabItemTag+self.currentScreenSequenceIndex)];
    [topButton setEnabled:YES];
   
    [self configureScreen];
}
-(BOOL) haveExistingStory
{
    KMSDebugLog(@"haveExistingStory - wizardCompletedIndex :%d",self.wizardCompletedIndex);
    if (self.currentProjectDict && self.wizardCompletedIndex > WizardStepUndefined)
    {
        return YES;
    }
    return NO;
}

-(BOOL) haveDataForKey :(NSString *)keyStr
{
    BOOL isDataExist = NO;
    
    id dataObj = [self.currentProjectDict objectForKey:keyStr];
    
    if (dataObj)
    {
        if ([dataObj isKindOfClass:[NSString class]])
        {
            dataObj = [dataObj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (![dataObj isEqualToString:@""])
            {
                isDataExist = YES;
            }
            else
            {
                isDataExist = NO;
            }
        }
        else if ([dataObj isKindOfClass:[NSArray class]])
        {
            if ([dataObj count] > 0)
            {
                isDataExist = YES;
            }
            else
            {
                isDataExist = NO;
            }
        }
        else
        {
            isDataExist = YES;
        }
        
    }
    else
    {
        isDataExist = NO;
    }
    
    
    return isDataExist;
}


-(void)showScreenWithId:(NSString *)screenId
{
    
    KMSDebugLog(@"showScreenWithId :%@",screenId);
    
    [self.camContainerView setHidden:YES];
    [self.previewContainerView setHidden:YES];
    [self.mergeContainerView setHidden:YES];
    [self.createNewStoryContainerView setHidden:YES];
    [self.bgMusicContainerView setHidden:YES];
    [self.trimContainerView setHidden:YES];
    [self.previewPlayerContainerView setHidden:YES];
    [self.scriptureContainerView setHidden:YES];
    [self.regionContainerView setHidden:YES];
    
    
    [self.wizardBarView setHidden:NO];
    [self enableWizardBar];

    [[AVCamViewController sharedInstance] stopRecordingTimer];
    
    if ([screenId isEqualToString:kWizardViewTitle])
    {
        [[CreateNewStoryViewController sharedInstance] configureView];
        [self.createNewStoryContainerView setHidden:NO];
    }
    else
    {
        [[CreateNewStoryViewController sharedInstance] hideAndStopViewActions];
    }
    
    
    if ([screenId isEqualToString:kWizardViewCamera] || [screenId isEqualToString:kWizardViewCameraLanding])
    {
        [[AVCamViewController sharedInstance] configureView];
        [self.camContainerView setHidden:NO];
    }
    else
    {
        [[AVCamViewController sharedInstance] hideAndStopViewActions];
    }
    
    if ([screenId isEqualToString:kWizardViewClipPreview] || [screenId isEqualToString:kWizardViewFinalPreview])
    {
        [self.previewContainerView setHidden:NO];
        [[RecordPreviewViewController sharedInstance] configureView];
        
    }
    else
    {
         [[RecordPreviewViewController sharedInstance] hideAndStopViewActions];
    }
    
    if ([screenId isEqualToString:kWizardViewVideoPlayer])
    {
        [[AVPlayerDemoPlaybackViewController sharedInstance] configureView];
        [self.previewPlayerContainerView setHidden:NO];
    }
    else
    {
        [[AVPlayerDemoPlaybackViewController sharedInstance] hideAndStopViewActions];
    }
    
    
    if ([screenId isEqualToString:kWizardViewTrim])
    {
        [[TrimVideoViewController sharedInstance] configureView];
        [self.trimContainerView setHidden:NO];
    }
    else
    {
        [[TrimVideoViewController sharedInstance] hideAndStopViewActions];
    }
        
    if ([screenId isEqualToString:kWizardViewMusic])
    {
        [[BGMusicViewController sharedInstance] configureView];
        [self.bgMusicContainerView setHidden:NO];
        
    }
    else
    {
        [[BGMusicViewController sharedInstance] hideAndStopViewActions];
        
    }
    
    if ([screenId isEqualToString:kWizardViewScripture])
    {
        [[ScriptureListViewController sharedInstance] configureView];
        [self.scriptureContainerView setHidden:NO];
    }
    else
    {
        [[ScriptureListViewController sharedInstance] hideAndStopViewActions];
    }
    
    if ([screenId isEqualToString:kWizardViewDescription])
    {
        [[DescriptionViewController sharedInstance] configureView];
        [self.mergeContainerView setHidden:NO];
    }
    else
    {
        [[DescriptionViewController sharedInstance] hideAndStopViewActions];
        
    }
    
    if ([screenId isEqualToString:kWizardViewRegion])
    {
        [[RegionViewController sharedInstance] configureView];
        [self.regionContainerView setHidden:NO];
    }
    else
    {
        [[DescriptionViewController sharedInstance] hideAndStopViewActions];
        
    }
    
    if ([screenId isEqualToString:kWizardViewUpload])
    {
        [[RecordPreviewViewController sharedInstance] configureView];
        [self.previewContainerView setHidden:NO];
    }
    else
    {
        [[RecordPreviewViewController sharedInstance] hideAndStopViewActions];
    }
}


@end
