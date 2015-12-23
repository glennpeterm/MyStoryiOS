//
//  OfflineScriptureListViewController.h
//  KnowMyStoryDemo
//
//  Created by Fingent on 11/02/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OfflineScriptureListViewController : UIViewController

{
    UIImageView *customLoadingImageView;
    UILabel *noScripturesFoundText;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *searchOnlineBtn;
@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *reachabiltySegment;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UILabel *versesTitlelabel;
@property (weak, nonatomic) IBOutlet UITextView *versesTextlabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)onReachabilitySegmentClicked:(id)sender;
- (IBAction)onSearchOnlineButtonClicked:(id)sender;
- (IBAction)onHomeButtonClicked:(id)sender;
- (IBAction)onDoneBtnClicked:(id)sender;
- (IBAction)onBackBtnClicked:(id)sender;
@end
