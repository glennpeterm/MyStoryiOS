//
//  DescriptionViewController.h
//  KnowMyStoryDemo
//
//  Created by Abdusha on 2/23/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DescriptionViewController : UIViewController <UITextFieldDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UIView *ContentView;
@property (weak, nonatomic) IBOutlet UIScrollView *ContentScrollView;
@property (weak, nonatomic) IBOutlet UILabel *HeaderLabel;
@property (weak, nonatomic) IBOutlet UITextField *videoTagsTextField;
@property (weak, nonatomic) IBOutlet UITextField *videoDescriptionTextField;
@property (weak, nonatomic) IBOutlet UIImageView *tagsMandatoryMarkerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *descriptionMandatoryMarkerImageView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

#pragma mark Singleton Methods
+ (DescriptionViewController *)sharedInstance;


- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)homeButtonPressed:(id)sender;
-(void)configureView;
-(void)hideAndStopViewActions;

-(BOOL)isMandatoryFieldsFilled;
@end
