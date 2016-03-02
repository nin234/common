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
    if (indexPath.row == 0)
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
            
            
            albumContentsViewController = [[AlbumContentsViewController alloc] initWithNibName:@"AlbumContentsViewController" bundle:nil];
                NSLog(@"Pushing AlbumContents view controller %s %d\n" , __FILE__, __LINE__);
                //  albumContentsViewController.assetsGroup = group_;
            [albumContentsViewController setDelphoto:true];
            [albumContentsViewController setEmailphoto:true];
            [delegate setAlbumName:item albumcntrl:albumContentsViewController];
            [albumContentsViewController setPhotoreqsource:source];
            [albumContentsViewController setDelegate:self];

                [albumContentsViewController setDelphoto:false];
                [navViewController pushViewController:albumContentsViewController animated:YES];
                
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
    
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"Sort By";
           // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
            cell.backgroundColor = [UIColor brownColor];
            return cell;
        }
        else if (indexPath.row > [indexes count])
            return cell;
        UIImageView *indicator;
        UILabel *label;
        const NSInteger IMAGE_SIZE = 30;
        const NSInteger SIDE_PADDING = 35;
    
        if (bInEmail || bInICloudSync)
        {
            NSNumber* numbr = [seletedItems objectAtIndex:indexPath.row-1];
            if ([numbr boolValue] == YES)
            {
                indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IsSelected.png"]];
                NSLog(@"Setting image  selected\n");
            }
            else
            {
                indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotSelected.png"]];
                NSLog(@"Setting image not selected\n");
            }
            indicator.tag = SELECTION_INDICATOR_TAG_SH;
            indicator.frame =
            CGRectMake(0, 0, IMAGE_SIZE, IMAGE_SIZE);
            [cell.contentView addSubview:indicator];
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(SIDE_PADDING, 0, 275, 25)];
            label.tag = TEXT_LABEL_TAG;
 
        }
        else
          label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 275, 25)];
            
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont boldSystemFontOfSize:14];
        [cell.contentView addSubview:label];
        NSUInteger row = indexPath.row;
        id item = [itemNames objectAtIndex:[[indexes objectAtIndex:row-1] intValue]];
    
     
    label.text = [delegate getLabelTxt:item];
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

    if (indexPath.row ==0)
    {
       
        [delegate pushSortOptionViewController];
        return;
    }
    printf("Row selected %ld\n", (long)indexPath.row);
    if (indexPath.row > [indexes count])
        return;
    
    if (bInEmail || bInICloudSync)
    {
        UITableViewCell *cell =
        [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *indicator = (UIImageView *)[cell.contentView viewWithTag:SELECTION_INDICATOR_TAG_SH];
        NSNumber* numbr = [seletedItems objectAtIndex:indexPath.row-1];
        if ([numbr boolValue] == YES)
        {
            indicator.image = [UIImage imageNamed:@"NotSelected.png"];
            NSLog(@"Changing image Not selected\n");
            [seletedItems replaceObjectAtIndex:indexPath.row-1 withObject:[NSNumber numberWithBool:NO]];
        }
        else
        {
            indicator.image = [UIImage imageNamed:@"IsSelected.png"];
            NSUInteger crnt = indexPath.row - 1;

            NSLog(@"Changing  image to selected at index %lu\n", (unsigned long)crnt);
             [seletedItems replaceObjectAtIndex:indexPath.row-1 withObject:[NSNumber numberWithBool:YES]];
                        NSUInteger cnt = [seletedItems count];
            for (NSUInteger i=0; i < cnt; ++i)
            {
                if (i==crnt)
                    continue;
                NSNumber* othr_row_no = [seletedItems objectAtIndex:i];
                if ([othr_row_no boolValue] == YES)
                {
                    UITableViewCell *othr_row_cell =
                    [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:0]];
                    UIImageView *othr_row_indicator = (UIImageView *)[othr_row_cell.contentView viewWithTag:SELECTION_INDICATOR_TAG_SH];
                    othr_row_indicator.image = [UIImage imageNamed:@"NotSelected.png"];
                    NSLog(@"Changing image Not selected at index %lu\n", (unsigned long)i);
                    [seletedItems replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
                }
            }
        }
   
        return;
    }
    
   
   //  pDlg.selectedItem = [itemNames objectAtIndex:indexPath.row-1];
    
    [delegate pushDisplayViewController:[itemNames objectAtIndex:[[indexes objectAtIndex:indexPath.row-1] intValue]]];
}

@end

