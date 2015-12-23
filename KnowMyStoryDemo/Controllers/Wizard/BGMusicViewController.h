//
//  BGMusicViewController.h
//  KnowMyStoryDemo
//
//  Created by Abdusha on 1/8/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface BGMusicViewController : UIViewController


@property int currentPlayingMusicIndex;     //Index of the selected Music
@property (strong,nonatomic) NSMutableArray *bgMusicArray;      // Music Array
@property (strong,nonatomic) AVAudioPlayer *backgroundMusicPlayer;      //Player
@property (weak, nonatomic) IBOutlet UITableView *bgMusicListTable;     //Table
@property (weak, nonatomic) IBOutlet UIButton *playButton;      //play Button
@property (weak, nonatomic) IBOutlet UIButton *nextButton;      //Next Button


#pragma mark Singleton Methods
+ (BGMusicViewController *)sharedInstance;


#pragma mark - view
-(void)configureView;
-(void)hideAndStopViewActions;

#pragma mark - Button Press Methods
- (IBAction)nextButtonPressed:(id)sender;       //
- (IBAction)homeButtonPressed:(id)sender;
- (IBAction)bgMusicListenButtonPressed:(UIButton *)sender;

-(void)stopBackgroundMusic;




@end
