/*
 File: AVCamViewController.m
 Abstract: View controller for camera interface.
 Version: 3.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "AVCamViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "AVCamPreviewView.h"
#import "WizardViewController.h"


#define kVerseSliderWidth       350
#define kVerseSliderCloseButtonWidth    40
#define kVerseSliderAnimationDuration   0.5f
#define kVerseSliderAutoHideTime    6.0f

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface AVCamViewController () <AVCaptureFileOutputRecordingDelegate>


@property (readonly) double progress;

// For use in the storyboards.
@property (nonatomic, weak) IBOutlet AVCamPreviewView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (nonatomic, weak) IBOutlet UIButton *stillButton;

- (IBAction)toggleMovieRecording:(id)sender;
- (IBAction)changeCamera:(id)sender;
- (IBAction)snapStillImage:(id)sender;
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;


@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

@end





@implementation AVCamViewController

@synthesize progress;

static AVCamViewController *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (AVCamViewController *)sharedInstance
{
    if (sharedInstance == nil)
    {
        //sharedInstance = [[AVCamViewController alloc] init];
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


- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

#pragma mark - View Life cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    sharedInstance = self;
    
    [self InitialiseView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

-(void)InitialiseView
{
    
    self.recordButton.exclusiveTouch = YES;
    self.cameraButton.exclusiveTouch = YES;
    self.homeButton.exclusiveTouch = YES;
    self.chooseAgainButton.exclusiveTouch = YES;
    
    self.autoHideVerseSlider = NO;
    self.verseAutoHideTimer = nil;
    
    [self.timeRemainingLabel setFont:kFONT_ROBOTO_SIZE_20];
    [self.messageLabel setFont:kFONT_ROBOTO_SIZE_18];
    [self.messageLabel setMinimumScaleFactor:0.2];
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    KMSDebugLog(@"#1 session sessionPreset:%@",[session sessionPreset]);
    //[session setSessionPreset:AVCaptureSessionPreset1280x720];
    if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [session setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    else
    {
        [session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    KMSDebugLog(@"#2 session sessionPreset:%@",[session sessionPreset]);
    
    [self setSession:session];
    
    // Setup the preview view
    [[self previewView] setSession:session];
    
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        //[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [AVCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
                [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
            });
        }
        
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:audioDeviceInput])
        {
            [session addInput:audioDeviceInput];
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        
        if ([session canAddOutput:movieFileOutput])
        {
            [session addOutput:movieFileOutput];
            
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            
            
            
            KMSDebugLog(@"[[UIDevice currentDevice] systemVersion] :%f ",[[[UIDevice currentDevice] systemVersion] floatValue]);
            // iOS 7 fix : Abdu 31 March 15
            if([[[UIDevice currentDevice] systemVersion] floatValue] < 8)
            {
                // setup video stabilization, if available
                if ([connection isVideoStabilizationSupported])
                {
                    if ([connection respondsToSelector:@selector(setEnablesVideoStabilizationWhenAvailable:)])
                    {
                        [connection setEnablesVideoStabilizationWhenAvailable:YES];
                    }
                }
            }
            else
            {
                [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
            }
            
            [self setMovieFileOutput:movieFileOutput];
        }
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput])
        {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }
    });
    
}
-(void)configureView
{
    
    if ([[self session] isRunning])
    {
        [self hideAndStopViewActions];
    }
    
    [self startCamera];
    [self setupForLanding:YES];
    
    if ([[WizardViewController sharedInstance] currentScreenSequenceIndex] == WizardStepVerse)
    {
        self.autoHideVerseSlider = YES;
        [self configureVerseSliderView];
    }
    else
    {
        [self.verseSliderView setHidden:YES];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

-(void)hideAndStopViewActions
{
    [self stopRecordingTimer];
    [self stopCamera];
    [self clearVerseTimer];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
}


-(void)setupForLanding:(BOOL)isLanding
{
    
    KMSDebugLog(@"isLanding :%d",isLanding);
    if (isLanding)
    {
        [self.homeButton setHidden:NO];
        [self.messageView setHidden:NO];
        [self.cameraButton setHidden:NO];
        [self.cameraButton setEnabled:YES];
        [self.timeRemainingLabel setHidden:YES];
        [self.recordButton setSelected:NO];
        [[self homeButton] setEnabled:YES];
        [[[WizardViewController sharedInstance] wizardBarView] setHidden:NO];
        
        if ([[WizardViewController sharedInstance] currentScreenSequenceIndex] == WizardStepVerse)
        {
            [self.chooseAgainButton setHidden:NO];
        }
    }
    else
    {
        [self.homeButton setHidden:YES];
        [self.messageView setHidden:YES];
        [self.cameraButton setHidden:YES];
        [self.cameraButton setEnabled:NO];
        [self.timeRemainingLabel setHidden:NO];
        [self.recordButton setSelected:YES];
        [[[WizardViewController sharedInstance] wizardBarView] setHidden:YES];
        
        [self.chooseAgainButton setHidden:YES];
    }
}

-(void) startCamera
{
    
    if (![self backgroundCompressingID])
    {
        [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:ACTIVITY_LOADING_TEXT_LOADING showProgress:NO onController:[WizardViewController sharedInstance] minTime:1 maxTime:0 autoHide:YES];
    }
    else
    {
        [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:ACTIVITY_LOADING_TEXT_COMPRESSING showProgress:YES onController:[WizardViewController sharedInstance]];
    }
    
    dispatch_async([self sessionQueue], ^{
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        __weak AVCamViewController *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
            AVCamViewController *strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf session] startRunning];
                //[[strongSelf recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
                [[strongSelf recordButton] setSelected:NO];
                //[strongSelf setupForLanding];
                NSLog(@"session queue finished");
            });
        }]];
        [[self session] startRunning];
        
        NSError *error = nil;
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusModeSupported:AVCaptureFocusModeLocked])
            {
                NSLog(@"AVCaptureFocusModeLocked");
                [device  setFocusMode:AVCaptureFocusModeLocked];
                //[[[self videoDeviceInput] device]  setSmoothAutoFocusEnabled:YES];
            }
            [device unlockForConfiguration];
        }

        {
            NSLog(@"AVCaptureFocusModeLocked : %@", error);
        }
    });
    
    NSString *currentScreen = [[WizardViewController sharedInstance] getCurrentScreenName];
    
    self.remainingRecordTime = [[[[WizardViewController sharedInstance].currentProjectDict objectForKey:currentScreen] objectForKey:@"recordTime"] intValue];
    NSString *messageText = [[[WizardViewController sharedInstance].currentProjectDict objectForKey:currentScreen] objectForKey:@"message"];
    [self.messageLabel setText:messageText];
    
    NSString *remainingTimeStr = [NSString stringWithFormat:@"%.2d:%.2d",self.remainingRecordTime/60,self.remainingRecordTime%60];
    [self.timeRemainingLabel setText:remainingTimeStr];
    [self.timeRemainingLabel setTextColor:[UIColor grayColor]];
    
}

-(void) stopCamera
{
    
    if ([[self session] isRunning])
    {
        dispatch_async([self sessionQueue], ^{
            
            //[[self session] stopRunning];
            // iOS 7 Issue Fix - Abdu 07 April 15
            @try
            {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
                [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
                [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
                [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
                [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
                NSLog(@"stopCamera - Removed Observers");
            }
            @catch (NSException *exception)
            {
                NSLog(@"stopCamera - removeObserver exception:%@", exception.reason);
            }
            @finally
            {
                NSLog(@"stopCamera - Completed");
            }
            
            
            
            
            
            [[self session] stopRunning];
        });
    }
    [self stopRecordingTimer];
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
/*
 - (BOOL)shouldAutorotate
 {
	// Disable autorotation of the interface when recording is in progress.
	//return ![self lockInterfaceRotation];
 return NO;
 }
 
 - (NSUInteger)supportedInterfaceOrientations
 {
 //Abdu Jan 06
 //return UIInterfaceOrientationMaskAll;
 NSLog(@"supportedInterfaceOrientations");
	return UIInterfaceOrientationMaskLandscapeRight;
 }
 
 - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
 {
 NSLog(@"willRotateToInterfaceOrientation : %d",toInterfaceOrientation);
 
	[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
 }*/

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CapturingStillImageContext)
    {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (isCapturingStillImage)
        {
            [self runStillImageCaptureAnimation];
        }
    }
    else if (context == RecordingContext)
    {
        BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRecording)
            {
                [[self cameraButton] setEnabled:NO];
                [self.recordButton setSelected:YES];
                
                //ABDU 08 APRIL 15 - iOS 7 fix - disable for 1 sec
                //[[self recordButton] setEnabled:YES];
                [[self recordButton] setEnabled:NO];
                
            }
            else
            {
                [[self cameraButton] setEnabled:YES];
                [self.recordButton setSelected:NO];
                
                //ABDU 09 APRIL 15 - iOS 7 fix - disable after stop recording
                //[[self recordButton] setEnabled:YES];
                [[self recordButton] setEnabled:NO];
                
                [self stopRecordingTimer];
                [self clearVerseTimer];
            }
            [self setupForLanding:!isRecording];
        });
    }
    else if (context == SessionRunningAndDeviceAuthorizedContext)
    {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRunning)
            {
                [[self cameraButton] setEnabled:YES];
                [[self recordButton] setEnabled:YES];
                [[self stillButton] setEnabled:YES];
            }
            else
            {
                [[self cameraButton] setEnabled:NO];
                [[self recordButton] setEnabled:NO];
                [[self stillButton] setEnabled:NO];
            }
        });
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Actions

