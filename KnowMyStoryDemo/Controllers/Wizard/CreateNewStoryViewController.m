//
//  CreateNewStoryViewController.m
//  KnowMyStoryDemo
//
//  Created by Abdusha on 1/8/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "CreateNewStoryViewController.h"
#import "WizardViewController.h"
#import "TopicService.h"
#import "GAIDictionaryBuilder.h"
@interface CreateNewStoryViewController ()
{
    BOOL keyboardIsShown;
}

@end

@implementation CreateNewStoryViewController

static CreateNewStoryViewController *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (CreateNewStoryViewController *)sharedInstance
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    sharedInstance = self;
    
    
    
    [self InitialiseView];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

-(void)InitialiseView
{
    selectedTopicsArray = nil;
    topicListArray = [[NSMutableArray alloc] init];
    
    
    UITapGestureRecognizer *tapForTitle = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(dismissKeyboard)];
    
    keyboardIsShown  = NO;
    tapForTitle.cancelsTouchesInView = NO;
    [self.BaseView addGestureRecognizer:tapForTitle];
    
    [self registerKeyboardNotifications];
    self.ContentScrollView.contentSize = self.ContentView.frame.size;

    [self.topicTextField setDelegate:self];
    
    [self.HeadingLabel setTextColor:LIGHT_GREY];
    [self.HeadingLabel setFont:kFONT_ABEL_SIZE_30];
    [self.titleTextField setFont:kFONT_ROBOTO_SIZE_14];
    [self.topicTextField setFont:kFONT_ROBOTO_SIZE_14];

    UIView *titleSpacerView = [[UIView alloc] initWithFrame:kTEXTFIELD_PADDING_RECT];
    [self.titleTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.titleTextField setLeftView:titleSpacerView];
    
    UIView *topicLeftSpacerView = [[UIView alloc] initWithFrame:kTEXTFIELD_PADDING_RECT];
    [self.topicTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.topicTextField setLeftView:topicLeftSpacerView];
    
    UIView *topicRightSpacerView = [[UIView alloc] initWithFrame:kTEXTFIELD_ARROW_PADDING_RECT];
    [self.topicTextField setRightViewMode:UITextFieldViewModeAlways];
    [self.topicTextField setRightView:topicRightSpacerView];
    
    [self.topicTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self configureView];
}
-(void)configureView
{
    if (selectedTopicsArray)
    {
        selectedTopicsArray = nil;
    }
    
    [self.titleMandatoryMarkerImageView setHidden:YES];
    [self.topicMandatoryMarkerImageView setHidden:YES];
    selectedTopicsArray = [[NSMutableArray alloc] initWithArray:[[WizardViewController sharedInstance].currentProjectDict objectForKey:@"Topics"]];
    [self updateTopics];
    
    NSString *titleString = [[WizardViewController sharedInstance].currentProjectDict objectForKey:@"Title"];
    if (titleString)
    {
        [self.titleTextField setText:titleString];
    }
    [self hideTopicList];
    [self.nextButton setUserInteractionEnabled:YES];
}

-(void)hideAndStopViewActions
{
    [self.view endEditing:YES];
    [self hideTopicList];
}

#pragma mark - Button Press Methods

- (IBAction)nextButtonPressed:(id)sender
{
    [self sendAnalytics];
    if ([self isMandatoryFieldsFilled])
    {
        [self.nextButton setUserInteractionEnabled:NO];
        [[WizardViewController sharedInstance] nextButtonPressed:nil];
    }
    
}

-(void) sendAnalytics {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Tell Your Story-Start Recording Video"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Telling Your Story"
                                                          action:@"Start Recording Video"
                                                           label:@"User starts recording a selfie video"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
    
}

- (IBAction)homeButtonPressed:(id)sender
{
    [self hideAndStopViewActions];
    [self dismissViewControllerAnimated:NO completion:^{}];
    
}

#pragma mark - TopicList Methods

- (IBAction)topicTouched:(id)sender
{
    if (self.topicPopupView.isHidden)
    {
        [self startServiceForTopicList];
    }
    else
    {
        [self hideTopicList];
    }
}

