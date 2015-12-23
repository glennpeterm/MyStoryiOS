//
//  WizardTabButton.m
//  KnowMyStoryDemo
//
//  Created by Abdusha on 2/25/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "WizardTabButton.h"

@implementation WizardTabButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@synthesize sequenceNumberLabel;

-(void)setupButton
{
    if (!sequenceNumberLabel)
    {
        sequenceNumberLabel = [[UILabel alloc] initWithFrame:self.imageView.frame];
        [sequenceNumberLabel setTag:400];
        [sequenceNumberLabel setTextAlignment:NSTextAlignmentCenter];
        [sequenceNumberLabel setFont:kFONT_ABEL_SIZE_16];
        [sequenceNumberLabel setBackgroundColor:[UIColor clearColor]];
        [self insertSubview:sequenceNumberLabel aboveSubview:self.imageView];
        [sequenceNumberLabel setTextColor:[UIColor whiteColor]];
        
    }
    
    [self setImage:[UIImage imageNamed:@"WizardItem_OrangeCircle.png"] forState:UIControlStateNormal];
    [sequenceNumberLabel setHidden:NO];
    [self setEnabled:NO];
    markedAsCompleted = NO;
}

-(void)markAsCompleted
{
    if (!markedAsCompleted)
    {
        [self setImage:[UIImage imageNamed:@"WizardItem_OrangeCircle_Tick.png"] forState:UIControlStateNormal];
        [sequenceNumberLabel setHidden:YES];
        markedAsCompleted =YES;
    }
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
}

- (void)setSelected:(BOOL)selected
{
       [super setSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted
{
        [super setHighlighted:highlighted];
}

@end