- (IBAction)toggleMovieRecording:(id)sender
{
    
    [[self recordButton] setEnabled:NO];
    [[self cameraButton] setEnabled:NO];
    [[self homeButton] setEnabled:NO];
    
    dispatch_async([self sessionQueue], ^{
        if (![[self movieFileOutput] isRecording])
        {
            [self setLockInterfaceRotation:YES];
            
            if ([[UIDevice currentDevice] isMultitaskingSupported])
            {
                // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
                [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
                KMSDebugLog(@"BackgroundRecordingID :%lu",(unsigned long)[self backgroundRecordingID]);
            }
            
            // Update the orientation on the movie file output video connection before starting recording.
            [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
            
            [[self movieFileOutput] setMaxRecordedDuration:(CMTimeMakeWithSeconds(self.remainingRecordTime,NSEC_PER_SEC))];
            
            // Turning OFF flash for video recording
            [AVCamViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
            
            NSString *DestFilename = [NSString stringWithFormat:@"videoClip_%d_%d.mov",[[WizardViewController sharedInstance] currentScreenSequenceIndex],arc4random() % 10000 ];
            
            //Set the file save to URL
            NSError *error =nil;
            KMSDebugLog(@"Starting recording to file: %@", DestFilename);
            NSString *DestPath;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:MY_SELFIE_DIRNAME];
            
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:DestPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:DestPath withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
            DestPath = [DestPath stringByAppendingPathComponent:DestFilename];
            
            if (error) {
                NSLog(@"DestPath Error :%@",error);
            }
            /*
             if ([[NSFileManager defaultManager] fileExistsAtPath:DestPath])
             {
             [[NSFileManager defaultManager] removeItemAtPath:DestPath error:&error];
             }
             
             if (error) {
             NSLog(@"FilePath Error :%@",error);
             }*/
            
            NSURL* saveLocationURL = [[NSURL alloc] initFileURLWithPath:DestPath];
            //[self movieFileOutput] setMaxRecordedDuration:<#(CMTime)#>
            [[self movieFileOutput] startRecordingToOutputFileURL:saveLocationURL recordingDelegate:self];
            //[saveLocationURL release];*/
            //NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"videoClip_%d.mov",arc4random() % 1000]];
            //[[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
        }
        else
        {
            [self stopRecordingTimer];
            [[self movieFileOutput] stopRecording];
        }
    });
    
    if (![[self movieFileOutput] isRecording])
    {
        [self createRecordTimer];
    }
}

- (IBAction)changeCamera:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self cameraButton] setEnabled:NO];
        [[self recordButton] setEnabled:NO];
        [[self stillButton] setEnabled:NO];
    });
    
    
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
        
        switch (currentPosition)
        {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
        }
        
        AVCaptureDevice *videoDevice = [AVCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        NSError *error = nil;
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        KMSDebugLog(@"videoDeviceInput : %@",videoDeviceInput);
        
        if (error)
        {
            NSLog(@"videoDeviceInput error : %@",error);
        }
        [[self session] setSessionPreset:AVCaptureSessionPresetHigh];
        
        KMSDebugLog(@"#1 session inputs:%@",[[self session] inputs]);
        
        [[self session] removeInput:[self videoDeviceInput]];
        KMSDebugLog(@"#2 session inputs:%@",[[self session] inputs]);
        
        if ([[self session] canAddInput:videoDeviceInput])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            
            [AVCamViewController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            
            [[self session] addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        else
        {
            [[self session] addInput:[self videoDeviceInput]];
        }
        
        if ([[self session] canSetSessionPreset:AVCaptureSessionPreset1280x720])
        {
            [[self session] setSessionPreset:AVCaptureSessionPreset1280x720];
        }
        [[self session] commitConfiguration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self cameraButton] setEnabled:YES];
            [[self recordButton] setEnabled:YES];
            [[self stillButton] setEnabled:YES];
        });
    });
}

