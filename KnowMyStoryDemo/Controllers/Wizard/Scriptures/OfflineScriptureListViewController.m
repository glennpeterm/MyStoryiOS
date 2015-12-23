//
//  OfflineScriptureListViewController.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 11/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "OfflineScriptureListViewController.h"
#import "OfflineBible.h"
#import "ScriptureSearchService.h"
#import "WizardViewController.h"

#define kCUSTOM_ROW_COUNT 10
@interface OfflineScriptureListViewController()
{
    NSMutableArray *offlineScriptures;
    OfflineBible *selectedOfflineVerse;
    NSDictionary *selectedbibledict;
    
    NSString *verseText;
    BOOL isOnlineResults;
    NSMutableArray *onlineVerses;
    NSInteger currentIndex;
}
@end
@implementation OfflineScriptureListViewController
//static OfflineScriptureListViewController *sharedInstance = nil;
//
//#pragma mark -
//#pragma mark Singleton Methods
//+ (OfflineScriptureListViewController *)sharedInstance
//{
//    if (sharedInstance == nil)
//    {
//        //sharedInstance = [[ScriptureListViewController alloc] init];
//    }
//    
//    return sharedInstance;
//}
//+ (id)allocWithZone:(NSZone *)zone {
//    @synchronized(self) {
//        if (sharedInstance == nil) {
//            sharedInstance = [super allocWithZone:zone];
//            return sharedInstance;  // assignment and return on first allocation
//        }
//    }
//    return nil; // on subsequent allocation attempts return nil
//}
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//        sharedInstance = self;
//    }
//    return self;
//}
//
- (void)viewDidLoad{
    [super viewDidLoad];
   // sharedInstance = self;
    [self initialiseView];
    
   
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

#pragma mark - Initialisation
-(void)initialiseView
{
    onlineVerses = [[NSMutableArray alloc]init];
    offlineScriptures = [[NSMutableArray alloc]initWithArray:[DBHelper getOfflineBible]];
    [self copyfromIndex:0];
    self.searchText.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.searchText.leftViewMode = UITextFieldViewModeAlways;
    self.searchText.font = kFONT_BOLD_SIZE_17;
    noScripturesFoundText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 31)];
    noScripturesFoundText.font = kFONT_ABEL_SIZE_18;
    noScripturesFoundText.text = @"No matching results found. Please try again.";
    noScripturesFoundText.textAlignment = NSTextAlignmentCenter;
    
    customLoadingImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 62, 63)];
    if (![customLoadingImageView.animationImages count])
    {
        
        
        NSMutableArray *loadingImagesArray = [[NSMutableArray alloc] initWithCapacity:ACTIVITY_LOADING_IMAGES_COUNT];
        for (int i = 1; i <= ACTIVITY_LOADING_IMAGES_COUNT; i++)
        {
            NSString *imageStr = [NSString stringWithFormat:@"%@%02d",ACTIVITY_LOADING_ORANGE_IMAGENAME_PREFIX,i];
            KMSDebugLog(@"imageStr : %@",imageStr);
            [loadingImagesArray addObject:[UIImage imageNamed:imageStr]];
        }
        [customLoadingImageView setAnimationImages:loadingImagesArray];
        [customLoadingImageView setAnimationDuration:1];
    }
    
    //Abdu 08 April 15
     self.reachabiltySegment.layer.cornerRadius = 0.0;
     self.reachabiltySegment.layer.borderColor = ORANGE_COLOR.CGColor;
     self.reachabiltySegment.layer.borderWidth = 2;
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    if (currentIndex<[offlineScriptures count]) {
          [self copyfromIndex:currentIndex];
    }
  
    [self.tableView reloadData];
}
-(void)configureView
{
    [self onSelectScriptureAgainBtnClicked:nil];
    WizardViewController *wizardVC = [WizardViewController sharedInstance];
    NSDictionary *scripture = [wizardVC.currentProjectDict objectForKey:@"Scripture"];
    selectedOfflineVerse.book_name = [scripture objectForKey:@"bookName"];
    selectedOfflineVerse.chapter= [scripture objectForKey:@"chapter"];
    selectedOfflineVerse.verse= [scripture objectForKey:@"verseNumber"];
    selectedOfflineVerse.verse_text= [scripture objectForKey:@"verse"];
    selectedOfflineVerse.uniqueId = [scripture objectForKey:@"book_order"];
    selectedOfflineVerse.bible_type = [scripture objectForKey:@"bibleType"];
}

