//
//  List1ViewController.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 5/19/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import "List1ViewController.h"
#import "List.h"
#import "AppCmnUtil.h"

@interface AddRowTarget : NSObject

@property (nonatomic) NSUInteger rowNo;
@property (nonatomic, weak) List1ViewController *pLst1Vw;

-(void) addRow1;
@end

@implementation AddRowTarget

@synthesize rowNo;
@synthesize pLst1Vw;

-(void) addRow1
{
    [pLst1Vw addRow:rowNo];
    return;
}

@end





@implementation List1ViewController

@synthesize editMode;
@synthesize name;
@synthesize itemMp;
@synthesize hiddenMp;
@synthesize hiddenCells;
@synthesize pSearchBar;
@synthesize default_name;


-(void) cleanUpItemMp
{
    NSArray *keys = [itemMp allKeys];
    NSUInteger cnt = [keys count];
    
    for (NSUInteger i=0; i < cnt; ++i)
    {
        NSNumber *rowNo = [keys objectAtIndex:i];
        NSString *item = [itemMp objectForKey:rowNo];
        if ([item isEqualToString:@" "] == YES)
            [itemMp removeObjectForKey:rowNo];
    }
    
    return;
}

-(void) addRow:(NSUInteger)rowNo
{
    NSUInteger insrtedRowNo = rowNo + 1;
    NSArray *insertIndexPaths = [NSArray arrayWithObjects:
                                 [NSIndexPath indexPathForRow:insrtedRowNo inSection:0],
                                 nil];
    UITableView *tv = self.tableView;
    
 
    
    ++nRows;
    NSArray *keys1 = [itemMp allKeys];
    NSArray *keys = [keys1 sortedArrayUsingSelector: @selector(compare:)];
    
    NSInteger no_of_items = [keys count];
    
    NSString  *prevItem = nil;
    
    NSUInteger lastIndx = -1;
       NSLog(@"Inserting row at index=%lu no_of_items=%ld", (unsigned long)insrtedRowNo, (long)no_of_items);
    for(NSUInteger i=0; i < no_of_items; ++i)
    {
        NSNumber *rowNo1 = [keys objectAtIndex:i];
        lastIndx = [rowNo1 unsignedIntegerValue];
        if (lastIndx < insrtedRowNo)
            continue;
        NSString *item = prevItem;
        
        prevItem = [itemMp objectForKey:rowNo1];
        if (insrtedRowNo != [rowNo1 unsignedIntegerValue])
        {
            NSLog(@"Setting object %@ for key %@", item, rowNo1);
            [itemMp setObject:item forKey:rowNo1];
        }
        else
        {
            [itemMp setObject:@" " forKey:rowNo1];
             NSLog(@"Removing object %@ for key %@", item, rowNo1);
        }
        
        AddRowTarget *pBtnAct = [rowTarget objectForKey:rowNo1];
        if (pBtnAct != nil)
        {
            pBtnAct.rowNo = pBtnAct.rowNo+1;
            NSLog(@"Setting pBtnAct rowNo=%ld in rowNo1=%@ item=%@", (unsigned long)pBtnAct.rowNo, rowNo1, item);
        }
        
    }
    
    if (prevItem != nil && lastIndx != -1)
    {
        ++lastIndx;
        NSLog(@"Setting last object %@ for key %ld", prevItem, (long)lastIndx);
        [itemMp setObject:prevItem forKey:[NSNumber numberWithUnsignedInteger:lastIndx]];
    }
    
    if (insrtedRowNo == (no_of_items+1))
    {
        [itemMp setObject:@" " forKey:[NSNumber numberWithInteger:insrtedRowNo]];
    }
    

    [tv beginUpdates];
    [tv insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight];
    [tv endUpdates];
    [tv reloadData];
    return;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        bDicInit = false;
        bSearchStr = false;
        inEditAction = false;
        textFldRowNo = -1;
        CGRect viewRect = CGRectMake(0, 0, 320, 45);
        pSearchBar = [[UISearchBar alloc] initWithFrame:viewRect];
        pSearchBar.delegate = self;
        hiddenCells  = [[NSMutableDictionary alloc] init];
        hiddenMp =[[NSMutableDictionary alloc] init];
        inDeleteAction = false;
        undoArry = [[NSMutableArray alloc] init];
        redoArry  = [[NSMutableArray alloc] init];
        rowTarget = [[NSMutableDictionary alloc] init];
       
        AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
        if (editMode == eListModeAdd)
        {
            NSLog(@"Initializing List1ViewController in eListModeAdd\n");
            if (pAppCmnUtil.mlistName != nil)
            {
                [self refreshMasterList];
            }
            else
            {
                [self createNewList];
            }
        }
        else if (pAppCmnUtil.listName != nil)
        {
            NSLog(@"Initializing List1ViewController in eListModeDisplay\n");
            [self refreshList];
        }
    }
    return self;
    
}

