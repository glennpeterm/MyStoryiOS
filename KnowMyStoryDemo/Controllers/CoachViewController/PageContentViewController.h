//
//  PageContentViewController.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 22/09/15.
//  Copyright © 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
