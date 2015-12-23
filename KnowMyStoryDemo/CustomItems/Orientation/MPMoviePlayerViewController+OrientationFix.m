//
//  MPMoviePlayerViewController+OrientationFix.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 04/03/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "MPMoviePlayerViewController+OrientationFix.h"

@implementation MPMoviePlayerViewController (OrientationFix)
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
