//
//  List1ViewController.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 5/19/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import "List1ViewController.h"
#import "List.h"
#import "LocalList.h"
#import "AppCmnUtil.h"
#import "EditViewController.h"
#import "MasterList.h"

const NSInteger TEXTFIELD_TAG = 54325;

@interface AddRowTarget : NSObject

@property (nonatomic) NSUInteger rowNo;
@property (nonatomic, weak) List1ViewController *pLst1Vw;
@property (nonatomic, weak) UIButton *rowAddButton;




-(void) addRow1;
@end

@implementation AddRowTarget

@synthesize rowNo;
@synthesize pLst1Vw;
@synthesize rowAddButton;



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
@synthesize bEasyGroc;
@synthesize bDoubleParent;
@synthesize list;
@synthesize mlistName;
@synthesize nameVw;
@synthesize share_id;
@synthesize mlist_share_id;


-(void) cleanUpItemMp
{
    NSArray *keys = [itemMp allKeys];
    NSUInteger cnt = [keys count];
    
    for (NSUInteger i=0; i < cnt; ++i)
    {
        NSNumber *rowNo = [keys objectAtIndex:i];
        LocalList *item = [itemMp objectForKey:rowNo];
        if ([item.item isEqualToString:@" "] == YES)
        {
            NSLog (@"Removing item %@ at row =%lu cleanUpItemMp", item.item, (unsigned long)[rowNo unsignedIntegerValue]);
            [itemMp removeObjectForKey:rowNo];
        }
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
        LocalList *item = [itemMpCpy objectForKey:rowNo1];
        if (row < insrtedRowNo)
        {
            [itemMp setObject:item forKey:rowNo1];
            
        }
        else
        {
            ++row;
            item.rowno = row;
            [itemMp setObject:item forKey:[NSNumber numberWithUnsignedInteger:row]];
        }
        NSLog(@"Setting item %@ to row %lu in addRow", item.item, (unsigned long)row);
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
        nameVw = @"Temp";
        bDoubleParent = false;
        nRows = 1;
        mInvMp = [[NSMutableDictionary alloc] init];
        mScrtchArr = nil;
        bInvChanged = false;
        [self populateData];
        
    }
    return self;
    
}

#pragma mark - Data initialization

-(void) populateData
{
    if (bEasyGroc)
    {
        if (editMode == eListModeAdd)
        {
            NSLog(@"Initializing List1ViewController in eListModeAdd\n");
            if (mlistName != nil)
            {
                [self refreshMasterList];
            }
            else
            {
                [self createNewList];
            }
        }
        else
        {
            NSLog(@"Initializing List1ViewController in eListModeDisplay\n");
            [self refreshList];
        }
    }
    else
    {
        if (editMode == eListModeAdd)
        {
            if (mlistName != nil)
            {
                [self refreshMasterList];
            }
            else
            {
                [self createListFromBkUp];
            }

        }
        else if (editMode == eListModeEdit)
        {
            if (mlistName != nil)
            {
                [self refreshMasterList];
            }
            else
            {
               [self populateCheckList];
            }
        }
        else
        {
              [self populateCheckList];
        }
    }
    
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

-(void) createListFromBkUp
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    name = pAppCmnUtil.listName;

    if (pAppCmnUtil.itemsMp != nil)
    {
        
        itemMp = pAppCmnUtil.itemsMp;
        nRows = [itemMp count] + 1;
        for (id key in itemMp)
        {
            NSNumber *rowNo = (NSNumber *) key;
            NSUInteger rowno = [rowNo unsignedIntegerValue];
            if (rowno > nRows)
                nRows = rowno +1;
        }
    }
    else
    {
        itemMp = [NSMutableDictionary dictionaryWithCapacity:15];
        nRows =1;
    }
}

