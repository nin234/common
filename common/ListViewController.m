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
    CGPoint hitPoint = [rowAddButton convertPoint:CGPointZero toView:pLstVw.tableView];
    NSIndexPath *hitIndex = [pLstVw.tableView indexPathForRowAtPoint:hitPoint];
    [pLstVw addRow:hitIndex.row];
    return;
}

-(void) selectSeason
{
    CGPoint hitPoint = [rowAddButton convertPoint:CGPointZero toView:pLstVw.tableView];
    NSIndexPath *hitIndex = [pLstVw.tableView indexPathForRowAtPoint:hitPoint];
    [pLstVw showSeasonPicker:hitIndex.row];
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
@synthesize seasonPicker;
@synthesize mlistName;
@synthesize easyGrocLstType;

-(void) showSeasonPicker : (NSUInteger) rowNo
{
    seasonPickerRowNo = rowNo;
    seasonPicker.hidden = NO;
}

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
        AddRowTargetTmpl *pBtnAct = [rowTarget objectForKey:rowNo1];
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
    if (self) {
        // Custom initialization
           }
    return self;
}

-(void) pickSeasons
{
    seasonPicker.hidden = YES;
    NSNumber * rowNum = [NSNumber numberWithUnsignedInteger:seasonPickerRowNo];
    MasterList *mlistForSo = [itemMp objectForKey:rowNum];
    mlistForSo.startMonth = startMonth;
    mlistForSo.endMonth = endMonth;
    
}

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[component][row];
}

- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 12;
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    if (!component)
        startMonth = row+1;
    else
        endMonth = row+1;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    inEditAction = false;
    textFldRowNo = -1;
    rowTarget = [[NSMutableDictionary alloc] init];
    if (self)
    {
        [self refreshMasterList];
        CGRect mainScrn = [UIScreen mainScreen].applicationFrame;
        CGRect  viewRect;
        viewRect = CGRectMake(0, mainScrn.origin.y + mainScrn.size.height/4, mainScrn.size.width, mainScrn.size.height/2);
        seasonPicker = [[UIPickerView alloc] initWithFrame:viewRect];
        UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,mainScrn.size.width,50)];
       // [toolBar setBarStyle:UIBarStyleBlackOpaque];
        UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickSeasons) ];
       
        toolBar.items = @[pBarItem];
        
       [seasonPicker addSubview:toolBar];
      //  seasonPicker.inputAccessoryView = toolBar;
        [self.tableView addSubview:seasonPicker];
        seasonPicker.hidden = YES;
        _pickerData = @[ @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"],
                         @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov",@"Dec"]];
        seasonPicker.delegate = self;
        seasonPicker.dataSource = self;
        
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
        
        itemMp = [NSMutableDictionary dictionaryWithCapacity:nRows];
        for (NSUInteger i=0; i < nRows-1; ++i)
        {
            NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:i+1];
            [itemMp setObject:[mlist objectAtIndex:i] forKey:rowNm];
        }
        if (editMode != eViewModeDisplay)
            nRows += 35;
        NSLog(@"Setting nRows %lu\n", (unsigned long)nRows);
        
    }
    else
    {
        nRows = 50;
        itemMp = [NSMutableDictionary dictionaryWithCapacity:50];
    }
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
    
    [self templItemDisplay:pListView.name lstcntr:pListView];
    [pListView cleanUpItemMp];
    [pAppCmnUtil.dataSync addTemplItem:pListView.name itemsDic:pListView.itemMp];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
            break;
    }
    
    
    if (editMode == eViewModeEdit)
    {
        UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(itemEditActions)];
        
        self.navigationItem.rightBarButtonItem = pBarItem;
        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(templItemEditCancel) ];
        self.navigationItem.leftBarButtonItem = pBarItem1;
        NSString *title = @"Template List";
        self.navigationItem.title = [NSString stringWithString:title];
    }
    else if (editMode == eViewModeDisplay)
    {
        UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(templItemEdit) ];
        self.navigationItem.rightBarButtonItem = pBarItem;
        NSString *title = @"Template List";
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
    MasterList *item = [itemMp objectForKey:rowNm];
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
    UIActionSheet *pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", @"Delete", nil];
    
    [pSh showInView:self.tableView];
    [pSh setDelegate:self];
    
    
    return;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(editMode != eViewModeDisplay)
        [self.tableView setEditing:YES animated:YES];
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
                MasterList *item = [itemMp objectForKey:rowNm];
                if (item == nil)
                {
                    item = [[MasterList alloc] init];
                    item.startMonth = 1;
                    item.endMonth =12;
                    item.inventory =10;
                }
                [itemMp setObject:item forKey:rowNm];
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
      AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
        [pAppCmnUtil.dataSync deletedTemplItem:name];
        [pAppCmnUtil popView];
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
    MasterList *sourceItem = [itemMp objectForKey:soureRow];
    MasterList *prevItem;
    
    NSArray *keys1 = [itemMp allKeys];
    NSArray *keys = [keys1 sortedArrayUsingSelector: @selector(compare:)];
    NSInteger no_of_items = [keys count];
    for(NSUInteger i=0; i < no_of_items; ++i)
    {
        NSNumber *rowNo = [keys objectAtIndex:i];
        if ([rowNo unsignedIntegerValue] < sourceIndexPath.row && [rowNo unsignedIntegerValue] < destinationIndexPath.row)
            continue;
        
        if ([rowNo unsignedIntegerValue] > sourceIndexPath.row && [rowNo unsignedIntegerValue] > destinationIndexPath.row)
            continue;
        if (sourceIndexPath.row < destinationIndexPath.row)
        {
            if ([rowNo unsignedIntegerValue] == sourceIndexPath.row)
                continue;
            else if ([rowNo unsignedIntegerValue] < destinationIndexPath.row)
            {
                MasterList *item = [itemMp objectForKey:rowNo];
                NSUInteger newKey = [rowNo unsignedIntegerValue];
                --newKey;
                [itemMp setObject:item forKey:[NSNumber numberWithUnsignedInteger:newKey]];
            }
            else
            {
                MasterList *item = [itemMp objectForKey:rowNo];
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
                MasterList *tmpItem = [itemMp objectForKey:rowNo];
                [itemMp setObject:prevItem forKey:rowNo];
                prevItem = tmpItem;
            }
        }
        
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
            
            return UITableViewCellEditingStyleDelete;
        }

        
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
            MasterList *item = [itemMp objectForKey:rowNo];
            if (item == nil)
                continue;
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
    NSUInteger row = indexPath.row;
    switch (row)
    {
        case 0:
        {
          CGRect textFrame = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y, cell.bounds.size.width, cell.bounds.size.height);
            UITextField *textField = [[UITextField alloc] initWithFrame:textFrame];
            textField.delegate = self;
            [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            if (name == nil)
            {
                NSString *pListName = @"List";
                 AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
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
            }
            [cell.contentView addSubview:textField];
        }
            
        break;
          
            
        default:
        {
             AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
            CGRect textFrame = CGRectMake(cell.bounds.origin.x+10, cell.bounds.origin.y, cell.bounds.size.width, cell.bounds.size.height);
           
                UITextField *textField = [[UITextField alloc] initWithFrame:textFrame];
            
                textField.delegate = self;
                [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
                NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:row];
                MasterList *item = [itemMp objectForKey:rowNm];
                if (item != nil)
                {
                //Ignoring the space place holder for empty inserted rows
                    if ([item.item isEqualToString:@" "] == NO)
                        textField.text = item.item;
                    if(editMode != eViewModeDisplay)
                    {
                        UIView *pVw = [[UIView alloc] init];
                        cell.showsReorderControl = YES;
                        UIButton *rowAddButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
                        
                        AddRowTargetTmpl *pBtnAct= [[AddRowTargetTmpl alloc] init];
                        [rowTarget setObject:pBtnAct forKey:rowNm];
                        pBtnAct.rowNo = row;
                        pBtnAct.pLstVw = self;
                        
                        UIButton *seasonPicker = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                        pBtnAct.rowAddButton = rowAddButton;
                        pBtnAct.seasonPicker = seasonPicker;
                        [rowAddButton addTarget:pBtnAct action:@selector(addRow1) forControlEvents:UIControlEventTouchDown];
                        
                        [seasonPicker addTarget:pBtnAct action:@selector(selectSeason) forControlEvents:UIControlEventTouchDown];
                        [pVw addSubview:rowAddButton];
                        
                        [pVw addSubview:seasonPicker];
                        if (pAppCmnUtil.bEasyGroc && easyGrocLstType == eInvntryLst)
                            cell.editingAccessoryView = pVw;
                        else
                            cell.editingAccessoryView = rowAddButton;

                    }
                    else
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
                        
                        invOnOffSwtch.tag = row;

                    }
                }
                else
                {
                    
                    if (editMode != eViewModeDisplay)
                    {
                        UIView *pVw = [[UIView alloc] init];
                        UIButton *rowAddButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
                        
                        AddRowTargetTmpl *pBtnAct= [[AddRowTargetTmpl alloc] init];
                        [rowTarget setObject:pBtnAct forKey:rowNm];
                        pBtnAct.rowNo = row;
                        pBtnAct.pLstVw = self;
                         UIButton *seasonPicker = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                        pBtnAct.rowAddButton = rowAddButton;
                        pBtnAct.seasonPicker = seasonPicker;
                        [rowAddButton addTarget:pBtnAct action:@selector(addRow1) forControlEvents:UIControlEventTouchDown];
                        [pVw addSubview:rowAddButton];
                        [seasonPicker addTarget:pBtnAct action:@selector(selectSeason) forControlEvents:UIControlEventTouchDown];
                       
                        [pVw addSubview:seasonPicker];
                        if (pAppCmnUtil.bEasyGroc && easyGrocLstType == eInvntryLst)
                            cell.editingAccessoryView = pVw;
                        else
                            cell.editingAccessoryView = rowAddButton;
                        
                        rowAddButton.hidden = YES;
                        seasonPicker.hidden = YES;
                        
                    }
                    
                }

                [cell.contentView addSubview:textField];
          

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