- (IBAction)snapStillImage:(id)sender
{
    dispatch_async([self sessionQueue], ^{
        // Update the orientation on the still image output video connection before capturing.
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
        
        // Flash set to Auto for Still Capture
        [AVCamViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
        
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer)
            {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
            }
        }];
    });
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    
    if ([[WizardViewController sharedInstance] currentScreenSequenceIndex] == WizardStepVerse)
    {
        [self hideVerseView];
    }
    //Auto Focus
    /*CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
     [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
     */
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    //Auto Focus
    /*
     CGPoint devicePoint = CGPointMake(.5, .5);
     [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
     */
}

#pragma mark File Output Delegate


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"create snapshot");
}





- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (error)
        NSLog(@"%@", error);
    
    [self setLockInterfaceRotation:NO];
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    if (backgroundRecordingID != UIBackgroundTaskInvalid)
        [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
    
    KMSDebugLog(@"outputFileURL :%@ ",outputFileURL);
    [self resizeVideo:outputFileURL];
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    //Auto Focus
    /*
     dispatch_async([self sessionQueue], ^{
     AVCaptureDevice *device = [[self videoDeviceInput] device];
     NSError *error = nil;
     if ([device lockForConfiguration:&error])
     {
     if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
     {
     [device setFocusMode:focusMode];
     [device setFocusPointOfInterest:point];
     }
     if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
     {
     [device setExposureMode:exposureMode];
     [device setExposurePointOfInterest:point];
     }
     [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
     [device unlockForConfiguration];
     }
     else
     {
     NSLog(@"%@", error);
     }
     });*/
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self previewView] layer] setOpacity:0.0];
        [UIView animateWithDuration:.25 animations:^{
            [[[self previewView] layer] setOpacity:1.0];
        }];
    });
}

- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //Granted access to mediaType
            [self setDeviceAuthorized:YES];
        }
        else
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"MyStory!"
                                            message:@"MyStory doesn't have permission to use Camera, please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}

-(void) createRecordTimer
{
    [self stopRecordingTimer];
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(updateRecordTimer:)
                                                      userInfo:nil
                                                       repeats:YES];
    [self.timeRemainingLabel setTextColor:ORANGE_COLOR];
}

-(void)updateRecordTimer:(NSTimer *)timer
{
    if (self.remainingRecordTime == 0)
    {
        
        if ([[self movieFileOutput] isRecording])
        {
            [[self movieFileOutput] stopRecording];
        }
        [self stopRecordingTimer];
    }
    else
    {
        //iOS 7 fix - disable for 1 sec
        if (![[self recordButton] isEnabled])
        {
            [[self recordButton] setEnabled:YES];
        }
        
        
        self.remainingRecordTime--;
        NSString *remainingTimeStr = [NSString stringWithFormat:@"%.2d:%.2d",self.remainingRecordTime/60,self.remainingRecordTime%60];
        [self.timeRemainingLabel setText:remainingTimeStr];
        
    }
    
}
-(void)stopRecordingTimer
{
    KMSDebugLog(@"stopRecordingTimer");
    KMSDebugLog(@"self.remainingRecordTime : %d",self.remainingRecordTime);
    if (self.recordTimer)
    {
        if ([self.recordTimer isValid])
        {
            [self.recordTimer invalidate];
            KMSDebugLog(@"Record Timer Invalidated");
        }
        self.recordTimer = nil;
        KMSDebugLog(@"Record Timer = nil");
    }
    [self.timeRemainingLabel setTextColor:[UIColor grayColor]];
}

