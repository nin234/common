//
//  MainViewController.m
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController
@synthesize pSearchBar;
@synthesize pAllItms;
@synthesize emailAction;
@synthesize fbAction;
@synthesize delegate;
@synthesize delegate_1;

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


-(void) loadView
{
    [super loadView];
    CGRect mainScrn = [UIScreen mainScreen].applicationFrame;
    CGRect  viewRect;
       viewRect = CGRectMake(0, mainScrn.origin.y + self.navigationController.navigationBar.frame.size.height, mainScrn.size.width, 50);
       self.pSearchBar = [[UISearchBar alloc] initWithFrame:viewRect];
    [self.pSearchBar setDelegate:self];
    [self.view addSubview:self.pSearchBar];
    self.pAllItms = [[MainListViewController alloc]
                     initWithNibName:nil bundle:nil];
    [self.pAllItms setDelegate:delegate_1];
    self.pAllItms.navViewController = self.navigationController;
    
    CGRect tableRect = CGRectMake(0, mainScrn.origin.y + self.navigationController.navigationBar.frame.size.height + 50, mainScrn.size.width, mainScrn.size.height - self.navigationController.navigationBar.frame.size.height);
    UITableView *pTVw = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    self.pAllItms.tableView = pTVw;
   [self.view addSubview:self.pAllItms.tableView];
    
    [delegate initRefresh];
    
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
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    // Do any additional setup after loading the view from its nib.
    NSString *title = @"House List";
    self.navigationItem.title = [NSString stringWithString:title];
  
    UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(itemAdd) ];
    self.navigationItem.rightBarButtonItem = pBarItem;
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(iCloudOrEmail)];
    
    self.navigationItem.leftBarButtonItem = pBarItem1;
    //pDlg.dataSync.refreshNow = true;
   //  pBarItem1 = [[UIBarButtonItem alloc] initWithTitle:@"Email" style:UIBarButtonItemStyleBordered target:pDlg action:@selector(emailNow)];

}

-(void) itemAdd
{
    [delegate itemAdd];
}

-(void) iCloudOrEmail
{
    [delegate iCloudOrEmail];
}

- (void)viewDidUnload
{
    [self setPSearchBar:nil];
    [self setPAllItms:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
