//
//  ChatMainViewController.m
//  common
//
//  Created by Ninan Thomas on 3/25/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import "ChatMainViewController.h"
#import "ChatsSharingDelegate.h"

@interface ChatMainViewController ()

@end

@implementation ChatMainViewController


@synthesize to;
@synthesize pChatOutputView;
@synthesize pChatInputView;
@synthesize bViewWithKeyBoard;
@synthesize notesHeight;
@synthesize defaultNotesHeight;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        defaultNotesHeight = 45.0;
        bViewWithKeyBoard = false;
        notesHeight = defaultNotesHeight;
        kbsize.height = 0.0;
        kbsize.width = 0.0;
        maxTextHeight = 0.0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadView
{
    [super loadView];
    [self setViewWithoutKeyBoard:notesHeight text:nil];
    [self registerForKeyboardNotifications];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    if ([ChatsSharingDelegate sharedInstance].bRedrawViewsOnPhotoDelete)
    {
        NSString *notesTxt = pChatInputView.notes.text;
        bViewWithKeyBoard = false;
        NSArray *pVws = [self.view subviews];
        for (NSUInteger i = 0; i < [pVws count]; ++i)
        {
            [[pVws objectAtIndex:i] removeFromSuperview];
        }
        NSLog(@"Show view with out keyboard textViewSize=,%f", notesHeight);
        [ChatsSharingDelegate sharedInstance].bRedrawViewsOnPhotoDelete = false;
        [self setViewWithoutKeyBoard:notesHeight text:notesTxt];
    }
}

-(void) setViewWithKeyBoard: (CGFloat) inputTextViewSize text:(NSString *) notesTxt
{
    
    bViewWithKeyBoard = true;
    CGRect tableRect;
    CGRect mainScrn= [[UIScreen mainScreen] bounds];
    double statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    tableRect = CGRectMake(0, mainScrn.origin.y + self.navigationController.navigationBar.frame.size.height+statusBarHeight, mainScrn.size.width, mainScrn.size.height - self.navigationController.navigationBar.frame.size.height-inputTextViewSize- kbsize.height-statusBarHeight);
    pChatOutputView = [ChatViewController1 alloc];
    pChatOutputView.to = to;
    UITableView *pTVw = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStyleGrouped];
      pChatOutputView.tableView = pTVw;
    pChatOutputView = [pChatOutputView initWithNibName:nil bundle:nil];
    
  
    [self.view addSubview:pChatOutputView.tableView];
    [pChatOutputView scrollToBottom];
    
    CGRect  inputViewRect;
    inputViewRect = CGRectMake(0, mainScrn.origin.y + mainScrn.size.height-inputTextViewSize-kbsize.height-statusBarHeight/2, mainScrn.size.width, inputTextViewSize+kbsize.height);
    pChatInputView = [ChatViewController2 alloc];
    pChatInputView.notesHeight = inputTextViewSize - 15;
    pChatInputView.bShowKeyBoard = true;
    if (notesTxt != nil)
    {
        pChatInputView.initialText = notesTxt;
    }
    pChatInputView.to = to;
    UITableView *pInputTblVw = [[UITableView alloc] initWithFrame:inputViewRect style:UITableViewStylePlain];
      pChatInputView.tableView = pInputTblVw;
    pChatInputView  = [pChatInputView initWithNibName:nil bundle:nil];
    
    [self.view addSubview:pChatInputView.tableView];
   
}



