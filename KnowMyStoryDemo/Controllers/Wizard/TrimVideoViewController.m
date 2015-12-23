//
//  TrimVideoViewController.m
//  KnowMyStoryDemo
//
//  Created by Abdusha on 12/16/14.
//  Copyright (c) 2014 Fingent. All rights reserved.
//

#import "TrimVideoViewController.h"
#import "WizardViewController.h"
#import "AVPlayerDemoPlaybackViewController.h"

#define THUMBNAIL_WIDTH     88
#define THUMBNAIL_HEIGHT    50
//#define THUMBNAIL_SIZE CGSizeMake(227.0f, 128.0f)
#define THUMBNAIL_SIZE CGSizeMake(88.0f, 50.0f)
#define PREVIEW_IMAGE_SIZE CGSizeMake(1280.0f, 720.0f)


static NSString *const AVAssetTracksKey = @"tracks";
static NSString *const AVAssetDurationKey = @"duration";
static NSString *const AVAssetCommonMetadataKey = @"commonMetadata";


@interface TrimVideoViewController ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTrimmingID;

@end

@implementation TrimVideoViewController

@synthesize thumbnailsView;

static TrimVideoViewController *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (TrimVideoViewController *)sharedInstance
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

#pragma mark - View Life cycle methods

- (void)viewDidLoad {
    KMSDebugLog();
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    sharedInstance = self;
    
    self.thumbnailsCount = 0;
    self.thumbnailsViewTotalWidth = 0;
    self.thumbnailsView_SidePadding = 0;
    self.startMarkerTime = 0.0;
    self.endMarkerTime = 0.0;
    [self initializeTrimView];
}

-(void)viewDidAppear:(BOOL)animated
{
    KMSDebugLog();
    [super viewDidAppear:animated];
}

-(void)InitialiseView
{
    KMSDebugLog();
    [self configureView];
}
-(void)configureView
{
    KMSDebugLog();
}
-(void)hideAndStopViewActions
{
    KMSDebugLog();
    [self stopVideoPreview];
}

-(void) initializeTrimView
{
    KMSDebugLog();
    [self calculateThumbnailViewSize];
    [self addThumbnailsInView];
}
-(void) configureTrimView
{
    KMSDebugLog();
    self.draggingSlider = 0;
    self.startMarkerTime = 0.0;
    self.endMarkerTime = self.fullClipDuration;
    
    [self loadVideoPreview];
    [self generateThumbnailsForAsset:self.asset thumbnailCount:self.thumbnailsCount andCompletionHandler:^(NSArray* thumbnailsArray)
     {
         self.thumbnails = [NSArray arrayWithArray:thumbnailsArray];
         [self setThumbnailsImages];
     }
     ];

    float sliderY = 0;
    [self.startSliderButton setFrame:CGRectMake(0 - self.startSliderButton.frame.size.width,sliderY,self.startSliderButton.frame.size.width,self.startSliderButton.frame.size.height)];
    [self.endSliderButton setFrame:CGRectMake(self.thumbnailsViewTotalWidth,sliderY,self.endSliderButton.frame.size.width,self.endSliderButton.frame.size.height)];
    [self updateOverlayBars];
}


-(void) setFullClipDuration:(float)duration
{
    KMSDebugLog();
    _fullClipDuration = duration;
    self.endMarkerTime = self.fullClipDuration;
    [self updateMarkerTime];
}


