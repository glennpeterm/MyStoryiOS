//
//  CoachViewController.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 22/09/15.
//  Copyright © 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoachViewController : UIViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) UIPageControl *pageControl;
@property(nonatomic,retain)NSArray *coachImageListArray;

@end
