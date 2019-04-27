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
#import "NotesViewController.h"

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
    self.pAllItms = [EasyListViewController alloc];
    
    self.pAllItms.bShareView = bShareView;
    CGFloat yoffset;
    if(bShareView)
        yoffset = 0;
    else
        yoffset = 50;
      CGRect tableRect = CGRectMake(0, mainScrn.origin.y + self.navigationController.navigationBar.frame.size.height + yoffset, mainScrn.size.width, mainScrn.size.height - self.navigationController.navigationBar.frame.size.height);
    UITableView *pTVw = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    self.pAllItms.tableView = pTVw;
    self.pAllItms = [self.pAllItms initWithNibName:nil bundle:nil];
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
            aViewController.delegate = [delegate getTemplListVwCntrlDelegate];
            [pAppCmnUtil.navViewController pushViewController:aViewController animated:YES];
        }
        break;
        
        case 1:
        {
            NSLog(@"Calling shareMgrStartAndShow %s %d", __FILE__, __LINE__);
            [delegate shareMgrStartAndShow];
        }
        break;
        
        default:
        break;
    }
    
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Clicked button Index %ld, %s %d", (long)buttonIndex, __FILE__, __LINE__);
    
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
    
    UIImage *imageHelp = [UIImage imageNamed:@"ic_help_outline_18pt_2x"];
    UIBarButtonItem *pHelpBtn = [[UIBarButtonItem alloc] initWithImage:imageHelp style:UIBarButtonItemStylePlain target:self action:@selector(showHelpScreen)];
    NSArray *barItems = [NSArray arrayWithObjects:pBarItem,pHelpBtn,nil];
    self.navigationItem.rightBarButtonItems =barItems;
    
   
}

-(void) showHelpScreen
{
    NSLog(@"Showing help screen");
    NotesViewController *notesViewController = [NotesViewController alloc] ;
    NSLog(@"Pushing Notes view controller %s %d\n" , __FILE__, __LINE__);
    //  albumContentsViewController.assetsGroup = group_;
    notesViewController.notes.editable = NO;
    notesViewController.mode = eNotesModeDisplay;
    
    notesViewController.title = @"How to use";
    
    notesViewController.notesTxt = @"Create Planner lists for each store. Click planner icon in the bottom tab bar to go to the Planner section of the App.\n\nCreate a new planner by clicking the + button on the top right hand corner. Enter the name of the store in the text box. Planners can be created for multiple stores.\n\nTo add items to planner, select the newly created planner item on the screen.\nThe planner list of a store is made up of three different sections (One-time, Replenish and Always). To switch between the sections click the buttons on the top navigation bar. Click the Edit button on top right corner to make changes to planner list and click the Save button to save the changes\n\nReplenish list keeps track of items that needs to be bought when they run out. The switch in the off position (red color) indicates that particular item has run out. When a list is created from the Home screen this item will be added to the list.\nAlways list are the items that are needed on every store visit. \n\nOne-time items are infrequently needed items. The items in this list are used the next time a new list is created from the Home screen. The items in the list are deleted after a new list is created and cannot be used again.\n\n After creating planner lists click the + button on the top right corner of the Home screen. Create a new list by selecting the appropriate Planner list. A new list created  from the planner list will merge items from these 3 components (Always, Replenish and One-time).\\nnClicking the brand new list on this screen will create an empty blank list. This can be used for one time lists.\n\n The list can be shared with friends. The first step to share is to add Contacts to share the list with. \n\nClick the Contacts icon in the bottom tab bar to bring up the Contacts screen. There will be a ME line. Selecting the ME line, shows the share Id of the EasyGrocList on this iPhone. This number uniquely identifies the App for sharing purposes. Now navigate back to Contacts screen by clicking the Contacts button on top left corner. Click the + button on top right corner to add a new contact. Enter the share Id and a name to identify the contact.The Share Id is the number in the ME row of your friend's EasyGrocList app. \n\nClick the Share icon in the bottom tab bar. This will bring up the Share screen. Select the List to share and click the People icon on the top right corner. This will bring up the Contacts screen. Select the contacts to share the item. Once the contacts are selected click the Done button. This will sent the list to the selected Contacts";
    notesViewController = [notesViewController initWithNibName:@"NotesViewController" bundle:nil];
    [notesViewController.notes setFont:[UIFont fontWithName:@"ArialMT" size:20]];
    [self.navigationController pushViewController:notesViewController animated:NO];
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
