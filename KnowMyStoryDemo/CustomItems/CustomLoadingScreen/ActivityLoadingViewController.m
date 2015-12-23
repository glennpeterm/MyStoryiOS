//
//  ActivityLoadingViewController.m
//  KnowMyStoryDemo
//
//  Created by Abdusha on 3/2/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "ActivityLoadingViewController.h"

@interface ActivityLoadingViewController ()
{
    NSTimer *minActivityTimer;
    NSTimer *maxActivityTimer;
    int hideRequestPendingCount;
}

@property (nonatomic, retain) NSString *loadingViewTextString;
@property (nonatomic, retain) UIViewController *currentViewController;

@end

@implementation ActivityLoadingViewController

static ActivityLoadingViewController *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (ActivityLoadingViewController *)sharedInstance
{
    if (sharedInstance == nil)
    {
        //sharedInstance = [[ActivityLoadingViewController alloc] init];
        KMSDebugLog();
    }
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            KMSDebugLog();
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        sharedInstance = self;
        KMSDebugLog();
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    KMSDebugLog();
    sharedInstance = self;
    //self.currentViewController = nil;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - Activity View


-(void)configureActivityView
{
    if (![self.customLoadingImageView.animationImages count])
    {
        NSMutableArray *loadingImagesArray = [[NSMutableArray alloc] initWithCapacity:ACTIVITY_LOADING_IMAGES_COUNT];
        for (int i = 1; i <= ACTIVITY_LOADING_IMAGES_COUNT; i++)
        {
            NSString *imageStr = [NSString stringWithFormat:@"%@%02d",ACTIVITY_LOADING_IMAGENAME_PREFIX,i];
            [loadingImagesArray addObject:[UIImage imageNamed:imageStr]];
        }
        [self.customLoadingImageView setAnimationImages:loadingImagesArray];
        [self.customLoadingImageView setAnimationDuration:1];
    }
    
    self.minActivityTime = 0;
    self.maxActivityTime = 0;
    minActivityTimer = nil;
    maxActivityTimer = nil;
    hideRequestPendingCount = 0;

}


#pragma mark - public methods
-(void) ShowLoadingIndicatorViewWithText:(NSString *)loadingTxt showProgress:(BOOL)isProgressEnabled onController:(id)aViewController minTime:(NSTimeInterval)minTime maxTime:(NSTimeInterval)maxTime autoHide:(BOOL)hideAutomatically
{
    self.minActivityTime = minTime;
    self.maxActivityTime = maxTime;
    if (hideAutomatically)
    {
        hideRequestPendingCount = 1;
    }
    [self ShowLoadingIndicatorViewWithText:loadingTxt showProgress:isProgressEnabled onController:aViewController];
}
-(void) ShowLoadingIndicatorViewWithText:(NSString *)loadingTxt showProgress:(BOOL)isProgressEnabled onController:(id)aViewController
{
    
    [self resetTimers];
    KMSDebugLog(@"aViewController :%@ loadingTxt :%@",aViewController,loadingTxt);
    if (aViewController)
    {
        self.currentViewController = aViewController;
        [self.currentViewController.view setUserInteractionEnabled:NO];
        [self.currentViewController.view addSubview:self.loadingIndicatorView];
        
        CGRect ControllerFrame = self.currentViewController.view.frame;
        // iOS 7 View size issue fix - Abdu 31 March 15
        if (ControllerFrame.size.height > ControllerFrame.size.width)
        {
            [self.loadingIndicatorView setFrame:CGRectMake(ControllerFrame.origin.x, ControllerFrame.origin.y, ControllerFrame.size.height, ControllerFrame.size.width)];
        }
        else
        {
            [self.loadingIndicatorView setFrame:ControllerFrame];
        }
        [self.currentViewController.view setNeedsDisplay];
        [self.currentViewController.view setNeedsLayout];
    }
    
    if (self.minActivityTime > 0)
    {
        minActivityTimer = [NSTimer scheduledTimerWithTimeInterval:self.minActivityTime
                                                            target:self
                                                          selector:@selector(completedMinActivityTimer)
                                                          userInfo:nil
                                                           repeats:NO];
        self.minActivityTime = 0;
    }
    if (self.maxActivityTime > 0)
    {
        maxActivityTimer = [NSTimer scheduledTimerWithTimeInterval:self.maxActivityTime
                                                            target:self
                                                          selector:@selector(completedMaxActivityTimer)
                                                          userInfo:nil
                                                           repeats:NO];
        self.maxActivityTime = 0;
    }
    
    [self ShowLoadingIndicatorViewWithText:loadingTxt showProgress:isProgressEnabled];
    
    
}
#pragma mark - private methods

-(void) ShowLoadingIndicatorViewWithText:(NSString *)loadingTxt showProgress:(BOOL)isProgressEnabled
{
    KMSDebugLog(@"loadingTxt :%@",loadingTxt);
    
    [self ShowLoadingIndicatorViewWithText:loadingTxt];
    [self.progressViewIndicator setHidden:!isProgressEnabled];
}

-(void) ShowLoadingIndicatorViewWithText:(NSString *)loadingTxt
{
    
    KMSDebugLog(@"loadingTxt :%@",loadingTxt);
    
    self.loadingViewTextString = loadingTxt;
    
    [self updateProgressViewWithValue:0.0];
    [self.loadingIndicatorView setHidden:NO];
    
    //Abdu 10 March 15
    [self.customLoadingImageView startAnimating];
    if ([loadingTxt isEqualToString: ACTIVITY_LOADING_TEXT_MERGING ]) {
        self.mergeHintText.text = @"Please wait. This might take a few minutes depending on file size.";
        
        
    } else {
        self.mergeHintText.text = @" ";
    }
    [self.loadingIndicatorLabel setText:loadingTxt];
}

-(void)completedMinActivityTimer
{
     [self clearMinActivityTimer];
    if (hideRequestPendingCount > 0)
    {
        [self HideLoadingIndicatorView];
    }
   
}

-(void)completedMaxActivityTimer
{
    [self clearMaxActivityTimer];
    [self HideLoadingIndicatorView];
    
}

-(void) clearMinActivityTimer
{
    if (minActivityTimer)
    {
        if ([minActivityTimer isValid])
        {
            [minActivityTimer invalidate];
        }
        minActivityTimer= nil;
    }

}

-(void) clearMaxActivityTimer
{
    if (maxActivityTimer)
    {
        if ([maxActivityTimer isValid])
        {
            [maxActivityTimer invalidate];
        }
        maxActivityTimer = nil;
    }

}

-(void)resetTimers
{
    [self clearMinActivityTimer];
    [self clearMaxActivityTimer];
}


-(void) HideLoadingIndicatorView
{
    
    [self clearMaxActivityTimer];
    
    
    if (minActivityTimer)
    {
        if ([minActivityTimer isValid])
        {
            hideRequestPendingCount++;
            return;
        }
    }
    
    
    hideRequestPendingCount = 0;
    
    KMSDebugLog(@"currentViewController :%@",self.currentViewController);
    if (self.currentViewController)
    {
        
        [self.currentViewController.view setUserInteractionEnabled:YES];
        
        if ([self.loadingIndicatorView isDescendantOfView:self.currentViewController.view])
        {
            KMSDebugLog(@"loadingIndicatorView isDescendantOfView currentViewController");
        }
        else
        {
            KMSDebugLog(@"loadingIndicatorView NOT isDescendantOfView currentViewController");
        }
        [self.loadingIndicatorView removeFromSuperview];
        
        self.currentViewController = nil;
    }
    if (!self.loadingIndicatorView.isHidden)
    {
        [self.loadingIndicatorView setHidden:YES];
        
        //Abdu 10 March 15
        [self.customLoadingImageView stopAnimating];
        
        //[self.view setUserInteractionEnabled:YES];
    }
    
}

-(void) updateProgressViewWithValue:(float)progressValue
{
    [self.progressViewIndicator setProgress:progressValue animated:NO];
    [self.loadingIndicatorLabel setText:[NSString stringWithFormat:@"%@ %.2d%%",self.loadingViewTextString,(int)(progressValue *100)]];
}

@end