-(void)calculateThumbnailViewSize
{
    KMSDebugLog();
    CGRect ScreenFrame = [[UIScreen mainScreen] applicationFrame];
    
    float width = ScreenFrame.size.width;
    
    // iOS 7 fix : Abdu 01 April 15
    if (width < ScreenFrame.size.height)
    {
        width = ScreenFrame.size.height;
    }
    self.thumbnailsCount = width / THUMBNAIL_WIDTH;
    self.thumbnailsView_SidePadding = ((int)width % THUMBNAIL_WIDTH) / 2;
    self.thumbnailsViewTotalWidth = self.thumbnailsCount * THUMBNAIL_WIDTH;
    
    //Trim Modification Feb 19
    CGRect newThumbnailsViewFrame = CGRectMake(self.thumbnailsView_SidePadding, 0, self.thumbnailsViewTotalWidth , self.thumbnailsView.frame.size.height);
    
    // iOS 7 fix : Abdu 31 March 15
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8 )
    {
        [self.thumbnailsView setPreservesSuperviewLayoutMargins:NO];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.thumbnailsView setFrame:newThumbnailsViewFrame];
    });
    KMSDebugLog(@"thumbnailsCount :%i thumbnailsView_SidePadding :%f",self.thumbnailsCount,self.thumbnailsView_SidePadding);
    KMSDebugLog(@"Thumbnail :%d",self.thumbnailsViewTotalWidth);
    KMSDebugLog(@"thumbnailsView Frame : %@", NSStringFromCGRect(self.thumbnailsView.frame));
}

-(void)loadVideoPreview
{
    KMSDebugLog();
    
    WizardViewController *wizardViewController = [WizardViewController sharedInstance];
    NSString *currentScreen = [wizardViewController getCurrentScreenName];
    NSString *videoURL = [[wizardViewController.currentProjectDict objectForKey:currentScreen] objectForKey:@"videoPath"];
    [self loadTrimViewWithURL:[NSURL URLWithString:videoURL]];
    KMSDebugLog(@"fullClipDuration :%f",self.fullClipDuration);
}

-(void) stopVideoPreview
{
    KMSDebugLog();
    [[AVPlayerDemoPlaybackViewController sharedInstance] pause:nil];
    [self.previewButton setSelected:NO];
}


-(void)loadTrimViewWithURL:(NSURL *) url
{
    KMSDebugLog();
    _filename = [[url lastPathComponent] copy];
    _asset = [AVURLAsset URLAssetWithURL:url options:@{AVURLAssetPreferPreciseDurationAndTimingKey : @YES}];
    _thumbnails = @[];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]])
    {
        KMSDebugLog(@"Trim file exist");
    }
    else
    {
        KMSDebugLog(@"Trim not file exist");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)generateThumbnailsForAsset:(AVAsset *)asset thumbnailCount:(int)thumbnailCount andCompletionHandler:(void (^)(NSArray* thumbnailsArray))completionHandler
{
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    KMSDebugLog(@"generateThumbnailsForAsset");
    if (thumbnailCount == 1)
    {
        _imageGenerator.maximumSize = PREVIEW_IMAGE_SIZE;
    }
    else
    {
        _imageGenerator.maximumSize = THUMBNAIL_SIZE;
    }
    
    CMTime duration = asset.duration;
    AVAssetTrack *videoAssetTrack= [[asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    
    UIImageOrientation videoOrientation= UIImageOrientationUp;
    if(videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0)
    {
        videoOrientation= UIImageOrientationDown;
    }
    CMTimeValue intervalSeconds = duration.value / thumbnailCount;
    KMSDebugLog(@"duration.value :%lld  duration.timescale:%d",duration.value,duration.timescale);
    CMTime time = kCMTimeZero;
    NSMutableArray *times = [NSMutableArray array];
    for (NSUInteger i = 0; i < thumbnailCount; i++) {
        [times addObject:[NSValue valueWithCMTime:time]];
        time = CMTimeAdd(time, CMTimeMake(intervalSeconds, duration.timescale));
    }
    
    
    /*[self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime,
                                                                                          CGImageRef cgImage,
                                                                                          CMTime actualTime,
                                                                                          AVAssetImageGeneratorResult result,
                                                                                          NSError *error)*/
     [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime,
                                                                                           CGImageRef cgImage,
                                                                                           CMTime actualTime,
                                                                                           AVAssetImageGeneratorResult result,
                                                                                           NSError *error)

     {
         if (error)
         {
             KMSDebugLog(@"generateCGImagesAsynchronouslyForTimes Error: %@",error);
             completionHandler(imagesArray);
         }
         else
         {
             if (cgImage)
             {
                 UIImage *image = [UIImage imageWithCGImage:cgImage];
                 
                 //Orientation support
                 //UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:videoOrientation];
                 // NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                 UIImage *rotatedImage = image;
                 if(videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0)
                 {
                     rotatedImage = [self imageRotatedByDegrees:image deg:180];
                 }
                 
                 [imagesArray addObject:rotatedImage];
                 
             }
             
             if (imagesArray.count == thumbnailCount)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     completionHandler(imagesArray);
                 });
             }
         }
     }];
}


