//
//  MainViewController.m
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "NotesViewController.h"
#import "AppCmnUtil.h"
#import "SubscribeViewController.h"

@implementation MainViewController
@synthesize pSearchBar;
@synthesize pAllItms;
@synthesize emailAction;
@synthesize fbAction;
@synthesize delegate;
@synthesize delegate_1;
@synthesize bShareView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
               
        emailAction = false;
        fbAction = false;
       
        
        
    }
    return self;
}

- (void)mapView:(MKMapView *)mapViewL didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"Got did update user location in MainViewController\n");
    
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
    NSLog(@"Search button clicked Initiating new search with %@\n", [searchBar text]);
    [delegate searchStrSet:[searchBar text]];
    [searchBar resignFirstResponder];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
     printf("Started editing search bar %s %d\n", __FILE__, __LINE__);
    
    searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [delegate searchStrReset];
    searchBar.text = nil;
    [searchBar resignFirstResponder];
}




-(void) shareContactsAdd
{
    [delegate shareContactsAdd];
    return;
}

-(void) itemAdd
{
    [delegate itemAdd];
}

-(void) iCloudOrEmail
{
    [delegate iCloudOrEmail];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [self setPSearchBar:nil];
    [self setPAllItms:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



-(void) loadView
{
    [super loadView];
    CGRect mainScrn = [UIScreen mainScreen].bounds;
    CGFloat barHeight = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    if (!bShareView)
    {
        CGRect  viewRect;
        viewRect = CGRectMake(0, mainScrn.origin.y + barHeight, mainScrn.size.width, 50);
        self.pSearchBar = [[UISearchBar alloc] initWithFrame:viewRect];
        [self.pSearchBar setDelegate:self];
        [self.view addSubview:self.pSearchBar];
    }
    pAllItms = [MainListViewController alloc];
    if (!bShareView)
    {
        pAllItms.bInICloudSync = false;
        pAllItms.bInEmail = false;
        pAllItms.bAttchmentsInit = false;
    }
    else
    {
        pAllItms.bInICloudSync = true;
        pAllItms.bInEmail = true;
        pAllItms.bAttchmentsInit = false;
    }
    
    [pAllItms setDelegate:delegate_1];
    pAllItms.navViewController = self.navigationController;
    pAllItms.bShareView = bShareView;
    pAllItms   = [pAllItms initWithNibName:nil bundle:nil];
    CGRect tableRect;
    UITabBarController *tabBarController = [UITabBarController new];
    CGFloat tabBarHeight = tabBarController.tabBar.frame.size.height;
    if (bShareView)
    {
        tableRect = CGRectMake(0, mainScrn.origin.y + barHeight, mainScrn.size.width, mainScrn.size.height - (barHeight + tabBarHeight));
    }
    else
    {
        tableRect = CGRectMake(0, mainScrn.origin.y + barHeight + 50, mainScrn.size.width, mainScrn.size.height - (barHeight + tabBarHeight));
    }
    UITableView *pTVw = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    pAllItms.tableView = pTVw;
    [self.view addSubview:self.pAllItms.tableView];
    if (bShareView)
    {
        [delegate refreshShareView];
    }
    else
    {
        [delegate initRefresh];
    }
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    if (self.bShareView)
    {
        //  [self.tabBarController.tabBar setHidden:YES];
    }
}

-(void) viewDidLoad
{
    
    [super viewDidLoad];
    
    NSString *title = [delegate mainVwCntrlTitle];
    self.navigationItem.title = [NSString stringWithString:title];
    if (self.bShareView)
    {
        
       
        UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Recipients" style:UIBarButtonItemStylePlain target:self action:@selector(shareContactsAdd)];
        self.navigationItem.rightBarButtonItem = pBarItem;
        return;
    }
    
    
    UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(itemAdd) ];
   
   
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showHelpScreen) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* infoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    UIBarButtonItem *subBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"B" style:UIBarButtonItemStylePlain target:self action:@selector(showSubscribeScreen)];
    
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    
    if (pAppCmnUtil.share_id > 1000 && pAppCmnUtil.share_id < 2500 && pAppCmnUtil.share_id != 2352
        && pAppCmnUtil.share_id != 2354)
    {
        self.navigationItem.leftBarButtonItem = infoBarButtonItem;
    }
    else
    {
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:infoBarButtonItem, subBarButtonItem, nil];
    }
      
    
       self.navigationItem.rightBarButtonItem =pBarItem;
    
    
}

-(void) showHelpScreen
{
    NSLog(@"Showing help screen");
    NotesViewController *notesViewController = [NotesViewController alloc] ;
    NSLog(@"Pushing Notes view controller %s %d\n" , __FILE__, __LINE__);
    //  albumContentsViewController.assetsGroup = group_;
    notesViewController.notes.editable = NO;
    notesViewController.mode = eNotesModeDisplay;
    notesViewController.notes.selectable = NO;
    
    notesViewController.title = @"How to use";
    
    notesViewController.notesTxt = [delegate helpTxt];
    
    notesViewController = [notesViewController initWithNibName:@"NotesViewController" bundle:nil];
    [notesViewController.notes setFont:[UIFont fontWithName:@"ArialMT" size:20]];
    [self.navigationController pushViewController:notesViewController animated:NO];
}

-(void) showSubscribeScreen
{
    NSLog(@"Showing subscribe screen");
    
    SubscribeViewController *subViewController = [[SubscribeViewController alloc] initWithNibName:@"SubscribeViewController" bundle:nil];
    [self.navigationController pushViewController:subViewController animated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
   // return YES;
}

/*
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL) shouldAutorotate
{
    return YES;
}

 */
@end
