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

@synthesize notes;
@synthesize to;
@synthesize pChatTableVw;
@synthesize pChatInputView;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
        
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
    CGRect mainScrn= [[UIScreen mainScreen] bounds];
   
    
    CGRect  viewRect;
    viewRect = CGRectMake(0, mainScrn.origin.y + mainScrn.size.height-150, mainScrn.size.width, 150);
     notes = [[UITextView alloc] initWithFrame:viewRect];
    [self.view addSubview:self.notes];
    CGRect tableRect;
   
    tableRect = CGRectMake(0, mainScrn.origin.y + self.navigationController.navigationBar.frame.size.height, mainScrn.size.width, mainScrn.size.height - self.navigationController.navigationBar.frame.size.height-150);
    pChatTableVw = [ChatViewController1 alloc];
    pChatTableVw = [pChatTableVw initWithNibName:nil bundle:nil];
    UITableView *pTVw = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    pChatTableVw.tableView = pTVw;
    [self.view addSubview:pChatTableVw.tableView];
}

-(void) gotMsgNow:(NSString *)msg
{
    NSLog (@"Setting tmpLabel to %@ and reloading data", msg);
    
    [self.pChatTableVw.tableView reloadData];
}

-(void) sendMsg
{
    NSLog(@"Sending message");
    ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
    [pShrDelegate sendMsg:to Msg:notes.text];
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
