//
//  RegionViewController.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 27/01/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "RegionViewController.h"
#import "Country.h"
#import <QuartzCore/QuartzCore.h>
#import "Language.h"
#import "WizardViewController.h"

@interface RegionViewController ()
{
    NSMutableArray *countryList;
    NSMutableArray *languageList;
    NSArray *sectionTitles;
    UITextField * currentlyEditingTextField;
    
}
@end

@implementation RegionViewController


static RegionViewController *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (RegionViewController *)sharedInstance
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
    
    [self initialiseListView];
    [self initialiseView];
    // Do any additional setup after loading the view.
}
- (void)initialiseView{
    
    [self registerKeyboardNotifications];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:kTEXTFIELD_PADDING_RECT];
    self.languageText.leftView = paddingView;
    self.languageText.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *padding  = [[UIView alloc] initWithFrame:kTEXTFIELD_PADDING_RECT];
    self.countryText.leftView = padding;
    self.countryText.leftViewMode = UITextFieldViewModeAlways;
    
    
    //self.titleText.font = kFONT_BOLD_SIZE_20;
    self.titleText.textColor = LIGHT_GREY;
    
    [self.titleText setFont:kFONT_ABEL_SIZE_30];
    [self.languageText setFont:kFONT_ROBOTO_SIZE_14];
    [self.countryText setFont:kFONT_ROBOTO_SIZE_14];

    
    countryList = [[NSMutableArray alloc]initWithArray:[DBHelper getCountryListInOrder]];
    languageList = [[NSMutableArray alloc]initWithArray:[DBHelper getLanguageList]];
    
    NSArray *topListedCountriesArray = [[NSArray alloc] initWithObjects:@"India",@"United States",@"United Kingdom",nil];
    [self setupTopListedCountries:topListedCountriesArray];
    [self.tableView reloadData];
    
    
}

- (void)initialiseListView{
    
    sectionTitles =  @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];


}

-(void)configureView
{
    [self hideCustomPopOver];
    WizardViewController *wizardVC = [WizardViewController sharedInstance];
    if ([wizardVC.currentProjectDict objectForKey:@"Country"]){
        self.countryText.text =[wizardVC.currentProjectDict objectForKey:@"Country"];
    }
    if ([wizardVC.currentProjectDict objectForKey:@"Language"]){
        self.languageText.text=[wizardVC.currentProjectDict objectForKey:@"Language"];
    }
    
    [self.languageMandatoryMarkerImageView setHidden:YES];
    [self.countryMandatoryMarkerImageView setHidden:YES];
    [self.nextButton setUserInteractionEnabled:YES];
    
}

-(void)hideAndStopViewActions
{
    [self.view endEditing:YES];
    [self hideCustomPopOver];
}
#pragma mark - Keyboard Notifications

- (void)registerKeyboardNotifications
{
    //to handle view according to keyboard movement
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardDidShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void)unregisterKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) keyboardWillHide:(NSNotification *)note
{
    [self adjusProfileViewFrame:NO];
}

-(void) keyboardWillShow:(NSNotification *)note
{
    [self adjusProfileViewFrame:YES];
}
- (void)adjusProfileViewFrame:(BOOL)isKeyBoardAppeared
{
    //adjusting view according to keyboard visibility
    
    if (isKeyBoardAppeared)
    {
        [self.regionScrollView setContentSize:CGSizeMake(self.regionScrollView.frame.size.width, 350)];
        
    }
    else
    {
        [self.regionScrollView setContentSize:CGSizeMake(self.regionScrollView.frame.size.width, 312)];
        
        
    }
    //    if ([currentlyEditingTextField isEqual:self.countryText]) {
    //        self.countryListView.frame = CGRectMake(self.countryText.frame.origin.x, self.countryText.frame.origin.y+40, self.countryText.frame.size.width, 250);
    //    }else{
    //        self.countryListView.frame = CGRectMake(self.countryText.frame.origin.x, self.languageText.frame.origin.y+40, self.countryText.frame.size.width, 250);
    //    }
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Detect touch anywhere
    UITouch *touch = [touches anyObject];
    
    // Get the specific point that was touched
    CGPoint point = [touch locationInView:self.view];
    NSLog(@"pointx: %f pointy:%f", point.x, point.y);
    
    // See if the point touched is within these rectangular bounds
    if (!CGRectContainsPoint(CGRectMake(98, 45, self.countryText.frame.size.width+15, 230), point))
    {
        [self hideCustomPopOver];
        
    }
}