-(void)showTopicList
{
    if (topicListArray && ([topicListArray count] > 0))
    {
        [self.topicTableView reloadData];
        [self.topicPopupView setHidden:NO];
        [[WizardViewController sharedInstance] disableWizardBar];
    }
    
}
-(void)hideTopicList
{
    [self.topicPopupView setHidden:YES];
    [[WizardViewController sharedInstance] enableWizardBar];
}

#pragma mark - TextField Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.titleTextField)
    {
        [self updateTitle];
    }
    [self.view endEditing:YES];
    return YES;
}

-(void)dismissKeyboard
{
    [self.view endEditing:YES];
    [self updateTitle];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.topicPopupView isHidden])
    {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint touchLocation = [touch locationInView:self.topicPopupView];
        if (!(CGRectContainsPoint(self.topicTableView.frame, touchLocation) == YES))
        {
            [self hideTopicList];
        }
    }
    
}

#pragma mark - Tableview Datasource
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [topicListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = nil;
    static NSString *cellIdentifier = @"cellIdentify";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:cellIdentifier];
    }
    //Disable row selection highlight
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSDictionary *topicDict = [topicListArray objectAtIndex:indexPath.row];
    NSString *topicID = [topicDict objectForKey:@"id"];
    NSString *topicName = [topicDict objectForKey:@"name"];
    
    //Topic label
    UILabel *topicLbl = (UILabel *)[cell.contentView viewWithTag:1001];
    [topicLbl setText:topicName];
    [topicLbl setFont:kFONT_ROBOTO_SIZE_14];
    
    //Check button
    UIButton *checkBtn = (UIButton *)[cell.contentView viewWithTag:1002];
    [checkBtn setSelected:NO];
    
    for (NSDictionary *existingTopicDict in selectedTopicsArray)
    {
        NSString *existingTopicID = [existingTopicDict objectForKey:@"id"];
        //Check whether the topic is in selection
        if ([existingTopicID isEqualToString:topicID])
        {
            //Enabel check mark on row
            [checkBtn setSelected:YES];
            break;
        }
    }
    return cell;
    
}

#pragma mark - Tableview Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *checkBtn = (UIButton *)[cell.contentView viewWithTag:1002];
   
    NSDictionary *topicDict = [topicListArray objectAtIndex:indexPath.row];
    NSString *selectedTopicID = [topicDict objectForKey:@"id"];
    
    KMSDebugLog(@"didSelectRowAtIndexPath selectedTopicID :%@ ",selectedTopicID);
    NSDictionary *currentDict = nil;
    for (NSDictionary *existingTopicDict in selectedTopicsArray)
    {
        NSString *existingTopicID = [existingTopicDict objectForKey:@"id"];
        KMSDebugLog(@"didSelectRowAtIndexPath existingTopicID :%@ ",existingTopicID);
        //Check whether the topic is in selection
        if ([existingTopicID isEqualToString:selectedTopicID])
        {
            //Enabel check mark on row
            currentDict = existingTopicDict;
            break;
        }
    }
    
    KMSDebugLog(@"currentDict :%@",currentDict);
    if (currentDict)
    {
        KMSDebugLog(@"Removing topic from selection array");
        [selectedTopicsArray removeObject:currentDict];
         [checkBtn setSelected:NO];
    }
    else
    {
        KMSDebugLog(@"Adding topic to selection array");
        [selectedTopicsArray addObject:topicDict];
         [checkBtn setSelected:YES];
    }
    [self updateTopics];
}

-(void) updateTopics
{
    KMSDebugLog(@"updateTopics selectedTopicsArray count :%d",[selectedTopicsArray count]);
    if (selectedTopicsArray && [selectedTopicsArray count] > 0)
    {
        NSMutableArray *selectedTopicNamesArray =[[NSMutableArray alloc] init];
        for (NSDictionary *existingTopicDict in selectedTopicsArray)
        {
            //add the topic is to selected list
            NSString *topicName = [existingTopicDict objectForKey:@"name"];
            [selectedTopicNamesArray addObject:topicName];
        }

        NSString *topicNamesString = [selectedTopicNamesArray componentsJoinedByString:@", "];
        [self.topicTextField setText:topicNamesString];
    }
    else
    {
        [self.topicTextField setText:@""];
    }
    [[WizardViewController sharedInstance].currentProjectDict setValue:selectedTopicsArray forKey:@"Topics"];
    [[WizardViewController sharedInstance] saveProjectData];
    
}

