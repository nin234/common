//
//  TemplListViewController.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 4/28/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import "TemplListViewController.h"
#import "ComponentsViewController.h"
#import "AppCmnUtil.h"

const NSInteger SELECTION_INDICATOR_TAG_3 = 53330;

@interface TemplListViewController ()

@end

@implementation TemplListViewController

@synthesize delegate;
@synthesize bShareTemplView;

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
        AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
        [pAppCmnUtil.dataSync lock];
        masterList = [NSArray arrayWithArray:[pAppCmnUtil.dataSync getMasterListNames]];
        cnt = [masterList count];
        [pAppCmnUtil.dataSync unlock];
        NSLog (@"Master list name %@ count %ld", masterList, (long)cnt);
        bShareTemplView = false;
        seletedItems = [[NSMutableArray alloc] init];

    }
    return self;
}

-(AppCmnUtil *) getAppCmnUtil
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    return pAppCmnUtil;
}

-(void) refreshMasterList
{
   
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    [pAppCmnUtil.dataSync lock];

    masterList = [NSArray arrayWithArray:[pAppCmnUtil.dataSync getMasterListNames]];
    cnt = [masterList count];
     [pAppCmnUtil.dataSync unlock];
    NSLog (@" Refreshed Master list name %@ count %ld", masterList, (long)cnt);
}



- (void)templItemAdd
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
   
    if (pAppCmnUtil.bEasyGroc)
    {
        UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Template list" message:@"Please enter name of Template list" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"OK", nil];
        pAvw.alertViewStyle = UIAlertViewStylePlainTextInput;
        [pAvw show];
    }
    else
    {
    
        
        ListViewController *aViewController = [ListViewController alloc];
        aViewController.editMode = eViewModeAdd;
        aViewController.mlistName = nil;
        aViewController = [aViewController initWithNibName:nil bundle:nil];
        [pAppCmnUtil.navViewController pushViewController:aViewController animated:YES];
    }
    return;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case CANCEL_TEMPL_NAME_BUTTON:
            return;
            break;
            
        case ADD_TEMPL_NAME_BUTTON:
        {
            NSString *templName =  [[alertView textFieldAtIndex:0] text];
             AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
            [pAppCmnUtil.dataSync addTemplName:templName];
        }
            break;
            
        default:
            break;
    }
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Clicked button Index %ld", (long)buttonIndex);
    
    switch (buttonIndex)
    {
            
        case 0:
            [delegate templShareMgrStartAndShow];
            break;
            
        default:
            break;
    }
    
}

-(void) templScrnActions
{
    
    
    UIActionSheet *pSh;
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    
    pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil];
    EasyViewController *pMainVwCntrl = [pAppCmnUtil.navViewController.viewControllers objectAtIndex:0];
    [pSh showInView:pMainVwCntrl.pAllItms.tableView];
    [pSh setDelegate:self];
    
    
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
    if (self.bShareTemplView)
    {
        
        UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithTitle:@"\U0001F46A\U0001F46A" style:UIBarButtonItemStylePlain target:self action:@selector(shareContactsAdd)];
        self.navigationItem.rightBarButtonItem = pBarItem;
        return;
    }
    UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(templItemAdd) ];
    self.navigationItem.rightBarButtonItem = pBarItem;
     AppCmnUtil *appCmnUtil = [AppCmnUtil sharedInstance];
    if (appCmnUtil.bEasyGroc == true)
    {
        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(templScrnActions)];
    
        self.navigationItem.leftBarButtonItem = pBarItem1;
    }

    

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

-(NSString *) getSelectedItem
{
    NSUInteger cnt = [seletedItems count];
    for (NSUInteger i=0; i < cnt; ++i)
    {
        
        NSNumber* row_no = [seletedItems objectAtIndex:i];
        if ([row_no boolValue] == YES)
        {
            return [masterList objectAtIndex:i];
        }
    }
    return NULL;
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
    NSString *text;
    NSArray *pArr = [[masterList objectAtIndex:indexPath.row] componentsSeparatedByString:@":::"];
    NSString *textLstName = [pArr objectAtIndex:[pArr count]-1];
    if(bShareTemplView)
    {
        NSNumber* numbr = [seletedItems objectAtIndex:indexPath.row];
        if ([numbr boolValue] == YES)
        {
            text = @"\u2705";
        }
        else
        {
            text = @"\u2B1C";
        }
        
        text = [text stringByAppendingString:textLstName];
        label.text = text;
    }
    else
    {
        label.text = textLstName;
    }
    label.tag = SELECTION_INDICATOR_TAG_3;
    NSLog(@"Setting template list label %@ for row %ld\n", label.text, (long)indexPath.row);
    if (!self.bShareTemplView)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    
    if (bShareTemplView)
    {
        UITableViewCell *cell =
        [tableView cellForRowAtIndexPath:indexPath];
        UILabel *textField = (UILabel *)[cell.contentView viewWithTag:SELECTION_INDICATOR_TAG_3];
        NSNumber* numbr = [seletedItems objectAtIndex:indexPath.row];
        if ([numbr boolValue] == YES)
        {
            
            [seletedItems replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
            textField.text = @"\u2B1C";
            textField.text = [textField.text stringByAppendingString:[masterList objectAtIndex:indexPath.row]];
        }
        else
        {
            textField.text = @"\u2705";
            textField.text = [textField.text stringByAppendingString:[masterList objectAtIndex:indexPath.row]];
            NSUInteger crnt = indexPath.row;
            
            NSLog(@"Changing  image to selected at index %lu\n", (unsigned long)crnt);
            [seletedItems replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
            NSUInteger cnt = [seletedItems count];
            for (NSUInteger i=0; i < cnt; ++i)
            {
                if (i==crnt)
                    continue;
                NSNumber* othr_row_no = [seletedItems objectAtIndex:i];
                if ([othr_row_no boolValue] == YES)
                {
                    UITableViewCell *othr_row_cell =
                    [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                    UILabel *othr_row_textfld = (UILabel *)[othr_row_cell.contentView viewWithTag:SELECTION_INDICATOR_TAG_3];
                    othr_row_textfld.text =@"\u2B1C";
                    othr_row_textfld.text =  [othr_row_textfld.text stringByAppendingString:[masterList objectAtIndex:i]];
                    NSLog(@"Changing image Not selected at index %lu\n", (unsigned long)i);
                    [seletedItems replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
                }
            }
            

        }
        return;
    }
    
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    if (pAppCmnUtil.bEasyGroc)
    {
        ComponentsViewController *aViewController = [ComponentsViewController alloc];
        aViewController.masterListName = [masterList objectAtIndex:indexPath.row];
        aViewController = [aViewController initWithNibName:nil bundle:nil];
        [pAppCmnUtil.navViewController pushViewController:aViewController animated:NO];
    }
    else
    {
        
        ListViewController *aViewController = [ListViewController alloc];
        aViewController.editMode = eViewModeDisplay;
        aViewController.mlistName= [masterList objectAtIndex:indexPath.row];
        aViewController = [aViewController initWithNibName:nil bundle:nil];
    
        [pAppCmnUtil.navViewController pushViewController:aViewController animated:NO];
    }
    
}

@end