#pragma mark -  Handle Custom Table

-(void)showCustomPopOver{
    [[WizardViewController sharedInstance] disableWizardBar];
     self.countryListView.hidden = NO;
    
}
- (void)hideCustomPopOver{
      [[WizardViewController sharedInstance] enableWizardBar];
     self.countryListView.hidden = YES;
}
#pragma mark -  Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextField Delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    currentlyEditingTextField = textField;
    
    [self showCustomPopOver];
    [self.tableView reloadData];
    //    if ([currentlyEditingTextField isEqual:self.countryText]) {
    //        self.countryListView.frame = CGRectMake(self.countryText.frame.origin.x, self.countryText.frame.origin.y+40, self.countryText.frame.size.width, 250);
    //    }else{
    //        self.countryListView.frame = CGRectMake(self.countryText.frame.origin.x, self.languageText.frame.origin.y+40, self.countryText.frame.size.width, 250);
    //    }
    // [textField resignFirstResponder];
    return NO;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   [self showCustomPopOver];
    //    if ([currentlyEditingTextField isEqual:self.countryText]) {
    //        self.countryListView.frame = CGRectMake(self.countryText.frame.origin.x, self.countryText.frame.origin.y+40, self.countryText.frame.size.width, 250);
    //    }else{
    //        self.countryListView.frame = CGRectMake(self.countryText.frame.origin.x, self.languageText.frame.origin.y+40, self.countryText.frame.size.width, 250);
    //    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self showCustomPopOver];
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    [self hideCustomPopOver];
    return YES;
}


#pragma mark - Search
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring
{
    if ([currentlyEditingTextField isEqual:self.countryText])
    {
     //   self.countryListView.frame = CGRectMake(24, 110 , 514, 100);
        if ([countryList count] >0)
        {
            [countryList removeAllObjects];
        }
        if (substring.length == 0)
        {
            countryList = [[NSMutableArray alloc]initWithArray:[DBHelper getCountryListInOrder]];
        }
        else
        {
            countryList =[[NSMutableArray alloc]initWithArray: [DBHelper getFilteredCountryList:substring]];
        }
        [self.tableView reloadData];
        
    }
    else if ([currentlyEditingTextField isEqual:self.languageText])
    {
      //  self.countryListView.frame = CGRectMake(24, 54 , 514, 100);
        if([languageList count]>0)
        {
            [languageList removeAllObjects];
        }
        if (substring.length == 0)
        {
            languageList = [[NSMutableArray alloc]initWithArray:[DBHelper getLanguageList]];
        }
        else
        {
            languageList =[[NSMutableArray alloc]initWithArray: [DBHelper getFilteredLanguageList:substring]];
        }
        [self.tableView reloadData];
    }
}
- (void)saveDataToPlist{
    WizardViewController *wizardVC = [WizardViewController sharedInstance];
    if (self.countryText.text.length >0) {
        
        [wizardVC.currentProjectDict setValue:self.countryText.text forKey:@"Country"];
        
    }
    if (self.languageText.text.length >0) {
        [wizardVC.currentProjectDict setValue:self.languageText.text forKey:@"Language"];
    }
    [wizardVC saveProjectData];
    
}


#pragma mark  - Button Actions

- (IBAction)onHomeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{}];
    
}

- (IBAction)onNextButtonClicked:(id)sender {
    
    // on appearing the datepicker for dismissing the keyboard
    [self.view endEditing:YES];
    
    [self saveDataToPlist];
    
    
    if ([self isMandatoryFieldsFilled])
    {
        [self.nextButton setUserInteractionEnabled:NO];
        [[WizardViewController sharedInstance] nextButtonPressed:nil];
    }
}

#pragma mark - Mandatory fields Checking

