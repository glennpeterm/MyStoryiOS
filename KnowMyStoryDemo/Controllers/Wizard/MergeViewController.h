//
//  MergeViewController.h
//  KnowMyStoryDemo
//
//  Created by Abdusha on 12/24/14.
//  Copyright (c) 2014 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface MergeViewController : UIViewController


@property (nonatomic) UIBackgroundTaskIdentifier backgroundMergingID;

#pragma mark Singleton Methods
+ (MergeViewController *)sharedInstance;


- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)homeButtonPressed:(id)sender;
- (IBAction)mergeButtonPressed:(id)sender;

-(void)mergeAllVideoswithCompletionHandler:(void (^)(NSError* error))completionHandler;
-(void)exportDidFinish:(AVAssetExportSession*)session andCompletionHandler:(void (^)(NSError* error))completionHandler;
//-(void)mergeFinalVideo;

-(void)configureView;
-(void)hideAndStopViewActions;

@end
