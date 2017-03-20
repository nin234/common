//
//  EasyViewController.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 3/5/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import "EasyViewController.h"
#import "AppCmnUtil.h"
#import "EasyAddViewController.h"
#import "TemplListViewController.h"

@interface EasyViewController ()

@end

@implementation EasyViewController

@synthesize bShareView;
@synthesize delegate;


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
    
    [self.pAllItms filter:[searchBar text]];
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
    
    searchBar.text = nil;
  //  pDlg.dataSync.refreshNow = true;
    [self.pAllItms removeFilter];
    [searchBar resignFirstResponder];
}

-(void) mainScreenActions: (NSInteger) buttonIndex
{
     AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    switch (buttonIndex)
    {
        case 0:
        {
            
            EasyViewController *pMainVwCntrl = [pAppCmnUtil.navViewController.viewControllers objectAtIndex:0];
            
            
            pMainVwCntrl.pSearchBar.text = nil;
            [pMainVwCntrl.pSearchBar resignFirstResponder];
            TemplListViewController *aViewController = [[TemplListViewController alloc]
                                                        initWithNibName:nil bundle:nil];
            [pAppCmnUtil.navViewController pushViewController:aViewController animated:YES];
        }
        break;
        
        case 1:
        {
            [delegate shareMgrStartAndShow];
        }
        break;
        
        default:
        break;
    }
    
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Clicked button Index %ld", (long)buttonIndex);
    
    switch (eAction)
    {
        
        
        case eActnShetMainScreen:
        [self mainScreenActions:buttonIndex];
        break;
        
        default:
        break;
    }
    
}

-(void) mainScrnActions
{
    
    eAction = eActnShetMainScreen;
    
    UIActionSheet *pSh;
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    
    pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Template Lists", @"Share", nil];
    EasyViewController *pMainVwCntrl = [pAppCmnUtil.navViewController.viewControllers objectAtIndex:0];
    [pSh showInView:pMainVwCntrl.pAllItms.tableView];
    [pSh setDelegate:self];
    
    
    return;
}


- (void)itemAdd
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    EasyViewController *pMainVwCntrl = [pAppCmnUtil.navViewController.viewControllers objectAtIndex:0];
    
    
    pMainVwCntrl.pSearchBar.text = nil;
    [pMainVwCntrl.pSearchBar resignFirstResponder];
    EasyAddViewController *aViewController = [[EasyAddViewController alloc]
                                              initWithNibName:nil bundle:nil];
    [pAppCmnUtil.navViewController pushViewController:aViewController animated:YES];
    return;
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
   
    UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(itemAdd) ];
    
    
    self.navigationItem.rightBarButtonItem = pBarItem;
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(mainScrnActions)];
    
    self.navigationItem.leftBarButtonItem = pBarItem1;
}

-(void) shareContactsAdd
{
    [delegate shareContactsSetSelected];
       return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