-(void)resizeVideo:(NSURL*)path
{
    
    AVAsset *avAsset = [[AVURLAsset alloc] initWithURL:path options:nil];
    if ([[avAsset tracks] count]>= 2)
    {
        
        
        
        KMSDebugLog(@"avAsset tracks :%@",[avAsset tracks]);
        [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:ACTIVITY_LOADING_TEXT_COMPRESSING showProgress:YES onController:[WizardViewController sharedInstance]];
        
        progress = 0.0;
        
        // iOS 7 Issue Fix - Abdu 07 April 15
        if ([[UIDevice currentDevice] isMultitaskingSupported])
        {
            [self setBackgroundCompressingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
        }
        KMSDebugLog(@"BackgroundCompressingID :%lu",(unsigned long)[self backgroundCompressingID]);
        
        @autoreleasepool
        {
            NSString *newFileURL = [[path URLByDeletingPathExtension] path];
            NSURL *fullPath = [NSURL fileURLWithPath:[newFileURL stringByAppendingString:@"_resizedVideo.mov"]];
            NSError *error = nil;
            
            AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:fullPath fileType:AVFileTypeQuickTimeMovie error:&error];
            NSParameterAssert(videoWriter);
            
            
            
            AVAssetTrack *videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            NSDictionary *videoCleanApertureSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        [NSNumber numberWithInt:videoTrack.naturalSize.width], AVVideoCleanApertureWidthKey,
                                                        [NSNumber numberWithInt:videoTrack.naturalSize.height], AVVideoCleanApertureHeightKey,
                                                        [NSNumber numberWithInt:10], AVVideoCleanApertureHorizontalOffsetKey,
                                                        [NSNumber numberWithInt:10], AVVideoCleanApertureVerticalOffsetKey,
                                                        nil];
            /*NSDictionary *videoCleanApertureSettings = [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithInt:1280], AVVideoCleanApertureWidthKey,
             [NSNumber numberWithInt:720], AVVideoCleanApertureHeightKey,
             [NSNumber numberWithInt:10], AVVideoCleanApertureHorizontalOffsetKey,
             [NSNumber numberWithInt:10], AVVideoCleanApertureVerticalOffsetKey,
             nil];*/
            
            
            /*NSDictionary *codecSettings = [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithInt:1960000], AVVideoAverageBitRateKey,
             [NSNumber numberWithInt:24],AVVideoMaxKeyFrameIntervalKey,
             //videoCleanApertureSettings, AVVideoCleanApertureKey,
             nil];*/
            
            
            
            NSDictionary *codecSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithInt:1960000], AVVideoAverageBitRateKey,
                                           [NSNumber numberWithInt:30],AVVideoMaxKeyFrameIntervalKey,
                                           videoCleanApertureSettings, AVVideoCleanApertureKey,
                                           nil];
            //[NSNumber numberWithInt:1960000], AVVideoAverageBitRateKey,
            
            NSDictionary *videoCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      AVVideoCodecH264, AVVideoCodecKey,
                                                      codecSettings,AVVideoCompressionPropertiesKey,
                                                      [NSNumber numberWithInt:videoTrack.naturalSize.width], AVVideoWidthKey,
                                                      [NSNumber numberWithInt:videoTrack.naturalSize.height], AVVideoHeightKey,
                                                      nil];
            
            AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                                    assetWriterInputWithMediaType:AVMediaTypeVideo
                                                    outputSettings:videoCompressionSettings];
            
            NSParameterAssert(videoWriterInput);
            NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
            videoWriterInput.expectsMediaDataInRealTime = YES;
            [videoWriter addInput:videoWriterInput];
            NSError *aerror = nil;
            AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:avAsset error:&aerror];
            
            KMSDebugLog(@"videoTrack.naturalSize w:%f h:%f ",videoTrack.naturalSize.width,videoTrack.naturalSize.height);
            KMSDebugLog(@"TypeVideo tracks :%@",[avAsset tracksWithMediaType:AVMediaTypeVideo]);
            
            videoWriterInput.transform = videoTrack.preferredTransform;
            NSDictionary *videoOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
            AVAssetReaderTrackOutput *asset_reader_output = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoOptions];
            [reader addOutput:asset_reader_output];
            //audio setup
            
            AVAssetWriterInput* audioWriterInput = [AVAssetWriterInput
                                                    assetWriterInputWithMediaType:AVMediaTypeAudio
                                                    outputSettings:nil];
            
            AVAssetReader *audioReader = [AVAssetReader assetReaderWithAsset:avAsset error:&error];
            KMSDebugLog(@"TypeAudio tracks :%@",[avAsset tracksWithMediaType:AVMediaTypeAudio]);
            AVAssetTrack* audioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
            AVAssetReaderOutput *readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
            
            [audioReader addOutput:readerOutput];
            NSParameterAssert(audioWriterInput);
            NSParameterAssert([videoWriter canAddInput:audioWriterInput]);
            audioWriterInput.expectsMediaDataInRealTime = NO;
            [videoWriter addInput:audioWriterInput];
            [videoWriter startWriting];
            
            [videoWriter startSessionAtSourceTime:kCMTimeZero];
            [reader startReading];
            dispatch_queue_t _processingQueue1 = dispatch_queue_create("assetAudioWriterQueue", NULL);
            
            
            /*convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);
             progress = (double) convertedByteCount / finalSizeByteCount;
             NSNumber* progressNumber = [NSNumber numberWithDouble: progress];
             [self performSelectorOnMainThread: @selector (updateProgress:)
             withObject: progressNumber
             waitUntilDone: NO];
             */
            
            /*NSLog (@"duration: %f", CMTimeGetSeconds (videoTrack.timeRange.duration));
             double finalSizeByteCount = videoTrack.timeRange.duration.value * 2 * sizeof (SInt16);
             __block UInt64 convertedByteCount = 0;*/
            
            [videoWriterInput requestMediaDataWhenReadyOnQueue:_processingQueue1 usingBlock:
             ^{
                 
                 while ([videoWriterInput isReadyForMoreMediaData]) {
                     
                     
                     CMSampleBufferRef sampleBuffer;
                     if ([reader status] == AVAssetReaderStatusReading)
                     {
                         if(![videoWriterInput isReadyForMoreMediaData])
                             continue;
                         
                         sampleBuffer = [asset_reader_output copyNextSampleBuffer];
                         
                         if(sampleBuffer)
                         {
                             BOOL result = [videoWriterInput appendSampleBuffer:sampleBuffer];
                             
                             CMTime presTime = CMSampleBufferGetPresentationTimeStamp( sampleBuffer );
                             float progressValue = CMTimeGetSeconds(presTime)/CMTimeGetSeconds(avAsset.duration);
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [[ActivityLoadingViewController sharedInstance] updateProgressViewWithValue:progressValue];
                             });
                             
                             
                             /*
                              convertedByteCount += CMSampleBufferGetTotalSampleSize (sampleBuffer);
                              progress = (double) convertedByteCount / finalSizeByteCount;
                              NSLog(@"Compression progress From TotalTimeStamp :%f",progress);*/
                             
                             //NSLog(@"WRITTING... result :%d",result);
                             CFRelease(sampleBuffer);
                             
                             if (!result) {
                                 [reader cancelReading];
                                 break;
                             }
                         }
                     }
                     else
                     {
                         
                         [videoWriterInput markAsFinished];
                         
                         switch ([reader status])
                         {
                             case AVAssetReaderStatusReading:
                                 // the reader has more for other tracks, even if this one is done
                                 KMSDebugLog(@"video AVAssetReaderStatusReading");
                                 break;
                                 
                             case AVAssetReaderStatusCompleted:
                                 // your method for when the conversion is done
                                 // should call finishWriting on the writer
                                 //hook up audio track
                             {
                                 KMSDebugLog(@"video AVAssetReaderStatusCompleted");
                                 
                                 //NSString *path = [fullPath path];
                                 //NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
                                 KMSDebugLog(@"path : %@", [fullPath path]);
                                 //NSLog(@"size after compress video is %d",data.length);
                                 //[videoWriter startSessionAtSourceTime:kCMTimeZero];
                                 /*[videoWriter finishWritingWithCompletionHandler:^
                                  {
                                  NSLog(@"videoWriter finishWritingWithCompletionHandler ");
                                  }];*///
                                 
                                 
                                 [videoWriter startSessionAtSourceTime:kCMTimeZero];
                                 [audioReader startReading];
                                 KMSDebugLog(@"Request");
                                 KMSDebugLog(@"Asset Writer ready :%d",audioWriterInput.readyForMoreMediaData);
                                 while (audioWriterInput.readyForMoreMediaData)
                                 {
                                     CMSampleBufferRef nextBuffer;
                                     //if ([audioReader status] == AVAssetReaderStatusReading &&(nextBuffer = [readerOutput copyNextSampleBuffer]))
                                     if ([audioReader status] == AVAssetReaderStatusReading)
                                     {
                                         if(![audioWriterInput isReadyForMoreMediaData])
                                             continue;
                                         
                                         //NSLog(@"Ready");
                                         nextBuffer = [readerOutput copyNextSampleBuffer];
                                         
                                         if (nextBuffer)
                                         {
                                             //NSLog(@"NextBuffer");
                                             BOOL result = [audioWriterInput appendSampleBuffer:nextBuffer];
                                             CMTime presTime = CMSampleBufferGetPresentationTimeStamp( nextBuffer );
                                             KMSDebugLog(@"Audio Compression progress From PresentationTimeStamp : %f",CMTimeGetSeconds(presTime)/CMTimeGetSeconds(avAsset.duration));
                                             
                                             CFRelease(nextBuffer);
                                             
                                             if (!result) {
                                                 [audioReader cancelReading];
                                                 break;
                                             }
                                         }
                                         
                                     }
                                     else
                                     {
                                         [audioWriterInput markAsFinished];
                                         
                                         switch ([audioReader status])
                                         {
                                             case AVAssetReaderStatusCompleted:
                                             {
                                                 
                                                 //[videoWriter finishWriting];
                                                 KMSDebugLog(@"audioReader AVAssetReaderStatusCompleted");
                                                 
                                                 KMSDebugLog(@"setting  final... the URL");
                                                 //self.finalURL=[[NSURL alloc]initFileURLWithPath:newName];
                                                 
                                                 
                                                 break;
                                             }
                                             case AVAssetReaderStatusReading:
                                             {
                                                 // the reader has more for other tracks, even if this one is done
                                                 KMSDebugLog(@"audioReader AVAssetReaderStatusReading");
                                                 break;
                                             }
                                             case AVAssetReaderStatusFailed:
                                             {
                                                 [videoWriter cancelWriting];
                                                 NSLog(@"audioReader AVAssetReaderStatusFailed Error : %@",error);
                                                 
                                                 break;
                                             }
                                             case AVAssetReaderStatusUnknown:
                                             {
                                                 NSLog(@"audioReader AVAssetReaderStatusUnknown");
                                                 break;
                                             }
                                             case AVAssetReaderStatusCancelled:
                                             {
                                                 NSLog(@"audioReader AVAssetReaderStatusCancelled");
                                                 break;
                                             }
                                         }
                                     }
                                     
                                     
                                 }
                                 
                                 [videoWriter endSessionAtSourceTime:avAsset.duration];
                                 [videoWriter finishWritingWithCompletionHandler:^(void)
                                  {
                                      KMSDebugLog(@"videoWriter finishWritingWithCompletionHandler ");
                                  }];
                                 if (![NSThread isMainThread])
                                 {
                                     NSLog(@"videoWriter running on background thread");
                                 } else{
                                     
                                     NSLog(@"videoWriter running on MAIN thread");

                                 }

                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     NSLog(@" PHASE 2 videoWriter running on MAIN thread");

                                     [self.delegate capturedVideoWithURL:fullPath];
                                     
                                     NSError *error =nil;
                                     if (path && [[NSFileManager defaultManager] fileExistsAtPath:[path path]])
                                     {
                                         [[NSFileManager defaultManager] removeItemAtPath:[path path] error:&error];
                                         NSLog(@"Orginal Video Found and deleted after compressing");
                                     }
                                     else
                                     {
                                         NSLog(@"Orginal Video not Found");
                                     }
                                     
                                     if (error)
                                     {
                                         NSLog(@"FilePath Error :%@",error);
                                     }
                                 });
                                 
                                 UIBackgroundTaskIdentifier bgCompressingID = [self backgroundCompressingID];
                                 [self setBackgroundCompressingID:UIBackgroundTaskInvalid];
                                 if (bgCompressingID != UIBackgroundTaskInvalid)
                                     [[UIApplication sharedApplication] endBackgroundTask:bgCompressingID];
                                 
                                 
                                 break;
                             }
                             case AVAssetReaderStatusFailed:
                             {
                                 [videoWriter cancelWriting];
                                 NSLog(@"video AVAssetReaderStatusFailed Error : %@",error);
                                 break;
                             }
                             case AVAssetReaderStatusUnknown:
                             {
                                 NSLog(@"video AVAssetReaderStatusUnknown");
                                 break;
                             }
                             case AVAssetReaderStatusCancelled:
                             {
                                 NSLog(@"video AVAssetReaderStatusCancelled");
                                 break;
                             }
                         }
                         break;
                     }
                 }
             }
             ];
            NSLog(@"Write Ended");
            
        }
    }
    else
    {
        NSLog(@"No tracks in the video clip");
        
    }
}