#pragma mark - Textfield Delegates
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    if (!isOnlineResults)
    {
        [self.searchText resignFirstResponder];
        if (substring.length == 0) {
             [onlineVerses removeAllObjects];
            offlineScriptures = [[NSMutableArray alloc]initWithArray:[DBHelper getOfflineBible]];
        }else
        {
             [onlineVerses removeAllObjects];
            offlineScriptures =[[NSMutableArray alloc]initWithArray: [DBHelper getFilteredBibleVersesList:substring]];
        
        }
    }
    if ([offlineScriptures count]>0)
    {
         [self copyfromIndex:0];
    }
    [self.tableView reloadData];
}
-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    // to dismiss the keyboard
    [textField resignFirstResponder];
    [self onReachabilitySegmentClicked:nil];
    return YES;
}
#pragma mark- TableView Datasource
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (indexPath.row == [onlineVerses count] )
        {
            [self refresh:nil];
        }
   
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count =0;
   
    if ([onlineVerses count]==[offlineScriptures count]) {
        count = [onlineVerses count];
    }else{
        count = [onlineVerses count] +1;
    }
    if (count ==0) {
        count = 1;
    }
    
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure Cell
    UILabel *versesTitleText = (UILabel *)[cell.contentView viewWithTag:8];
    
    versesTitleText.font = kFONT_BOLD_SIZE_20;
    versesTitleText.textColor = LIGHT_GREY;
    
    UILabel *versesText = (UILabel *)[cell.contentView viewWithTag:9];
    
    versesText.lineBreakMode = NSLineBreakByWordWrapping;
    versesText.numberOfLines =0;
    
    versesText.font = kFONT_REGULAR_SIZE_16;
    versesText.textColor = LIGHT_GREY;
    
    UILabel *indexText = (UILabel *)[cell.contentView viewWithTag:6];
    
    indexText.font = kFONT_BOLD_SIZE_20;
    indexText.textColor = LIGHT_GREY;
    if ([onlineVerses count] == 0)
    {
        static NSString *loadMoreIdentifier = @"NoItemCell";
        cell = [tableView dequeueReusableCellWithIdentifier:loadMoreIdentifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:
                    UITableViewCellStyleDefault reuseIdentifier: loadMoreIdentifier];
        }
        [cell addSubview:noScripturesFoundText];
        noScripturesFoundText.center= CGPointMake(self.tableView.frame.size.width/2, self.tableView.frame.size.height/2);
        
    }
    
    else if (isOnlineResults)
    {
        if (indexPath.row == [onlineVerses count] )
        {
            static NSString *loadMoreIdentifier = @"LoadNextCell";
            
            cell = [tableView dequeueReusableCellWithIdentifier:loadMoreIdentifier];
            if (!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:
                        UITableViewCellStyleDefault reuseIdentifier: loadMoreIdentifier];
            }
                    [cell addSubview:customLoadingImageView];
                    customLoadingImageView.center = CGPointMake(self.tableView.frame.size.width/2, self.tableView.frame.size.height/5);
                    [customLoadingImageView startAnimating];
        }
        else
        {
           
            NSDictionary * dict = [onlineVerses objectAtIndex:indexPath.row];
            if ([dict isEqual:selectedbibledict])
            {
                versesTitleText.textColor = ORANGE_COLOR;
                indexText.textColor = ORANGE_COLOR;
                versesText.textColor = ORANGE_COLOR;
            }
            else
            {
                versesTitleText.textColor = LIGHT_GREY;
                versesText.textColor = LIGHT_GREY;
                indexText.textColor = LIGHT_GREY;
            }
            versesTitleText.text =[NSString stringWithFormat:@"%@ %@: %@", [dict objectForKey:@"book_name"],[dict objectForKey:@"chapter_id"],[dict objectForKey:@"verse_id"]];
            indexText.text = [NSString stringWithFormat:@"%02d.", indexPath.row +1];
            versesText.text = [dict objectForKey:@"verse_text"];
        }
    }
    else
    {
        if (indexPath.row == [onlineVerses count] )
        {
            static NSString *loadMoreIdentifier = @"LoadNextCell";
            cell = [tableView dequeueReusableCellWithIdentifier:loadMoreIdentifier];
            if (!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:
                        UITableViewCellStyleDefault reuseIdentifier: loadMoreIdentifier];
            }

            [cell addSubview:customLoadingImageView];
            customLoadingImageView.center = CGPointMake(self.tableView.frame.size.width/2, self.tableView.frame.size.height/5);
            [customLoadingImageView startAnimating];

        }
        else
        {
            OfflineBible *offlineVerse = [offlineScriptures objectAtIndex:indexPath.row];
            if ([offlineVerse isEqual:selectedOfflineVerse])
            {
                versesTitleText.textColor = ORANGE_COLOR;
                indexText.textColor = ORANGE_COLOR;
                versesText.textColor = ORANGE_COLOR;
            }
            else
            {
                versesTitleText.textColor = LIGHT_GREY;
                versesText.textColor = LIGHT_GREY;
                indexText.textColor = LIGHT_GREY;
            }
            versesTitleText.text =[NSString stringWithFormat:@"%@ %@: %@", offlineVerse.book_name,offlineVerse.chapter,offlineVerse.verse];
            indexText.text = [NSString stringWithFormat:@"%02d.", indexPath.row +1];
            versesText.text = offlineVerse.verse_text;
            
            // update from client
            
            //            if ([offlineVerse.bible_type isEqualToString:OLD_TESTAMENT]) {
            //                bookTypeImageView.image = [UIImage imageNamed:@"old_testimon"];
            //            }else{
            //                bookTypeImageView.image = [UIImage imageNamed:@"new_testimon"];
            //
            //            }
            //
            //            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            //            attachment.image = bookTypeImageView.image;
            //
            //            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            //
            //            NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@: %@   ", offlineVerse.book_name,offlineVerse.chapter,offlineVerse.verse]];
            //            [myString appendAttributedString:attachmentString];
            //
            //            versesTitleText.attributedText = myString;
            
            
        }
        
    }
    return cell;

}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(isOnlineResults)
    {
        if ([onlineVerses count] !=0 )
        {
          selectedbibledict = [onlineVerses objectAtIndex:indexPath.row];
        }
    }
    else
    {
         if ([offlineScriptures count]!=0)
         {
             selectedOfflineVerse = [offlineScriptures objectAtIndex:indexPath.row];
         }
    }
    [tableView reloadData];
}
#pragma mark - Button Actions
- (IBAction)onBackBtnClicked:(id)sender
{
    [self.view endEditing:YES];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)onReachabilitySegmentClicked:(id)sender
{
    if (self.reachabiltySegment.selectedSegmentIndex == 0)
    {
        if (self.searchText.text.length >0)
        {
            isOnlineResults = YES;
            [self.view endEditing:YES];
            [self startServiceForScriptureSelection];
        }
        else
        {
            [self showAlertWithMessage:@"Please enter valid keyword for searching online"];
        }
    }
    else
    {
        isOnlineResults = NO;
        [self searchAutocompleteEntriesWithSubstring:self.searchText.text];
    }
    
}

