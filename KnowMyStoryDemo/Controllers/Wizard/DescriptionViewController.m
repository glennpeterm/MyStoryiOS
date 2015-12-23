//
//  DescriptionViewController.m
//  KnowMyStoryDemo
//
//  Created by Abdusha on 2/23/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "DescriptionViewController.h"
#import "WizardViewController.h"


#define kTabBarHeight 47

@interface DescriptionViewController ()
{
    BOOL keyboardIsShown;
    int movementDistanceWhileKeyboardAppear;
}

@end

@implementation DescriptionViewController
static DescriptionViewController *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (DescriptionViewController *)sharedInstance
{
    if (sharedInstance == nil)
    {
        //sharedInstance = [[WizardViewController alloc] init];
    }
    
    return sharedInstance;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
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
    }
    return self;
}

#pragma mark - View Life cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedInstance = self;
    // Do any additional setup after loading the view.
    
    [self InitialiseView];
}


-(void)InitialiseView
{

    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    keyboardIsShown = NO;
    movementDistanceWhileKeyboardAppear = 0;
    self.ContentScrollView.contentSize = self.ContentView.frame.size;
    
    UITapGestureRecognizer *tapForTitle = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(dismissKeyboard)];
    
    tapForTitle.cancelsTouchesInView = NO;
    [self.ContentView addGestureRecognizer:tapForTitle];
    
    
    [self.videoTagsTextField setDelegate:self];
    [self.videoDescriptionTextField setDelegate:self];
    
    [self.HeaderLabel setTextColor:LIGHT_GREY];
    [self.HeaderLabel setFont:kFONT_ABEL_SIZE_30];
    [self.videoTagsTextField setFont:kFONT_ROBOTO_SIZE_14];
    [self.videoDescriptionTextField setFont:kFONT_ROBOTO_SIZE_14];
    
    UIView *titleSpacerView = [[UIView alloc] initWithFrame:kTEXTFIELD_PADDING_RECT];
    [self.videoTagsTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.videoTagsTextField setLeftView:titleSpacerView];
    
    UIView *topicLeftSpacerView = [[UIView alloc] initWithFrame:kTEXTFIELD_PADDING_RECT];
    [self.videoDescriptionTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.videoDescriptionTextField setLeftView:topicLeftSpacerView];
    
    [self configureView];
}
-(void)configureView
{
    NSString *tagsString = [[WizardViewController sharedInstance].currentProjectDict objectForKey:@"Tags"];
    if (tagsString)
    {
        [self.videoTagsTextField setText:tagsString];
    }
    
    NSString *descString = [[WizardViewController sharedInstance].currentProjectDict objectForKey:@"Description"];
    if (descString)
    {
        [self.videoDescriptionTextField setText:descString];
    }
    
    [self.tagsMandatoryMarkerImageView setHidden:YES];
    [self.descriptionMandatoryMarkerImageView setHidden:YES];
    [self.nextButton setUserInteractionEnabled:YES];
}
-(void)hideAndStopViewActions
{
    [self.view endEditing:YES];
}
- (IBAction)nextButtonPressed:(id)sender
{
    [self updateFields];
    if ([self isMandatoryFieldsFilled])
    {
        [self.nextButton setUserInteractionEnabled:NO];
        [[WizardViewController sharedInstance] nextButtonPressed:nil];
    }
}

- (IBAction)homeButtonPressed:(id)sender
{
    [self hideAndStopViewActions];
    [self dismissViewControllerAnimated:NO completion:^{}];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.videoTagsTextField || textField == self.videoDescriptionTextField)
    {
        [self dismissKeyboard];
    }
    return YES;
}

-(void)dismissKeyboard
{
    [self.view endEditing:YES];
    [self updateFields];
}
-(void)updateFields
{
    
    [[WizardViewController sharedInstance].currentProjectDict setValue:[self.videoTagsTextField text] forKey:@"Tags"];
    [[WizardViewController sharedInstance].currentProjectDict setValue:[self.videoDescriptionTextField text] forKey:@"Description"];
    
    [[WizardViewController sharedInstance] saveProjectData];
}

