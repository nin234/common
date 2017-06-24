//
//  ListViewController.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 4/2/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import "ListViewController.h"
#import "AppCmnUtil.h"
#import "MasterList.h"
#import "LocalMasterList.h"
#import "SeasonPickerViewController.h"



@interface AddRowTargetTmpl : NSObject

@property (nonatomic) NSUInteger rowNo;
@property (nonatomic, weak) ListViewController *pLstVw;
@property (nonatomic, weak) UIButton *rowAddButton;
@property (nonatomic, weak) UIButton *seasonPicker;

-(void) addRow1;
@end

@implementation AddRowTargetTmpl

@synthesize rowNo;
@synthesize pLstVw;
@synthesize rowAddButton;
@synthesize seasonPicker;




-(void) addRow1
{
    [pLstVw addRow:rowNo];
    return;
}

-(void) selectSeason
{
    [pLstVw showSeasonPicker:rowNo];
}

@end


@interface ListViewController ()

@end

@implementation ListViewController

@synthesize name;
@synthesize itemMp;
@synthesize editMode;
@synthesize nRows;
@synthesize mlist;
@synthesize default_name;
@synthesize mlistName;
@synthesize easyGrocLstType;
@synthesize pCompVwCntrl;
@synthesize bCheckListView;


-(void) showSeasonPicker : (NSUInteger) rowNo
{
    
    seasonPickerRowNo = rowNo;
    SeasonPickerViewController *pPickerVwCntrl = [SeasonPickerViewController alloc];
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:rowNo];
    LocalMasterList *item = [itemMp objectForKey:rowNm];
    
   pPickerVwCntrl.mitem = item;
   pPickerVwCntrl = [pPickerVwCntrl initWithNibName:nil bundle:nil];
    reloadAfterSeasonPicked = true;
    NSLog(@"Launching season picker for row %lu", (unsigned long)rowNo);
    [pAppCmnUtil.navViewController pushViewController:pPickerVwCntrl animated:NO];
    
}

-(void) cleanUpItemMp
{
    NSArray *keys = [itemMp allKeys];
    NSUInteger cnt = [keys count];
    
    for (NSUInteger i=0; i < cnt; ++i)
    {
        NSNumber *rowNo = [keys objectAtIndex:i];
        LocalMasterList *item = [itemMp objectForKey:rowNo];
        if ([item.item isEqualToString:@" "] == YES)
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
    
    NSLog(@"Inserting row at index=%lu no_of_items=%ld", (unsigned long)insrtedRowNo, (long)no_of_items);
    NSMutableDictionary *itemMpCpy = [[NSMutableDictionary alloc] initWithDictionary:itemMp];
    [itemMp removeAllObjects];
    for(NSUInteger i=0; i < no_of_items; ++i)
    {
        NSNumber *rowNo1 = [keys objectAtIndex:i];
        NSUInteger row = [rowNo1 unsignedIntegerValue];
        LocalMasterList *item = [itemMpCpy objectForKey:rowNo1];
        if (row < insrtedRowNo)
        {
            [itemMp setObject:item forKey:rowNo1];
            continue;
        }
        else
        {
            ++row;
            item.rowno = row;
            [itemMp setObject:item forKey:[NSNumber numberWithUnsignedInteger:row]];
        }
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
        bCheckListView = false;
        inEditAction = false;
        textFldRowNo = -1;
        rowTarget = [[NSMutableDictionary alloc] init];
        reloadAfterSeasonPicked = false;
        if (editMode != eViewModeDisplay)
            [self.tableView setEditing:YES animated:YES];
        [self refreshMasterList];
                
    }
    return self;
}

-(void) refreshMasterListCpyFromLstVwCntrl:(ListViewController *) pLst
{
    itemMp = pLst.itemMp;
    name = pLst.name;
    default_name = name;
    NSLog(@"Refreshing master list in ListViewController by Copy");
    NSLog(@"Master list %@ for name %@ after copy %s %d\n", itemMp, name, __FILE__, __LINE__);
    nRows = [itemMp count] +2;
    
}

-(void) refreshMasterList
{
     AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    if (mlistName != nil)
        mlist = [pAppCmnUtil.dataSync getMasterList:mlistName];
    else
        mlist = nil;
    name = mlistName;
    
    default_name = name;
    NSLog(@"Refreshing master list in ListViewController");
    NSLog(@"Master list %@ for name %@ %s %d\n", mlist, name, __FILE__, __LINE__);
    [self refreshMasterListImpl];
    return;
}

-(void) refreshMasterListImpl
{
    if (mlist != nil)
    {
        nRows = [mlist count]+1;
        NSUInteger mlistcnt = [mlist count];
        
        itemMp = [NSMutableDictionary dictionaryWithCapacity:nRows];
        for (NSUInteger i=0; i < mlistcnt; ++i)
        {
            MasterList *itemML = [mlist objectAtIndex:i];
            LocalMasterList *item = [[LocalMasterList alloc] initFromMasterList:itemML];
              NSNumber *rowNm = [NSNumber numberWithLongLong:item.rowno];
            if (item.rowno > nRows)
                nRows = (NSUInteger) item.rowno;
            [itemMp setObject:item forKey:rowNm];
        }
        if (editMode != eViewModeDisplay)
            nRows += 13;
        else
            nRows += 3;
       
        
    }
    else
    {
        nRows = 15;
        itemMp = [NSMutableDictionary dictionaryWithCapacity:50];
    }
     NSLog(@"Setting nRows %lu\n", (unsigned long)nRows);
    NSLog(@"itemMp dictionary to set view %@\n", itemMp);
}

-(void) templItemEditCancel
{
    
     AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    [pAppCmnUtil popView];
    return;
}

- (void)templItemEdit
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    [pAppCmnUtil popView];
    
    ListViewController *aViewController = [ListViewController alloc];
    aViewController.editMode = eViewModeEdit;
    aViewController.easyGrocLstType = easyGrocLstType;
    aViewController.mlistName = mlistName;
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    [pAppCmnUtil.navViewController pushViewController:aViewController animated:YES];
    return;
}

