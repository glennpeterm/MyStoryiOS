//
//  UIAlertView+OrientationFix.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 23/03/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "UIAlertView+OrientationFix.h"

@implementation UIAlertView (OrientationFix)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}
@end