-(void) refreshMasterList
{
    
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    ItemKey *itk = [[ItemKey alloc] init];
    itk.name = mlistName;
    itk.share_id = mlist_share_id;
    mlist = [pAppCmnUtil.dataSync getMasterList:itk];
    if (bEasyGroc)
    {
        name = mlistName;
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        NSString *formattedDateString = [dateFormatter stringFromDate:today];
        name = [name stringByAppendingString:@" "];
        name = [name stringByAppendingString:formattedDateString];
        default_name = name;
    }
    else
    {
        name = pAppCmnUtil.listName;
    }
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar  components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger month = [components month];
    itemMp = [NSMutableDictionary dictionaryWithCapacity:100];
    NSLog(@"Master list %@ for name %@ %s %d\n", mlist, name, __FILE__, __LINE__);
    if (mlist != nil)
    {
        int recrLstCnt = (int)[mlist count];
        
        
        for (NSUInteger i=0; i < recrLstCnt; ++i)
        {
            NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:nRows];
            LocalList *newItem = [[LocalList alloc] init];
            MasterList *mitem =[mlist objectAtIndex:i];
            if (bEasyGroc)
            {
                if (mitem.endMonth > mitem.startMonth)
                {
                    if (month > mitem.endMonth || month < mitem.startMonth)
                        continue;
                    
                }
                else if (mitem.endMonth == mitem.startMonth)
                {
                    if (month != mitem.endMonth)
                        continue;
                }
                else
                {
                    if (month < mitem.startMonth && month > mitem.endMonth)
                        continue;
                }
            }
            newItem.rowno = nRows;
            ++nRows;
            newItem.item = mitem.item;
            newItem.hidden = false;
            [itemMp setObject:newItem forKey:rowNm];
        }
       
        
    }
    
    if (bEasyGroc)
    {
        
        mInvListName = [mlistName stringByAppendingString:@":INV"];
        itk.name = mInvListName;
        mInvArr = [pAppCmnUtil.dataSync getMasterList:itk];
        NSUInteger invArrCnt = [mInvArr count];
        
        for (NSUInteger i=0; i < invArrCnt; ++i)
        {
            NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:nRows];
            LocalList *newItem = [[LocalList alloc] init];
            MasterList *mitem =[mInvArr objectAtIndex:i];
            NSNumber *invLstRowNo = [NSNumber numberWithUnsignedInteger:mitem.rowno];
            [mInvMp setObject:mitem forKey:invLstRowNo];
            
            if (mitem.inventory)
                continue;
            bInvChanged = true;
            newItem.rowno = nRows;
            ++nRows;
            newItem.item = mitem.item;
            newItem.hidden = false;
            [itemMp setObject:newItem forKey:rowNm];
        }
        
        mScrtchListName = [mlistName stringByAppendingString:@":SCRTCH"];
        itk.name = mScrtchListName;
        mScrtchArr = [pAppCmnUtil.dataSync getMasterList:itk];
        NSUInteger scrtchArrCnt = [mScrtchArr count];
        for (NSUInteger i=0; i < scrtchArrCnt; ++i)
        {
            NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:nRows];
            LocalList *newItem = [[LocalList alloc] init];
            MasterList *mitem =[mScrtchArr objectAtIndex:i];
            newItem.rowno = nRows;
            ++nRows;
            newItem.item = mitem.item;
            newItem.hidden = false;
            [itemMp setObject:newItem forKey:rowNm];
        }

        if (bEasyGroc)
            nRows += 35;
        
    }
    
    
    if (bEasyGroc && nRows ==1)
    {
        nRows = 50;
        itemMp = [NSMutableDictionary dictionaryWithCapacity:50];
    }
    NSLog(@"itemMp dictionary to set view %@\n", itemMp);
    NSLog(@"Setting nRows %lu\n", (unsigned long)nRows);
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

-(void) populateCheckList
{
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
            List *itemNL = [list objectAtIndex:i];
             LocalList *item = [[LocalList alloc] initFromList:itemNL];
            [itemMp setObject:item forKey:rowNm];
        }
        nRows += 3;
        NSLog(@"Setting nRows %lu\n", (unsigned long)nRows);
        
    }
    else
    {
        nRows = 2;
    }
    NSLog(@"itemMp dictionary to set view %@\n", itemMp);
    
    return;

}