-(void) templItemDisplay:(NSString *)templ_name lstcntr:(ListViewController *) pLst
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    ListViewController *aViewController = [ListViewController alloc];
    aViewController.editMode = eViewModeDisplay;
    aViewController.easyGrocLstType = easyGrocLstType;
    aViewController.name = templ_name;
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    [pAppCmnUtil.navViewController pushViewController:aViewController animated:YES];
    [aViewController refreshMasterListCpyFromLstVwCntrl:pLst];
    [aViewController.tableView reloadData];
    return;
}


- (void)templItemAddDone
{
     AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    
    ListViewController *pListView = (ListViewController *)[pAppCmnUtil.navViewController popViewControllerAnimated:NO];
    
    //[self templItemDisplay:pListView.name lstcntr:pListView];
    [pListView cleanUpItemMp];
    if (bCheckListView)
    {
        [pAppCmnUtil.dataSync addTemplName:pListView.name];
    }
    
    [pAppCmnUtil.dataSync addTemplItem:pListView.name itemsDic:pListView.itemMp];
    if (pAppCmnUtil.bEasyGroc && [pListView.itemMp count])
    {
        switch (easyGrocLstType)
        {
            case eInvntryLst:
                pCompVwCntrl.invLstExists = true;
                break;
                
            case eScratchLst:
                pCompVwCntrl.scrtchLstExists = true;
                break;
                
            case eRecurrngLst:
                pCompVwCntrl.recrLstExists = true;
                break;
                
            default:
                break;
        }
 
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

- (void) templItemAddCancel
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    [pAppCmnUtil.navViewController popViewControllerAnimated:NO];
}

- (void) templItemEditDone
{
     AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    ListViewController *pListView = (ListViewController *)[pAppCmnUtil.navViewController popViewControllerAnimated:NO];
    [pListView cleanUpItemMp];
    [pAppCmnUtil.dataSync editedTemplItem:pListView.name itemsDic:pListView.itemMp];
    return;
}

- (void)switchToggled:(id)sender
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    UISwitch *toggleSwitch = (UISwitch *)sender;
    NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:toggleSwitch.tag];
    LocalMasterList *item = [itemMp objectForKey:rowNm];
    if (item != nil)
    {
        if (toggleSwitch.on == YES)
        {
            item.inventory = 10;
        }
        else
        {
            item.inventory = 0;
        }
    }
    [pAppCmnUtil.dataSync editedTemplItem:item.name itemsDic:itemMp];
    
}