- (UIImage*)GenerateThumbnailImageForAsset:(AVAsset *)asset
{
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    KMSDebugLog(@"err==%@, imageRef==%@", err, imgRef);
    return [[UIImage alloc] initWithCGImage:imgRef];
}

- (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    
    //you can update the code for retina display by using "UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, 0);"
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



-(void)addThumbnailsInView
{
    KMSDebugLog(@"self.thumbnails count:%lu",(unsigned long)[self.thumbnails count]);
    self.thumbnailImageViews = [[NSMutableArray alloc] initWithCapacity:self.thumbnailsCount];
    
    int xPos = 0 , xOffset = 0;
    for (int i =0 ; i < self.thumbnailsCount; i++)
    {
        UIImageView *thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, 0, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)];
        xPos = xPos + THUMBNAIL_WIDTH + xOffset;
        [self.thumbnailImageViews addObject:thumbView];
        [self.thumbnailsView addSubview:thumbView];
    }
    //Trim Modification Feb 19
    [self.thumbnailsView bringSubviewToFront:self.thumbOverlayLeft];
    [self.thumbnailsView bringSubviewToFront:self.thumbOverlayRight];
    [self.thumbnailsView bringSubviewToFront:self.startSliderButton];
    [self.thumbnailsView bringSubviewToFront:self.endSliderButton];
    
    KMSDebugLog(@"thumbnailsView Frame : %@", NSStringFromCGRect(self.thumbnailsView.frame));
    
}

