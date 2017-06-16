//
//  DisplayViewController.m
//  Shopper
//
//  Created by Ninan Thomas on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "AlbumContentsViewController.h"
#import "DisplayViewController.h"
#import "MapViewController.h"
#include <sys/types.h>
#include <dirent.h>
#include "string.h"
#import "NotesViewController.h"
#import "List1ViewController.h"
#import "AppCmnUtil.h"
#include <math.h>

@implementation DisplayViewController

@synthesize nSmallest;
@synthesize processQuery;
@synthesize pFlMgr;
@synthesize pAlName;
@synthesize navViewController;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
            nSmallest = 0;
        processQuery = true;
        checkListArr = nil;
	     NSString *pAlMoc = pAlName;
	    printf("In DisplayViewController Selected album name %s\n", [pAlMoc UTF8String]);
	    char szFileNo[64];
	    if (pAlMoc == nil)
            return self;
	    
	    NSURL *albumurl = [NSURL URLWithString:pAlMoc];
        
        if ([pFlMgr fileExistsAtPath:[albumurl path]] == YES)
       {
           NSLog(@"Album directory exists");
           
       }
        else
        {
            NSLog(@"Album directory does not exist");
        }
        NSArray *keys = [NSArray arrayWithObject:NSURLIsRegularFileKey];
        NSArray *files = [pFlMgr contentsOfDirectoryAtURL:albumurl includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
        NSUInteger cnt = [files count];
         NSLog(@"Getting locally stored file %lu", (unsigned long)cnt);
        for (NSUInteger i = 0; i < cnt; ++i)
        {
            NSURL *fileurl = [files objectAtIndex:i];
            NSError *error;
            NSNumber *isReg;
            if ([fileurl getResourceValue:&isReg forKey:NSURLIsRegularFileKey error:&error] == YES)
            {
                if ([isReg boolValue] == YES)
                {
                    NSString *pFil = [fileurl lastPathComponent];
                    int size = (int) strcspn([pFil UTF8String], ".");
                    if (size)
                    {
                        strncpy(szFileNo, [pFil UTF8String], size);
                        szFileNo[size] = '\0';
                        int val = strtod(szFileNo, NULL);
                        if (val < nSmallest)
                            nSmallest = val;
                        if (nSmallest == 0)
                            nSmallest = val;
                    }
                    
                }
            }
            else
            {
                NSLog(@"Failed to get resource value %@\n", error);
            }
            
        }
        NSLog(@"album url %@ nSmallest %d\n", albumurl, nSmallest);
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void) loadView
{
    [super loadView];
    
}


