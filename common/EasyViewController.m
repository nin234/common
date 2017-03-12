//
//  EasyViewController.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 3/5/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import "EasyViewController.h"
#import "AppDelegate.h"

@interface EasyViewController ()

@end

@implementation EasyViewController

@synthesize bShareView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        bShareView  = false;
       
    }
    return self;
}


-(void) loadView
{
    [super loadView];
    CGRect mainScrn = [UIScreen mainScreen].applicationFrame;
    if(!bShareView)
    {
        CGRect  viewRect;
        viewRect = CGRectMake(0, mainScrn.origin.y + self.navigationController.navigationBar.frame.size.height, mainScrn.size.width, 50);
        self.pSearchBar = [[UISearchBar alloc] initWithFrame:viewRect];
        [self.pSearchBar setDelegate:self];
        [self.view addSubview:self.pSearchBar];
    }
    self.pAllItms = [[EasyListViewController alloc]
                     initWithNibName:nil bundle:nil];
    self.pAllItms.bShareView = bShareView;
    CGFloat yoffset;
    if(bShareView)
        yoffset = 0;
    else
        yoffset = 50;
      CGRect tableRect = CGRectMake(0, mainScrn.origin.y + self.navigationController.navigationBar.frame.size.height + yoffset, mainScrn.size.width, mainScrn.size.height - self.navigationController.navigationBar.frame.size.height);
    UITableView *pTVw = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    self.pAllItms.tableView = pTVw;
    [self.view addSubview:self.pAllItms.tableView];
    
}

- (void)enableCancelButton:(UISearchBar *)aSearchBar
{
    for (id subview in [aSearchBar subviews])
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            [subview setEnabled:TRUE];
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    
    
    //execute a new fetch statement
    //repopulate the table
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    // printf("Finished editing search bar %s %d\n", __FILE__, __LINE__);
    
    // [searchBar resignFirstResponder];
    [self performSelector:@selector(enableCancelButton:) withObject:searchBar afterDelay:0.0];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    printf("Clicked results list button\n");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //printf("Clicked search button\n");
    NSLog(@"Search button clicked in MainView Initiating new search with %@\n", [searchBar text]);
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    pDlg.pSearchStr = [searchBar text];
    [self.pAllItms filter:pDlg.pSearchStr];
    //pDlg.dataSync.refreshNow = true;
    [searchBar resignFirstResponder];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    printf("Started editing search bar %s %d\n", __FILE__, __LINE__);
    
    searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    pDlg.pSearchStr = nil;
    searchBar.text = nil;
  //  pDlg.dataSync.refreshNow = true;
    [self.pAllItms removeFilter];
    [searchBar resignFirstResponder];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *title = @"List";
    self.navigationItem.title = [NSString stringWithString:title];
    if (bShareView)
    {
        
        UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithTitle:@"\U0001F46A\U0001F46A" style:UIBarButtonItemStylePlain target:self action:@selector(shareContactsAdd)];
        self.navigationItem.rightBarButtonItem = pBarItem;
        return;
    }
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:pDlg action:@selector(itemAdd) ];
    
    
    self.navigationItem.rightBarButtonItem = pBarItem;
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:pDlg action:@selector(mainScrnActions)];
    
    self.navigationItem.leftBarButtonItem = pBarItem1;
}

-(void) shareContactsAdd
{
   AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    pDlg.appUtl.selFrndCntrl.bModeShare = true;
    pDlg.appUtl.tabBarController.selectedIndex = 1;
    
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
