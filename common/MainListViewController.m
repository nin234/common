//
//  MainListViewController.m
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainListViewController.h"
#import "MainViewController.h"
#import "AlbumContentsViewController.h"
#import <sys/stat.h>
#import "AppUtil.h"

const NSInteger SELECTION_INDICATOR_TAG_SH = 54321;
const NSInteger TEXT_LABEL_TAG = 54322;
const NSInteger EDITING_HORIZONTAL_OFFSET = 35;

@implementation MainListViewController
@synthesize bInEmail;
@synthesize bInICloudSync;
@synthesize attchments;
@synthesize currPhotoSelIndx;
@synthesize albumContentsViewController;
@synthesize movOrImg;
@synthesize bAttchmentsInit;
@synthesize bUpdated;
@synthesize bUpdating;
@synthesize redrawTable;
@synthesize seletedItems;
@synthesize itemNames;
@synthesize indexes;
@synthesize actionNow;
@synthesize navViewController;
@synthesize delegate;
@synthesize bShareView;

//static int nRows;
/*
+(int) noofRows
{
    
    return nRows;
}

+(void) setNoofRows : (int) rows
{
    
    nRows = rows;
}
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        actionNow = 0;
        bUpdated = false;
        bUpdating = false;
        seletedItems = [[NSMutableArray alloc] init];
        itemNames = [[NSMutableArray alloc] init];
        indexes = [[NSMutableArray alloc] init];
        NSLog(@"Creating the fetch queue\n");
         //self.hidesBottomBarWhenPushed = YES;
               
    }
    return self;
}

-(void) updateMainList:(NSInteger) timeval
{
    [NSThread sleepForTimeInterval:10];
        
}

- (id)initWithStyle:(UITableViewStyle)style
{
  
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
      
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) cleanUp:(int) indx
{
    [seletedItems removeObjectAtIndex:indx];
    [itemNames removeObjectAtIndex:indx];
    [indexes removeObjectAtIndex:indx];
    return;
}


#pragma mark - View lifecycle

-(void) loadView
{
    //  printf("LOADING main table view %s %d\n" , __FILE__, __LINE__);
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   // printf("Main window will appear\n");
    if (bShareView)
    {
        [delegate refreshShareView];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
  //  return YES;
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
#pragma mark - Table view data source



-(void) lockItems
{
    return;
}

-(void) unlockItems
{
    return;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger nRows = 1;
  //  AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   // [pDlg.dataSync lock];
        nRows = [indexes count] +1;
  //  [pDlg.dataSync unlock];
    return nRows +2;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    if (indexPath.row == 0 && !bShareView)
        cell.backgroundColor = [UIColor brownColor];
    return;
}

- (void) shareSelectedtoOH
{
    
    return;
}


- (void) syncSelectedtoiCloud
{

}

-(void) photoSelDone
{
    if(!bAttchmentsInit)
    {
        [self attchmentsInit];
        bAttchmentsInit = true;
    }
     
    [albumContentsViewController getAttchmentsUrls];
    
    NSArray *arry = [NSArray arrayWithArray:albumContentsViewController.attchments];
    [attchments addObjectsFromArray:arry];
    
    NSArray *movarr = [NSArray arrayWithArray:albumContentsViewController.movOrImg];
    [movOrImg addObjectsFromArray:movarr];
    
    NSLog(@"No of attchments  %lu no of movOrImg %lu original count attchments %lu  movOrImg %lu\n",  (unsigned long)[attchments count], (unsigned long)[movOrImg count],(unsigned long)[albumContentsViewController.attchments count], (unsigned long)[albumContentsViewController.movOrImg count]);

    [navViewController popViewControllerAnimated:NO];
    [self getPhotos:currPhotoSelIndx+1 source:photoreqsource];
    
    return;
}

-(void) photoSelCancel
{
     [navViewController popViewControllerAnimated:NO];
    [self getPhotos:currPhotoSelIndx+1 source:photoreqsource];
    return;
}

-(void)attchmentsClear
{
    [attchments removeAllObjects];
    [movOrImg   removeAllObjects];
}

-(void)attchmentsInit
{
    attchments = [[NSMutableArray alloc] init ];
    movOrImg    = [[NSMutableArray alloc] init];
    return;
}


-(bool) itemsSelected
{
    NSUInteger count = [seletedItems count];
    for (NSUInteger i =0; i < count; ++i)
    {
        if ([[seletedItems objectAtIndex:i] boolValue] == YES)
        {
            return true;
        }
    }

    
    return  false;
}

-(void) getPhotos :(int) startIndx source:(int) source
{
    
    //Here we are in email , so refreshData will not be invoked by the update thread, so no need to lock
    if (!startIndx && source == PHOTOREQSOURCE_SHARE)
    {
        [attchments removeAllObjects];
        [movOrImg removeAllObjects];
        
    }
    photoreqsource = source;
    NSUInteger count = [seletedItems count];
    bool bFound = false;
    for (int i =startIndx; i < count; ++i)
    {
        if ([[seletedItems objectAtIndex:i] boolValue] == YES)
        {
            currPhotoSelIndx = i;
            bFound = true;
            id item = [itemNames objectAtIndex:[[indexes objectAtIndex:i] intValue]];
            
           albumContentsViewController = [delegate pushAlbumContentsViewController:item indx:i source:source delegate:self];
            
            break;
        }
    }
    
    if (!bFound)
    {
        [delegate photoActions:source];
        
    }
     
    return;
}

-(id ) getSelectedItem
{
    NSUInteger count = [seletedItems count];
    for (NSUInteger i =0; i < count; ++i)
    {
        if ([[seletedItems objectAtIndex:i] boolValue] == YES)
        {
            id item = [itemNames objectAtIndex:[[indexes objectAtIndex:i] intValue]];
            return item;
        }
    }
    return nil;
}

-(id) getMessage : (int) source
{
    
    NSUInteger count = [seletedItems count];
    for (NSUInteger i =0; i < count; ++i)
    {
        if ([[seletedItems objectAtIndex:i] boolValue] == YES)
        {
            id item = [itemNames objectAtIndex:[[indexes objectAtIndex:i] intValue]];
            return  item;
        }
    }
    return nil;
}

-(void) resetSelectedItems
{
    NSUInteger count = [seletedItems count];
    for (NSUInteger i =0; i < count; ++i)
         [seletedItems replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
    return;
}

- (NSString *) getAlbumDir: (NSString *) album_name
{
    NSString *pHdir = NSHomeDirectory();
    NSString *pAlbums = @"/Documents/albums";
    NSString *pAlbumsDir = [pHdir stringByAppendingString:pAlbums];
    pAlbumsDir = [pAlbumsDir stringByAppendingString:@"/"];
    NSString *pNewAlbum = [pAlbumsDir stringByAppendingString:album_name];
    NSURL *url = [NSURL fileURLWithPath:pNewAlbum isDirectory:YES];
    return [url absoluteString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   // if (cell == nil)
   // {
      //  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]; 
        }
        else
        {
            NSArray *pVws = [cell.contentView subviews];
            NSUInteger cnt = [pVws count];
            for (NSUInteger i=0; i < cnt; ++i)
            {
                [[pVws objectAtIndex:i] removeFromSuperview];
            }
            cell.textLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.backgroundColor = nil;
        }
    
        if (indexPath.row == 0 && !bShareView)
        {
            cell.textLabel.text = @"Sort By";
           // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
            cell.backgroundColor = [UIColor brownColor];
            return cell;
        }
        else
        {
            if (!bShareView && indexPath.row > [indexes count])
                return cell;
            if (bShareView && indexPath.row >= [indexes count])
                return cell;
        }
    
        UILabel *label;
        label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 275, 25)];
            
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont boldSystemFontOfSize:14];
        [cell.contentView addSubview:label];
        NSUInteger row = indexPath.row;
    id item;
     if (bShareView)
     {
         NSString *text;
         NSNumber* numbr = [seletedItems objectAtIndex:indexPath.row];
         if ([numbr boolValue] == YES)
         {
             text = @"\u2705   ";
         }
         else
         {
             text = @"\u2B1C   ";
         }
          item = [itemNames objectAtIndex:[[indexes objectAtIndex:row] intValue]];
         text = [text stringByAppendingString:[delegate getLabelTxt:item]];
         label.text = text;
     }
    else
    {
        item = [itemNames objectAtIndex:[[indexes objectAtIndex:row-1] intValue]];
        label.text = [delegate getLabelTxt:item];
    }
    
     
    
        NSLog(@"Setting main list label %@\n", label.text);
       
    
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
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int attchmnts = (int)buttonIndex;
    
    switch (attchmnts)
    {
        case 0:
            return;
            break;
        case 1:
            [self getPhotos:0 source:PHOTOREQSOURCE_SHARE];
            break;
            
        default:
            break;
    }
    return;
}

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

    
    printf("Row selected %ld\n", (long)indexPath.row);
    if (indexPath.row > [indexes count])
        return;
    
    if (bShareView)
    {
        UITableViewCell *cell =
        [tableView cellForRowAtIndexPath:indexPath];
        NSNumber* numbr = [seletedItems objectAtIndex:indexPath.row];
        NSArray *subvw =  [cell.contentView subviews];
        if ([subvw count] != 1)
            return;
        UILabel *label = [subvw objectAtIndex:0];
        if ([numbr boolValue] == YES)
        {
            NSString* text = @"\u2B1C   ";
             id item = [itemNames objectAtIndex:[[indexes objectAtIndex:indexPath.row] intValue]];
            text = [text stringByAppendingString:[delegate getLabelTxt:item]];
            label.text = text;
            NSLog(@"Changing image Not selected\n");
            [seletedItems replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
        }
        else
        {
            NSString* text = @"\u2705   ";
            id item = [itemNames objectAtIndex:[[indexes objectAtIndex:indexPath.row] intValue]];
            text = [text stringByAppendingString:[delegate getLabelTxt:item]];
            label.text = text;
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
                    NSArray *subvw =  [othr_row_cell.contentView subviews];
                    if ([subvw count] != 1)
                        return;
                    UILabel *label = [subvw objectAtIndex:0];
                    NSString* text = @"\u2B1C   ";
                    id item = [itemNames objectAtIndex:[[indexes objectAtIndex:indexPath.row] intValue]];
                    text = [text stringByAppendingString:[delegate getLabelTxt:item]];
                    label.text = text;

                    
                    [seletedItems replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
                }
            }
            if (bShareView)
            {
                UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Attach Pictures" message:@"" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                [pAvw show];
            }
        }
   
        return;
    }
    
   
   //  pDlg.selectedItem = [itemNames objectAtIndex:indexPath.row-1];
    if (!indexPath.row)
    {
        [delegate pushSortOptionViewController];
        return;
    }
    
    [delegate pushDisplayViewController:[itemNames objectAtIndex:[[indexes objectAtIndex:indexPath.row-1] intValue]] indx:(int)indexPath.row-1];
}

@end