- (IBAction)onSearchOnlineButtonClicked:(id)sender
{
    if (self.searchText.text.length >0)
    {
        [self.searchText resignFirstResponder];
        isOnlineResults = YES;
        [self startServiceForScriptureSelection];
    }
    else
    {
        [self showAlertWithMessage:@"Please enter valid keyword for searching online"];
    }
  
}

- (IBAction)onHomeButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)onDoneBtnClicked:(id)sender
{
    if (isOnlineResults)
    {
        if ( [selectedbibledict objectForKey:@"verse_text"])
        {
             [self showCustomAlertWithScriptureText];
        }
        else
        {
              [self showAlertWithMessage:@"Please Select a verse"];
        }
    }
    else
    {
        if (selectedOfflineVerse.verse_text.length==0)
        {
            [self showAlertWithMessage:@"Please Select a verse"];
        }
        else
        {
            [self showCustomAlertWithScriptureText];
        }
    }
  
    
}
-(void)saveScriptureDataToPlist
{
    WizardViewController *wizardVC = [WizardViewController sharedInstance];
    NSMutableDictionary *scriptureDict = [[NSMutableDictionary alloc]init];
     if(isOnlineResults)
     {
         [scriptureDict setValue:[selectedbibledict objectForKey:@"book_name"] forKey:@"bookName"];
         [scriptureDict setValue:[selectedbibledict objectForKey:@"book_order"] forKey:@"book_order"];
         [scriptureDict setValue:[selectedbibledict objectForKey:@"chapter_id"] forKey:@"chapter"];
         [scriptureDict setValue:[selectedbibledict objectForKey:@"verse_id"] forKey:@"verseNumber"];
         [scriptureDict setValue:[selectedbibledict objectForKey:@"verse_text"] forKey:@"verse"];
         [scriptureDict setObject:[selectedbibledict objectForKey:@"book_id"] forKey:@"book_id"];
         
         [wizardVC.currentProjectDict setValue:scriptureDict forKey:@"Scripture"];
     }
     else
     {
         [scriptureDict setValue:selectedOfflineVerse.book_name forKey:@"bookName"];
         [scriptureDict setValue:selectedOfflineVerse.uniqueId forKey:@"book_order"];
         [scriptureDict setValue:selectedOfflineVerse.chapter forKey:@"chapter"];
         [scriptureDict setValue:selectedOfflineVerse.verse forKey:@"verseNumber"];
         [scriptureDict setValue:selectedOfflineVerse.verse_text forKey:@"verse"];
         [wizardVC.currentProjectDict setValue:scriptureDict forKey:@"Scripture"];
     }
    [wizardVC saveProjectData];
}