- (void)keyboardWillHide:(NSNotification *)n
{
    
    if (keyboardIsShown)
    {
        
        //const int movementDistance = -30; // tweak as needed
        const float movementDuration = 0.3f; // tweak as needed
        
        int movement = movementDistanceWhileKeyboardAppear;
        [UIView beginAnimations: @"animateTextField" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        [UIView commitAnimations];
        
        keyboardIsShown = NO;
    }
    
}


- (void)keyboardWillShow:(NSNotification *)n
{
    if (keyboardIsShown) {
        return;
    }
    
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    const int offset = 10;
    float remainingViewArea = self.ContentView.frame.size.height - keyboardSize.height;

    CGRect textFiledFrame;
    if (self.videoTagsTextField.isFirstResponder)
    {
        textFiledFrame = self.videoTagsTextField.frame;
    }
    else if (self.videoDescriptionTextField.isFirstResponder)
    {
        textFiledFrame = self.videoDescriptionTextField.frame;
    }
    float textFieldY = textFiledFrame.origin.y + textFiledFrame.size.height;
    
    if (textFieldY >= remainingViewArea)
    {
        movementDistanceWhileKeyboardAppear = (textFieldY - remainingViewArea) + offset;
        //const int movementDistance = -30; // tweak as needed
        const float movementDuration = 0.3f; // tweak as needed
        
        int movement = -movementDistanceWhileKeyboardAppear;
        [UIView beginAnimations: @"animateTextField" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        [UIView commitAnimations];
        
        keyboardIsShown = YES;
    }
}

- (void)keyboardWasShown:(NSNotification *)notification {
    
    
    if (keyboardIsShown) {
        return;
    }
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    KMSDebugLog(@"#1 keyboardRect w:%f h:%f",keyboardSize.width,keyboardSize.height);
    // Abdu 08 April 15 - iOS 7 fix
    if (keyboardSize.width < keyboardSize.height)
    {
        keyboardSize = CGSizeMake(keyboardSize.height, keyboardSize.width);
    }
    KMSDebugLog(@"#2 keyboardRect w:%f h:%f",keyboardSize.width,keyboardSize.height);
    
    CGRect textFiledFrame;
    if (self.videoTagsTextField.isFirstResponder)
    {
        textFiledFrame = self.videoTagsTextField.frame;
    }
    else if (self.videoDescriptionTextField.isFirstResponder)
    {
        textFiledFrame = self.videoDescriptionTextField.frame;
    }
    
    CGPoint fieldOrigin = textFiledFrame.origin;
    CGFloat fieldHeight = textFiledFrame.size.height;
    fieldOrigin.y += (fieldHeight + 10);

    CGRect visibleRect = self.ContentView.frame;
    KMSDebugLog(@"self.ContentView :%@",self.ContentView);
    visibleRect.size.height -= keyboardSize.height;
    
    KMSDebugLog(@"fieldOrigin.y :%f visibleH : %f",fieldOrigin.y,visibleRect.size.height);
    
    if (visibleRect.size.height >= 0 && visibleRect.size.height < fieldOrigin.y)
    {
        if (!CGRectContainsPoint(visibleRect, fieldOrigin))
        {
            
            CGPoint scrollPoint = CGPointMake(0.0, fieldOrigin.y - visibleRect.size.height);
            
            [self.ContentScrollView setContentOffset:scrollPoint animated:YES];
            
            keyboardIsShown = YES;
            
        }
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    [self.ContentScrollView setContentOffset:CGPointZero animated:YES];
    keyboardIsShown = NO;
}


-(BOOL)isMandatoryFieldsFilled
{
    BOOL isCompleted = YES;
    
    if (![[WizardViewController sharedInstance] haveDataForKey:@"Tags"])
    {
        [self.tagsMandatoryMarkerImageView setHidden:NO];
        isCompleted = NO;
    }
    else
    {
        [self.tagsMandatoryMarkerImageView setHidden:YES];
    }
    if (![[WizardViewController sharedInstance] haveDataForKey:@"Description"])
    {
        [self.descriptionMandatoryMarkerImageView setHidden:NO];
        isCompleted = NO;
    }
    else
    {
        [self.descriptionMandatoryMarkerImageView setHidden:YES];
    }
    return isCompleted;
    
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

@end
