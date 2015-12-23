//
//  TrimVideoViewController.h
//  KnowMyStoryDemo
//
//  Created by Abdusha on 12/16/14.
//  Copyright (c) 2014 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>

//#import "THTimelineItem.h"

typedef void(^THPreparationCompletionBlock)(BOOL complete);


@interface TrimVideoViewController : UIViewController


#pragma mark Singleton Methods
+ (TrimVideoViewController *)sharedInstance;


@property (weak, nonatomic) IBOutlet UIView *thumbnailsBaseView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *trimButton;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UILabel *markerTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftMarkerTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightMarkerTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *thumbnailsView;
@property (weak, nonatomic) IBOutlet UIView *startSliderButton;
@property (weak, nonatomic) IBOutlet UIView *endSliderButton;
@property (weak, nonatomic) IBOutlet UIView *orangeBar;
@property (weak, nonatomic) IBOutlet UIView *thumbOverlayLeft;
@property (weak, nonatomic) IBOutlet UIView *thumbOverlayRight;


@property int thumbnailsCount;
@property int thumbnailsViewTotalWidth;
@property float thumbnailsView_SidePadding;
@property (assign , nonatomic) float fullClipDuration;
@property float startMarkerTime;
@property float endMarkerTime;
@property int draggingSlider;

@property (nonatomic, strong) NSArray *thumbnails;
@property (nonatomic, strong) NSMutableArray *thumbnailImageViews;
@property (nonatomic, strong) AVAsset *asset;

- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)homeButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)trimButtonPressed:(id)sender;
- (IBAction)previewButtonPressed:(id)sender;

-(void)loadVideoPreview;
-(void)stopVideoPreview;

-(void)generateThumbnailsForAsset:(AVAsset *)asset thumbnailCount:(int)thumbnailCount andCompletionHandler:(void (^)(NSArray* thumbnailsArray))completionHandler;

-(void)calculateThumbnailViewSize;

-(void)configureTrimView;
-(void)configureView;
-(void)hideAndStopViewActions;

@end
