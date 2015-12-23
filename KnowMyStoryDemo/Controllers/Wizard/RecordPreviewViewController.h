//
//  RecordPreviewViewController.h
//  KnowMyStoryDemo
//
//  Created by Abdusha on 12/17/14.
//  Copyright (c) 2014 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface RecordPreviewViewController : UIViewController<UIAlertViewDelegate>


@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) MPMoviePlayerController *mvPlayer;
@property (weak, nonatomic) IBOutlet UIView *previewClipView;
@property (weak, nonatomic) IBOutlet UIButton *reRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *trimButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) NSTimer *saveTimer;


@property (weak, nonatomic) IBOutlet UIImageView *thumbnailPreviewImageView;

#pragma mark Singleton Methods
+ (RecordPreviewViewController *)sharedInstance;

-(void)playVideoPreviewWithURL:(NSURL *)videoURL;
-(void)playVideoPreview;
-(void) stopVideoPreview;

- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)homeButtonPressed:(id)sender;
- (IBAction)rerecordButtonPressed:(id)sender;
- (IBAction)trimButtonPressed:(id)sender;
- (IBAction)previewButtonPressed:(id)sender;
- (IBAction)uploadButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;




-(void)configureView;
-(void)hideAndStopViewActions;

@end