-(void) refreshList
{
    
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    ItemKey *itk = [[ItemKey alloc] init];
    itk.name = name;
    itk.share_id = share_id;
    list = [pAppCmnUtil.dataSync getList:itk];
    
    default_name = name;
    NSLog(@"list %@ for name=%@ share_id=%lld %s %d\n", list, name,  share_id, __FILE__, __LINE__);
    if (list != nil)
    {
        nRows = [list count]+1;
        NSUInteger lstcnt = [list count];
        itemMp = [NSMutableDictionary dictionaryWithCapacity:nRows];
        hiddenMp = [NSMutableDictionary dictionaryWithCapacity:nRows];
        for (NSUInteger i=0; i < lstcnt; ++i)
        {
           
            List *itemNL = [list objectAtIndex:i];
            LocalList *item = [[LocalList alloc] initFromList:itemNL];
             NSNumber *rowNm = [NSNumber numberWithLongLong:item.rowno];
            [itemMp setObject:item forKey:rowNm];
            if (item.rowno > nRows)
                nRows = (NSUInteger)item.rowno;
            NSLog (@"Setting item %@ to itempMp %@", item.item, rowNm);
            if (editMode == eListModeDisplay)
            {
                NSNumber *rowVal = [NSNumber numberWithBool:item.hidden];
                [hiddenMp setObject:rowVal forKey:rowNm];
                if (item.hidden == YES)
                {
                  //  NSLog (@"Setting hiddent item %@ to itempMp %@", item, rowNm);
                    [hiddenCells setObject:rowVal forKey:rowNm];
                }
            }
        }
        if (editMode != eListModeDisplay)
            nRows += 13;
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
 

    return;
}

#pragma mark - Callback functions and Action Sheet

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
    NSLog(@"Adding item done ");
    ItemKey *itk = [[ItemKey alloc] init];
    itk.name = pListView.name;
    itk.share_id = pAppCmnUtil.share_id;
    [pAppCmnUtil.dataSync addItem:itk itemsDic:pListView.itemMp];
    if (bEasyGroc)
    {
        if (bInvChanged)
        {
            for (NSNumber *key in mInvMp)
            {
                MasterList *mitem = [mInvMp objectForKey:key];
                mitem.inventory = 10;
            }
            ItemKey *mtk = [[ItemKey alloc] init];
            mtk.name = mInvListName;
            mtk.share_id = mlist_share_id;
            [pAppCmnUtil.dataSync editedTemplItem:mtk itemsDic:mInvMp];
        }
        if (mScrtchArr != nil && [mScrtchArr count])
        {
            ItemKey *mtk = [[ItemKey alloc] init];
            mtk.name = mScrtchListName;
            mtk.share_id = mlist_share_id;
            [pAppCmnUtil.dataSync deletedTemplItem:mtk];
        }
        
    }
    
    
    return;
}

-(void) itemDisplay:(ItemKey *) itk
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    pAppCmnUtil.listName = itk.name;
    [pAppCmnUtil.dataSync selectedItem:itk];
    List1ViewController *aViewController = [List1ViewController alloc];
    aViewController.editMode = eListModeDisplay;
    aViewController.bEasyGroc = bEasyGroc;
    aViewController.name = itk.name;
    aViewController.share_id = itk.share_id;
    
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    [pAppCmnUtil.navViewController pushViewController:aViewController animated:YES];
    return;
}




-(void) itemEditCancel
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    List1ViewController *pListView = (List1ViewController *)[pAppCmnUtil.navViewController popViewControllerAnimated:NO];
    NSLog(@"Edit cancelled for item %@", pListView.name);
    ItemKey *itk = [[ItemKey alloc] init];
    itk.name = pListView.name;
    itk.share_id = pListView.share_id;
    
    [self itemDisplay:itk];
    return;
}


