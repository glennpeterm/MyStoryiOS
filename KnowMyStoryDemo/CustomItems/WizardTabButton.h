//
//  WizardTabButton.h
//  KnowMyStoryDemo
//
//  Created by Abdusha on 2/25/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizardTabButton : UIButton
{
    BOOL markedAsCompleted;
}


@property (strong,readwrite) UILabel *sequenceNumberLabel;

-(void)setupButton;
-(void)markAsCompleted;

@end