-(void)setThumbnailsImages
{
    KMSDebugLog();
    
    for (int i =0 ; i < [self.thumbnails count]; i++)
    {
        UIImageView *thumbView = [self.thumbnailImageViews objectAtIndex:i];
        [thumbView setImage:[self.thumbnails objectAtIndex:i]];
    }
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.thumbnailsView];
    CGRect touchRect = CGRectMake(touchLocation.x - 10, touchLocation.y - 10, 20, 20);
    if (CGRectIntersectsRect(self.startSliderButton.frame, touchRect) == YES)
    {
        self.draggingSlider = 1;
    }
    else if (CGRectIntersectsRect(self.endSliderButton.frame, touchRect) == YES)
    {
        self.draggingSlider = 2;
    }
    else
    {
        CGPoint touchLocation = [touch locationInView:self.view];
        if(touchLocation.y > 40 && touchLocation.y < self.thumbnailsBaseView.frame.origin.y)
        {
            if(!(CGRectContainsPoint(self.cancelButton.frame, touchLocation) == YES) && !(CGRectContainsPoint(self.trimButton.frame, touchLocation) == YES))
            {
                KMSDebugLog(@"Play Pause");
                [[AVPlayerDemoPlaybackViewController sharedInstance] playStopButtonPressed:nil];
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.draggingSlider = 0;
}
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.thumbnailsView];
    if (self.draggingSlider == 1)
    {
        float startX = self.startSliderButton.frame.size.width/2;
        float endX =  self.endSliderButton.frame.origin.x - self.startSliderButton.frame.size.width/2;
        float xPos = location.x;
        if (xPos < -startX)
        {
            xPos = -startX;
        }
        else if(xPos >= endX)
        {
            xPos = endX;
        }

        [self.startSliderButton setCenter:CGPointMake(xPos, (self.startSliderButton.frame.origin.y + (self.startSliderButton.frame.size.height/2)))];
        float calcX = self.startSliderButton.frame.origin.x + self.startSliderButton.frame.size.width;
        
        //int startTime = self.fullClipDuration * (1/(self.thumbnailsViewTotalWidth / calcX));
        // Millisecond precision
        float startTime = self.fullClipDuration * (1/(self.thumbnailsViewTotalWidth / calcX));
        
        self.startMarkerTime = startTime;
        [[AVPlayerDemoPlaybackViewController sharedInstance] setCurrentSeekPosition:startTime];
        [[AVPlayerDemoPlaybackViewController sharedInstance] setStartMarkerTime:startTime];
        [[AVPlayerDemoPlaybackViewController sharedInstance] pause:nil];
        [self updateOverlayBars];
    }
    else if (self.draggingSlider == 2)
    {
        float startX = self.startSliderButton.frame.origin.x + self.startSliderButton.frame.size.width + self.endSliderButton.frame.size.width/2;
        float endX =  self.thumbnailsViewTotalWidth + self.endSliderButton.frame.size.width/2;
        float xPos = location.x;
        if (xPos <= startX)
        {
            xPos = startX;
        }
        else if(xPos >= endX)
        {
            xPos = endX;
        }
        [self.endSliderButton setCenter:CGPointMake(xPos, (self.endSliderButton.frame.origin.y + (self.endSliderButton.frame.size.height/2)))];
        float calcX = self.endSliderButton.frame.origin.x;
        
        //int endTime = self.fullClipDuration * (1/(self.thumbnailsViewTotalWidth / calcX));
        // Millisecond precision
        float endTime = self.fullClipDuration * (1/(self.thumbnailsViewTotalWidth / calcX));
        
        self.endMarkerTime = endTime;
        
        [[AVPlayerDemoPlaybackViewController sharedInstance] setCurrentSeekPosition:endTime];
        [[AVPlayerDemoPlaybackViewController sharedInstance] setEndMarkerTime:endTime];
        [[AVPlayerDemoPlaybackViewController sharedInstance] pause:nil];
        [self updateOverlayBars];
    }
    
}

-(void)updateMarkerTime
{
    int startMin = (int)self.startMarkerTime/60;
    int startSec = (int)self.startMarkerTime %60;
    // Millisecond precision
    int startMilliSec = (int)((self.startMarkerTime - (startMin * 60) - startSec) * 100);
    
    
    int endMin = (int)self.endMarkerTime/60;
    int endSec = ((int)self.endMarkerTime%60);
    // Millisecond precision
    int endMilliSec = (int)((self.endMarkerTime - (endMin * 60) - endSec) * 100);
    
    //Left Marker Time Label
    NSString *startMarkerTimeString = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",startMin,startSec,startMilliSec];
    [self.leftMarkerTimeLabel setText:startMarkerTimeString];
    
    //Right Marker Time Label
    NSString *endMarkerTimeString = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",endMin,endSec,endMilliSec];
    [self.rightMarkerTimeLabel setText:endMarkerTimeString];
}