- (void) itemAddCancel
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    [pAppCmnUtil popView];
    
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
    for (NSNumber *key in itemMp)
    {
        LocalList *item = [itemMp objectForKey:key];
        NSLog(@"itemEditDone itemMp item=%@ row=%ld", item.item, (unsigned long)[key unsignedIntegerValue]);
    }
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    List1ViewController *pListView = (List1ViewController *)[pAppCmnUtil.navViewController popViewControllerAnimated:NO];
    [pAppCmnUtil popView];
    [pListView cleanUpItemMp];
    /*
     for (NSNumber *key in pListView.itemMp)
     {
     LocalList *item = [pListView.itemMp objectForKey:key];
     NSLog(@"itemEditDone1 itemMp item=%@ row=%ld item.row=%lld", item.item, (unsigned long)[key unsignedIntegerValue], item.rowno);
     }
     */
    
    ItemKey *itk = [[ItemKey alloc] init];
    itk.name =  pListView.name;
    itk.share_id = pListView.share_id;
    [pAppCmnUtil.dataSync editItem:itk itemsDic:pListView.itemMp];
    
    return;
}




#pragma mark - View lifecycle

-(void)willMoveToParentViewController:(UIViewController *)parent
{
    if (!bEasyGroc && (editMode == eListModeEdit || editMode == eListModeAdd))
    {
        AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
        pAppCmnUtil.itemsMp = itemMp;
    }
}

-(void)didMoveToParentViewController:(UIViewController *)parent
{
    
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    if (editMode == eListModeEdit && !bEasyGroc)
    {
        EditViewController *pEditView = nil;
        NSArray *pVwCntrls =  [pAppCmnUtil.navViewController viewControllers];
        for (id pVwCntrl in pVwCntrls)
        {
            if ([pVwCntrl isMemberOfClass:[EditViewController class]])
                pEditView = pVwCntrl;
        }
        if (pEditView != nil )
        {
            pEditView.itemMp = itemMp;
            [pEditView populateCheckListArrFromItemMp];
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
    
   
    if (editMode == eListModeAdd)
    {
        if (bEasyGroc == true)
        {
            NSString *title = @"New List";
            self.navigationItem.title = [NSString stringWithString:title];
        
            UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(itemAddDone) ];
            self.navigationItem.rightBarButtonItem = pBarItem;
            UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(itemAddCancel) ];
            self.navigationItem.leftBarButtonItem = pBarItem1;
        }
        else
        {
            NSString *title = @"Check List";
            self.navigationItem.title = [NSString stringWithString:title];
        }
    }
    else if (editMode == eListModeEdit)
    {
        if (bEasyGroc == true)
        {
            NSString *title = @"Edit List";
            self.navigationItem.title = [NSString stringWithString:title];
        
            UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(itemEditActions)];
        
            self.navigationItem.rightBarButtonItem = pBarItem;

            UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:  UIBarButtonSystemItemCancel target:self action:@selector(itemEditCancel) ];
            self.navigationItem.leftBarButtonItem = pBarItem1;
        }
        else
        {
            NSString *title = @"Check List";
            self.navigationItem.title = [NSString stringWithString:title];
        }
    }
    else
    {
        if (bEasyGroc == true)
        {
        
            NSString *title = @"List";
            self.navigationItem.title = [NSString stringWithString:title];
        
            UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(itemDispActions)];
        
            self.navigationItem.rightBarButtonItem = pBarItem;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackGroundActions:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        }
        else
        {
            NSString *title = @"Check List";
            self.navigationItem.title = [NSString stringWithString:title];
        }
    }
}

- (void)applicationEnterBackGroundActions:(NSNotification *)notification
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    if (itemMp == nil || ![itemMp count] || hiddenMp == nil || ![hiddenMp count])
        return;
    NSLog(@"Updating hidden items in  application enter  background");
    ItemKey *itk = [[ItemKey alloc] init];
    itk.name = name;
    itk.share_id = share_id;
    [pAppCmnUtil.dataSync editItem:itk itemsDic:itemMp];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(bEasyGroc && editMode != eListModeDisplay)
        [self.tableView setEditing:YES animated:YES];
}

