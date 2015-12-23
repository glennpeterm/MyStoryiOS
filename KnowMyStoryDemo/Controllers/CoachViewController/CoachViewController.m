//
//  CoachViewController.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 22/09/15.
//  Copyright © 2015 Fingent. All rights reserved.
//

#import "CoachViewController.h"
#import "PageContentViewController.h"

@interface CoachViewController ()

@end

@implementation CoachViewController
@synthesize coachImageListArray;
int nextIndex = 0;
int presentPage = 0;
int previousPage = 0;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.pageViewController.view.frame = self.view.frame;
    [self addChildViewController:_pageViewController];
    [self.view insertSubview:_pageViewController.view belowSubview:self.closeButton];
    
    //    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
    self.pageControl.numberOfPages = self.coachImageListArray.count;
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    [self.view insertSubview:self.pageControl belowSubview:self.closeButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.coachImageListArray count] == 0) || (index >= [self.coachImageListArray count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.coachImageListArray[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    NSLog(@"previous page PHASE 2 %lu",(unsigned long)index);
    previousPage = (int)index;
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    NSLog(@"count page %lu",(unsigned long)index);
    presentPage = (int)index;
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [self.coachImageListArray count]) {

        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
   
    NSUInteger index = ((PageContentViewController*) previousViewControllers[0]).pageIndex;
    //NSUInteger imageListCount = [self.coachImageListArray count];
    //if((index == imageListCount-2 && nextIndex == --imageListCount)){

    if((index == 10 && nextIndex == 11)){
    
        self.closeButton.hidden = NO;
    } else {
        self.closeButton.hidden = YES;

    }

}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    PageContentViewController *pageContentView = (PageContentViewController*) pendingViewControllers[0];
    self.pageControl.currentPage = pageContentView.pageIndex;
    nextIndex = pageContentView.pageIndex;
//    NSLog(@"next page %d",pageContentView.pageIndex);

}

- (void)removeView
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
}
- (IBAction)removeFromSuperView:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"exitCoachview" object: nil];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