-(void) updateTitle
{
    
    NSString *titleStr = [self.titleTextField text];
    titleStr = [titleStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [[WizardViewController sharedInstance].currentProjectDict setValue:[self.titleTextField text] forKey:@"Title"];
    [[WizardViewController sharedInstance] saveProjectData];

}


#pragma mark  - SERVICE CALLS
- (void)startServiceForTopicList
{

    [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:ACTIVITY_LOADING_TEXT_LOADING showProgress:NO onController:[WizardViewController sharedInstance]];
    ServiceType serviceTypeRequest = ServiceTypeTopicList;
    TopicService *topicService = [[TopicService alloc]init];
    [topicService initServiceForTopic:serviceTypeRequest target:self];
    [topicService start];
}

#pragma mark - Service calls and Delegates

- (void)serviceSuccessful:(id)response
{
    
    if ([response isKindOfClass:[NSMutableArray class]])
    {
        
        if ([topicListArray count] > 0)
        {
            [topicListArray removeAllObjects];
        }
        
        [topicListArray addObjectsFromArray:response];
        [self showTopicList];
    }

    [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];
}
- (void)serviceFailed:(id)response
{

    [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];
    
    if ([response isKindOfClass:[NSString class]])
    {
        NSString *failureMsg = (NSString *)response;
        [self showAlertWithMessage:failureMsg];
        
    }else{
        [self showAlertWithMessage:NO_SERVER_RESPONSE];
        
    }
    
}
-(void)networkError
{

    [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];
    [self showAlertWithMessage:kSERVICE_NETWORK_NOT_AVAILABLE_MSG];
}

- (void)showAlertWithMessage:(NSString *)message
{
    
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:kALERT_TITLE
                                                  message:message delegate:self
                                        cancelButtonTitle:kALERT_OK_BUTTON
                                        otherButtonTitles: nil];
    [alert show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard Notifications

- (void)registerKeyboardNotifications
{
    //to handle view according to keyboard movement
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWasShown:)
     name:UIKeyboardDidShowNotification
     object:self.view.window];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillBeHidden:)
     name:UIKeyboardWillHideNotification
     object:self.view.window];
}

- (void)unregisterKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    
    
    if (keyboardIsShown) {
        return;
    }
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    // Abdu 01 April 15 - iOS 7 fix
    if (keyboardSize.width < keyboardSize.height)
    {
        keyboardSize = CGSizeMake(keyboardSize.height, keyboardSize.width);
    }
    CGRect textFiledFrame;
    if (self.titleTextField.isFirstResponder)
    {
        textFiledFrame = self.titleTextField.frame;
    }
    else if (self.topicTextField.isFirstResponder)
    {
        textFiledFrame = self.topicTextField.frame;
    }

    CGPoint fieldOrigin = textFiledFrame.origin;
    CGFloat fieldHeight = textFiledFrame.size.height;
    fieldOrigin.y += (fieldHeight + 10);
    CGRect visibleRect = self.ContentView.frame;
    visibleRect.size.height -= keyboardSize.height;

    
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
    
    if (![[WizardViewController sharedInstance] haveDataForKey:@"Title"])
    {
        [self.titleMandatoryMarkerImageView setHidden:NO];
        isCompleted = NO;
    }
    else
    {
        [self.titleMandatoryMarkerImageView setHidden:YES];
    }
    if ([[WizardViewController sharedInstance] wizardForcedSelectionIndex] > WizardStepUndefined && ![[WizardViewController sharedInstance] haveDataForKey:@"Topics"])
    {
        [self.topicMandatoryMarkerImageView setHidden:NO];
        isCompleted = NO;
    }
    else
    {
        [self.topicMandatoryMarkerImageView setHidden:YES];
    }
    
    
    return isCompleted;
    
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
