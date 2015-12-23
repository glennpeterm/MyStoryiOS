//
//  ScriptureListViewController.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 05/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "ScriptureListViewController.h"
#import "BibleBooks.h"
#import "BibleVerse.h"
#import "ScriptureSearchService.h"
#import "OfflineScriptureListViewController.h"
#import "WizardViewController.h"

@interface ScriptureListViewController ()
{
    BibleBooks *selectedBibleBook;
    BibleVerse *selectedBibleVerse;
    UIImageView *backgroundView;
    NSString *verseText;
    
    UIView *oldView;
    UIView *selectedView;
    NSDictionary *selectedBibleVerseDict;
}
@end

@implementation ScriptureListViewController
@synthesize bibleChapters,bibleBooks,bibleVerse,totalbibleVerse;

static ScriptureListViewController *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (ScriptureListViewController *)sharedInstance
{
    if (sharedInstance == nil)
    {
        //sharedInstance = [[ScriptureListViewController alloc] init];
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

    
#pragma mark - View [resultDict objectForKey:@"verse_text"]];
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedInstance = self;
    [self initialiseView];
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

#pragma mark - Initialisation
-(void)initialiseView
{
    
    self.bookTitle.font = kFONT_BOLD_SIZE_17;
    self.chapterTitle.font = kFONT_BOLD_SIZE_17;
    self.verseTitle.font = kFONT_BOLD_SIZE_17;
    self.findVersebtn.titleLabel.font = kFONT_BUTTON_SIZE_16;
    self.bibleBooks = [[DBHelper getBibleBookNames]mutableCopy];
    selectedBibleBook = [bibleBooks objectAtIndex:0];
    self.totalbibleVerse = [[DBHelper getBibleVerse] mutableCopy];
    self.bibleVerse = [[self.totalbibleVerse filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"chapter == %@ && book_order == %@", [NSString stringWithFormat:@"%d",1],selectedBibleBook.book_order]]mutableCopy];

    if ([self.bibleVerse count]>0)
    {
         selectedBibleVerse = [self.bibleVerse objectAtIndex:0];
    }
    
}

-(void)configureView
{
    
    [self onSelectScriptureAgainBtnClicked:nil];
    [self.bookNamesPicker selectRow:0 inComponent:0 animated:YES];
    [self.chapterPicker selectRow:0 inComponent:0 animated:YES];
    [self.versePicker selectRow:0 inComponent:0 animated:YES];
    [self performSelector:@selector(selectThePreviouslySelectedRow) withObject:nil afterDelay:1];
}

- (void)selectThePreviouslySelectedRow{
    [self highLightSelectedrowInPicker:self.bookNamesPicker forRow:[self.bookNamesPicker selectedRowInComponent:0]];
    [self highLightSelectedrowInPicker:self.chapterPicker forRow:[self.chapterPicker selectedRowInComponent:0]];
    if ([self.bibleVerse count]!=0)
    {
        [self highLightSelectedrowInPicker:self.versePicker forRow:[self.versePicker selectedRowInComponent:0]];
    }

}

- (void)hideAndStopViewActions{
    
}
#pragma mark - pickerview Delegates


- (void)highLightSelectedrowInPicker:(UIPickerView *)picker forRow:(int)rowNumber{
    selectedView = [picker viewForRow:rowNumber forComponent:0];
    UILabel *pickerLabel = (UILabel *)selectedView;
    pickerLabel.textColor = ORANGE_COLOR;
    UILabel *oldLabel = (UILabel *)oldView;
    oldLabel.textColor = LIGHT_GREY;
    self.nextButton.enabled = YES;


}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    [self performSelector:@selector(selectThePreviouslySelectedRow) withObject:nil afterDelay:1];


    selectedBibleBook = [bibleBooks objectAtIndex:[self.bookNamesPicker selectedRowInComponent:0]];
    NSString * selectedChapter ;
    if ([self.chapterPicker selectedRowInComponent:0] <=[selectedBibleBook.number_of_chapters intValue]) {
        selectedChapter = [NSString stringWithFormat:@"%d",[self.chapterPicker selectedRowInComponent:0]+1];
    }
    

    if ([pickerView isEqual:self.bookNamesPicker]) {
 
        
      if ([selectedBibleBook.number_of_chapters intValue] >0) {

          [self.chapterPicker reloadComponent:0];

          if ([self.chapterPicker selectedRowInComponent:0] <=[selectedBibleBook.number_of_chapters intValue]) {
             
            selectedChapter = [NSString stringWithFormat:@"%d",[self.chapterPicker selectedRowInComponent:0]+1];
          }else{
              selectedChapter = [NSString stringWithFormat:@"1"];
          }
      }
    }
    
     if (![pickerView isEqual:self.versePicker])
     {
       self.bibleVerse = [[self.totalbibleVerse filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"chapter == %@ && book_order == %@", selectedChapter,selectedBibleBook.book_order]] mutableCopy];
         
         if ([self.bibleVerse count] !=0)
         {
             [self.versePicker reloadAllComponents];
             if ([self.versePicker selectedRowInComponent:0] <=[self.bibleVerse count])
             {
                 selectedBibleVerse = [self.bibleVerse objectAtIndex:[self.versePicker selectedRowInComponent:0]];
             }
         }
     }
   if ([self.bibleVerse count] !=0)
   {
       if ([self.versePicker selectedRowInComponent:0] <=[self.bibleVerse count])
       {
           selectedBibleVerse = [self.bibleVerse objectAtIndex:[self.versePicker selectedRowInComponent:0]];
       }
   }
    
}