-(void) itemEditActions
{
    inEditAction = true;
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    UIActionSheet *pSh;
    if (pAppCmnUtil.bEasyGroc)
    {
        pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", nil];
    }
    else
    {
        pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", @"Delete", nil];
    }
    
    [pSh showInView:self.tableView];
    [pSh setDelegate:self];
    
    
    return;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog (@"In view will appear %s %d", __FILE__, __LINE__);
    NSString *title;
    switch (easyGrocLstType) {
        case eInvntryLst:
            title = @"Inventory List";
            break;
            
        case eScratchLst:
            title =@"Scratch Pad";
            break;
            
        case eRecurrngLst:
            title = @"Recurring List";
            break;
            
        default:
            title = @"Template List";
            break;
    }
    
    
    if (editMode == eViewModeEdit)
    {
        UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(itemEditActions)];
        
        self.navigationItem.rightBarButtonItem = pBarItem;
        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(templItemEditCancel) ];
        self.navigationItem.leftBarButtonItem = pBarItem1;
        self.navigationItem.title = [NSString stringWithString:title];
    }
    else if (editMode == eViewModeDisplay)
    {
        UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(templItemEdit) ];
        self.navigationItem.rightBarButtonItem = pBarItem;
        self.navigationItem.title = [NSString stringWithString:title];
    }
    else
    {
        
        self.navigationItem.title = [NSString stringWithString:title];
        
        UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(templItemAddDone) ];
        self.navigationItem.rightBarButtonItem = pBarItem;
        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(templItemAddCancel) ];
        self.navigationItem.leftBarButtonItem = pBarItem1;
        
    }
    

    if (reloadAfterSeasonPicked)
    {
        self.tableView.editing = YES;
        [self.tableView reloadData];
        reloadAfterSeasonPicked = false;
    }
    
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                LocalMasterList *item = [itemMp objectForKey:rowNm];
                if (item == nil)
                {
                    item = [[LocalMasterList alloc] init];
                    item.startMonth = 1;
                    item.endMonth =12;
                    item.inventory =10;
                    item.item = textField.text;
                     [itemMp setObject:item forKey:rowNm];
                }
                else
                {
                    item.item = textField.text;
                }
               
                if (indPath.row > nRows-3)
                {
                    nRows+=13;
                    [self.tableView reloadData];
                }

            }
            else
                [itemMp removeObjectForKey:rowNm];
        }
            break;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (editMode != eViewModeDisplay)
    {

        if (textFldRowNo != -1)
        {
            
            self.tableView.editing = NO;
            self.tableView.editing = YES;
        }
        return YES;
    }

    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    if (editMode == eViewModeEdit)
    {
        UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
        NSIndexPath *indPath = [self.tableView indexPathForCell:cell];
        if (!indPath.row)
            return NO;
    }
    
    if (editMode != eViewModeDisplay)
    {
        textFldRowNo = textField.tag;
        return YES;
    }

  return NO;
}


