//
//  CustomProgressView.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 17/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "CustomProgressView.h"

@interface CustomProgressView()

    @property (nonatomic, weak) UIImageView *trackImageView;
    @property (nonatomic, weak) UIImageView *progressImageView;

@end
@implementation CustomProgressView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupProgressView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupProgressView];
    }
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIImageView *trackImageView = self.trackImageView;
    UIImageView *progressImageView = self.progressImageView;
    if (!trackImageView || !progressImageView)
    {
        return;
    }
    
    CGRect bounds = self.bounds;
    CGFloat boundsTop = CGRectGetMinY(bounds);
    UIImage *trackImage = self.trackImage;
    if (trackImage)
    {
        CGRect trackFrame = trackImageView.frame;
        CGFloat trackHeight = trackImage.size.height;
        trackImageView.frame = (CGRect){
            .origin.x = CGRectGetMinX(trackFrame),
            .origin.y = (boundsTop
                         + ((CGRectGetHeight(bounds) - trackHeight) * 0.5f)),
            .size.width = CGRectGetWidth(trackFrame),
            .size.height = trackHeight
        };
    }
    
    UIImage *progressImage = self.progressImage;
    if (progressImage)
    {
        CGRect progressFrame = progressImageView.frame;
        CGFloat progressHeight = progressImage.size.height;
        progressImageView.frame = (CGRect){
            .origin.x = CGRectGetMinX(progressFrame),
            .origin.y = (boundsTop
                         + ((CGRectGetHeight(bounds) - progressHeight) * 0.5f)),
            .size.width = CGRectGetWidth(progressFrame),
            .size.height = progressHeight
        };
    }
}


#pragma mark - UIProgressView

- (void)setProgressImage:(UIImage *)progressImage
{
    [super setProgressImage:progressImage];
    self.progressImageView.image = progressImage;
}

- (void)setTrackImage:(UIImage *)trackImage
{
    [super setTrackImage:trackImage];
    self.trackImageView.image = trackImage;
}


#pragma mark - private

- (void)setupProgressView
{
    if ([self compareVersionString:[UIDevice currentDevice].systemVersion
                 withVersionString:@"7.1"] == NSOrderedAscending)
    {
        return;
    }
    
    NSArray *subviews = self.subviews;
    if ([subviews count] != 2)
    {
        return;
    }
    
    for (UIView *subview in subviews)
    {
        if (![subview isKindOfClass:[UIImageView class]])
        {
            return;
        }
    }
    
    self.trackImageView = subviews[0];
    self.progressImageView = subviews[1];
    
    self.trackImageView.image = self.trackImage;
    self.progressImageView.image = self.progressImage;
}

- (NSComparisonResult)compareVersionString:(NSString *)versionString1
                         withVersionString:(NSString *)versionString2
{
    NSArray *components1 = [versionString1 componentsSeparatedByString:@"."];
    NSArray *components2 = [versionString2 componentsSeparatedByString:@"."];
    
    NSUInteger components1Count = [components1 count];
    NSUInteger components2Count = [components2 count];
    NSUInteger partCount = MAX(components1Count, components2Count);
    
    for (NSInteger part = 0; part < partCount; ++part)
    {
        if (part >= components1Count)
        {
            return NSOrderedAscending;
        }
        
        if (part >= components2Count)
        {
            return NSOrderedDescending;
        }
        
        NSString *part1String = components1[part];
        NSString *part2String = components2[part];
        NSInteger part1 = [part1String integerValue];
        NSInteger part2 = [part2String integerValue];
        
        if (part1 > part2)
        {
            return NSOrderedDescending;
        }
        if (part1 < part2)
        {
            return NSOrderedAscending;
        }
    }
    return NSOrderedSame;
}
@end
