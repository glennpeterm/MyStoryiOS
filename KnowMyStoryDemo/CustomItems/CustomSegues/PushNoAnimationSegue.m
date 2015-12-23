//
//  PushNoAnimationSegue.m
//  KnowMyStoryDemo
//
//  Created by Abdusha on 3/2/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "PushNoAnimationSegue.h"

@implementation PushNoAnimationSegue

-(void) perform
{
    UIViewController *vc = self.sourceViewController;
    [vc.navigationController pushViewController:self.destinationViewController animated:NO];
}

@end