-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (inEditAction)
    {
        inEditAction = false;
        switch (buttonIndex)
        {
            case eSaveList:
            {
                
                [self templItemEditDone];
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
    printf("Clicked button at index %ld in delete template list\n", (long)buttonIndex);
    if (buttonIndex == 0)
    {
          }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return nRows;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    
    [theTextField resignFirstResponder];
    
    return YES;
}


-(void) DeleteConfirm
{
    
    //printf("Launch UIActionSheet");
    NSLog(@"Touched delete list button\n");
    UIActionSheet *pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete List" otherButtonTitles:nil];
    [pSh showInView:self.tableView];
    [pSh setDelegate:self];
    
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editMode != eViewModeDisplay)
    {
        if (indexPath.row)
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
    LocalMasterList *sourceItem = [itemMp objectForKey:soureRow];
    if (sourceItem != nil)
    {
        [itemMp removeObjectForKey:soureRow];
        NSLog(@"SourceItem %lld %@", sourceItem.rowno, sourceItem.item);
    }
    
    NSArray *keys1 = [itemMp allKeys];
    NSArray *keys = [keys1 sortedArrayUsingSelector: @selector(compare:)];
    NSInteger no_of_items = [keys count];
    NSArray *reversedKeys = [[keys reverseObjectEnumerator] allObjects];
    //apple orange beets nil nil carrots nil mango cilantro nil
    for(NSUInteger i=0; i < no_of_items; ++i)
    {
        NSNumber *rowNo;
        if (sourceIndexPath.row < destinationIndexPath.row)
            rowNo = [keys objectAtIndex:i];
        else
            rowNo = [reversedKeys objectAtIndex:i];
        
        if ([rowNo unsignedIntegerValue] < sourceIndexPath.row && [rowNo unsignedIntegerValue] < destinationIndexPath.row)
            continue;
        
        if ([rowNo unsignedIntegerValue] > sourceIndexPath.row && [rowNo unsignedIntegerValue] > destinationIndexPath.row)
            continue;
        
        if ([rowNo unsignedIntegerValue] == sourceIndexPath.row)
            continue;
        
        LocalMasterList *item = [itemMp objectForKey:rowNo];
        NSUInteger newKey = [rowNo unsignedIntegerValue];
        if (sourceIndexPath.row < destinationIndexPath.row)
            --newKey;
        else
            ++newKey;
        if (item != nil)
        {
            item.rowno = newKey;
            [itemMp setObject:item forKey:[NSNumber numberWithUnsignedInteger:newKey]];
            [itemMp removeObjectForKey:rowNo];
            NSLog(@"adding and removing item %lld %@", item.rowno, item.item);
        }
    }
    if (sourceItem != nil)
    {
        NSLog(@"Setting sourceItem %lld %@", sourceItem.rowno, sourceItem.item);
        sourceItem.rowno = destinationIndexPath.row;
        [itemMp setObject:sourceItem forKey:[NSNumber numberWithLongLong:sourceItem.rowno]];
    }

    [tableView reloadData];
}



- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editMode != eViewModeDisplay)
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
            
            
        }
        if (indexPath.row)
            return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
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
            LocalMasterList *item = [itemMp objectForKey:rowNo];
            if (item == nil)
                continue;
            [itemMp removeObjectForKey:rowNo];
            NSUInteger newKey = [rowNo unsignedIntegerValue];
            --newKey;
            item.rowno = newKey;
            [itemMp setObject:item forKey:[NSNumber numberWithUnsignedInteger:newKey]];
        }
        NSLog(@"Commit editing style keys %@ itemMp %@ %ld for row %ld", keys, itemMp, (long)editingStyle, (long)indexPath.row);
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
        
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListCell";
    static NSArray* fieldNames = nil;
    if (!fieldNames)
    {
        fieldNames = [NSArray arrayWithObjects:@"Name", nil];
    }
    
    
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
    }
    
    if (indexPath.section != 0)
        return nil;
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    NSUInteger row = indexPath.row;
    switch (row)
    {
        case 0:
        {
          CGRect textFrame = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y, cell.bounds.size.width, cell.bounds.size.height);
            UILabel *textField = [[UILabel alloc] initWithFrame:textFrame];
            if (name == nil)
            {
                NSString *pListName = @"List";
                
                long listno = pAppCmnUtil.dataSync.masterListCnt+1;
                NSString *intStr = [[NSNumber numberWithLongLong:listno] stringValue];
                pListName = [pListName stringByAppendingString:intStr];
                textField.text = pListName;
                name = pListName;
                default_name = name;
                textField.text = name;
            }
            else
            {
                textField.text = name;
                if (pAppCmnUtil.bEasyGroc)
                {
                    switch (easyGrocLstType)
                    {
                        case eInvntryLst:
                            textField.text = [name substringToIndex:[name length]-4];
                        break;
                            
                        case eScratchLst:
                            textField.text = [name substringToIndex:[name length]-7];
                            break;

                    default:
                        break;
                    }
                }
                
            }
            [cell.contentView addSubview:textField];
        }
            
        break;
          
            
        default:
        {
            CGRect textFrame = CGRectMake(cell.bounds.origin.x+10, cell.bounds.origin.y, cell.bounds.size.width, cell.bounds.size.height);
           
                UITextField *textField = [[UITextField alloc] initWithFrame:textFrame];
            
                textField.delegate = self;
                [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
                NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:row];
                LocalMasterList *item = [itemMp objectForKey:rowNm];
                if (item != nil)
                {
                //Ignoring the space place holder for empty inserted rows
                    if ([item.item isEqualToString:@" "] == NO)
                        textField.text = item.item;
                                    
                    if(pAppCmnUtil.bEasyGroc && editMode == eViewModeDisplay && easyGrocLstType == eInvntryLst)
                        [self setHideSwitch:cell rowNm:row mitem:item];
                }
                if (editMode != eViewModeDisplay)
                {
                    [self setEditAccessories:cell rowNm:row];
                }
              //NSLog(@"cell for row at index path in row %lu edit mode = %d text=%@", (unsigned long)row, editMode, textField.text);
                [cell.contentView addSubview:textField];
        }
        break;
            
    }
    // Configure the cell...
    
    return cell;
}