-(void) createNewList
{
    name = @"List";
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *formattedDateString = [dateFormatter stringFromDate:today];
    name = [name stringByAppendingString:@" "];
    name = [name stringByAppendingString:formattedDateString];
    default_name = name;
    nRows = 50;
    itemMp = [NSMutableDictionary dictionaryWithCapacity:15];

    return;
}

-(void) refreshMasterList
{
    
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    mlist = [pAppCmnUtil.dataSync getMasterList:pAppCmnUtil.mlistName];
    name = pAppCmnUtil.mlistName;
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *formattedDateString = [dateFormatter stringFromDate:today];
    name = [name stringByAppendingString:@" "];
    name = [name stringByAppendingString:formattedDateString];
    default_name = name;
    NSLog(@"Master list %@ for name %@ %s %d\n", mlist, name, __FILE__, __LINE__);
    if (mlist != nil)
    {
        nRows = [mlist count]+1;
        
        itemMp = [NSMutableDictionary dictionaryWithCapacity:nRows];
        for (NSUInteger i=0; i < nRows-1; ++i)
        {
            NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:i+1];
            [itemMp setObject:[mlist objectAtIndex:i] forKey:rowNm];
        }
        nRows += 35;
        NSLog(@"Setting nRows %lu\n", (unsigned long)nRows);
        
    }
    else
    {
        nRows = 50;
        itemMp = [NSMutableDictionary dictionaryWithCapacity:50];
    }
    NSLog(@"itemMp dictionary to set view %@\n", itemMp);
    return;

    
    return;
}

-(void) refreshListFromCpy:(List1ViewController *)pLst
{
    name = pLst.name;
    default_name = name;
    itemMp = pLst.itemMp;
    hiddenMp = pLst.hiddenMp;
    hiddenCells = pLst.hiddenCells;
    nRows = [itemMp count] +2;
    return;
}

-(void) refreshList
{
    
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    list = [pAppCmnUtil.dataSync getList:pAppCmnUtil.listName];
    name = pAppCmnUtil.listName;
    default_name = name;
    NSLog(@"list %@ for name %@ %s %d\n", list, name, __FILE__, __LINE__);
    if (list != nil)
    {
        nRows = [list count]+1;
        
        itemMp = [NSMutableDictionary dictionaryWithCapacity:nRows];
        hiddenMp = [NSMutableDictionary dictionaryWithCapacity:nRows];
        for (NSUInteger i=0; i < nRows-1; ++i)
        {
            NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:i+1];
            List *item = [list objectAtIndex:i];
            [itemMp setObject:item.item forKey:rowNm];
            if (editMode == eListModeDisplay)
            {
                NSNumber *rowVal = [NSNumber numberWithBool:item.hidden];
                [hiddenMp setObject:rowVal forKey:rowNm];
                if (item.hidden == YES)
                {
                    [hiddenCells setObject:rowVal forKey:rowNm];
                }
            }
        }
        if (editMode != eListModeDisplay)
            nRows += 35;
        else
            nRows += 3;
        NSLog(@"Setting nRows %lu\n", (unsigned long)nRows);
        
    }
    else
    {
        if (editMode != eListModeDisplay)
        {
            nRows = 50;
            itemMp = [NSMutableDictionary dictionaryWithCapacity:5];
        }
        else
        {
            nRows = 2;
        }
    }
    NSLog(@"itemMp dictionary to set view %@\n", itemMp);

    return;
}

