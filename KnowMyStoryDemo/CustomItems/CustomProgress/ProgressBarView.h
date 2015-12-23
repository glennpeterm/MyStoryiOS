
// File Name: ProgressBarView.h
// Created By: Baburaj U
// Created On: 21/08/12.
// Purpose: To display progress view
// Copyright (c) 2012 Rapid Value Solutions. All rights reserved.

#import <UIKit/UIKit.h>

@protocol dismissAlert <NSObject>
- (void)dismissCustomAlert;
- (void)showOverlayView;
@end
@interface ProgressBarView : UIView

@property (nonatomic , assign)id<dismissAlert> progressDelegate;
-(void) setProgress:(float)prgrs;

@end
