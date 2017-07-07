//
//  ComponentsViewController.m
//  common
//
//  Created by Ninan Thomas on 3/25/17.
//  Copyright © 2017 Sinacama. All rights reserved.
//

#import "ComponentsViewController.h"
#import "ListViewController.h"
#import "AppCmnUtil.h"


@interface ComponentsViewController ()

@end

@implementation ComponentsViewController

@synthesize masterListName;
@synthesize mlist;
@synthesize masterInvListName;
@synthesize masterScrathListName;
@synthesize mlistInv;
@synthesize mlistScrtch;
@synthesize invLstExists;
@synthesize scrtchLstExists;
@synthesize recrLstExists;
@synthesize share_id;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        mlist = nil;
        AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
        if (masterListName != nil)
        {
            ItemKey *itk = [[ItemKey alloc] init];
            itk.name = masterListName;
            itk.share_id = share_id;
            mlist = [pAppCmnUtil.dataSync getMasterList:itk];
            if (mlist)
                recrLstExists = true;
            else
                recrLstExists = false;
            masterScrathListName = [masterListName stringByAppendingString:@":SCRTCH"];
            masterInvListName = [masterListName stringByAppendingString:@":INV"];
            itk.name = masterScrathListName;
            mlistScrtch = [pAppCmnUtil.dataSync getMasterList:itk];
            if (mlistScrtch)
                scrtchLstExists = true;
            else
                scrtchLstExists = false;
            itk.name = masterInvListName;
            mlistInv = [pAppCmnUtil.dataSync getMasterList:itk];
            if (mlistInv)
                invLstExists = true;
            else
                invLstExists = false;
            
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString *title = masterListName;
    self.navigationItem.title = [NSString stringWithString:title];
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteTemplateList)];
    
    self.navigationItem.rightBarButtonItem = pBarItem1;
}
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!buttonIndex)
    {
        NSLog (@"In action sheet deleting list");
        AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
        [pAppCmnUtil.dataSync deletedTemplItem:masterInvListName];
        [pAppCmnUtil.dataSync deletedTemplItem:masterScrathListName];
        [pAppCmnUtil.dataSync deletedTemplItem:masterListName];
        
        [pAppCmnUtil popView];

    }
}

- (void) deleteTemplateList
{
    NSLog(@"Touched delete list button\n");
    UIActionSheet *pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete List" otherButtonTitles:nil];
    [pSh showInView:self.tableView];
    [pSh setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *CellIdentifier = @"ComponentsViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    else
    {
        NSArray *pVws = [cell.contentView subviews];
        unsigned long int cnt = [pVws count];
        for (NSUInteger i=0; i < cnt; ++i)
        {
            [[pVws objectAtIndex:i] removeFromSuperview];
        }
        cell.imageView.image = nil;
        cell.textLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.section == 0)
    {
        cell.textLabel.text = @"Recurring List";
        return cell;
    }
    if (indexPath.section == 1)
    {
        cell.textLabel.text = @"Inventory List";
        return cell;
    }
    if (indexPath.section == 2)
    {
        cell.textLabel.text = @"Scratch Pad";
        return cell;
    }



    
    // Configure the cell...
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
   
    if (section == 0)
    {
        static NSString *headerReuseIdentifier = @"RecrrngComponentsSectionHeaderVwId";
    
        UITableViewHeaderFooterView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
    // Add any optional custom views of your own
        sectionHeaderView.textLabel.text = @"List contains items required every time";
    
        return sectionHeaderView;
    }
    else if (section == 1)
    {
        static NSString *headerReuseIdentifier = @"InvComponentsSectionHeaderVwId";
        
        UITableViewHeaderFooterView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
        // Add any optional custom views of your own
        sectionHeaderView.textLabel.text = @"Items required only when inventory runs out/low";
        
        return sectionHeaderView;
    }
    else if (section == 2)
    {
        static NSString *headerReuseIdentifier = @"ScratchComponentsSectionHeaderVwId";
        
        UITableViewHeaderFooterView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
        // Add any optional custom views of your own
        sectionHeaderView.textLabel.text = @"Infrequently required items. Contents Ddleted each time new list created";
        
        return sectionHeaderView;
    }
    return nil;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    // *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    ListViewController *aViewController = [ListViewController alloc];
    aViewController.share_id = share_id;
    if (indexPath.section == 0)
    {
        aViewController.easyGrocLstType = eRecurrngLst;
        if (!recrLstExists)
        {
            aViewController.editMode = eViewModeAdd;
        }
        else
        {
            aViewController.editMode = eViewModeDisplay;
        }
        aViewController.mlistName = masterListName;
        

    }
    else if (indexPath.section ==1)
    {
        aViewController.easyGrocLstType = eInvntryLst;
        if (!invLstExists)
        {
            aViewController.editMode = eViewModeAdd;
        }
        else
        {
            aViewController.editMode = eViewModeDisplay;
        }
        aViewController.mlistName = masterInvListName;
    }
    else if (indexPath.section ==2)
    {
        aViewController.easyGrocLstType = eScratchLst;
        if (!scrtchLstExists)
        {
            aViewController.editMode = eViewModeAdd;
        }
        else
        {
            aViewController.editMode = eViewModeDisplay;
        }
        aViewController.mlistName = masterScrathListName;
    }
    else
    {
        return;
    }
    
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    aViewController.pCompVwCntrl = self;
    [pAppCmnUtil.navViewController pushViewController:aViewController animated:YES];
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
