//
//  WizardViewController.h
//  KnowMyStoryDemo
//
//  Created by Abdusha on 12/17/14.
//  Copyright (c) 2014 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVCamViewController.h"
#import "WizardTabButton.h"

@interface WizardViewController : UIViewController<CamDelegate , UIScrollViewDelegate>
{
    int wizardCompletedIndex;
    int currentScreenSequenceIndex;
    NSMutableDictionary *currentProjectDict;
    NSArray *screenSequenceArray;
    
    
    //Wizard tracking
    int _selectedIndex;
    
}

@property (assign , nonatomic) BOOL isInWizardController;

//Wizard Scroller
@property (assign , nonatomic) int selectedIndex;
@property (readonly, assign, nonatomic) CGFloat scrollWidth;
@property (readonly, assign, nonatomic) CGFloat scrollHeight;

@property (weak, nonatomic) IBOutlet UIView *camContainerView;
@property (weak, nonatomic) IBOutlet UIView *previewContainerView;
@property (weak, nonatomic) IBOutlet UIView *mergeContainerView;
@property (weak, nonatomic) IBOutlet UIView *createNewStoryContainerView;
@property (weak, nonatomic) IBOutlet UIView *bgMusicContainerView;
@property (weak, nonatomic) IBOutlet UIView *trimContainerView;
@property (weak, nonatomic) IBOutlet UIView *previewPlayerContainerView;
@property (weak, nonatomic) IBOutlet UIView *scriptureContainerView;
@property (weak, nonatomic) IBOutlet UIView *regionContainerView;

@property (weak, nonatomic) IBOutlet UIView *wizardBarView;

@property (weak, nonatomic) IBOutlet UIScrollView *topTabScroller;
@property (weak, nonatomic) IBOutlet UIView *topTabContentView;
@property (weak, nonatomic) IBOutlet UIView *wizardBarOverlay;


@property (strong, nonatomic) NSMutableDictionary *currentProjectDict;
@property (strong, nonatomic) NSArray *screenSequenceArray;
@property int currentScreenSequenceIndex;
@property int wizardCompletedIndex;
@property int wizardForcedSelectionIndex;

#pragma mark Singleton Methods
+ (WizardViewController *)sharedInstance;

- (void)nextButtonPressed:(id)sender;

//Wizard
- (IBAction)topTabButtonPressed:(WizardTabButton *)sender;
-(void)disableWizardBar;
-(void)enableWizardBar;

-(void) showTrimView;
-(void) cancelTrimView;


-(void) configureScreenForIndex:(int)index;
-(void) configureScreen;
-(void) rerecordCurrentVideo;
-(void) readProjectData;
-(void) saveProjectData;
-(void) deleteProjectData;
-(void) deleteAndStartNewStory;
-(void) startStory;
-(BOOL) haveExistingStory;
-(BOOL) haveDataForKey :(NSString *)keyStr;

-(void)updateVideoForScreenIndex:(int)screenIndex withVideoUrl:(NSURL *)videoURL andCompletionHandler:(void (^)(NSError* error))completionHandler;
-(void)showScreenWithId:(NSString *)screenId;
-(NSString *)getCurrentScreenName;

@end
