//
//  EasyAddViewController.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 3/12/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import "EasyAddViewController.h"
#import "AppCmnUtil.h"
#import <MobileCoreServices/UTCoreTypes.h>
#include <sys/types.h>
#include <dirent.h>
#include <stdlib.h>
#include <sys/time.h>

@interface EasyAddViewController ()

@end

@implementation EasyAddViewController

@synthesize imagePickerController;
@synthesize listMode;


#pragma mark - view lifecycle

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
        
        
        [pAppCmnUtil.dataSync lock];
        masterList = [NSArray arrayWithArray:[pAppCmnUtil.dataSync getMasterListNames]];
        mcnt = [masterList count];
        [pAppCmnUtil.dataSync unlock];
        imagePickerController = [[UIImagePickerController alloc] init];
        NSLog (@"Master list name %@ count %ld", masterList, (long)mcnt);

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UITableViewHeaderFooterView *aTableViewHeaderFooterView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"TableViewSectionHeaderViewIdentifier"];
    // Register the above class for a header view reuse.
    [self.tableView registerClass:[aTableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"TableViewSectionHeaderViewIdentifier"];
    
    
    
    
    NSString *title = @"New List";
    self.navigationItem.title = [NSString stringWithString:title];
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    if (pAppCmnUtil.bEasyGroc)
    {
        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(itemAddOptionsCancel) ];
        self.navigationItem.leftBarButtonItem = pBarItem1;
    }

}

#pragma mark - Helper functions

