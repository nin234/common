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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        bViewWithKeyBoard = false;
        
        
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
    [self setViewWithoutKeyBoard];
    [self registerForKeyboardNotifications];
    
}

-(void) setViewWithKeyBoard: (CGSize) kbsize
{
    bViewWithKeyBoard = true;
    CGRect tableRect;
    CGRect mainScrn= [[UIScreen mainScreen] bounds];
    tableRect = CGRectMake(0, mainScrn.origin.y + self.navigationController.navigationBar.frame.size.height, mainScrn.size.width, mainScrn.size.height - self.navigationController.navigationBar.frame.size.height-150- kbsize.height);
    pChatOutputView = [ChatViewController1 alloc];
    pChatOutputView = [pChatOutputView initWithNibName:nil bundle:nil];
    UITableView *pTVw = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    pChatOutputView.tableView = pTVw;
    [self.view addSubview:pChatOutputView.tableView];
    
    CGRect  inputViewRect;
    inputViewRect = CGRectMake(0, mainScrn.origin.y + mainScrn.size.height-150-kbsize.height, mainScrn.size.width, 150+kbsize.height);
    pChatInputView = [ChatViewController2 alloc];
    pChatInputView.bShowKeyBoard = true;
    pChatInputView  = [pChatInputView initWithNibName:nil bundle:nil];
    UITableView *pInputTblVw = [[UITableView alloc] initWithFrame:inputViewRect style:UITableViewStylePlain];
    pChatInputView.tableView = pInputTblVw;
    [self.view addSubview:pChatInputView.tableView];
   
}

-(void) setViewWithoutKeyBoard
{
    CGRect mainScrn= [[UIScreen mainScreen] bounds];
    
    CGRect tableRect;
    
    tableRect = CGRectMake(0, mainScrn.origin.y + self.navigationController.navigationBar.frame.size.height, mainScrn.size.width, mainScrn.size.height - self.navigationController.navigationBar.frame.size.height-150);
    pChatOutputView = [ChatViewController1 alloc];
    pChatOutputView = [pChatOutputView initWithNibName:nil bundle:nil];
    UITableView *pTVw = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    pChatOutputView.tableView = pTVw;
    [self.view addSubview:pChatOutputView.tableView];
    
    CGRect  inputViewRect;
    inputViewRect = CGRectMake(0, mainScrn.origin.y + mainScrn.size.height-150, mainScrn.size.width, 150);
    pChatInputView = [ChatViewController2 alloc];
    pChatInputView.bShowKeyBoard = false;
    pChatInputView  = [pChatInputView initWithNibName:nil bundle:nil];
    UITableView *pInputTblVw = [[UITableView alloc] initWithFrame:inputViewRect style:UITableViewStylePlain];
    pChatInputView.tableView = pInputTblVw;
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
    bViewWithKeyBoard = false;
    NSArray *pVws = [self.view subviews];
    for (NSUInteger i = 0; i < [pVws count]; ++i)
    {
        [[pVws objectAtIndex:i] removeFromSuperview];
    }
    [self setViewWithoutKeyBoard];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"Keyboard was shown");
    if (bViewWithKeyBoard)
    {
        return;
    }
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSArray *pVws = [self.view subviews];
    for (NSUInteger i = 0; i < [pVws count]; ++i)
    {
        [[pVws objectAtIndex:i] removeFromSuperview];
    }
    [self setViewWithKeyBoard:kbSize];
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