-(void) setHideSwitch :(UITableViewCell *) cell rowNm:(NSUInteger)row mitem:(LocalMasterList *)item
{
    
    CGRect switchFrame = CGRectMake(cell.bounds.size.width - 15, cell.bounds.origin.y, cell.bounds.size.width, cell.bounds.size.height);
    UISwitch *invOnOffSwtch = [[UISwitch alloc] initWithFrame:switchFrame];
    [invOnOffSwtch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = invOnOffSwtch;
   invOnOffSwtch.onTintColor = [UIColor greenColor];
   invOnOffSwtch.tintColor = [UIColor redColor];
    if (item.inventory)
    {
        invOnOffSwtch.on = YES;
    }
    else
    {
        invOnOffSwtch.on = NO;
    }
    NSLog(@"Setting inventory switch for row = %lu item=%@ inventory=%d", (unsigned long)row, item.item, item.inventory);
    invOnOffSwtch.tag = row;
}

-(void) setEditAccessories :(UITableViewCell *) cell rowNm:(NSUInteger)row
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:row];
    UIView *pVw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width/6, cell.bounds.size.height)];
    UIButton *rowAddButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [rowAddButton setFrame:CGRectMake(0,0, cell.bounds.size.width/12, cell.bounds.size.height)];
    cell.showsReorderControl = YES;
    AddRowTargetTmpl *pBtnAct= [[AddRowTargetTmpl alloc] init];
    [rowTarget setObject:pBtnAct forKey:rowNm];
    pBtnAct.rowNo = row;
    pBtnAct.pLstVw = self;
    UIButton *seasonPickerBtn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [seasonPickerBtn setFrame:CGRectMake(cell.bounds.size.width/12 +5, 0, cell.bounds.size.width/12, cell.bounds.size.height)];
    pBtnAct.rowAddButton = rowAddButton;
    pBtnAct.seasonPicker = seasonPickerBtn;
    [rowAddButton addTarget:pBtnAct action:@selector(addRow1) forControlEvents:UIControlEventTouchDown];
    [pVw addSubview:rowAddButton];
    [seasonPickerBtn addTarget:pBtnAct action:@selector(selectSeason) forControlEvents:UIControlEventTouchDown];
    
    [pVw addSubview:seasonPickerBtn];
    if (pAppCmnUtil.bEasyGroc && easyGrocLstType == eRecurrngLst)
    {
        cell.editingAccessoryView = pVw;
        
    }
    else
        cell.editingAccessoryView = rowAddButton;
    
    
    rowAddButton.hidden = NO;
    

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