- (void) itemAddOptionsCancel
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];

    [pAppCmnUtil popView];
    return;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage* image = (UIImage *) [info objectForKey:
                                  UIImagePickerControllerOriginalImage];
    struct timeval tv;
    gettimeofday(&tv, 0);
    long filno = tv.tv_sec/2;
    NSString *pFlName = [[NSNumber numberWithInt:(int)filno] stringValue];
    pFlName = [pFlName stringByAppendingString:@".jpg"];
    
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    NSURL *pFlUrl;
    NSError *err;
    NSURL *albumurl = pAppCmnUtil.pPicsDir;
    if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
    {
        
        pFlUrl = [albumurl URLByAppendingPathComponent:pFlName isDirectory:NO];
    }
    
    NSDictionary *dict = [pAppCmnUtil.pFlMgr attributesOfItemAtPath:[pFlUrl path] error:&err];
    if (dict != nil)
        NSLog (@"Loading image in DisplayViewController %@ file size %lld\n", pFlUrl, [dict fileSize]);
    else
        NSLog (@"Loading image in DisplayViewController %@ file size not obtained\n", pFlUrl);
    
    
    
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    if ([data writeToURL:pFlUrl atomically:YES] == NO)
    {
        NSLog(@"Failed to write to file %ld %@\n", filno, pFlUrl);
        return;
        // --nAlNo;
        
    }
    else
    {
        NSLog(@"Save file %@\n", pFlUrl);
        
    }
    
    CGSize oImgSize;
    oImgSize.height = 71;
    oImgSize.width = 71;
    UIGraphicsBeginImageContext(oImgSize);
    [image drawInRect:CGRectMake(0, 0, oImgSize.width, oImgSize.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //  CGImageRef thumbnailImageRef = MyCreateThumbnailImageFromData (data, 5);
    // UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    CGSize pImgSiz = [thumbnail size];
    NSLog(@"Added thumbnail Image height = %f width=%f \n", pImgSiz.height, pImgSiz.width);
    
    NSData *thumbnaildata = UIImageJPEGRepresentation(thumbnail, 0.3);
    
    albumurl = pAppCmnUtil.pThumbNailsDir;
    if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
    {
        
        pFlUrl = [albumurl URLByAppendingPathComponent:pFlName isDirectory:NO];
    }
    
    if ([thumbnaildata writeToURL:pFlUrl atomically:YES] == NO)
    {
        NSLog (@"Failed to write to thumbnail file %ld %@\n", filno, pFlUrl);
        return;
        // --nAlNo;
        
    }
    else
    {
        NSLog(@"Save thumbnail file %@\n", pFlUrl);
    }
    
    NSString *name = @"List";
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *formattedDateString = [dateFormatter stringFromDate:today];
    name = [name stringByAppendingString:@" "];
    name = [name stringByAppendingString:formattedDateString];
    ItemKey *itk = [[ItemKey alloc] init];
    itk.name = name;
    itk.share_id = pAppCmnUtil.share_id;
    [pAppCmnUtil.dataSync addPicItem:itk picItem:pFlName];
    [pAppCmnUtil showPicList:name pictName:pFlName imagePicker:imagePickerController];
    return;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    
    if (pAppCmnUtil.bEasyGroc == true)
    {
            return 3;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    
    if (pAppCmnUtil.bEasyGroc == true)
    {
        // Return the number of rows in the section.
        if (section == 2)
        {
            if (!mcnt)
            {
                return 3;
            }
            else
            {
                return mcnt;
            }
        
        }
        else
            return 1;
    }
    else
    {
        if (!mcnt)
        {
            return 3;
        }
        else
        {
            return mcnt;
        }
 
    }
}

-(void) loadView
{
    [super loadView];
    CGRect tableRect = CGRectMake(0, 50, 60, 230);
    UITableView *pTVw = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStyleGrouped];
    //[self.view insertSubview:self.pAllItms.tableView atIndex:1];
    self.tableView = pTVw;
    return;
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
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    
    if (pAppCmnUtil.bEasyGroc == true)
    {
        if (indexPath.section == 0 && indexPath.row ==0)
        {
            cell.imageView.image = [UIImage imageNamed:@"camera.png"];
            cell.textLabel.text = @"Picture List";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            
        }
        
        if (indexPath.section == 1 && indexPath.row ==0)
        {
            
            cell.textLabel.text = @"Brand New List";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            
        }
        
        if (indexPath.section == 2 && mcnt)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 275, 25)];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont boldSystemFontOfSize:14];
            ItemKey *itk = [masterList objectAtIndex:indexPath.row];
            label.text = itk.name;
            NSLog(@"Setting template list label %@ for row %ld\n", label.text, (long)indexPath.row);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.contentView addSubview:label];
        }
    }
    else
    {
        if ( mcnt)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 275, 25)];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont boldSystemFontOfSize:14];
            ItemKey *itk = [masterList objectAtIndex:indexPath.row];
            label.text = itk.name;
            NSLog(@"Setting template list label %@ for row %ld\n", label.text, (long)indexPath.row);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.contentView addSubview:label];
        }

    }
    

    
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    
    if (pAppCmnUtil.bEasyGroc == true)
    {
        if (section <2)
            return 10.0;
    }
    
    return 40.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    
    if (pAppCmnUtil.bEasyGroc == true)
    {
        if (section <2)
            return nil;
    }
    static NSString *headerReuseIdentifier = @"TableViewSectionHeaderViewIdentifier";
    
    // Reuse the instance that was created in viewDidLoad, or make a new one if not enough.
    UITableViewHeaderFooterView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
    // Add any optional custom views of your own
    sectionHeaderView.textLabel.text = @"Create list from Template lists";
    
    return sectionHeaderView;
    
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
   
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    
    
    
    if (pAppCmnUtil.bEasyGroc == false)
    {
        if ([masterList count] < indexPath.row + 1)
        {
            NSLog(@"Row count greater than template list items");
            return;
        }
        [pAppCmnUtil popView];
        List1ViewController *aViewController = [List1ViewController alloc];
        aViewController.editMode = listMode;
        aViewController.bEasyGroc = false;
        ItemKey *itk = [masterList objectAtIndex:indexPath.row];
        aViewController.mlistName = itk.name;
        aViewController.mlist_share_id = itk.share_id;
        
        NSLog(@"Setting List1ViewController masterlistname = %@ share_id=%lld %s %d", aViewController.mlistName, aViewController.mlist_share_id, __FILE__, __LINE__);
        aViewController.bDoubleParent = true;
        aViewController = [aViewController initWithNibName:nil bundle:nil];
        
        [pAppCmnUtil.navViewController pushViewController:aViewController animated:NO];

        return;
    }
    
    if (indexPath.section == 2)
    {
        if ([masterList count] < indexPath.row + 1)
        {
            NSLog(@"Row count greater than template list items");
            return;
        }
        
        List1ViewController *aViewController = [List1ViewController alloc];
        aViewController.editMode = eListModeAdd;
        aViewController.bEasyGroc = true;
        ItemKey *itk = [masterList objectAtIndex:indexPath.row];
        aViewController.mlistName = itk.name;
        aViewController.mlist_share_id = itk.share_id;
        aViewController.share_id = pAppCmnUtil.share_id;
        

        aViewController = [aViewController initWithNibName:nil bundle:nil];
        [pAppCmnUtil.navViewController pushViewController:aViewController animated:NO];
        
    }
    else if (indexPath.section == 1)
    {
        
        List1ViewController *aViewController = [List1ViewController alloc];
        aViewController.editMode = eListModeAdd;
        aViewController.bEasyGroc = true;
        aViewController = [aViewController initWithNibName:nil bundle:nil];
        aViewController.mlistName = nil;
        [pAppCmnUtil.navViewController pushViewController:aViewController animated:NO];
         aViewController.share_id = pAppCmnUtil.share_id;

    }
    else if (indexPath.section ==0)
    {
        NSLog(@"Initializing and displaying camera\n");
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear] == NO)
            return;
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController.editing = YES;
        self.imagePickerController.delegate = (id)self;
        //self.imagePickerController.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.imagePickerController.showsCameraControls = YES;
        self.imagePickerController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];;
        
        NSLog(@"Media types %@\n", self.imagePickerController.mediaTypes);
        
        self.imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        [self presentViewController:imagePickerController animated:NO completion:nil];
 
    }
    else
    {
        NSLog(@"Invalid section %ld\n", (long)indexPath.section);
    }

}

@end