- (IBAction)homeButtonPressed:(id)sender
{
    [self hideAndStopViewActions];
    [self dismissViewControllerAnimated:NO completion:^{}];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (IBAction)showVerseButtonPressed:(id)sender
{
    if (self.isVerseSliderShown)
    {
        [self hideVerseView];
    }
    else
    {
        [self showVerseView];
    }
    
}

- (IBAction)verseChooseAgainButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[WizardViewController sharedInstance] showScreenWithId:kWizardViewScripture];
}

//Verse Sliding View
-(void)configureVerseSliderView
{
    KMSDebugLog(@"configureVerseSliderView");
    CGRect sliderHideRet = CGRectMake(-(kVerseSliderWidth - kVerseSliderCloseButtonWidth/2), 0, kVerseSliderWidth, self.view.frame.size.height);
    
    [self.verseSliderView setFrame:sliderHideRet];
    
    // iOS 7 fix : Abdu 01 April 15
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8 )
    {
        [self.verseSliderView setPreservesSuperviewLayoutMargins:NO];
    }
    
    WizardViewController *wizardVC = [WizardViewController sharedInstance];
    NSDictionary *scriptureDict = [wizardVC.currentProjectDict objectForKey:@"Scripture"];
    NSString *verseTitleStr = [NSString stringWithFormat:@"%@ %@:%@", [scriptureDict objectForKey:@"bookName"],[scriptureDict objectForKey:@"chapter"],[scriptureDict objectForKey:@"verseNumber"]];
    [self.verseTitleLabel setText:verseTitleStr];
    [self.verseDetailTextView setText:[scriptureDict objectForKey:@"verse"]];
    
    if (self.verseSliderView.superview != self.view)
    {
        [self.view addSubview:self.verseSliderView];
        KMSDebugLog(@"Adding verseSliderView to self.view");
    }
    [self.verseSliderView setHidden:NO];
    
    self.isVerseSliderShown = NO;
    self.isVerseSliderMoving = NO;
    
    if (self.autoHideVerseSlider)
    {
        [self showVerseView];
        [self clearVerseTimer];
        self.verseAutoHideTimer = [NSTimer scheduledTimerWithTimeInterval:kVerseSliderAutoHideTime
                                                                   target:self
                                                                 selector:@selector(hideVerseView)
                                                                 userInfo:nil
                                                                  repeats:NO];
    }
    
}
-(void)showVerseView
{
    if (!self.isVerseSliderShown && !self.isVerseSliderMoving)
    {
        //const float movementDuration = 0.5f;
        self.isVerseSliderShown = YES;
        self.isVerseSliderMoving = YES;
        [self.view setUserInteractionEnabled:NO];
        
        [UIView beginAnimations: @"animateVerseSlider" context:NULL];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: kVerseSliderAnimationDuration];
        [UIView setAnimationDelegate:self];
        //[UIView setAnimationDidStopSelector:@selector(sliderAnimationCompleted)];
        [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
        CGRect sliderFrame = self.verseSliderView.frame;
        self.verseSliderView.frame = CGRectOffset(sliderFrame, sliderFrame.size.width - kVerseSliderCloseButtonWidth/2,0);
        
        [UIView commitAnimations];
    }
    
    
    
}
-(void)hideVerseView
{
    if (self.isVerseSliderShown && !self.isVerseSliderMoving)
    {
        self.isVerseSliderMoving = YES;
        
        //const float movementDuration = 0.5f;
        [self.view setUserInteractionEnabled:NO];
        [UIView beginAnimations: @"animateVerseSlider" context:NULL];
        //[UIView setAnimationDidStopSelector:@selector(sliderAnimationCompleted)];
        [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:kVerseSliderAnimationDuration];
        [UIView setAnimationDelegate:self];
        CGRect sliderFrame = self.verseSliderView.frame;
        self.verseSliderView.frame = CGRectOffset(sliderFrame,-(sliderFrame.size.width - kVerseSliderCloseButtonWidth/2),0);
        
        [UIView commitAnimations];
        
        self.isVerseSliderShown = NO;
        
    }
    [self clearVerseTimer];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    if ([animationID isEqualToString:@"animateVerseSlider"])
    {
        // something done after the animation
        KMSDebugLog(@"sliderAnimationCompleted :%i",finished);
        [self.view setUserInteractionEnabled:YES];
        self.isVerseSliderMoving = NO;
    }
}
-(void) clearVerseTimer
{
    if (self.verseAutoHideTimer)
    {
        if ([self.verseAutoHideTimer isValid])
        {
            [self.verseAutoHideTimer invalidate];
        }
        self.verseAutoHideTimer = nil;
    }
    
}

/*
 -(void)sliderAnimationCompleted
 {
 NSLog(@"sliderAnimationCompleted ");
 [self.view setUserInteractionEnabled:YES];
 }*/
@end
