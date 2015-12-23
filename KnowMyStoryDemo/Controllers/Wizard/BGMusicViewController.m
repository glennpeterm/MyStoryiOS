//
//  BGMusicViewController.m
//  KnowMyStoryDemo
//
//  Created by Abdusha on 1/8/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "BGMusicViewController.h"
#import "WizardViewController.h"

@interface BGMusicViewController ()

@end

@implementation BGMusicViewController

static BGMusicViewController *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (BGMusicViewController *)sharedInstance
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
    // Do any additional setup after loading the view.
    sharedInstance = self;
    self.currentPlayingMusicIndex = -1;
    
    [self readBGMusicData];
    [self InitialiseView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopBackgroundMusic];
}

-(void)InitialiseView
{
    [self configureView];
}
-(void)configureView
{
    self.currentPlayingMusicIndex = -1;
    
    for (int i=0 ; i < [self.bgMusicArray count];i++)
    {
        NSString *selectedBgMusic =  [[WizardViewController sharedInstance].currentProjectDict objectForKey:@"BGMusicFileName"];
        NSString *currentCellBGMusic = [[self.bgMusicArray objectAtIndex:i] objectForKey:@"title"];
        if ([selectedBgMusic isEqualToString:currentCellBGMusic])
        {
            self.currentPlayingMusicIndex = i;
            break;
        }
    }
    [self.bgMusicListTable reloadData];
    if(self.currentPlayingMusicIndex >=0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentPlayingMusicIndex inSection:0];
        [self.bgMusicListTable selectRowAtIndexPath:indexPath
                                           animated:NO
                                     scrollPosition:UITableViewScrollPositionNone];
    }
    [self.nextButton setUserInteractionEnabled:YES];
}

-(void)hideAndStopViewActions
{
    [self stopBackgroundMusic];
}

-(void)stopBackgroundMusic
{
    if (self.backgroundMusicPlayer !=nil)
    {
        if ([self.backgroundMusicPlayer isPlaying])
        {
            [self.backgroundMusicPlayer stop];
        }
        self.backgroundMusicPlayer = nil;
        @try
        {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            NSError *audioSessionError;
            [audioSession setActive:NO error:&audioSessionError];
            KMSDebugLog(@"audioSession Deactivating - Error : %@",audioSessionError);
        }
        @catch (NSException *exception)
        {
            KMSDebugLog(@"audioSession Deactivating exception:%@", exception.reason);
        }
    }
    
}

-(void) readBGMusicData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TellMyStoryBGMusic" ofType:@"plist"]; //1
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath: path]) //2
    {
        self.bgMusicArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
    else
    {
        NSLog(@"File Not found : BG Music property list");
    }
}


#pragma mark - Tableview Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.bgMusicArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = nil;
    static NSString *cellIdentifier = @"BGMusicCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:cellIdentifier];
        
    }
    //Disable row selection highlight
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    UIImageView *speakerImage = (UIImageView *)[cell.contentView viewWithTag:1001];
    NSURL *fileURL = [[self.bgMusicArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    NSString *fileName = [fileURL lastPathComponent];
    
    UILabel *bgMusicNameLbl = (UILabel *)[cell.contentView viewWithTag:1002];
    [bgMusicNameLbl setText:[NSString stringWithFormat:@"%.2d. %@",(indexPath.row + 1),fileName]];
    [bgMusicNameLbl setTextAlignment:NSTextAlignmentLeft];
    [bgMusicNameLbl setFont:kFONT_ROBOTO_SIZE_18];
    
    if (self.currentPlayingMusicIndex == indexPath.row)
    {
        [bgMusicNameLbl setTextColor:ORANGE_COLOR];
        if ([self.backgroundMusicPlayer isPlaying])
        {
            [speakerImage setHighlighted:YES];
        }
        else
        {
            [speakerImage setHighlighted:NO];
        }
    }
    else
    {
        [bgMusicNameLbl setTextColor:LIGHT_GREY];
    }
    return cell;
    
}

#pragma mark - Tableview Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentPlayingMusicIndex == indexPath.row && [self.backgroundMusicPlayer isPlaying])
    {
        [self stopBackgroundMusic];
    }
    else
    {
        
        if (!(self.currentPlayingMusicIndex == indexPath.row))
            {
                self.currentPlayingMusicIndex = indexPath.row;
                NSString *selectedBGMusic = [[self.bgMusicArray objectAtIndex:indexPath.row] objectForKey:@"title"];
                [[WizardViewController sharedInstance].currentProjectDict setValue:selectedBGMusic forKey:@"BGMusicFileName"];
                [[WizardViewController sharedInstance].currentProjectDict setValue:[NSNumber numberWithBool:NO] forKey:@"isMerged"];
                [[WizardViewController sharedInstance] saveProjectData];
            }
        [self bgMusicListenButtonPressed:nil];
    }
    [self.bgMusicListTable reloadData];
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

#pragma mark - Button Press Methods

- (IBAction)nextButtonPressed:(id)sender
{
    NSString *selectedBgMusic =  [[[WizardViewController sharedInstance] currentProjectDict] objectForKey:@"BGMusicFileName"];
    if ([selectedBgMusic isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Background Music not selected" message:@"Please select a Background Music from the list"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [self.nextButton setUserInteractionEnabled:NO];
    [[WizardViewController sharedInstance] nextButtonPressed:nil];
}
- (IBAction)homeButtonPressed:(id)sender
{
    [self hideAndStopViewActions];
    [self dismissViewControllerAnimated:NO completion:^{}];
    
}
- (IBAction)bgMusicListenButtonPressed:(UIButton *)sender
{
    if (self.backgroundMusicPlayer !=nil)
    {
        if ([self.backgroundMusicPlayer isPlaying])
        {
            [self.backgroundMusicPlayer stop];
        }
        self.backgroundMusicPlayer = nil;
    }
    NSString *selectedBgMusic =  [[WizardViewController sharedInstance].currentProjectDict objectForKey:@"BGMusicFileName"];
    NSString *BgMusicFilePath  =[[NSBundle mainBundle]pathForResource:selectedBgMusic ofType:@"mp3"];
    if (BgMusicFilePath)
    {
        NSURL *BgMusicFilePathURL = [NSURL fileURLWithPath:BgMusicFilePath];
        NSError *bgMPError;
        self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:BgMusicFilePathURL error:&bgMPError];
        [self.backgroundMusicPlayer prepareToPlay];
    
        @try
        {
            NSError *audioSessionError;
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setActive:YES error:&audioSessionError];
            KMSDebugLog(@"audioSession Activating setActive Error : %@",audioSessionError);
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:&audioSessionError];
            KMSDebugLog(@"audioSession Activating setCategory Error : %@",audioSessionError);
        }
        @catch (NSException *exception)
        {
            KMSDebugLog(@"audioSession Activating exception:%@", exception.reason);
        }
        [self.backgroundMusicPlayer play];
    }
}
@end