// on confirm scripture Btn clicked from custom alert
- (IBAction)onConfirmScriptureBtnClicked:(id)sender
{
    [self saveScriptureDataToPlist];
    [[WizardViewController sharedInstance] enableWizardBar];
     self.messageView.hidden = YES;
    [self onBackBtnClicked:nil];
     [[WizardViewController sharedInstance] showScreenWithId:kWizardViewCameraLanding];
}

// on choose gain button clicked from custom alert allow user to choose the scripture again
- (IBAction)onSelectScriptureAgainBtnClicked:(id)sender
{
    
    [[WizardViewController sharedInstance] enableWizardBar];
   self.messageView.hidden = YES;
}
#pragma mark - Alert
- (void)showAlertWithMessage:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: kALERT_TITLE
                                                        message: message
                                                       delegate: nil
                                              cancelButtonTitle: kALERT_OK_BUTTON
                                              otherButtonTitles: nil];
    
    [alertView show];
    
    
}

- (void)showCustomAlertWithScriptureText
{
    
    [[WizardViewController sharedInstance] disableWizardBar];
    self.messageView.hidden = NO;
    self.versesTitlelabel.textColor = LIGHT_GREY;
    self.versesTitlelabel.font = kFONT_BOLD_SIZE_30;
    
    self.versesTextlabel.editable = NO;
    [self.versesTextlabel performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:0.1];
    [self.versesTextlabel flashScrollIndicators];
    self.versesTextlabel.font = kFONT_BOLD_SIZE_22;
    self.versesTextlabel.textColor = LIGHT_GREY;
    
    self.confirmButton.backgroundColor = ORANGE_COLOR;
    [self.confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
    self.confirmButton.titleLabel.font =kFONT_BUTTON_SIZE_15;
    self.confirmButton.titleLabel.textColor = [UIColor whiteColor];
    [self.confirmButton addTarget:self action:@selector(onConfirmScriptureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.cancelButton.backgroundColor = [UIColor blackColor];
    [self.cancelButton setTitle:@"Choose Again" forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font =kFONT_BUTTON_SIZE_15;
    [self.cancelButton addTarget:self action:@selector(onSelectScriptureAgainBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.titleLabel.textColor = [UIColor whiteColor];
    self.cancelButton.frame = CGRectMake(25, 170, 200, 45);
    
    if (isOnlineResults)
    {
        self.versesTitlelabel.text = [NSString stringWithFormat:@"%@ %@:%@", [selectedbibledict objectForKey:@"book_name"],[selectedbibledict objectForKey:@"chapter_id"],[selectedbibledict objectForKey:@"verse_id"]];
        self.versesTextlabel.text = [selectedbibledict objectForKey:@"verse_text"];
    }
    else
    {
        self.versesTitlelabel.text = [NSString stringWithFormat:@"%@ %@:%@", selectedOfflineVerse.book_name,selectedOfflineVerse.chapter,selectedOfflineVerse.verse];
        self.versesTextlabel.text = selectedOfflineVerse.verse_text;
    }
}


#pragma mark  -  Overlay View Management

- (void)showOverlayView
{
    
    [[ActivityLoadingViewController sharedInstance] ShowLoadingIndicatorViewWithText:ACTIVITY_LOADING_TEXT_LOADING showProgress:NO onController:[WizardViewController sharedInstance]];
}

- (void)removeOverlayView
{
    
    [[ActivityLoadingViewController sharedInstance] HideLoadingIndicatorView];
}

#pragma mark  -

- (void)copyfromIndex:(int)fromIndex
{
    if (!onlineVerses)
    {
        onlineVerses = [[NSMutableArray alloc]init];
    }
    for (int i =fromIndex; i<fromIndex+kCUSTOM_ROW_COUNT; i++)
    {
        if ([offlineScriptures count]>i)
        {
            [onlineVerses addObject:[offlineScriptures objectAtIndex:i]];

        }
        
    }
    currentIndex = fromIndex+kCUSTOM_ROW_COUNT;
    KMSDebugLog(@"online %@", onlineVerses);
}
#pragma mark - service calls

- (void)startServiceForScriptureSelection
{
    [self showOverlayView];
    [onlineVerses removeAllObjects];
    offlineScriptures = nil;
    NSString *searchString  = [self.searchText.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    ScriptureSearchService *scriptureService = [[ScriptureSearchService alloc]init];
    [scriptureService initService:ServiceTypeScriptureForKeyword withSearchText:searchString target:self];
    [scriptureService start];
}

#pragma mark -  Service Class Delegate Methods
-(void)serviceSuccessful:(id)response
{
    [self removeOverlayView];
    if ([response isKindOfClass:[NSArray class]])
    {
        NSArray *responseArr = (NSArray *)response;
        isOnlineResults =YES;
        offlineScriptures = [responseArr objectAtIndex:1];
        
        KMSDebugLog(@"%@", offlineScriptures);
        [self copyfromIndex:0];
        [self.tableView reloadData];
     
    }
    
    KMSDebugLog(@"success");
}

-(void)serviceFailed:(id)response
{
    
    [self removeOverlayView];
    if ([response isKindOfClass:[NSString class]])
    {
        NSString *failureMessage = (NSString*)response;
        isOnlineResults = NO;
        [self showAlertWithMessage:failureMessage];
    }
    else
    {
        [self showAlertWithMessage:NO_SERVER_RESPONSE];
    }
}
- (void)networkError
{
    
    [self removeOverlayView];
    isOnlineResults = NO;
    [self showAlertWithMessage:kSERVICE_NETWORK_NOT_AVAILABLE_MSG];
}

@end
