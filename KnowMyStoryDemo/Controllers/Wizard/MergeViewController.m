//
//  MergeViewController.m
//  KnowMyStoryDemo
//
//  Created by Abdusha on 12/24/14.
//  Copyright (c) 2014 Fingent. All rights reserved.
//

#import "MergeViewController.h"

#import "WizardViewController.h"
#import "RecordPreviewViewController.h"
#import "GAIDictionaryBuilder.h"
@interface MergeViewController ()


@property (nonatomic, strong) AVAssetExportSession *exportSession;


@end


@implementation MergeViewController

static MergeViewController *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (MergeViewController *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[MergeViewController alloc] init];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    sharedInstance = self;
    self.exportSession = nil;
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


-(void)mergeAllVideoswithCompletionHandler:(void (^)(NSError* error))completionHandler
{
    KMSDebugLog(@"mergeAllVideoswithCompletionHandler");
    NSError* error=nil;
    
    WizardViewController *wizardViewController = [WizardViewController sharedInstance];
    [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:ACTIVITY_LOADING_TEXT_MERGING showProgress:YES onController:wizardViewController];
    
    // iOS 7 Issue Fix - Abdu 07 April 15
    if ([[UIDevice currentDevice] isMultitaskingSupported])
    {
        [self setBackgroundMergingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
    }
    
    KMSDebugLog(@"BackgroundMergingID :%lu",(unsigned long)[self backgroundMergingID]);
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];

    NSMutableArray *videoCompositionLayerArrayTemp = [[NSMutableArray alloc] init];
    CMTime sequenceTime = kCMTimeZero;
    
    for (int i = WizardStepIntroduction; i < WizardStepMusic; i++)
    {
        NSString *currentScreen = [wizardViewController.screenSequenceArray objectAtIndex:i];
        NSString *videoURL = [[wizardViewController.currentProjectDict objectForKey:currentScreen] objectForKey:@"videoPath"];
        KMSDebugLog(@"%d - currentScreen :%@ - videoURL :%@",i,currentScreen,videoURL);
        
        AVAsset *videoAsset = [AVAsset assetWithURL:[NSURL URLWithString:videoURL]];
        AVAssetTrack *videoAssetTrack= [[videoAsset tracksWithMediaType:AVMediaTypeVideo] lastObject];
        
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [videoTrack setPreferredVolume:1.0f];
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:videoAssetTrack atTime:sequenceTime error:&error];
        [videoTrack setPreferredVolume:1.0f];
        AVMutableCompositionTrack *AudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [AudioTrack setPreferredVolume:1.0f];
        [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:sequenceTime error:&error];
        [AudioTrack setPreferredVolume:1.0f];
        
        AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        CGFloat FirstAssetWidthScaleToFitRatio = 1280.0/videoAssetTrack.naturalSize.width;
        CGFloat FirstAssetHeightScaleToFitRatio = 720.0/videoAssetTrack.naturalSize.height;
        KMSDebugLog(@"FirstAssetWidthScaleToFitRatio :%f FirstAssetHeightScaleToFitRatio :%f",FirstAssetWidthScaleToFitRatio ,FirstAssetHeightScaleToFitRatio);
        
        CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetWidthScaleToFitRatio,FirstAssetHeightScaleToFitRatio);
        [videoLayerInstruction setTransform:CGAffineTransformConcat(videoAssetTrack.preferredTransform, FirstAssetScaleFactor) atTime:sequenceTime];
        
        sequenceTime = CMTimeAdd(sequenceTime, videoAsset.duration);
        [videoLayerInstruction setOpacity:0.0 atTime:sequenceTime];
        [videoCompositionLayerArrayTemp addObject:videoLayerInstruction];
        
    }
    
    //Adding B-Roll footage video
    NSString *bRollVideoURL  =[[NSBundle mainBundle] pathForResource:VIDEO_B_ROLL_FOOTAGE_FILENAME ofType:@"mp4"];
    AVAsset *bRollVideoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:bRollVideoURL]];
    AVAssetTrack *bRollVideoAssetTrack= [[bRollVideoAsset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    
    AVMutableCompositionTrack *bRollVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [bRollVideoTrack setPreferredVolume:1.0f];
    [bRollVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, bRollVideoAsset.duration) ofTrack:bRollVideoAssetTrack atTime:sequenceTime error:&error];
    [bRollVideoTrack setPreferredVolume:1.0f];
    AVMutableCompositionTrack *bRollAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [bRollAudioTrack setPreferredVolume:1.0f];
    [bRollAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, bRollVideoAsset.duration) ofTrack:[[bRollVideoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:sequenceTime error:&error];
    [bRollAudioTrack setPreferredVolume:1.0f];
    
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:bRollVideoTrack];
    [videoLayerInstruction setTransform:bRollVideoAssetTrack.preferredTransform atTime:sequenceTime];
    
    sequenceTime = CMTimeAdd(sequenceTime, bRollVideoAsset.duration);
    [videoLayerInstruction setOpacity:0.0 atTime:sequenceTime];
    [videoCompositionLayerArrayTemp addObject:videoLayerInstruction];
    
    
    NSMutableArray *videoCompositionLayerArray = [[NSMutableArray alloc] init];
    for (int j = 5; j>= 0 ; j--)
    {
        [videoCompositionLayerArray addObject:[videoCompositionLayerArrayTemp objectAtIndex:j]];
    }
    
    NSString *selectedBgMusic =  [[WizardViewController sharedInstance].currentProjectDict objectForKey:@"BGMusicFileName"];
    NSString *soundOne1  =[[NSBundle mainBundle]pathForResource:selectedBgMusic ofType:@"mp3"];
    
    NSURL *url1 = [NSURL fileURLWithPath:soundOne1];
    AVAsset *avAsset1 = [AVURLAsset URLAssetWithURL:url1 options:nil];
    AVAssetTrack *clipAudioTrack1 = [[avAsset1 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    AVMutableCompositionTrack *compositionAudioTrack1 = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionAudioTrack1 setPreferredVolume:0.1f];
    if(CMTimeCompare(sequenceTime, avAsset1.duration) == -1)
    {
        [compositionAudioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, sequenceTime) ofTrack:clipAudioTrack1 atTime:kCMTimeZero error:&error];
        [compositionAudioTrack1 setPreferredVolume:0.1f];
    }
    else if(CMTimeCompare(sequenceTime, avAsset1.duration) == 1)
    {
        CMTime currentTime = kCMTimeZero;
        while(YES)
        {
            CMTime audioDuration = avAsset1.duration;
            CMTime totalDuration = CMTimeAdd(currentTime,audioDuration);
            if(CMTimeCompare(totalDuration, sequenceTime)==1)
            {
                audioDuration = CMTimeSubtract(sequenceTime,currentTime);
            }
            [compositionAudioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioDuration) ofTrack:clipAudioTrack1 atTime:currentTime error:&error];
            [compositionAudioTrack1 setPreferredVolume:0.1f];
            currentTime = CMTimeAdd(currentTime, audioDuration);
            if(CMTimeCompare(currentTime, sequenceTime) == 1 || CMTimeCompare(currentTime, sequenceTime) == 0)
            {
                break;
            }
        }
    }
    
    KMSDebugLog(@"videoCompositionLayerArray : %@",videoCompositionLayerArray);
    AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    MainInstruction.timeRange =  CMTimeRangeMake(kCMTimeZero,sequenceTime);
    MainInstruction.layerInstructions = videoCompositionLayerArray;
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, 30);
    MainCompositionInst.renderSize = CGSizeMake(1280.0, 720.0);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/mergeVideo-%d.mp4",MY_SELFIE_DIRNAME,arc4random() % 1000]];
    //    1280x720
    //    1920x1080
    //    640x480
    //    960x540
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    if (self.exportSession)
    {
        [self.exportSession cancelExport];
        self.exportSession = nil;
    }
    self.exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPreset1280x720];
    self.exportSession.outputURL=url;
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    self.exportSession.videoComposition = MainCompositionInst;
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self exportDidFinish:self.exportSession andCompletionHandler:^(NSError* error)
              {
                  completionHandler(error);
              }
              ];
         });
     }];
        [self monitorExportProgress];
}
-(void)sendAnalytics
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Tell Your Story-Finish Recording Video"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Tell Your Story"
                                                          action:@"Finish recording video"
                                                           label:@"User finishes recording a selfie video"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];

}
- (void)monitorExportProgress {
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    __weak id weakSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        AVAssetExportSessionStatus status = [weakSelf exportSession].status;
        if (status == AVAssetExportSessionStatusExporting) {
            [[ActivityLoadingViewController sharedInstance] updateProgressViewWithValue:[weakSelf exportSession].progress];
            [weakSelf monitorExportProgress];
        } else if (status == AVAssetExportSessionStatusFailed) {
            KMSDebugLog(@"Export Progress Failed");
        } else if (status == AVAssetExportSessionStatusCompleted) {
             KMSDebugLog(@"Export Progress Completed");
        }
    });
}