- (void)itemAddDone
{
     AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    List1ViewController *pListView = (List1ViewController *)[pAppCmnUtil.navViewController popViewControllerAnimated:NO];
    [pAppCmnUtil popView];
    if (![pListView.itemMp count])
    {
        NSLog(@"Empty list not adding");
        return;
    }
    [pListView cleanUpItemMp];
    [pAppCmnUtil.dataSync addItem:pListView.name itemsDic:pListView.itemMp];
    [self itemDisplay:pListView.name lstcntr:pListView];
    
    return;
}

-(void) itemDisplay:(NSString *)listname
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    pAppCmnUtil.listName = listname;
    [pAppCmnUtil.dataSync selectedItem:listname];
    List1ViewController *aViewController = [List1ViewController alloc];
    aViewController.editMode = eListModeDisplay;
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    [pAppCmnUtil.navViewController pushViewController:aViewController animated:YES];
    return;
}




-(void) itemEditCancel
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    List1ViewController *pListView = (List1ViewController *)[pAppCmnUtil.navViewController popViewControllerAnimated:NO];
    [self itemDisplay:pListView.name];
    return;
}

-(void) itemDisplay:(NSString *)itemname lstcntr:(List1ViewController *)pLst
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    pAppCmnUtil.listName = itemname;
    [pAppCmnUtil.dataSync selectedItem:itemname];
    List1ViewController *aViewController = [List1ViewController alloc];
    aViewController.editMode = eListModeDisplay;
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    [pAppCmnUtil.navViewController pushViewController:aViewController animated:YES];
    [aViewController refreshListFromCpy:pLst];
    [aViewController.tableView reloadData];
    
    return;
}

- (void) itemAddCancel
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    [pAppCmnUtil popView];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
   
    if (editMode == eListModeAdd)
    {
        NSString *title = @"New List";
        self.navigationItem.title = [NSString stringWithString:title];
        
        UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(itemAddDone) ];
        self.navigationItem.rightBarButtonItem = pBarItem;
        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(itemAddCancel) ];
        self.navigationItem.leftBarButtonItem = pBarItem1;
    }
    else if (editMode == eListModeEdit)
    {
        NSString *title = @"Edit List";
        self.navigationItem.title = [NSString stringWithString:title];
        
        UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(itemEditActions)];
        
        self.navigationItem.rightBarButtonItem = pBarItem;

        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(itemEditCancel) ];
        self.navigationItem.leftBarButtonItem = pBarItem1;
    }
    else
    {
        NSString *title = @"List";
        self.navigationItem.title = [NSString stringWithString:title];
        
        UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(itemDispActions)];
        
        self.navigationItem.rightBarButtonItem = pBarItem;
       
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(editMode != eListModeDisplay)
        [self.tableView setEditing:YES animated:YES];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"Updating hidden items in  view will disappear");
    if (editMode == eListModeDisplay)
    {
        if (bSearchStr )
        {
            if (hiddenCellsUnFiltrdMp != nil && [hiddenCellsUnFiltrdMp count])
                hiddenCells = [[NSMutableDictionary alloc] initWithDictionary:hiddenCellsUnFiltrdMp];
            if (hiddenUnFiltrdMp != nil && [hiddenUnFiltrdMp count] )
                hiddenMp = [[NSMutableDictionary alloc] initWithDictionary:hiddenUnFiltrdMp];
            itemMp = [[NSMutableDictionary alloc] initWithDictionary:itemUnFiltrdMp];
        }
        
        AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
        if (itemMp == nil || ![itemMp count] || hiddenMp == nil || ![hiddenMp count])
            return;
        [pAppCmnUtil.dataSync hiddenItems:name itemsDic:itemMp hiddenDic:hiddenMp];
    }
}

-(void) itemDispActions
{
    
    UIActionSheet *pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Undo", @"Redo", @"Show All", @"Edit", nil];
    
    [pSh showInView:self.tableView];
    [pSh setDelegate:self];
    

    return;
}

-(void) itemEditActions
{
    inEditAction = true;
    UIActionSheet *pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", @"Delete", nil];
    
    [pSh showInView:self.tableView];
    [pSh setDelegate:self];
    
    
    return;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) DeleteConfirm
{
    
    //printf("Launch UIActionSheet");
    NSLog(@"Touched delete list button\n");
    inDeleteAction = true;
    UIActionSheet *pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete List" otherButtonTitles:nil];
    [pSh showInView:self.tableView];
    [pSh setDelegate:self];
    
}

