//
//  ActivityLoadingViewController.h
//  KnowMyStoryDemo
//
//  Created by Abdusha on 3/2/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityLoadingViewController : UIViewController



#pragma mark Singleton Methods
+ (ActivityLoadingViewController *)sharedInstance;



@property  NSTimeInterval minActivityTime;
@property  NSTimeInterval maxActivityTime;

//Activity View
@property (weak, nonatomic) IBOutlet UIView *loadingIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *customLoadingImageView;
@property (weak, nonatomic) IBOutlet UILabel *loadingIndicatorLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressViewIndicator;
@property (weak, nonatomic) IBOutlet UILabel *mergeHintText;


//Activity View
-(void)configureActivityView;
-(void) ShowLoadingIndicatorViewWithText:(NSString *)loadingTxt showProgress:(BOOL)isProgressEnabled onController:(id)aViewController minTime:(NSTimeInterval)minTime maxTime:(NSTimeInterval)maxTime autoHide:(BOOL)hideAutomatically;
-(void) ShowLoadingIndicatorViewWithText:(NSString *)loadingTxt showProgress:(BOOL)isProgressEnabled onController:(id)aViewController;
-(void) HideLoadingIndicatorView;
-(void) updateProgressViewWithValue:(float)progressValue;

@end
