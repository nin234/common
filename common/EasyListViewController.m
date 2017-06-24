//
//  EasyListViewController.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 3/5/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import "EasyListViewController.h"
#import "List1ViewController.h"
#import "EasyDisplayViewController.h"
#import "EasySlideScrollView.h"
#import "AppCmnUtil.h"

const NSInteger SELECTION_INDICATOR_TAG_2 = 53323;

@interface EasyListViewController ()

@end

@implementation EasyListViewController

@synthesize list;
@synthesize bShareView;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
        pAppCmnUtil.dataSync.refreshMainLst = true;
        seletedItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (bShareView)
    {
        NSLog(@"Refreshing list in view will appear");
        [self refreshList];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    
    [theTextField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}


-(NSString *) getSelectedItem
{
    NSUInteger cnt = [seletedItems count];
    for (NSUInteger i=0; i < cnt; ++i)
    {
        
        NSNumber* row_no = [seletedItems objectAtIndex:i];
        if ([row_no boolValue] == YES)
        {
            return [list objectAtIndex:i];
        }
    }
        return NULL;
}
    

#pragma mark - Table view data source

-(void) refreshList
{
    
     AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    NSArray *listNames = [pAppCmnUtil.dataSync getListNames];
    list = [[listNames reverseObjectEnumerator] allObjects];
    
    picDic = [pAppCmnUtil.dataSync getPics];
    unFiltrdList = [NSArray arrayWithArray:list];
    NSUInteger cnt = [list count];
    seletedItems = [[NSMutableArray alloc] initWithCapacity:cnt];
    for (NSUInteger i=0; i < cnt ; ++i)
    {
        [seletedItems addObject:[NSNumber numberWithBool:NO]];
    }
    
    NSLog(@"refreshList %lu %s %d", (unsigned long)[seletedItems count], __FILE__, __LINE__);
    if (bShareView)
    {
        NSLog(@"Reloading tableview %s %d", __FILE__, __LINE__);
        [self.tableView reloadData];
    }
    return;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (bShareView)
        return [seletedItems count];

    // Return the number of rows in the section.
    if (list != nil)
    {
        return [list count] + 4;
    }
    
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MainListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    else
    {
        NSArray *pVws = [cell.contentView subviews];
        unsigned long cnt = [pVws count];
        for (NSUInteger i=0; i < cnt; ++i)
        {
            [[pVws objectAtIndex:i] removeFromSuperview];
        }
        cell.textLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = nil;
        cell.imageView.image = nil;
    }
    
    if (list != nil && [list count] > indexPath.row)
    {
        NSString *text;
        NSString *origtext;
        if(bShareView)
        {
            NSNumber* numbr = [seletedItems objectAtIndex:indexPath.row];
            if ([numbr boolValue] == YES)
            {
                text = @"\u2705   ";
            }
            else
            {
                text = @"\u2B1C   ";
            }
            NSString *lstName = [list objectAtIndex:indexPath.row];
            origtext = lstName;
            NSArray *pArr = [lstName componentsSeparatedByString:@":::"];
            NSString *textLstName = [pArr objectAtIndex:[pArr count]-1];
            
            text = [text stringByAppendingString:textLstName];
            
           
        }
        else
        {
            NSString *lstName = [list objectAtIndex:indexPath.row];
            origtext = lstName;
            NSArray *pArr = [lstName componentsSeparatedByString:@":::"];
            NSString *textLstName = [pArr objectAtIndex:[pArr count]-1];
            text = textLstName;
        }
        NSString *pic = [picDic objectForKey:origtext];
        CGRect textFrame = CGRectMake(10, 10, 275, 25);
        if (pic != nil)
        {
           
            AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
            NSURL *albumurl = pAppCmnUtil.pThumbNailsDir;
            NSURL *thumburl;
             NSError *err;
            if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
            {
                thumburl = [albumurl URLByAppendingPathComponent:pic isDirectory:NO];
            }
            if ([thumburl checkResourceIsReachableAndReturnError:&err] == YES)
            {
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:thumburl]];
                NSLog(@"Set icon image %@ for picture list in EasyListViewController\n", pic);
                cell.imageView.image = image;
            }
            textFrame = CGRectMake(70, 10, 275, 25);
        }
        UILabel *textField = [[UILabel alloc] initWithFrame:textFrame];
        textField.text = text;
        textField.tag = SELECTION_INDICATOR_TAG_2;
        [cell.contentView addSubview:textField];
       
        if (!bShareView)
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    

    // Configure the cell...
    
    return cell;
}