#pragma mark - PickerView Datasource
// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    NSInteger  rowCount =0;
    if ([pickerView isEqual:self.bookNamesPicker]) {
        rowCount =  [self.bibleBooks count];
    }
    if ([pickerView isEqual:self.chapterPicker]) {
        rowCount = [selectedBibleBook.number_of_chapters intValue];
    }
    if ([pickerView isEqual:self.versePicker]) {
        rowCount = [self.bibleVerse count];
    }
    return rowCount;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
     NSString *title = @"Book";
    
        return title;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row       forComponent:(NSInteger)component  reusingView:(UIView *)view {
    self.nextButton.enabled = NO;

    UILabel *pickerLabel = (UILabel *)view;
    
    if (pickerLabel == nil) {
        
        CGRect frame = CGRectMake(0.0, 0.0, pickerView.frame.size.width, 32);
        pickerLabel = [[UILabel alloc] initWithFrame:frame] ;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:kFONT_BOLD_SIZE_20];
        [pickerLabel setTextColor:LIGHT_GREY];
       
        BibleBooks *bookName ;
         if ([self.bibleBooks count] >row) {
        bookName = [self.bibleBooks objectAtIndex:row];
         }
        if ([pickerView isEqual:self.bookNamesPicker]) {
      
            pickerLabel.text = bookName.book_name;
            
        }
         if ([pickerView isEqual:self.chapterPicker]) {
             if ([selectedBibleBook.number_of_chapters intValue]>row){
                 pickerLabel.text = [NSString stringWithFormat:@"%d",row+1];
             }
         }
        if ([pickerView isEqual:self.versePicker]) {
            if ([self.bibleVerse count] !=0) {
                BibleVerse *verses = [self.bibleVerse objectAtIndex:row];
                pickerLabel.text = [NSString stringWithFormat:@"%d", [verses.verse intValue]];
            }
        }
    }
    oldView = pickerLabel;
    return pickerLabel;
    
}

#pragma mark - Button Actions
// on confirm scripture Btn clicked from custom alert
- (IBAction)onConfirmScriptureBtnClicked:(id)sender{
    
    [self saveScriptureDataToPlist];
    self.messageView.hidden = YES;
    [[WizardViewController sharedInstance] enableWizardBar];
    [[WizardViewController sharedInstance] showScreenWithId:kWizardViewCameraLanding];
}

// on choose gain button clicked from custom alert allow user to choose the scripture again
- (IBAction)onSelectScriptureAgainBtnClicked:(id)sender{
    
    [[WizardViewController sharedInstance] enableWizardBar];
    self.messageView.hidden = YES;

}

// on help me find a verse button clicked
- (IBAction)onHomeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{}];
}

- (IBAction)onFindAVerseBtnClicked:(id)sender {
    
}