-(void) viewWillDisappear:(BOOL)animated
{
    
   
    [super viewWillDisappear:animated];
    
    if (bEasyGroc && editMode == eListModeDisplay)
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
        NSLog(@"Updating hidden items in  view will disappear");
        ItemKey *itk = [[ItemKey alloc] init];
        itk.name = name;
        itk.share_id = share_id;
        [pAppCmnUtil.dataSync editItem:itk itemsDic:itemMp];
       
    }
     
    NSLog(@"In  view will disappear");
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            ItemKey *itk = [[ItemKey alloc] init];
            itk.name = name;
            itk.share_id = share_id;

            [pAppCmnUtil.dataSync deletedEasyItem:itk];
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
            LocalList *item = [itemMp objectForKey:undoIndx];
            item.hidden = NO;
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
            LocalList *item = [itemMp objectForKey:redoIndx];
            item.hidden = YES;
            [hiddenMp setObject:hidden forKey:redoIndx];
            [self.tableView reloadData];
        }
        break;
        
        case eShowAll:
        {
            [hiddenCells removeAllObjects];
            
            NSArray *keys = [hiddenMp allKeys];
            
            for (NSNumber *key in keys)
            {
                NSNumber *hidden = [NSNumber numberWithBool:NO];
                [hiddenMp setObject:hidden forKey:key];
                
            }
            
            
            for (NSNumber *key in itemMp)
            {
                LocalList *item = [itemMp objectForKey:key];
                if (item != nil)
                {
                    item.hidden = NO;
                }
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
     NSLog(@"Popped view controller");
    List1ViewController *aViewController = [List1ViewController alloc];
    aViewController.editMode = eListModeEdit;
    aViewController.name = name;
    aViewController.bEasyGroc = bEasyGroc;
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    aViewController.nameVw = @"Edited";
    NSLog(@"Pushing view controller");
    [pAppCmnUtil.navViewController pushViewController:aViewController animated:YES];
    NSLog(@"Pushed view controller");
    
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

#pragma mark - Search bar functions

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    NSLog(@"Search text %@", searchText);
    if (searchText == nil || ![searchText length])
    {
    
            // [searchBar resignFirstResponder];
            bSearchStr = false;
            searchBar.text = nil;
            //  pDlg.dataSync.refreshNow = true;
            itemMp = [[NSMutableDictionary alloc] initWithDictionary:itemUnFiltrdMp];
            hiddenCells = [[NSMutableDictionary alloc] initWithDictionary:hiddenCellsUnFiltrdMp];
            hiddenMp = [[NSMutableDictionary alloc] initWithDictionary:hiddenUnFiltrdMp];
            [searchBar resignFirstResponder];
            [self.tableView reloadData];

    }
    
    //execute a new fetch statement
    //repopulate the table
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
     NSLog(@"Finished editing search bar %s %d text=%@", __FILE__, __LINE__, searchBar.text);
    
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
        LocalList *item = [itemUnFiltrdMp objectForKey:[keys objectAtIndex:i]];
        NSStringCompareOptions  opt = NSCaseInsensitiveSearch;
        NSRange aR = [item.item rangeOfString:[searchBar text] options:opt];
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
   // NSLog(@"Number of rows=%ld", (unsigned long)nRows);
    return nRows;
}

#pragma mark - Text Edit functions

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
                LocalList *item = [itemMp objectForKey:rowNm];
                if (item != NULL)
                {
                    item.item = textField.text;
                  //  NSLog(@"changing item=%@ in row=%lld", item.item, item.rowno);
                }
                else
                {
                    item = [[LocalList alloc] init];
                    item.item = textField.text;
                    item.rowno = indPath.row;
                   // NSLog(@"Added item=%@ to row=%lld", item.item, item.rowno);
                    [itemMp setObject:item forKey:rowNm];
                }
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
        
        [textField resignFirstResponder];
       
        return YES;
    }
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (!bEasyGroc)
        return NO;
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