-(void) itemEditDone
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    List1ViewController *pListView = (List1ViewController *)[pAppCmnUtil.navViewController popViewControllerAnimated:NO];
    [pAppCmnUtil popView];
    [pListView cleanUpItemMp];
    [pAppCmnUtil.dataSync editItem:pListView.name itemsDic:pListView.itemMp];
    [self itemDisplay:pListView.name lstcntr:pListView];
    return;
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    printf("Clicked button at index %ld in display list\n", (long)buttonIndex);
    
    if (inEditAction)
    {
        inEditAction = false;
        switch (buttonIndex)
        {
            case eSaveList:
            {
                
                [self itemEditDone];
            }
            break;
                
            case eDeleteList:
                [self DeleteConfirm];
                break;
                
            default:
                break;
        }
        return;
    }
    
    if (inDeleteAction)
    {
        inDeleteAction = false;
        if (!buttonIndex)
        {
            AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
            [pAppCmnUtil.dataSync deletedEasyItem:name];
            [pAppCmnUtil popView];

        }
        return;
    }
    
    switch (buttonIndex)
    {
        case eUndoHide:
        {
            if (![undoArry count])
                break;
            NSNumber *undoIndx = [undoArry lastObject];
            [undoArry removeLastObject];
            [hiddenCells removeObjectForKey:undoIndx];
            [redoArry addObject:undoIndx];
            NSNumber *hidden = [NSNumber numberWithBool:NO];
            [hiddenMp setObject:hidden forKey:undoIndx];
            [self.tableView reloadData];
        }
        break;
            
        case eRedoHide:
        {
            if (![redoArry count])
                break;
            NSNumber *redoIndx = [redoArry lastObject];
            [redoArry removeLastObject];
            NSNumber *redoIndx1 = [NSNumber numberWithUnsignedInteger:[redoIndx unsignedIntegerValue]];
            [hiddenCells setObject:redoIndx1 forKey:redoIndx];
            NSNumber *hidden = [NSNumber numberWithBool:YES];
            [hiddenMp setObject:hidden forKey:redoIndx];
            [self.tableView reloadData];
        }
        break;
        
        case eShowAll:
        {
            [hiddenCells removeAllObjects];
            NSUInteger count = [hiddenMp count];
            for (NSUInteger i=0; i < count; ++i )
            {
                NSNumber *hidden = [NSNumber numberWithBool:NO];
                [hiddenMp setObject:hidden forKey:[NSNumber numberWithUnsignedInteger:i]];

            }
            [self.tableView reloadData];
            /*
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
             */
            
            
       
        }
        break;
            
        case eEditList:
        {
            
            [self itemEdit];
        }
        break;
            
        default:
            break;
    }
    
    return;
}