//- (void)exportDidFinish:(AVAssetExportSession*)session
- (void)exportDidFinish:(AVAssetExportSession*)session andCompletionHandler:(void (^)(NSError* error))completionHandler;
{
    KMSDebugLog(@"exportDidFinish");
    
    if(session.status == AVAssetExportSessionStatusCompleted)
    {
        NSURL *outputURL = session.outputURL;
        KMSDebugLog(@"exportDidFinish : Completed");
        WizardViewController *wizardViewController = [WizardViewController sharedInstance];

        //moving to resizeVideo competed
        [wizardViewController updateVideoForScreenIndex:WizardStepUpload withVideoUrl:outputURL andCompletionHandler:^(NSError* error)
         {
             UIBackgroundTaskIdentifier bgMergingID = [self backgroundMergingID];
             [self setBackgroundMergingID:UIBackgroundTaskInvalid];
             if (bgMergingID != UIBackgroundTaskInvalid)
                 [[UIApplication sharedApplication] endBackgroundTask:bgMergingID];
             if(error)
             {
                 KMSDebugLog(@"updateVideoForScreenIndex Error :%@",error);
             }

             if(![[[WizardViewController sharedInstance].currentProjectDict objectForKey:@"isCompleted"] boolValue])
             {
                 [[WizardViewController sharedInstance].currentProjectDict setValue:[NSNumber numberWithBool:YES] forKey:@"isMerged"];             //TODO: Get isCompleted Flag
                 [self sendAnalytics];
                 
                 
             }
             [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];
             completionHandler(error);
         }
         ];
    }
    else if(session.status == AVAssetExportSessionStatusCancelled)
    {
        KMSDebugLog(@"exportDidFinish : Cancelled");
    }
    else if(session.status == AVAssetExportSessionStatusExporting)
    {
        KMSDebugLog(@"exportDidFinish : Exporting");
    }
    else if(session.status == AVAssetExportSessionStatusFailed)
    {
        KMSDebugLog(@"exportDidFinish : Failed");
    }
    else if(session.status == AVAssetExportSessionStatusUnknown)
    {
        KMSDebugLog(@"exportDidFinish : Unknown");
    }
    else if(session.status == AVAssetExportSessionStatusWaiting)
    {
        KMSDebugLog(@"exportDidFinish : Waiting");
    }
    else
    {
        KMSDebugLog(@"exportDidFinish : Invalid status");
    }

    
    self.exportSession = nil;
}

@end