-(BOOL)isMandatoryFieldsFilled
{
    BOOL isCompleted = YES;
    
    if (![[WizardViewController sharedInstance] haveDataForKey:@"Language"])
    {
        [self.languageMandatoryMarkerImageView setHidden:NO];
        isCompleted = NO;
    }
    else
    {
        [self.languageMandatoryMarkerImageView setHidden:YES];
    }
    if (![[WizardViewController sharedInstance] haveDataForKey:@"Country"])
    {
        [self.countryMandatoryMarkerImageView setHidden:NO];
        isCompleted = NO;
    }
    else
    {
        [self.countryMandatoryMarkerImageView setHidden:YES];
    }
    
    
    return isCompleted;
    
}


#pragma mark- TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return sectionTitles;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
    
    if ([currentlyEditingTextField isEqual:self.countryText]) {
        NSString *selectedLetter = [sectionTitles objectAtIndex:index];
        int moveToIndex = 0;
        Country *countryObj = [DBHelper getCountryOfLetter:selectedLetter];
        if (countryObj) {
            moveToIndex = [countryList indexOfObject:countryObj];
            /*
             moveToIndex will have the location of the first occurence of the search letter.
             Get the indexPath from the location and call scrollToRowAtIndexPath to scroll to the cell with the
             text starting with the search letter.
             */
            NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:moveToIndex inSection:0];
            
            [self.tableView scrollToRowAtIndexPath:selectedPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }else{
            moveToIndex = 0;
        }
        
        
        
    }else if ([currentlyEditingTextField isEqual:self.languageText]) {
        NSString *selectedLetter = [sectionTitles objectAtIndex:index];
        int moveToIndex = 0;
        Language *langObj = [DBHelper getlanguageOfLetter:selectedLetter];
        if (langObj) {
            moveToIndex = [languageList indexOfObject:langObj];
            /*
             moveToIndex will have the location of the first occurence of the search letter.
             Get the indexPath from the location and call scrollToRowAtIndexPath to scroll to the cell with the
             text starting with the search letter.
             */
            NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:moveToIndex inSection:0];
            
            [self.tableView scrollToRowAtIndexPath:selectedPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }else{
            moveToIndex = 0;
        }
        
        
    }
    
    return [sectionTitles indexOfObject:title];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = 0;
    if ([currentlyEditingTextField isEqual:self.countryText]) {
        count = [countryList count];
    }else if ([currentlyEditingTextField isEqual:self.languageText]){
        count = [languageList count];
    }
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    if ([currentlyEditingTextField isEqual:self.countryText]) {
        Country *count= [countryList objectAtIndex:indexPath.row];
        
        cell.textLabel.text = count.countryName;
        if ([self.countryText.text isEqualToString:count.countryName]) {
            cell.accessoryType  = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }else if ([currentlyEditingTextField isEqual:self.languageText]){
        Language *languages = [languageList objectAtIndex:indexPath.row];
        cell.textLabel.text = languages.language;
        if ([self.languageText.text isEqualToString:languages.language]) {
            cell.accessoryType  = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    cell.textLabel.font = kFONT_ABEL_SIZE_18;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
    
}

#pragma mark- TableView delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([currentlyEditingTextField isEqual:self.countryText]) {
        Country *count= [countryList objectAtIndex:indexPath.row];
        self.countryText.text = count.countryName;
    }else if ([currentlyEditingTextField isEqual:self.languageText]){
      Language*  selectedLanguage = [languageList objectAtIndex:indexPath.row];
        self.languageText.text = selectedLanguage.language;
    }
    
    [self saveDataToPlist];
    [self hideCustomPopOver];
    //[[WizardViewController sharedInstance] disableWizardBar];
}



-(void)setupTopListedCountries:(NSArray*) topListedCountriesArray
{   
    for (int j = [topListedCountriesArray count] - 1; j>=0; j--)
    {
        for (int i=0; i < [countryList count]; i++)
        {
            Country *countryItem= [countryList objectAtIndex:i];
            if ([countryItem.countryName isEqualToString:[topListedCountriesArray objectAtIndex:j]])
            {

                Country *topCountry= [countryList objectAtIndex:i];
                [countryList removeObjectAtIndex:i];
                [countryList insertObject:topCountry atIndex:0];
                
            }
        }
        
    }
}

@end

