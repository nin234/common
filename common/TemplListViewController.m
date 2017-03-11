//
//  TemplListViewController.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 4/28/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import "TemplListViewController.h"
#import "AppDelegate.h"
#import "ListViewController.h"

@interface TemplListViewController ()

@end

@implementation TemplListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
            }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [pDlg.dataSync lock];
        masterList = [NSArray arrayWithArray:[pDlg.dataSync getMasterListNames]];
        cnt = [masterList count];
        [pDlg.dataSync unlock];
        NSLog (@"Master list name %@ count %ld", masterList, (long)cnt);

    }
    return self;
}

-(void) refreshMasterList
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [pDlg.dataSync lock];
    masterList = [NSArray arrayWithArray:[pDlg.dataSync getMasterListNames]];
    cnt = [masterList count];
    [pDlg.dataSync unlock];
    NSLog (@" Refreshed Master list name %@ count %ld", masterList, (long)cnt);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Clicked button at index %ld", (long)buttonIndex);
     AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIActionSheet *pSh;
    pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:pDlg cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Purchase", @"Restore Purchases", nil];
    
    [pSh showInView:self.tableView];
    [pSh setDelegate:pDlg];

    return;
}


- (void)templItemAdd
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!pDlg.appUtl.purchased && pDlg.no_of_template_lists >= 2)
    {
        NSLog(@"Cannot add a new item without upgrade COUNT=%lu", (unsigned long)cnt);
        UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Upgrade now" message:@"Only two template lists allowed with free version. Please upgrade now to add unlimited number of template lists" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [pAvw show];
        return;
    }
    
    pDlg.mlistName = nil;
    ListViewController *aViewController = [ListViewController alloc];
    aViewController.editMode = eViewModeAdd;
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    [pDlg.navViewController pushViewController:aViewController animated:YES];
    return;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString *title = @"Template Lists";
    self.navigationItem.title = [NSString stringWithString:title];
    
    UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(templItemAdd) ];
    self.navigationItem.rightBarButtonItem = pBarItem;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    
    return cnt;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    else
    {
        NSArray *pVws = [cell.contentView subviews];
        unsigned long Cnt = [pVws count];
        for (NSUInteger i=0; i < Cnt; ++i)
        {
            [[pVws objectAtIndex:i] removeFromSuperview];
        }
        cell.textLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = nil;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 275, 25)];
    
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont boldSystemFontOfSize:14];
    label.text = [masterList objectAtIndex:indexPath.row];
    NSLog(@"Setting template list label %@ for row %ld\n", label.text, (long)indexPath.row);
    [cell.contentView addSubview:label];

    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    pDlg.mlistName = [masterList objectAtIndex:indexPath.row];
    ListViewController *aViewController = [ListViewController alloc];
    aViewController.editMode = eViewModeDisplay;
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    [pDlg.navViewController pushViewController:aViewController animated:NO];
    
}

@end