-(void) setViewWithoutKeyBoard: (CGFloat) inputTextViewSize text:(NSString *) notesTxt
{
    CGRect mainScrn= [[UIScreen mainScreen] bounds];
    
    CGRect tableRect;
    double statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    double chat1Height = mainScrn.size.height - self.navigationController.navigationBar.frame.size.height-inputTextViewSize-statusBarHeight;
    NSLog(@"statusBarHeight=%lf chat1Height=%lf", statusBarHeight, chat1Height);
    tableRect = CGRectMake(0, mainScrn.origin.y + self.navigationController.navigationBar.frame.size.height + statusBarHeight, mainScrn.size.width, chat1Height);
    pChatOutputView = [ChatViewController1 alloc];
     pChatOutputView.to = to;
    UITableView *pTVw = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    pChatOutputView.tableView = pTVw;
    pChatOutputView = [pChatOutputView initWithNibName:nil bundle:nil];
   
    [self.view addSubview:pChatOutputView.tableView];
    [pChatOutputView scrollToBottom];
    
    CGRect  inputViewRect;
    double y =mainScrn.origin.y + mainScrn.size.height-inputTextViewSize-statusBarHeight/2;
    NSLog(@"inputTextViewSize=%lf y=%lf", inputTextViewSize, y);
    inputViewRect = CGRectMake(0, y, mainScrn.size.width, inputTextViewSize);
    pChatInputView = [ChatViewController2 alloc];
    pChatInputView.bShowKeyBoard = false;
    pChatInputView.notesHeight = inputTextViewSize - 15;
    pChatInputView.initialText = notesTxt;
    UITableView *pInputTblVw = [[UITableView alloc] initWithFrame:inputViewRect style:UITableViewStylePlain];
    pChatInputView.tableView = pInputTblVw;
    pChatInputView  = [pChatInputView initWithNibName:nil bundle:nil];
    pChatInputView.to = to;
    
    [self.view addSubview:pChatInputView.tableView];
   
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

-(void) showViewWithoutKeyBoard
{
  if (!bViewWithKeyBoard)
  {
      return;
  }
    NSString *notesTxt = pChatInputView.notes.text;
    bViewWithKeyBoard = false;
    NSArray *pVws = [self.view subviews];
    for (NSUInteger i = 0; i < [pVws count]; ++i)
    {
        [[pVws objectAtIndex:i] removeFromSuperview];
    }
    NSLog(@"Show view with out keyboard textViewSize=,%f", notesHeight);
    [self setViewWithoutKeyBoard:notesHeight text:notesTxt];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"Keyboard was shown");
    if (bViewWithKeyBoard)
    {
        return;
    }
    NSString *notesTxt = pChatInputView.notes.text;
    NSArray *pVws = [self.view subviews];
    for (NSUInteger i = 0; i < [pVws count]; ++i)
    {
        [[pVws objectAtIndex:i] removeFromSuperview];
    }
    NSDictionary* info = [aNotification userInfo];
     kbsize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self setViewWithKeyBoard:notesHeight text:notesTxt];
}

-(void) computeMaxTxtHeight
{
    if (kbsize.height == 0.0)
    {
        NSLog(@"Invalid ChatMainViewController:computeMaxTxtHeight invocation keyboard size not yet set");
        return;
    }
    CGRect mainScrn= [[UIScreen mainScreen] bounds];
    maxTextHeight = mainScrn.size.height - 200 - kbsize.height;
}

-(void) redrawViews:(CGFloat)  inputTextViewHeight text:(NSString *) notesText
{
    if (kbsize.height == 0.0)
    {
        NSLog(@"Invalid ChatMainViewController:redrawViews invocation keyboard size not yet set");
        return;
    }
    if (maxTextHeight == 0.0)
    {
        [self computeMaxTxtHeight];
    }
    
    if (notesHeight == maxTextHeight)
    {
        return;
    }
    
    if (inputTextViewHeight > maxTextHeight)
    {
        notesHeight = maxTextHeight;
    }
    else
    {
        notesHeight = inputTextViewHeight;
    }
    NSArray *pVws = [self.view subviews];
    for (NSUInteger i = 0; i < [pVws count]; ++i)
    {
        [[pVws objectAtIndex:i] removeFromSuperview];
    }
    [self setViewWithKeyBoard:notesHeight text:notesText];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSLog(@"Keyboard was hidden");
}

-(void) gotMsgNow:(NSString *)msg
{
    NSLog (@"Setting tmpLabel to %@ and reloading data", msg);
    
    [self.pChatOutputView.tableView reloadData];
}

-(void) sendMsg
{
    NSLog(@"Sending message");
    ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
    [pShrDelegate sendMsg:to Msg:pChatInputView.notes.text];
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