-(void) updateOverlayBars
{
    [self updateMarkerTime];
    
    float xOffsetWithThumbnailView = self.thumbnailsView.frame.origin.x;
    float OrangeBarXPos = xOffsetWithThumbnailView + self.startSliderButton.frame.origin.x+self.startSliderButton.frame.size.width;
    float OrangeBarWidth = xOffsetWithThumbnailView +  self.endSliderButton.frame.origin.x - OrangeBarXPos;
    CGRect newOrangeBarFrame = CGRectMake(OrangeBarXPos, self.orangeBar.frame.origin.y, OrangeBarWidth, self.orangeBar.frame.size.height);
    
    float OverlayLeftWidth = self.startSliderButton.frame.origin.x + self.startSliderButton.frame.size.width;
    CGRect newThumbOverlayLeftFrame = CGRectMake(0, 0, OverlayLeftWidth , THUMBNAIL_HEIGHT);
    
    float OverlayRightXPos = self.endSliderButton.frame.origin.x;
    float OverlayRightWidth = self.thumbnailsViewTotalWidth - OverlayRightXPos;
    CGRect newThumbOverlayRightFrame = CGRectMake(OverlayRightXPos,0, OverlayRightWidth , THUMBNAIL_HEIGHT);
    
    [self.orangeBar setFrame:newOrangeBarFrame];
    [self.thumbOverlayLeft setFrame:newThumbOverlayLeftFrame];
    [self.thumbOverlayRight setFrame:newThumbOverlayRightFrame];
}
#pragma mark - Button Press Methods
- (IBAction)cancelButtonPressed:(id)sender {
    
    [self hideAndStopViewActions];
    [[WizardViewController sharedInstance] cancelTrimView];
}

- (IBAction)trimButtonPressed:(id)sender
{
    [self stopVideoPreview];
    WizardViewController *wizardViewController = [WizardViewController sharedInstance];
    
    KMSDebugLog(@"BackgroundTrimmingID :%lu",(unsigned long)[self backgroundTrimmingID]);
    KMSDebugLog(@"startMarkerTime :%f  endMarkerTime:%f",self.startMarkerTime,self.endMarkerTime);
    CMTime startTime = CMTimeMakeWithSeconds((self.startMarkerTime), NSEC_PER_SEC);
    CMTime endTime = CMTimeMakeWithSeconds((self.endMarkerTime), NSEC_PER_SEC);
    CMTime totalTime = CMTimeSubtract(endTime,startTime);
    double time = CMTimeGetSeconds(totalTime);
    if (time >= 0.01)
    {
        
        [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:ACTIVITY_LOADING_TEXT_TRIMMING showProgress:YES onController:wizardViewController];
    // iOS 7 Issue Fix - Abdu 07 April 15
    if ([[UIDevice currentDevice] isMultitaskingSupported])
    {
        [self setBackgroundTrimmingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
    }
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    
    NSString *currentScreen = [wizardViewController.screenSequenceArray objectAtIndex:wizardViewController.currentScreenSequenceIndex];
    NSString *videoURL = [[wizardViewController.currentProjectDict objectForKey:currentScreen] objectForKey:@"videoPath"];
    
        NSLog(@"trimButtonPressed videoURL:%@",videoURL);
    AVAsset *videoAsset = [AVAsset assetWithURL:[NSURL URLWithString:videoURL]];
    AVAssetTrack *videoAssetTrack= [[videoAsset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    NSError *erro =nil;
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(startTime,totalTime) ofTrack:videoAssetTrack atTime:kCMTimeZero error:&erro];
    
    AVMutableCompositionTrack *AudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [AudioTrack insertTimeRange:CMTimeRangeMake(startTime, totalTime) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:&erro];
    
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        NSLog(@"videoAssetTrack.naturalSize.width :%f  videoAssetTrack.naturalSize.height:%f",videoAssetTrack.naturalSize.width,videoAssetTrack.naturalSize.height);
    CGFloat FirstAssetWidthScaleToFitRatio = 1280.0/videoAssetTrack.naturalSize.width;
    CGFloat FirstAssetHeightScaleToFitRatio = 720.0/videoAssetTrack.naturalSize.height;
    
    CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetWidthScaleToFitRatio,FirstAssetHeightScaleToFitRatio);
    [videoLayerInstruction setTransform:CGAffineTransformConcat(videoAssetTrack.preferredTransform, FirstAssetScaleFactor) atTime:kCMTimeZero];
    
    
    AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    MainInstruction.timeRange =  CMTimeRangeMake(kCMTimeZero,totalTime);
    MainInstruction.layerInstructions = [NSArray arrayWithObject:videoLayerInstruction];
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, 30);
    MainCompositionInst.renderSize = CGSizeMake(1280.0, 720.0);

    NSString *DestFilename = [NSString stringWithFormat:@"videoClip_%d_%d_trimmed.mov",([[WizardViewController sharedInstance] currentScreenSequenceIndex]),arc4random() % 10000 ];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:MY_SELFIE_DIRNAME];
    DestPath = [DestPath stringByAppendingPathComponent:DestFilename];
    NSURL* saveLocationURL = [[NSURL alloc] initFileURLWithPath:DestPath];

    if (self.exportSession)
    {
        [self.exportSession cancelExport];
        self.exportSession = nil;
    }
    self.exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPreset1280x720];
    self.exportSession.outputURL=saveLocationURL;
    self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    self.exportSession.videoComposition = MainCompositionInst;
    self.exportSession.shouldOptimizeForNetworkUse = YES;

    [self monitorExportProgress];
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self exportDidFinish:self.exportSession];
         });
     }];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid time selection" message:@"Please choose a selection time more than 1 millisecond."  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
    
}


