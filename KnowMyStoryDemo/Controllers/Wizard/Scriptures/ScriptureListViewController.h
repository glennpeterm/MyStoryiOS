//
//  ScriptureListViewController.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 05/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScriptureListViewController : UIViewController

#pragma mark Singleton Methods
+ (ScriptureListViewController *)sharedInstance;

@property (nonatomic, strong) NSArray *bibleBooks;
@property (nonatomic, strong) NSMutableArray *bibleChapters;
@property (nonatomic, strong) NSMutableArray *bibleVerse;
@property (nonatomic, strong) NSMutableArray *totalbibleVerse;

@property (weak, nonatomic) IBOutlet UIPickerView *bookNamesPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *chapterPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *versePicker;
@property (weak, nonatomic) IBOutlet UILabel *verseTitle;
@property (weak, nonatomic) IBOutlet UILabel *chapterTitle;
@property (weak, nonatomic) IBOutlet UILabel *bookTitle;
@property (weak, nonatomic) IBOutlet UIButton *findVersebtn;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UILabel *versesTitlelabel;
@property (weak, nonatomic) IBOutlet UITextView *versesTextlabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;


- (IBAction)onHomeButtonClicked:(id)sender;

- (IBAction)onFindAVerseBtnClicked:(id)sender;
- (IBAction)onSelectScriptureButtonClicked:(id)sender;


-(void)configureView;
-(void)hideAndStopViewActions;

@end
