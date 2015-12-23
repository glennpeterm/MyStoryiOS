//
//  ProgressBarView.m
//  SQLBIPOC
//
//  Created by Baburaj on 21/08/12.
//  Copyright (c) 2012 Rapid Value Solutions. All rights reserved.
//

#import "ProgressBarView.h"
#import "CustomProgressView.h"

@interface ProgressBarView()
{
    UIImageView *progressBgImage;
    CustomProgressView *routeProgressBar;
    UILabel *comletionPerLabel;
     UILabel *uploadingLabel;
    UILabel *staticRouteCompletion;
}

@end

@implementation ProgressBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createProgressBarView];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self createProgressBarView];
    }
    return self;
}


-(void) createProgressBarView
{
    [self setBackgroundColor:[UIColor whiteColor]];
    CGRect viewFrame = self.frame;
  
    viewFrame.origin.x =60;
    viewFrame.origin.y = viewFrame.size.height/2 + 40;
    viewFrame.size.width = viewFrame.size.width  -120;
    viewFrame.size.height =  100;
    
    routeProgressBar = [[CustomProgressView alloc]initWithFrame:viewFrame];
    [routeProgressBar setTrackImage:[UIImage imageNamed:@"uploading_ProgressBg.png"] ];
    [routeProgressBar setProgressImage:[UIImage imageNamed:@"uploading_fill.png"]];
   
   
    
   
    [self  addSubview: routeProgressBar];
    
   
        comletionPerLabel = [[UILabel alloc]initWithFrame:CGRectMake(viewFrame.origin.x,  viewFrame.origin.y-129, 330, 50)];
        //[comletionPerLabel setText:@"Hi"];
        [comletionPerLabel setBackgroundColor:[UIColor clearColor]];
        [comletionPerLabel setFont:kFONT_BOLD_SIZE_52];
        [comletionPerLabel setTextColor:ORANGE_COLOR];
        [comletionPerLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:comletionPerLabel];
    
    uploadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(viewFrame.origin.x,  viewFrame.origin.y -70, 300, 50)];
    [uploadingLabel setText:@"Uploading..."];
    [uploadingLabel setBackgroundColor:[UIColor clearColor]];
    [uploadingLabel setFont:kFONT_BOLD_SIZE_30];
    [uploadingLabel setTextColor:LIGHT_GREY];
    [uploadingLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:uploadingLabel];
   
}

#define LABEL_TEXT   @"%.0f %% complete"

-(void) setProgress:(float)prgrs
{
    if(!routeProgressBar)
        [self createProgressBarView];
    [routeProgressBar setProgress:prgrs/100];
    if (prgrs== 100) {
        uploadingLabel.text = @"Uploaded";
        [self performSelector:@selector(dissmissView) withObject:nil afterDelay:0.1];
      
    }
    NSString* labelText = [NSString stringWithFormat:LABEL_TEXT,prgrs];
    
    [comletionPerLabel setText:labelText];

    
}
- (void)dissmissView{
    if (self.progressDelegate && [self.progressDelegate respondsToSelector:@selector(showOverlayView)]) {
        [self.progressDelegate showOverlayView];
    }
}
-(void) dealloc
{
    routeProgressBar = nil;
    comletionPerLabel = nil;
    staticRouteCompletion = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