- (void)monitorExportProgress
{
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    __weak id weakSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        AVAssetExportSessionStatus status = [weakSelf exportSession].status;
        if (status == AVAssetExportSessionStatusExporting) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ActivityLoadingViewController sharedInstance] updateProgressViewWithValue:[weakSelf exportSession].progress];
                [weakSelf monitorExportProgress];
            });
            
        } else if (status == AVAssetExportSessionStatusFailed) {
            KMSDebugLog(@"Export Progress Failed");
        } else if (status == AVAssetExportSessionStatusCompleted) {
            //[weakSelf playerViewController].exporting = NO;
            KMSDebugLog(@"Export Progress Completed");
        }
    });
}

- (void)exportDidFinish:(AVAssetExportSession*)session
{
    KMSDebugLog(@"exportDidFinish");
    if(session.status == AVAssetExportSessionStatusCompleted)
    {
        KMSDebugLog(@"exportDidFinish : Completed");
        NSURL *outputURL = session.outputURL;
        WizardViewController *wizardViewController = [WizardViewController sharedInstance];
        KMSDebugLog(@"Exporting... WizardViewController :%@",wizardViewController);
        NSString *currentScreen = [wizardViewController.screenSequenceArray objectAtIndex:wizardViewController.currentScreenSequenceIndex];
        NSURL *existingVideoURL = [NSURL URLWithString:[[wizardViewController.currentProjectDict objectForKey:currentScreen] objectForKey:@"videoPath"]];
        NSError *error;
        if (existingVideoURL && [[NSFileManager defaultManager] fileExistsAtPath:[existingVideoURL path]])
        {
            [[NSFileManager defaultManager] removeItemAtPath:[existingVideoURL path] error:&error];
        }
        
        [wizardViewController updateVideoForScreenIndex:wizardViewController.currentScreenSequenceIndex withVideoUrl:outputURL andCompletionHandler:^(NSError* error)
         {
             KMSDebugLog(@"updateVideoForScreenIndex Error :%@",error);
             
             UIBackgroundTaskIdentifier bgTrimmingID = [self backgroundTrimmingID];
             [self setBackgroundTrimmingID:UIBackgroundTaskInvalid];
             if (bgTrimmingID != UIBackgroundTaskInvalid)
                 [[UIApplication sharedApplication] endBackgroundTask:bgTrimmingID];

             [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];
             
             [wizardViewController cancelTrimView];
             [wizardViewController configureScreen];
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
    
}




- (IBAction)previewButtonPressed:(id)sender
{
    if (!self.previewButton.isSelected)
    {
        [[AVPlayerDemoPlaybackViewController sharedInstance] play:nil];
        [self.previewButton setSelected:YES];
    }
    else
    {
        [[AVPlayerDemoPlaybackViewController sharedInstance] pause:nil];
        [self.previewButton setSelected:NO];
    }
    
}

@end
