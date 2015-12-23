//
//  CreateNewStoryViewController.h
//  KnowMyStoryDemo
//
//  Created by Abdusha on 1/8/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateNewStoryViewController : UIViewController<UITextFieldDelegate,UIScrollViewDelegate>
{
    NSMutableArray *topicListArray;
    NSMutableArray *selectedTopicsArray;
}


@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIView *BaseView;
@property (weak, nonatomic) IBOutlet UIView *ContentView;
@property (weak, nonatomic) IBOutlet UIScrollView *ContentScrollView;
@property (weak, nonatomic) IBOutlet UIView *topicPopupView;
@property (weak, nonatomic) IBOutlet UITableView *topicTableView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *topicTextField;
@property (weak, nonatomic) IBOutlet UILabel *HeadingLabel;

@property (weak, nonatomic) IBOutlet UIImageView *titleMandatoryMarkerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *topicMandatoryMarkerImageView;

#pragma mark Singleton Methods
+ (CreateNewStoryViewController *)sharedInstance;

- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)homeButtonPressed:(id)sender;
- (IBAction)topicTouched:(id)sender;


-(void)configureView;
-(void)hideAndStopViewActions;

-(BOOL)isMandatoryFieldsFilled;

@end