// on get the verse button clicked
- (IBAction)onSelectScriptureButtonClicked:(id)sender {
    if ([Reachability connected]) {
        [self showOverlayView];
        [self startServiceForScriptureSelection];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: kALERT_TITLE
                                                            message: @"Sorry, No network available"
                                                           delegate: self
                                                  cancelButtonTitle: kALERT_OK_BUTTON
                                                  otherButtonTitles: nil];
        
        [alertView show];
    }
  
}
#pragma mark - AlertView

- (void)showCustomAlertWithScriptureText
{
    [[WizardViewController sharedInstance] disableWizardBar];
    self.messageView.hidden = NO;
    self.versesTitlelabel.text = [NSString stringWithFormat:@"%@ %@:%@", [selectedBibleVerseDict objectForKey:@"book_name"],[selectedBibleVerseDict objectForKey:@"chapter_id"],[selectedBibleVerseDict objectForKey:@"verse_id"]];
    self.versesTitlelabel.textColor = LIGHT_GREY;
    self.versesTitlelabel.font = kFONT_BOLD_SIZE_30;

    self.versesTextlabel.text =  [selectedBibleVerseDict objectForKey:@"verse_text"];
    self.versesTextlabel.editable = NO;
    verseText = [selectedBibleVerseDict objectForKey:@"verse_text"];
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
  
   
    
}

- (void)showAlertWithMessage:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: kALERT_TITLE
                                                        message: message
                                                       delegate: nil
                                              cancelButtonTitle: kALERT_OK_BUTTON
                                              otherButtonTitles: nil];
    
    [alertView show];
    
    
}

-(void)saveScriptureDataToPlist
{
    WizardViewController *wizardVC = [WizardViewController sharedInstance];
    NSMutableDictionary *scriptureDict = [[NSMutableDictionary alloc]init];
    [scriptureDict setValue:[selectedBibleVerseDict objectForKey:@"book_name"] forKey:@"bookName"];
    [scriptureDict setValue:[selectedBibleVerseDict objectForKey:@"book_order"] forKey:@"book_order"];
    [scriptureDict setValue:[selectedBibleVerseDict objectForKey:@"chapter_id"] forKey:@"chapter"];
    [scriptureDict setValue:[selectedBibleVerseDict objectForKey:@"verse_id"] forKey:@"verseNumber"];
    [scriptureDict setObject:[selectedBibleVerseDict objectForKey:@"book_id"] forKey:@"book_id"];
    [scriptureDict setValue:verseText forKey:@"verse"];
    [wizardVC.currentProjectDict setValue:scriptureDict forKey:@"Scripture"];
    [wizardVC saveProjectData];
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

#pragma mark - service calls

- (void)startServiceForScriptureSelection{
    selectedBibleBook = [self.bibleBooks objectAtIndex:[self.bookNamesPicker selectedRowInComponent:0]];
    selectedBibleVerse = [self.bibleVerse objectAtIndex:[self.versePicker selectedRowInComponent:0]];
    ScriptureSearchService *scriptureService = [[ScriptureSearchService alloc]init];
    [scriptureService initService:ServiceTypeScriptureSearch withBibleInfo:selectedBibleBook andVerseInfo:selectedBibleVerse target:self];
    [scriptureService start];
}

#pragma mark -  Service Class Delegate Methods
-(void)serviceSuccessful:(id)response
{
    [self removeOverlayView];
    if ([response isKindOfClass:[NSArray class]]) {
        NSArray *responseArr = (NSArray *)response;
        selectedBibleVerseDict = [responseArr objectAtIndex:0];
       
        [self showCustomAlertWithScriptureText];
       
    }
    
    KMSDebugLog(@"success");
}

-(void)serviceFailed:(id)response {
    
    [self removeOverlayView];
    if ([response isKindOfClass:[NSString class]]) {
        NSString *failureMessage = (NSString*)response;
        
        [self showAlertWithMessage:failureMessage];
    }else{
        [self showAlertWithMessage:NO_SERVER_RESPONSE];
    }
}
- (void)networkError{
    
    [self removeOverlayView];
    [self showAlertWithMessage:kSERVICE_NETWORK_NOT_AVAILABLE_MSG];
}


#pragma mark - Memory management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
