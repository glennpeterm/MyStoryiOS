//
//  DVViewController.h
//  Youtube
//
//  Created by Ilya Puchka on 26.11.12.
//  Copyright (c) 2012 Denivip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YoutubeUploadService.h"
#import "ProgressBarView.h"

@interface YoutubeUploadViewController : UIViewController<UITextFieldDelegate,dismissAlert>



#pragma mark Singleton Methods
+ (YoutubeUploadViewController *)sharedInstance;


@property (weak, nonatomic) IBOutlet UITextField *descriptionText;
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextField *tagsText;
@property(nonatomic,strong) ProgressBarView *progressView;
@property(nonatomic,strong) NSString *uploadedFileName;
@property (weak, nonatomic) IBOutlet UIScrollView *uploadScrollView;

- (IBAction)uploadBtnClicked:(id)sender;


-(void)uploadVideoToYoutube;

@end