-(void) itemEdit
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    [pAppCmnUtil popView];
    List1ViewController *aViewController = [List1ViewController alloc];
    aViewController.editMode = eListModeEdit;
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    [pAppCmnUtil.navViewController pushViewController:aViewController animated:YES];
    
    return;
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
    NSLog(@"Search button clicked Initiating new search with %@\n", [searchBar text]);
   
    if(!bDicInit)
    {
        bDicInit = true;
        itemUnFiltrdMp = [[NSDictionary alloc] initWithDictionary:itemMp];
        
    }
    
    if(!bSearchStr)
    {
        hiddenUnFiltrdMp = [[NSDictionary alloc] initWithDictionary:hiddenMp];
        hiddenCellsUnFiltrdMp = [[NSDictionary alloc] initWithDictionary:hiddenCells];
    }
    itemMp = [NSMutableDictionary dictionaryWithCapacity:nRows];
    hiddenMp = [NSMutableDictionary dictionaryWithCapacity:nRows];
    hiddenCells = [NSMutableDictionary dictionaryWithCapacity:nRows];
    NSArray *keys = [itemUnFiltrdMp allKeys];
    NSUInteger cnt = [keys count];
    NSUInteger rowno =0;
    for (NSUInteger i=0; i < cnt; ++i)
    {
        NSString *item = [itemUnFiltrdMp objectForKey:[keys objectAtIndex:i]];
        NSStringCompareOptions  opt = NSCaseInsensitiveSearch;
        NSRange aR = [item rangeOfString:[searchBar text] options:opt];
        if (aR.location == NSNotFound && aR.length ==0)
        {
            continue;
        }
        NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:rowno+1];
        [itemMp setObject:item forKey:rowNm];
        NSNumber *rowVal = [hiddenCellsUnFiltrdMp objectForKey:[keys objectAtIndex:i]];
        if (rowVal != nil)
            [hiddenMp setObject:rowVal forKey:rowNm];
        ++rowno;
    }
    bSearchStr = true;
    //pDlg.dataSync.refreshNow = true;
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    printf("Started editing search bar %s %d\n", __FILE__, __LINE__);
    
    searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
       bSearchStr = false;
    searchBar.text = nil;
    //  pDlg.dataSync.refreshNow = true;
     itemMp = [[NSMutableDictionary alloc] initWithDictionary:itemUnFiltrdMp];
     hiddenCells = [[NSMutableDictionary alloc] initWithDictionary:hiddenCellsUnFiltrdMp];
    hiddenMp = [[NSMutableDictionary alloc] initWithDictionary:hiddenUnFiltrdMp];
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
    return;
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
    return nRows;
}

- (void)switchToggled:(id)sender
{
    UISwitch *toggleSwitch = (UISwitch *)sender;
       NSNumber *swtchKey = [NSNumber numberWithUnsignedInteger:toggleSwitch.tag];
 
      NSNumber *swtchKey1 = [NSNumber numberWithUnsignedInteger:toggleSwitch.tag];
    [hiddenCells setObject:swtchKey1 forKey:swtchKey];

    [undoArry addObject:swtchKey];
    
    NSNumber *hidden = [NSNumber numberWithBool:YES];
    [hiddenMp setObject:hidden forKey:swtchKey];
    [self.tableView reloadData];
}