-(void) filter:(NSString *) str
{
    if (str == nil || [str length] == 0)
    {
        list = [NSArray arrayWithArray:unFiltrdList];
        [self.tableView reloadData];
        return;
    }
    NSMutableArray *tmpArr = [[NSMutableArray alloc] init];
    NSUInteger lcnt = [list count];
    for (NSUInteger i=0; i < lcnt; ++i)
    {
        NSStringCompareOptions  opt = NSCaseInsensitiveSearch;
        NSRange aR = [[list objectAtIndex:i] rangeOfString:str options:opt];
        if (aR.location == NSNotFound && aR.length ==0)
        {
            continue;
        }
        [tmpArr addObject:[list objectAtIndex:i]];

    }
    list = [NSArray arrayWithArray:tmpArr];
    [self.tableView reloadData];
    
    return;
}

-(void) removeFilter
{
    list = [NSArray arrayWithArray:unFiltrdList];
    [self.tableView reloadData];
    return;
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
    
    if (bShareView)
    {
        UITableViewCell *cell =
        [tableView cellForRowAtIndexPath:indexPath];
        UILabel *textField = (UILabel *)[cell.contentView viewWithTag:SELECTION_INDICATOR_TAG_2];
        NSNumber* numbr = [seletedItems objectAtIndex:indexPath.row];
        if ([numbr boolValue] == YES)
        {

            [seletedItems replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
            textField.text = @"\u2B1C   ";
            textField.text = [textField.text stringByAppendingString:[list objectAtIndex:indexPath.row]];
        }
        else
        {
            textField.text = @"\u2705   ";
            textField.text = [textField.text stringByAppendingString:[list objectAtIndex:indexPath.row]];
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
                    UILabel *othr_row_textfld = (UILabel *)[othr_row_cell.contentView viewWithTag:SELECTION_INDICATOR_TAG_2];
                    othr_row_textfld.text =@"\u2B1C";
                    othr_row_textfld.text =  [othr_row_textfld.text stringByAppendingString:[list objectAtIndex:i]];
                    NSLog(@"Changing image Not selected at index %lu\n", (unsigned long)i);
                    [seletedItems replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
                }
            }

        }

        return;
    }
    
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    if (list != nil && [list count] > indexPath.row)
    {
        NSString *item = [list objectAtIndex:indexPath.row];
        NSString *pic = [picDic objectForKey:item];
        if (pic != nil)
        {
            EasyDisplayViewController *photoVwCntrl = [EasyDisplayViewController alloc];
            photoVwCntrl.picName = pic;
            photoVwCntrl.listName = item;
            photoVwCntrl = [photoVwCntrl initWithNibName:nil bundle:nil];
           //[photoVwCntrl.view addSubview:[[EasySlideScrollView alloc] init]];
            [pAppCmnUtil.navViewController pushViewController:photoVwCntrl animated:YES];
            
        }
        else
        {
            [self itemDisplay:item];
        }
    }
    
}

-(void) itemDisplay:(NSString *)listname
{
    NSLog(@"Displaying item %@", listname);
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    [pAppCmnUtil.dataSync selectedItem:listname];
    List1ViewController *aViewController = [List1ViewController alloc];
    aViewController.bEasyGroc = true;
    aViewController.name = listname;
    aViewController.editMode = eListModeDisplay;
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    [pAppCmnUtil.navViewController pushViewController:aViewController animated:YES];
    return;
}

@end
