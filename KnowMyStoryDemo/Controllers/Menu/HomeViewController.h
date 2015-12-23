//
//  HomeViewController.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 02/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SCHCircleView.h"

@interface HomeViewController : UIViewController<SCHCircleViewDataSource,SCHCircleViewDelegate>
{
    NSArray *coachImageListArray;

}

@property (strong, nonatomic)  UIView *baseView;
@property (strong, nonatomic)  SCHCircleView *circle_view;
@property (weak, nonatomic) NSArray *coachImageListArray;



@property (strong, nonatomic)  UIView *coachmarksView;
- (IBAction)hideCoachMarksBtnClicked:(id)sender;

#pragma mark - confirmationView

//@property (weak, nonatomic) IBOutlet UILabel *buildInfo;

//@property (weak, nonatomic) IBOutlet UILabel *titleInfo;
//@property (weak, nonatomic) IBOutlet UILabel *subTitleInfo;
@property (strong, nonatomic) UILabel *titleInfo;
@property (strong, nonatomic) UILabel *subTitleInfo;
//@property (strong, nonatomic) UILabel *buildInfo;

@property (weak, nonatomic) IBOutlet UIView *confirmation_popUp;
@property (weak, nonatomic) IBOutlet UIButton *finishLaterBtn;
@property (weak, nonatomic) IBOutlet UIButton *finishNowBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteNStartOverBtn;
@property (weak, nonatomic) IBOutlet UILabel *finishUrStoryText;
@property (weak, nonatomic) IBOutlet UILabel *yourStoryText;
@property (weak, nonatomic) IBOutlet UILabel *deleteTitle;
@property (weak, nonatomic) IBOutlet UILabel *deleteInfoText;
@property (weak, nonatomic) IBOutlet UIButton *noBtn;
@property (weak, nonatomic) IBOutlet UIButton *yesBtn;
@property (weak, nonatomic) IBOutlet UIView *confirmDeletePopUp;
@property (strong, nonatomic) UIButton *coachMarkTggle_button;

//@property
#pragma mark - button actions
- (IBAction)pressed:(id)sender; // menu

// confirmation view
- (IBAction)onDeleteNStartOverBtnClicked:(id)sender;
- (IBAction)onFinishLaterBtnClicked:(id)sender;
- (IBAction)onFinishNowBtnClicked:(id)sender;
- (IBAction)onConfirmDeleteBtnClicked:(id)sender;
- (IBAction)onCancelDeleteBtnClicked:(id)sender;

@end