-(void) itemEdit
{
    [delegate itemEdit];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithTitle:@"House Info" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.backBarButtonItem = pBarItem1;*/
   
    self.navigationItem.title = [NSString stringWithString:[delegate setTitle]];
    UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(itemEdit) ];
    self.navigationItem.rightBarButtonItem = pBarItem;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    NSLog(@"Stopping iCloud query in DisplayViewController\n");
    
    if (query != nil)
    {
        NSLog(@"Stop query in DisplayViewController\n");
        [query stopQuery];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"DisplayViewController will appear\n");
    if (query != nil)
    {
        
        if (![query isStarted])
        {
            NSLog(@"Start query in DisplayViewController\n");
            [query startQuery];
            processQuery = true;
        }
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //printf
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"DisplayViewController will disappear\n");
    

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return 14;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    if (indexPath.row == 0)
        cell.backgroundColor = [UIColor yellowColor];
    return;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static  NSArray* fieldNames = nil;
    
    if (!fieldNames)
    {
        fieldNames = [delegate getFieldDispNames];
        
    }
    
    
    static NSArray *secondFieldNames = nil;
    
    if(!secondFieldNames)
    {
        secondFieldNames = [delegate getSecondFieldNames];
      
    }
    
   
    NSUInteger row = indexPath.row;
    static NSString *CellIdentifier = @"itemdetail";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    printf("Drawing row %ld\n", (long)indexPath.row);
    
    if(indexPath.section == 0) 
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
            cell.imageView.image = nil;
            cell.textLabel.text = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if ([delegate isTwoFieldRow:row])
        {
            
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
            CGRect textFrame;
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont boldSystemFontOfSize:14];
            [cell.contentView addSubview:label];
            textFrame = CGRectMake(75, 12, 85, 25);
            UILabel *textField = [[UILabel alloc] initWithFrame:textFrame];
            NSString* fieldName = [fieldNames objectAtIndex:row];
            label.text = fieldName;
            [cell.contentView addSubview:textField];
            UILabel* label1 = [[UILabel alloc] initWithFrame:CGRectMake(160, 10, 75, 25)];
            NSString *secName = [secondFieldNames objectAtIndex:row];
            label1.text = secName;
            label1.textAlignment = NSTextAlignmentLeft;
            label1.font = [UIFont boldSystemFontOfSize:14];
            [cell.contentView addSubview:label1];
            textFrame = CGRectMake(235, 12, 85, 25);
            UILabel *textField1 = [[UILabel alloc] initWithFrame:textFrame];
            [cell.contentView addSubview:textField1];
            [delegate populateDispTextFields:textField textField1:textField1 row:row];
        }
        else if ([delegate isSingleFieldDispRow:row])
        {
            CGRect textFrame;
			
            // put a label and text field in the cell
            UILabel *label;
            if (row != 11)
                label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
            else
                label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 105, 25)];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont boldSystemFontOfSize:14];
            if (row == 0)
            {
                cell.backgroundColor = [UIColor yellowColor];
                label.backgroundColor = [UIColor yellowColor];
            }
            [cell.contentView addSubview:label];
            if (row != 12)
                textFrame = CGRectMake(75, 12, 200, 25);
            else
                textFrame = CGRectMake(110, 12, 170, 25);
            UILabel *textField = [[UILabel alloc] initWithFrame:textFrame];
            textField.lineBreakMode = NSLineBreakByCharWrapping;
            [delegate populateDispTextFields:textField textField1:nil row:row];
           
            [cell.contentView addSubview:textField];
            if (row == 0)
            {
                cell.backgroundColor = [UIColor yellowColor];
                label.backgroundColor = [UIColor yellowColor];
                textField.backgroundColor = [UIColor yellowColor];
            }
            
            NSString* fieldName = [fieldNames objectAtIndex:row];
            label.text = fieldName;
        }
        else if (row == 4)
        {
            cell.textLabel.text = @"Check List";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (row == 5)
        {
            cell.imageView.image = [UIImage imageNamed:@"note.png"];
            cell.textLabel.text = @"Notes";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
        }
        else if (row == 6)
        {
            
            printf("Selected album name %s nSmallest %d\n", [pAlName UTF8String], nSmallest);
            if (nSmallest)
            {
                NSString *pFlName = [[NSNumber numberWithInt:nSmallest] stringValue];
                pFlName = [pFlName stringByAppendingString:@".jpg"];
		NSURL *pFlUrl;
		NSError *err;
		NSURL *albumurl = [NSURL URLWithString:pAlName];
		if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
		{
		    pFlUrl = [albumurl URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
		    pFlUrl = [pFlUrl URLByAppendingPathComponent:pFlName isDirectory:NO];
		}
		
	       
		NSDictionary *dict = [pFlMgr attributesOfItemAtPath:[pFlUrl path] error:&err];
		if (dict != nil)
		    NSLog (@"Loading image in DisplayViewController %@ file size %lld\n", pFlUrl, [dict fileSize]);
		else 
		    NSLog (@"Loading image in DisplayViewController %@ file size not obtained\n", pFlUrl);
		UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:pFlUrl]];
                NSLog(@"Set icon image %@ in DisplayViewController\n", pFlUrl);
                cell.imageView.image = image;
            }
            cell.textLabel.text = @"Pictures";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
        }
        else if (row == 7)
        {
            cell.imageView.image = [UIImage imageNamed:@"map.png"];
            cell.textLabel.text = @"Map";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        
        
    }
    else
    {
        
        return nil;
    }

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
    if (indexPath.row == 6)
    {
        AlbumContentsViewController *albumContentsViewController = [AlbumContentsViewController alloc] ;
        NSLog(@"Pushing AlbumContents view controller %s %d\n" , __FILE__, __LINE__);
      //  albumContentsViewController.assetsGroup = group_;
        
        [albumContentsViewController setDelphoto:false];
        [albumContentsViewController setPFlMgr:pFlMgr];
        [albumContentsViewController setPAlName:pAlName];
        [albumContentsViewController setNavViewController:navViewController];
        albumContentsViewController = [albumContentsViewController initWithNibName:@"AlbumContentsViewController" bundle:nil];
        [self.navigationController pushViewController:albumContentsViewController animated:NO];
        
        [albumContentsViewController  setTitle:[delegate getDispItemTitle]];
       navViewController.navigationBar.topItem.title = [NSString stringWithString:[delegate getDispItemTitle]];
        
    }
    else if (indexPath.row == 7)
    {
        MKCoordinateSpan span;
        
        CLLocationCoordinate2D loc;
       
        loc.longitude = [delegate getDispLongitude];
        loc.latitude = [delegate getDispLatitude];
        span.latitudeDelta = 0.001;
        span.longitudeDelta = 0.001;
        if (fabs(loc.latitude) > 50.0)
            span.longitudeDelta = 0.002;
        MKCoordinateRegion reg = MKCoordinateRegionMake(loc, span);
        MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
        NSLog(@"Setting region to %f %f %f %f\n", reg.center.latitude, reg.center.longitude, reg.span.longitudeDelta, reg.span.latitudeDelta);
        [mapViewController  setTitle:[delegate getDispItemTitle]];
        mapViewController.reg = reg;
         [self.navigationController pushViewController:mapViewController animated:NO];
    }
    else if (indexPath.row == 5)
    {
        NotesViewController *notesViewController = [NotesViewController alloc] ;
        NSLog(@"Pushing Notes view controller %s %d\n" , __FILE__, __LINE__);
        //  albumContentsViewController.assetsGroup = group_;
        notesViewController.notes.editable = NO;
        notesViewController.mode = eNotesModeDisplay;
        
        notesViewController.title = [delegate getDispItemTitle];
        notesViewController.notesTxt = [delegate getDispNotes];
        notesViewController = [notesViewController initWithNibName:@"NotesViewController" bundle:nil];
        [self.navigationController pushViewController:notesViewController animated:NO];   
    }
    else if (indexPath.row == 4)
    {
            AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
        if (checkListArr == nil)
        {
            checkListArr = [pAppCmnUtil.dataSync getList:[delegate getDispName]];
        }
        
        if (checkListArr != nil)
        {
            
            List1ViewController *aViewController = [List1ViewController alloc];
            aViewController.editMode = eListModeDisplay;
            aViewController.bEasyGroc = false;
            aViewController.mlistName = nil;
            aViewController.bDoubleParent = false;
            aViewController.list = checkListArr;
            pAppCmnUtil.listName = [delegate getDispName];
            aViewController.name = [delegate getDispName];
            aViewController = [aViewController initWithNibName:nil bundle:nil];
            
            [pAppCmnUtil.navViewController pushViewController:aViewController animated:NO];
        }
    }
}

@end