- (void)textChanged:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    NSIndexPath *indPath = [self.tableView indexPathForCell:cell];
    //  NSLog(@"Text field changed editing %s %d\n", [textField.text UTF8String], indPath.row);
    switch (indPath.row)
    {
        case 0:
        {
            NSUInteger len = [textField.text length];
            if (len)
                name = textField.text;
            else
                name = default_name;
        }
            break;
            
        default:
        {
            NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:indPath.row];
            NSUInteger len = [textField.text length];
            if (len)
            {
                [itemMp setObject:textField.text forKey:rowNm];
                if (indPath.row > nRows-3)
                {
                    nRows+=35;
                    [self.tableView reloadData];
                }
            }
            else
                [itemMp removeObjectForKey:rowNm];
           
        }
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    
    [theTextField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
   
    NSLog(@"List1ViewController:textFieldShouldEndEditing %ld %lu", (long)textFldRowNo, (unsigned long)nRows);
    if (editMode != eListModeDisplay)
    {
        if (textFldRowNo != -1)
        {
           
            self.tableView.editing = NO;
            self.tableView.editing = YES;
        }
        [textField resignFirstResponder];
        
        return YES;
    }
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (editMode == eListModeEdit)
    {
        UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
        NSIndexPath *indPath = [self.tableView indexPathForCell:cell];
        if (indPath.row)
        {
            
            self.tableView.editing = NO;
            self.tableView.editing = YES;
        }

        if (!indPath.row)
            return NO;
    }
    if (editMode != eListModeDisplay)
    {
        textFldRowNo = textField.tag;
        return YES;
    }
    return NO;
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editMode != eListModeDisplay)
    {
        if ([itemMp objectForKey:[NSNumber numberWithInteger:indexPath.row]] != nil)
            return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
 
    NSLog(@"Move row at %ld to %ld", (long)sourceIndexPath.row, (long)destinationIndexPath.row);
    if (destinationIndexPath.row == sourceIndexPath.row)
        return;
    
    NSNumber *soureRow = [NSNumber numberWithInteger:sourceIndexPath.row];
    NSString *sourceItem = [itemMp objectForKey:soureRow];
    NSString *prevItem;
    
    NSArray *keys1 = [itemMp allKeys];
     NSArray *keys = [keys1 sortedArrayUsingSelector: @selector(compare:)];
    NSInteger no_of_items = [keys count];
    for(NSUInteger i=0; i < no_of_items; ++i)
    {
         NSNumber *rowNo = [keys objectAtIndex:i];
         if ([rowNo unsignedIntegerValue] < sourceIndexPath.row && [rowNo unsignedIntegerValue] < destinationIndexPath.row)
             continue;
        
        if ([rowNo unsignedIntegerValue] > sourceIndexPath.row && [rowNo unsignedIntegerValue] > destinationIndexPath.row)
            break;
        if (sourceIndexPath.row < destinationIndexPath.row)
        {
                if ([rowNo unsignedIntegerValue] == sourceIndexPath.row)
                    continue;
                else if ([rowNo unsignedIntegerValue] < destinationIndexPath.row)
                {
                    NSString *item = [itemMp objectForKey:rowNo];
                    NSUInteger newKey = [rowNo unsignedIntegerValue];
                    --newKey;
                    [itemMp setObject:item forKey:[NSNumber numberWithUnsignedInteger:newKey]];
                }
                else
                {
                    NSString *item = [itemMp objectForKey:rowNo];
                    NSUInteger newKey = [rowNo unsignedIntegerValue];
                    --newKey;
                    [itemMp setObject:item forKey:[NSNumber numberWithUnsignedInteger:newKey]];
                    [itemMp setObject:sourceItem forKey:rowNo];
                }
        }
        else
        {
            if ([rowNo unsignedIntegerValue] == destinationIndexPath.row)
            {
                prevItem = [itemMp objectForKey:rowNo];
                [itemMp setObject:sourceItem forKey:rowNo];
            }
            else
            {
                NSString *tmpItem = [itemMp objectForKey:rowNo];
                [itemMp setObject:prevItem forKey:rowNo];
                prevItem = tmpItem;
            }
        }
        
    }
    [tableView reloadData];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
       
        NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:indexPath.row];
        [itemMp removeObjectForKey:rowNm];
        NSArray *keys1 = [itemMp allKeys];
        NSArray *keys = [keys1 sortedArrayUsingSelector: @selector(compare:)];
        --nRows;
        NSInteger no_of_items = [keys count];
        
        for(NSUInteger i=0; i < no_of_items; ++i)
        {
            NSNumber *rowNo = [keys objectAtIndex:i];
            if ([rowNo unsignedIntegerValue] < indexPath.row)
                continue;
            NSString *item = [itemMp objectForKey:rowNo];
            
                
            [itemMp removeObjectForKey:rowNo];
            NSUInteger newKey = [rowNo unsignedIntegerValue];
            --newKey;
            [itemMp setObject:item forKey:[NSNumber numberWithUnsignedInteger:newKey]];
        }
         NSLog(@"Commit editing style keys %@ itemMp %@ %ld for row %ld", keys, itemMp, (long)editingStyle, (long)indexPath.row);
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView reloadData];
    }
    
   
}


- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSNumber *key = [NSNumber numberWithInteger:indexPath.row];
    
    if ([hiddenCells objectForKey:key] != nil)
        return 0.0;
    
    return self.tableView.rowHeight;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editMode != eListModeDisplay)
    {
        if ([itemMp objectForKey:[NSNumber numberWithInteger:indexPath.row]] != nil)
        {
            UITableViewCell *pCell = [self.tableView cellForRowAtIndexPath:indexPath];
            if (pCell != nil)
            {
                UIButton *pAddBtn = (UIButton *)pCell.editingAccessoryView;
                if(pAddBtn != nil)
                    pAddBtn.hidden = NO;
            }
         
        return UITableViewCellEditingStyleDelete;
        }
    }
    return UITableViewCellEditingStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"List1Cell";
    static NSArray* fieldNames = nil;
    if (!fieldNames)
    {
        fieldNames = [NSArray arrayWithObjects:@"Name", nil];
    }
    
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil || cell.bounds.size.height == 0.0)
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
        cell.textLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = nil;
        cell.accessoryView = nil;
        cell.editingAccessoryView = nil;
    }
    
    if (indexPath.section != 0)
        return nil;
    NSUInteger row = indexPath.row;
    NSNumber *key = [NSNumber numberWithInteger:indexPath.row];
    
   if ([hiddenCells objectForKey:key] != nil)
        return cell;
    switch (row)
    {
        case 0:
        {
            if (editMode == eListModeDisplay)
            {
                [cell.contentView addSubview:pSearchBar];
                break;
            }
            
            CGRect textFrame = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y, cell.bounds.size.width, cell.bounds.size.height);
            
            UITextField *textField = [[UITextField alloc] initWithFrame:textFrame];
            textField.delegate = self;
            [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            if (name == nil)
            {
                NSString *pListName = @"List";
                name = pListName;
                NSDate *today = [NSDate date];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
                NSString *formattedDateString = [dateFormatter stringFromDate:today];
                name = [name stringByAppendingString:@" "];
                name = [name stringByAppendingString:formattedDateString];
                default_name =name;
                textField.text = name;
            }
            else
            {
                NSArray *pArr = [name componentsSeparatedByString:@":::"];
                NSString *textLstName = [pArr objectAtIndex:[pArr count]-1];
                textField.text = textLstName;
            }
            textField.tag = 0;
            [cell.contentView addSubview:textField];
        }
            
            break;
            
        default:
        {
            CGRect textFrame = CGRectMake(cell.bounds.origin.x+10, cell.bounds.origin.y, cell.bounds.size.width, cell.bounds.size.height);
            UITextField *textField = [[UITextField alloc] initWithFrame:textFrame];
            textField.delegate = self;
            [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            if(editMode == eListModeDisplay)
            {
                if (row == 1)
                {
                    if (name != nil)
                    {
                        textField.text = name;
                        [cell.contentView addSubview:textField];
                    }
                    break;
                }
            }
                NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:editMode == eListModeDisplay?row-1: row];
                NSString *item = [itemMp objectForKey:rowNm];
                if (item != nil)
                {
                    //Ignoring the space place holder for empty inserted rows
                    if ([item isEqualToString:@" "] == NO)
                        textField.text = item;
                    if (editMode == eListModeDisplay)
                    {
                        
                        CGRect switchFrame = CGRectMake(cell.bounds.size.width - 15, cell.bounds.origin.y, cell.bounds.size.width, cell.bounds.size.height);
                        UISwitch *hideCell = [[UISwitch alloc] initWithFrame:switchFrame];
                        [hideCell addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
                        cell.accessoryView = hideCell;
                        hideCell.on = YES;
                        
                        hideCell.tag = row;
                    }
                    else
                    {
                       //cell.editing =YES;
                        cell.showsReorderControl = YES;
                        UIButton *rowAddButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
                        
                        AddRowTarget *pBtnAct= [[AddRowTarget alloc] init];
                        [rowTarget setObject:pBtnAct forKey:rowNm];
                        pBtnAct.rowNo = row;
                        pBtnAct.pLst1Vw = self;
                        [rowAddButton addTarget:pBtnAct action:@selector(addRow1) forControlEvents:UIControlEventTouchDown];
                        cell.editingAccessoryView = rowAddButton;
                        
                        
                    }
                }
                else
                {
                    
                    if (editMode != eListModeDisplay)
                    {
                        
                        UIButton *rowAddButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
                        
                        AddRowTarget *pBtnAct= [[AddRowTarget alloc] init];
                        [rowTarget setObject:pBtnAct forKey:rowNm];
                        pBtnAct.rowNo = row;
                        pBtnAct.pLst1Vw = self;
                        [rowAddButton addTarget:pBtnAct action:@selector(addRow1) forControlEvents:UIControlEventTouchDown];
                        cell.editingAccessoryView = rowAddButton;
                        rowAddButton.hidden = YES;

                    }
                    
                }
                textField.tag = row;
                [cell.contentView addSubview:textField];
            
                //NSLog(@"Adding textField %@ %f %f %f %f", textField.text, textFrame.origin.x, textFrame.origin.y, textFrame.size.height, textFrame.size.width);
                
            }
            
            break;
            
    }

        
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



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