-(void) setTextFieldVal:(UITextField*) textField itm:(LocalList *)item
{
    
    if (bEasyGroc)
    {
        textField.text = item.item;
        return;
        
    }
    [textField setUserInteractionEnabled:NO];
    if (item.hidden == YES)
    {
        textField.text = @"\u2705   ";
        textField.text = [textField.text stringByAppendingString:item.item];
    }
    else
    {
        
        textField.text = @"\u2B1C   ";
        textField.text = [textField.text stringByAppendingString:item.item];
    }
}

#pragma mark - Table view cellForRowIndex helper fns

-(void) setAccessories:(UITableViewCell *) cell rowNo:(NSNumber *)rowNm rowU : (NSUInteger) row
{
    if (bEasyGroc && editMode != eListModeDisplay)
    {
        cell.showsReorderControl = YES;
        UIButton *rowAddButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        
        AddRowTarget *pBtnAct= [[AddRowTarget alloc] init];
        [rowTarget setObject:pBtnAct forKey:rowNm];
        pBtnAct.rowNo = row;
        pBtnAct.pLst1Vw = self;
        pBtnAct.rowAddButton = rowAddButton;
        [rowAddButton addTarget:pBtnAct action:@selector(addRow1) forControlEvents:UIControlEventTouchDown];
        cell.editingAccessoryView = rowAddButton;
    }
    
}


- (void)switchToggled:(id)sender
{
    UISwitch *toggleSwitch = (UISwitch *)sender;
    NSNumber *swtchKey = [NSNumber numberWithUnsignedInteger:toggleSwitch.tag];
    
    NSNumber *swtchKey1 = [NSNumber numberWithUnsignedInteger:toggleSwitch.tag];
    [hiddenCells setObject:swtchKey1 forKey:swtchKey];
    
    LocalList *item = [itemMp objectForKey:swtchKey];
    item.hidden = YES;
    [undoArry addObject:swtchKey];
    
    NSNumber *hidden = [NSNumber numberWithBool:YES];
    [hiddenMp setObject:hidden forKey:swtchKey];
    [self.tableView reloadData];
}


-(void) setCheckMarkAccessory:(LocalList *)item  tableCell:(UITableViewCell *) cell
{
    if (item.hidden)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}

-(bool) setCellHiddenBool:(UITableViewCell *) cell rowU : (NSUInteger) row

{
    if (!bEasyGroc)
    {
        cell.hidden = NO;
        return false;
    }
    NSNumber *key = [NSNumber numberWithInteger:row-1];
    if ([hiddenCells objectForKey:key] != nil)
    {
        cell.hidden = YES;
        return true;
    }
    else
    {
        cell.hidden = NO;
    }
    return false;
}

-(void) setHidelCellSwitch:(UITableViewCell *) cell rowU : (NSUInteger) row
{
    CGRect switchFrame = CGRectMake(cell.bounds.size.width - 15, cell.bounds.origin.y, cell.bounds.size.width, cell.bounds.size.height);
    UISwitch *hideCell = [[UISwitch alloc] initWithFrame:switchFrame];
    [hideCell addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = hideCell;
    hideCell.on = YES;
    
    hideCell.tag = row-1;
}





#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!bEasyGroc)
        return NO;
    if (editMode != eListModeDisplay)
    {
        //if ([itemMp objectForKey:[NSNumber numberWithInteger:indexPath.row]] != nil)
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
    LocalList *sourceItem = [itemMp objectForKey:soureRow];
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
        NSLog(@"rowNo=%lu", (unsigned long)[rowNo unsignedIntegerValue]);
         if ([rowNo unsignedIntegerValue] < sourceIndexPath.row && [rowNo unsignedIntegerValue] < destinationIndexPath.row)
             continue;
        
        if ([rowNo unsignedIntegerValue] > sourceIndexPath.row && [rowNo unsignedIntegerValue] > destinationIndexPath.row)
            continue;
        
        if ([rowNo unsignedIntegerValue] == sourceIndexPath.row)
            continue;
        LocalList *item = [itemMp objectForKey:rowNo];
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
            LocalList *item = [itemMp objectForKey:rowNo];
            if (item == nil)
                continue;
            [itemMp removeObjectForKey:rowNo];
            NSUInteger newKey = [rowNo unsignedIntegerValue];
            --newKey;
            item.rowno = newKey;
            [itemMp setObject:item forKey:[NSNumber numberWithUnsignedInteger:newKey]];
        }
         NSLog(@"Commit editing style row =%ld ", (long)indexPath.row);
        for (NSNumber *key in itemMp)
        {
            LocalList *item = [itemMp objectForKey:key];
            NSLog(@"After delete commit itemMp item=%@ row=%ld", item.item, (unsigned long)[key unsignedIntegerValue]);
        }
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView reloadData];
    }
    
   
}


- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSNumber *key = [NSNumber numberWithInteger:indexPath.row-1];
    
    if ([hiddenCells objectForKey:key] != nil)
        return 0.0;
    
    return self.tableView.rowHeight;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!bEasyGroc)
        return UITableViewCellEditingStyleNone;
    
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
         
        
        }
        if (indexPath.row)
            return UITableViewCellEditingStyleDelete;
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
    
    
  // NSLog(@"Cell for index at row %lu", (unsigned long)row);
    
    if ([self setCellHiddenBool:cell rowU:row])
        return cell;
    
     //NSLog(@"Cell for index at row %lu", (unsigned long)row);
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
           // NSLog(@"Cell for index at row %lu %@", (unsigned long)row, nameVw);
            CGRect textFrame;
            if (bEasyGroc)
                textFrame= CGRectMake(cell.bounds.origin.x+10, cell.bounds.origin.y, cell.bounds.size.width, cell.bounds.size.height);
            else
                textFrame= CGRectMake(cell.bounds.origin.x+10, cell.bounds.origin.y, cell.bounds.size.width, cell.bounds.size.height);
            UITextField *textField = [[UITextField alloc] initWithFrame:textFrame];
            textField.delegate = self;
            if (bEasyGroc && editMode != eListModeDisplay)
            {
                [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            }
            
            
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
                LocalList *item = [itemMp objectForKey:rowNm];
                if (item != nil)
                {
                    //Ignoring the space place holder for empty inserted rows
                    if ([item.item isEqualToString:@" "] == NO)
                        [self setTextFieldVal:textField itm:item];
                    if (editMode == eListModeDisplay)
                    {
                        if (bEasyGroc)
                        {
                            [self setHidelCellSwitch:cell rowU:row];
                        }
                    }
                 }
            
                [self setAccessories:cell rowNo:rowNm rowU:row];
                textField.tag = row;
            
                [cell.contentView addSubview:textField];
            
            
          //     NSLog(@"Adding textField %@ row= %lu", textField.text, (unsigned long)row);
                
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
     <#DetailViewController#> *detailViewController = [[DetailViewController alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    
    NSLog(@"Did select row %ld %s %d", (long)indexPath.row, __FILE__, __LINE__);
    
    NSUInteger row = indexPath.row;
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSNumber *rowNm = [NSNumber numberWithUnsignedInteger:editMode == eListModeDisplay?row-1: row];
    LocalList *item = [itemMp objectForKey:rowNm];
    if (item == nil)
        return;
    
    if (!bEasyGroc && editMode != eListModeDisplay)
    {
        
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        UILabel *textField = (UILabel *)[selectedCell.contentView viewWithTag:row];
        if (textField != nil)
        {
            if (item.hidden == YES)
            {
                item.hidden= NO;
                textField.text = @"\u2B1C   ";
                
                textField.text = [textField.text stringByAppendingString:item.item];
            }
            else
            {
                item.hidden = YES;
                textField.text = @"\u2705   ";
                textField.text = [textField.text stringByAppendingString:item.item];
            }
            
        }
    }
}

@end
