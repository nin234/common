//
//  DataOps.m
//  Shopper
//
//  Created by Ninan Thomas on 11/17/12.
//
//

#import "DataOps.h"
#import <sys/stat.h>
#import "AVFoundation/AVAssetImageGenerator.h"
#import "AVFoundation/AVAsset.h"
#import "AVFoundation/AVTime.h"
#import "MasterListNames.h"
#import "MasterList.h"
#import "ListViewController.h"

#import "ListNames.h"
#import "List.h"
#import "AppCmnUtil.h"
#import "common-Swift.h"
#import "EasyListViewController.h"
#import "List1ViewController.h"
#import "LocalList.h"
#import "LocalMasterList.h"


@implementation DataOps

@synthesize refreshNow;
@synthesize updateNow;
@synthesize loginNow;
@synthesize shareQ;
@synthesize delegate;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

@synthesize easyManagedObjectContext = __easyManagedObjectContext;
@synthesize easyManagedObjectModel = __easyManagedObjectModel;
@synthesize easyPersistentStoreCoordinator = __easyPersistentStoreCoordinator;

@synthesize masterListCnt;
@synthesize navViewController;
@synthesize templNavViewController;
@synthesize listCnt;
@synthesize refreshMainLst;
@synthesize appName;
@synthesize templListViewController;
@synthesize bReady;

@class EasyViewController;

-(void) setRefreshNow:(bool)refNow
{
    [workToDo lock];
    refreshNow = refNow;
    if (refreshNow == true)
    {
        NSLog(@"Setting refreshNow and signalling work\n");
        [workToDo signal];
    }
    [workToDo unlock];
    return;
}

-(void) setLoginNow:(bool)lgNow
{
    [workToDo lock];
    loginNow = lgNow;
    [workToDo signal];
    [workToDo unlock];

}


-(void) setUpdateNow:(bool)upNow
{
    [workToDo lock];
    updateNow = upNow;
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) editedTemplItemNoLock:(ItemKey *)name itemsDic:(NSMutableDictionary*) itmsMp

{
   
    [masterListEditNames addObject:name];
    [masterListEditMps addObject:itmsMp];
    ++templItemsEdited;
    NSLog(@"Added edit templ item No Lock %@ %d and signalling work to do\n", name, templItemsEdited);
    return;
}

-(void) editedTemplItem:(ItemKey *)name itemsDic:(NSMutableDictionary*) itmsMp

{
    [workToDo lock];
    [masterListEditNames addObject:name];
    [masterListEditMps addObject:itmsMp];
    ++templItemsEdited;
    NSLog(@"Added edit templ item %@ %d and signalling work to do\n", name, templItemsEdited);
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) deletedTemplItemNoLock:(ItemKey *)name
{
    [masterListDeletedNames addObject:name];
    ++templItemsDeleted;
    NSLog(@"Added deleted item name=%@ share_id= %lld no=%d\n", name.name, name.share_id, templItemsDeleted);
    return;
}

-(void) deletedTemplItem:(ItemKey *)name
{
    [workToDo lock];
    [masterListDeletedNames addObject:name];
    ++templItemsDeleted;
    NSLog(@"Added deleted item name=%@ share_id= %lld no=%d and signalling work to do\n", name.name, name.share_id, templItemsDeleted);
    [workToDo signal];
    [workToDo unlock];
    
    return;
}


-(void) updateMasterLstVwCntrl
{
    
    NSLog(@"Updating MasterLstVwCntrl waiting for main queue");
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"Updating MasterLstVwCntrl in main queue");
        NSArray *vws = [templNavViewController viewControllers];
        NSUInteger vwcnt = [vws count];
        //NSLog(@"No of view controllers EasyDataOps:updateMasterLstVwCntrl %lu", (unsigned long)vwcnt);
        AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
        if (pAppCmnUtil.bEasyGroc)
        {
            
            [templListViewController.recurrLstDisp refreshMasterList];
            [templListViewController.recurrLstDisp.tableView reloadData];
            [templListViewController.invLstDisp refreshMasterList];
            [templListViewController.invLstDisp.tableView reloadData];
           [templListViewController.scrtchLstDisp refreshMasterList];
            [templListViewController.scrtchLstDisp.tableView reloadData];
            
            [templListViewController.recurrLst refreshMasterList];
            [templListViewController.recurrLst.tableView reloadData];
            [templListViewController.invLst refreshMasterList];
            [templListViewController.invLst.tableView reloadData];
            [templListViewController.scrtchLst refreshMasterList];
            [templListViewController.scrtchLst.tableView reloadData];
        }
        else
        {
          for (NSUInteger i=0; i < vwcnt; ++i)
          {
            if ([[vws objectAtIndex:i] isMemberOfClass:[ListViewController class]])
            {
                ListViewController *pLst = [vws objectAtIndex:i];
                NSLog(@"Refreshing ListViewController at index %lu", (unsigned long)i);
                [pLst refreshMasterList];
                [pLst.tableView reloadData];
            }
          }
        }
        NSLog(@"Refreshing TemplListViewController");
        [templListViewController refreshMasterList];
        [templListViewController.tableView reloadData];
       
    });
   
    return;
}

-(void) updateTemplEditedItems
{
    NSUInteger mecnt = [masterListEditNames count];
    for (NSUInteger i=0; i < mecnt; ++i)
    {
        ItemKey *itk = [masterListEditNames objectAtIndex:i];
        NSMutableArray* mlistarr =  [masterListArr objectForKey:itk];
        if (mlistarr != nil)
        {
            NSUInteger enmcnt = [mlistarr count];
            for (NSUInteger j=0; j < enmcnt; ++j)
            {
                [self.easyManagedObjectContext deleteObject:[mlistarr objectAtIndex:j]];
            }
        }
    }
    
    int nStoreCnt=0;
    for (int i=0; i < mecnt; ++i)
    {
        nStoreCnt += [[masterListEditMps objectAtIndex:i] count];
    }
    
    NSMutableArray *storeItems = [[NSMutableArray alloc] initWithCapacity:nStoreCnt];
    
    
    NSManagedObjectModel *managedObjectModel =
    [[self.easyManagedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    NSLog(@"entity count %lu %s %d", (unsigned long)[[ent allKeys] count], __FILE__, __LINE__);
    NSEntityDescription *entity =
    [ent objectForKey:@"MasterList"];
    
    for (int i=0 ; i < nStoreCnt; ++i)
    {
        MasterList *newItem = [[MasterList alloc]
                               initWithEntity:entity insertIntoManagedObjectContext:self.easyManagedObjectContext];
        [storeItems addObject:newItem];
    }
    
    NSLog(@"Update Edited templ item aquired lock 1");
    NSUInteger nTotCnt=0;
    for (int i=0; i <mecnt; ++i)
    {
        NSArray *keys = [[masterListEditMps objectAtIndex:i] allKeys];
        NSMutableDictionary *rowitems = [masterListEditMps objectAtIndex:i];
        ItemKey *itk = [masterListEditNames objectAtIndex:i];
        NSUInteger valcnt = [keys count];
        for (NSUInteger j=0; j < valcnt; ++j)
        {
            LocalMasterList *itemstr = [rowitems objectForKey:[keys objectAtIndex:j]];
            NSUInteger len = [itemstr.item length];
            if (!len)
            {
                continue;
            }
            MasterList *item = [storeItems objectAtIndex:nTotCnt];
            item.name =  itk.name;
            item.share_id = itk.share_id;
            item.item = itemstr.item;
            item.startMonth = itemstr.startMonth;
            item.endMonth = itemstr.endMonth;
            item.inventory = itemstr.inventory;
            item.rowno = [[keys objectAtIndex:j] intValue];
            ++nTotCnt;
            // NSLog(@"Storing item at index %@ %lu\n", item, (unsigned long)nTotCnt);
        }
    }
    
    if (nTotCnt < nStoreCnt)
    {
        for (NSUInteger i= nTotCnt ; i < nStoreCnt; ++i)
        {
            [self.easyManagedObjectContext deleteObject:[storeItems objectAtIndex:i]];
        }
    }
    
    if (templItemsEdited > mecnt)
    {
        NSRange aR;
        aR.location = 0;
        aR.length = mecnt;
        [masterListEditNames removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
        [masterListEditMps removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
    }
    else
    {
        [masterListEditMps removeAllObjects];
        [masterListEditNames removeAllObjects];
    }
    templItemsEdited -= mecnt;
    [self saveEasyContext];
    return;
}


-(void) updateTemplDeletedItems
{
    
   
    NSUInteger mecnt = [masterListDeletedNames count];
    for (NSUInteger i=0; i < mecnt; ++i)
    {
        ItemKey *itk = [masterListDeletedNames objectAtIndex:i];
        NSMutableArray* mlistarr =  [masterListArr objectForKey:itk];
        if (mlistarr != nil)
        {
            NSUInteger enmcnt = [mlistarr count];
            NSLog(@"Deleting objects for name=%@ share_id=%lld, item_count=%lu, i=%lu", itk.name, itk.share_id, (unsigned long)enmcnt, (unsigned long)i);
            for (NSUInteger j=0; j < enmcnt; ++j)
            {
                [self.easyManagedObjectContext deleteObject:[mlistarr objectAtIndex:j]];
            }
        }
    }
    
    NSUInteger mlnmcnt = [masterListNamesArr count];
    for (NSUInteger i=0; i < mecnt; ++i)
    {
        ItemKey *itk = [masterListDeletedNames objectAtIndex:i];
        for (NSUInteger j=0; j < mlnmcnt; ++j)
        {
            ItemKey *itr = [masterListNamesArr objectAtIndex:j];
            if ([itk.name isEqualToString:itr.name] && itk.share_id == itr.share_id)
            {
                [self.easyManagedObjectContext deleteObject:[masterListNamesTmp objectAtIndex:j]];
            }
        }
    }
    
    [masterListDeletedNames removeAllObjects];
    
    templItemsDeleted -= mecnt;
    
    
    [self saveEasyContext];
    return;
}

-(void) refreshItemData
{
    
    NSManagedObjectContext *moc = self.easyManagedObjectContext;
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"ListNames" inManagedObjectContext:moc];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:descr];
    NSError *error = nil;
    listNamesTmp = [moc executeFetchRequest:req error:&error];
    
   
    listCnt = [listNamesTmp count];
    listNamesArr = [[NSMutableArray alloc] initWithCapacity:listCnt];
    picDic = [[NSMutableDictionary alloc] init];
    for (NSInteger i=0; i < listCnt; ++i)
    {
        ListNames *mnameRow = [listNamesTmp objectAtIndex:i];
        ItemKey *itk = [[ItemKey alloc] init];
        itk.name = mnameRow.name;
        itk.share_id = mnameRow.share_id;
        
        [listNamesArr addObject:itk];
        if (mnameRow.picurl != nil)
        {
            [picDic setObject:mnameRow.picurl forKey:itk];
        }
    }
    // NSLog(@"Refreshing list data count=%ld %@ %@\n", (long)listCnt, listNamesArr, picDic);
   
    
    descr = [NSEntityDescription entityForName:@"List" inManagedObjectContext:moc];
    [req setEntity:descr];
    // NSSortDescriptor* listDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
    //ascending:YES];
    NSSortDescriptor* rownoDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rowno"
                                                                    ascending:YES];
    // NSArray *sortDescriptors = [NSArray arrayWithObjects:listDescriptor, rownoDescriptor, nil];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: rownoDescriptor, nil];
    
    listTmp = [[moc executeFetchRequest:req error:&error]sortedArrayUsingDescriptors:sortDescriptors];
    NSUInteger listcnt = [listTmp count];
    
    NSLog(@"No of items in List %lu", (unsigned long)listcnt);
    listArr = [NSMutableDictionary dictionaryWithCapacity:listcnt];
    for (NSUInteger i=0; i < listcnt; ++i)
    {
        List *item = [listTmp objectAtIndex:i];
        // NSLog(@"Adding item to master list %@\n", item);
        ItemKey *itk = [[ItemKey alloc] init];
        itk.name = item.name;
        itk.share_id = item.share_id;

        NSMutableArray* listarr =  [listArr objectForKey:itk];
        if (listarr != nil)
        {
            [listarr addObject:item];
        }
        else
        {
            listarr = [[NSMutableArray alloc] init];
            [listarr addObject:item];
            [listArr setObject:listarr forKey:itk];
            
        }
        
    }
    return;
}


-(instancetype) init
{
    self = [super init];
    if (self)
    {
        
        appName = [[NSString alloc] init];
        bReady = false;
        return self;
        
    }
    
    return nil;
    
}

-(void) main
{
    masterListEditNames = [[NSMutableArray alloc] init];
    masterListEditMps = [[NSMutableArray alloc] init];
    listArr = [[NSMutableDictionary alloc] init];
    newItems = [[NSMutableArray alloc] init];
    workToDo = [[NSCondition alloc]init];
    templItemsDeleted = 0;
    masterListDeletedNames = [[NSMutableArray alloc] init];
    refreshNow = false;
    itemsToAdd = 0;
     listMps = [[NSMutableArray alloc] init];
    easyItemsToAdd =0;
    itemsEdited = 0;
    templItemsEdited = 0;
     templItemsToAdd = 0;
    templShareItemsToAdd = 0;
    itemSelectedChanged = false;
    itemsToShare = 0;
    itemsToDownload = 0;
    itemsToDownloadOnStartUp = 0;
    forceRefresh = false;
    itemsDeleted = 0;
    editedItems = [[NSMutableArray alloc] init];
    deletedItems = [[NSMutableArray alloc] init];
    itemNamesTmp = [[NSArray alloc] init];
    itemNames = [[NSMutableArray alloc] init];
    unFilteredItemsTmp = [[NSArray alloc] init];
    unFilteredItems = [[NSMutableArray alloc] init];
    sharedItems = [[NSMutableArray alloc]init];
    downloadIds = [[NSMutableArray alloc] init];
    masterListNamesArr =[[NSMutableArray alloc] init];
     masterListArr = [[NSMutableDictionary alloc] init];
    updateNow = false;
    bInitRefresh = true;
    bInUpload = false;
    bRedColor = false;
    waitTime = 4;
    bAnimateNow = false;
    bAnimateOnDwld = false;
    bAnimateOnStrtUp = false;
    bInStartUpDownload =false;
    bShowSelfHelp = true;
    upldBkTaskId = UIBackgroundTaskInvalid;
    dwldBkTaskId = UIBackgroundTaskInvalid;
    dwldStrtUpTaskId = UIBackgroundTaskInvalid;
    loginTaskId = UIBackgroundTaskInvalid;
    masterListNames = [[NSMutableArray alloc] init];
    masterListMps = [[NSMutableArray alloc] init];
    shareMasterListNames = [[NSMutableArray alloc] init];
    shareMasterListMps = [[NSMutableArray alloc] init];
     picItemsToAdd = 0;
    listNames = [[NSMutableArray alloc] init];
    listPicUrls = [[NSMutableArray alloc] init];
     listPicNames = [[NSMutableArray alloc] init];
    listEditNames = [[NSMutableArray alloc] init];
    listEditMps = [[NSMutableArray alloc] init];
    listHiddenMps = [[NSMutableArray alloc] init];
    itemsHidden = 0;
    itemsEasyEdited = 0;
    itemsEasyDeleted = 0;
    listDeletedNames = [[NSMutableArray alloc] init];
    templNameItemsToAdd = 0;
    masterListNamesOnly = [[NSMutableArray alloc] init];
    
    
    shareQ = dispatch_queue_create("P2P_SHAREQ", DISPATCH_QUEUE_SERIAL);
    if ([appName isEqualToString:@"EasyGrocList"])
    {
        [self refreshItemData];
        [self updateEasyMainLstVwCntrl];
        [self refreshTemplData];
        [self updateMasterLstVwCntrl];
        [self getAlexaItems];
        
    }
    else
    {
        [self refreshData];
        [self updateMainLstVwCntrl];
        [self refreshTemplData];
        [self refreshItemData];
    }
   
    bReady = true;
    for(;;)
    {
        [workToDo lock];
        if (!templItemsDeleted || !easyItemsToAdd || !templItemsToAdd || !templShareItemsToAdd || !templItemsEdited || !itemsToAdd  || !itemsEdited ||!itemsDeleted || !refreshNow || !updateNow || !loginNow || !picItemsToAdd   || !itemSelectedChanged || !itemsEasyEdited || !itemsHidden || !itemsEasyDeleted || !refreshMainLst || !templNameItemsToAdd )
        {
          // NSLog(@"Waiting for work\n");
            NSDate *checkTime = [NSDate dateWithTimeIntervalSinceNow:waitTime];
            [workToDo waitUntilDate:checkTime];
        }
        [workToDo unlock];
        
        
        if (templItemsToAdd)
        {
            NSLog(@"Adding %d template items\n", templItemsToAdd);
            [workToDo lock];
            [self storeNewTemplItems];
            [self refreshTemplData];
            [workToDo unlock];
            [self updateMasterLstVwCntrl];
            
        }
        
        if (templShareItemsToAdd)
        {
            NSLog(@"Adding %d template Share items\n", templShareItemsToAdd);
            [workToDo lock];
            [self storeNewTemplShareItems];
            [self refreshTemplData];
            [workToDo unlock];
            [self updateMasterLstVwCntrl];
            
        }
        
        if (templNameItemsToAdd)
        {
            NSLog(@"Adding %d template names\n", templNameItemsToAdd);
            [workToDo lock];
            [self storeNewTemplNames];
            [self refreshTemplData];
             [workToDo unlock];
            [self updateMasterLstVwCntrl];
        }
        
       
        if (refreshMainLst)
        {
            [workToDo lock];
            [self refreshItemData];
            [workToDo unlock];
            [self updateEasyMainLstVwCntrl];
            refreshMainLst = false;
        }

        
        
        if (itemSelectedChanged)
        {
            [workToDo lock];
            [self updateSelectedItem];
            [self refreshItemData];
            [workToDo unlock];
            itemSelectedChanged = false;
        }
        
        if (picItemsToAdd)
        {
            NSLog(@"Adding %d pic items\n", picItemsToAdd);
            [workToDo lock];
            [self storeNewPicItems];
            [self refreshItemData];
            [workToDo unlock];
            [self updateEasyMainLstVwCntrl];
        }

        if (templItemsEdited)
        {
            NSLog(@"Editing %d templ items\n", templItemsEdited);
            [workToDo lock];
            [self updateTemplEditedItems];
            [self refreshTemplData];
            [workToDo unlock];
            [self updateMasterLstVwCntrl];
        }
        
        if (templItemsDeleted)
        {
            NSLog(@"Deleting %d template items\n", templItemsDeleted);
            [workToDo lock];
            [self updateTemplDeletedItems];
            [self refreshTemplData];
            [workToDo unlock];
            [self updateMasterLstVwCntrl];
        }
        
        if (itemsToAdd)
        {
            NSLog(@"Adding %d items\n", itemsToAdd);
            [workToDo lock];
            [self storeNewItems];
            [self refreshData];
            [workToDo unlock];
            [self updateMainLstVwCntrl];

        }
        
        if (itemsHidden)
        {
            
            NSLog(@"Updating  %d hidden items\n", itemsHidden);
                [workToDo lock];
            [self updateHiddenItems];
            [self refreshItemData];
             [workToDo unlock];
            
        }
        
        
        if (itemsEasyEdited)
        {
            NSLog(@"Editing %d items\n", itemsEasyEdited);
            [workToDo lock];
           [self updateEasyEditedItems];
           [self refreshItemData];
              [workToDo unlock];
           [self updateEasyMainLstVwCntrl];
            [self updateLstVwCntrl];
        }
        
        if (itemsEasyDeleted)
        {
            NSLog(@"Deleting easy %d items\n", itemsDeleted);
            [workToDo lock];
            [self updateEasyDeletedItems];
            [self refreshItemData];
             [workToDo unlock];
            [self updateEasyMainLstVwCntrl];
        }

        if (easyItemsToAdd)
        {
            NSLog(@"Adding %d list items\n", easyItemsToAdd);
            [workToDo lock];
            [self storeNewEasyItems];
            [self refreshItemData];
            [workToDo unlock];
            [self updateEasyMainLstVwCntrl];
            [self updateLstVwCntrl];
            
        }

        
        if (itemsEdited)
        {
            NSLog(@"Editing %d items\n", itemsEdited);
            [workToDo lock];
            [self updateEditedItems];
            [self refreshData];
             [workToDo unlock];
            [self updateMainLstVwCntrl];
            
        }
        
        
        
        if(itemsDeleted)
        {
            NSLog(@"Deleted %d items\n", itemsDeleted);
            [workToDo lock];
            [self updateDeletedItems];
            [self refreshData];
             [workToDo unlock];
            [self updateMainLstVwCntrl];

        }
        
        if (forceRefresh)
        {
            NSDate *now = [NSDate date];
            if ([now compare:refreshTime] == NSOrderedDescending)
            {
                forceRefresh = false;
                 [workToDo lock];
                [self refreshData];
                NSLog(@"FORCE Refreshing main screen contents in DataOps.m\n");
                 [workToDo unlock];
                [self updateMainLstVwCntrl];
            }
        }
        
        if(refreshNow)
        {
            
            
          //  forceRefresh = true;
           //  refreshTime = [NSDate dateWithTimeIntervalSinceNow:10];
             [workToDo lock];
             [self refreshData];
             [workToDo unlock];
             NSLog(@"Refreshing main screen contents in DataOps.m\n");
             [self updateMainLstVwCntrl];
            refreshNow = false;
        }
        
        if (updateNow)
        {
            updateNow = false;
            NSLog(@"Updating main screen contents in DataOps.m\n");
            [self updateMainLstVwCntrl];
        }
        
       // NSLog(@"Waiting for lock in main queue");
        
    }
    
    return;
}


-(void) updateEasyDeletedItems
{
    
    NSUInteger mecnt = [listDeletedNames count];
    for (NSUInteger i=0; i < mecnt; ++i)
    {
        ItemKey* itk = [listDeletedNames objectAtIndex:i];
        NSMutableArray* listarr =  [listArr objectForKey:itk];
        if (listarr != nil)
        {
            NSUInteger enmcnt = [listarr count];
            for (NSUInteger j=0; j < enmcnt; ++j)
            {
                [self.easyManagedObjectContext deleteObject:[listarr objectAtIndex:j]];
            }
        }
    }
    
    NSUInteger mlnmcnt = [listNamesArr count];
    for (NSUInteger i=0; i < mecnt; ++i)
    {
        ItemKey* itk = [listDeletedNames objectAtIndex:i];
        for (NSUInteger j=0; j < mlnmcnt; ++j)
        {
            ItemKey *itr = [listNamesArr objectAtIndex:j];
            if ([itk.name isEqualToString:itr.name] && itk.share_id == itr.share_id)
            {
                [self.easyManagedObjectContext deleteObject:[listNamesTmp objectAtIndex:j]];
            }
        }
    }
    
    [listDeletedNames removeAllObjects];
    
    itemsEasyDeleted -= mecnt;
  
    
    [self saveEasyContext];
    return;
}

-(NSArray *) getListNames
{
    [workToDo lock];
    NSArray *tmpArr = [NSArray arrayWithArray:listNamesArr];
    [workToDo unlock];
    return tmpArr;
}


-(void) editItem:(ItemKey *)name itemsDic:(NSMutableDictionary*) itmsMp
{
    [workToDo lock];
    [listEditNames addObject:name];
    [listEditMps addObject:itmsMp];
    ++itemsEasyEdited;
    NSLog(@"Signalling work to do for Updating item %@ %d", name, itemsEasyEdited);
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(NSDictionary *) getPics
{
    [workToDo lock];
    NSDictionary *pics = [NSDictionary dictionaryWithDictionary:picDic];
    [workToDo unlock];
    return pics;
}


-(void) updateLstVwCntrl
{
  
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSArray *vws = [pAppCmnUtil.navViewController viewControllers];
        NSUInteger vwcnt = [vws count];
        //NSLog(@"No of view controllers EasyDataOps:updateLstVwCntrl %lu", (unsigned long)vwcnt);
        for (NSUInteger i=0; i < vwcnt; ++i)
        {
            if ([[vws objectAtIndex:i] isMemberOfClass:[List1ViewController class]])
            {
                List1ViewController *pLst = [vws objectAtIndex:i];
                NSLog(@"updateLstVwCntrl refreshList ");
                [pLst refreshList];
                [pLst.tableView reloadData];
            }
            //  NSLog(@"View controller class EasyDataOps:updateLstVwCntrl %@", NSStringFromClass([[vws objectAtIndex:i] class]));
            
            
        }
    });
   
    return;
}

-(void) hiddenItems:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp hiddenDic:(NSMutableDictionary*) hiddensMp
{
    [workToDo lock];
    [listEditNames addObject:name];
    [listEditMps addObject:itmsMp];
    [listHiddenMps addObject:hiddensMp];
    ++itemsHidden;
    NSLog(@"Added hidden item %@ %d and signalling work to do\n", name, itemsEdited);
    [workToDo signal];
    [workToDo unlock];
    return;
    
}

-(void) updateHiddenItems
{
    
    
    NSUInteger ecnt = [listEditNames count];
    for (NSUInteger i=0; i < ecnt; ++i)
    {
        NSString *name = [listEditNames objectAtIndex:i];
        NSMutableArray* listarr =  [listArr objectForKey:name];
        if (listarr != nil)
        {
            NSUInteger enmcnt = [listarr count];
            for (NSUInteger j=0; j < enmcnt; ++j)
            {
                [self.easyManagedObjectContext deleteObject:[listarr objectAtIndex:j]];
            }
        }
    }
    
    int nStoreCnt=0;
    for (int i=0; i < ecnt; ++i)
    {
        nStoreCnt += [[listEditMps objectAtIndex:i] count];
    }
    
    
    
    NSUInteger mlnmcnt = [listNamesArr count];
    for (NSUInteger i=0; i < ecnt; ++i)
    {
        NSString *name = [listEditNames objectAtIndex:i];
        for (NSUInteger j=0; j < mlnmcnt; ++j)
        {
            if ([name isEqualToString:[listNamesArr objectAtIndex:j]])
            {
                [self.easyManagedObjectContext deleteObject:[listNamesTmp objectAtIndex:j]];
            }
        }
    }
    
    
    
    NSMutableArray *storeItems = [[NSMutableArray alloc] initWithCapacity:nStoreCnt];
    NSMutableArray *storeNames = [[NSMutableArray alloc] initWithCapacity:ecnt];
    
    NSManagedObjectModel *managedObjectModel =
    [[self.easyManagedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
    NSEntityDescription *entity =
    [ent objectForKey:@"List"];
    
    for (int i=0 ; i < nStoreCnt; ++i)
    {
        List *newItem = [[List alloc]
                         initWithEntity:entity insertIntoManagedObjectContext:self.easyManagedObjectContext];
        [storeItems addObject:newItem];
    }
    NSEntityDescription *nameEntity = [ent objectForKey:@"ListNames"];
    for (int i=0; i<ecnt; ++i)
    {
        ListNames *newName = [[ListNames alloc] initWithEntity:nameEntity insertIntoManagedObjectContext:self.easyManagedObjectContext];
        [storeNames addObject:newName];
    }
    
    
   
    NSUInteger nTotCnt=0;
    for (int i=0; i <ecnt; ++i)
    {
        NSArray *keys = [[listEditMps objectAtIndex:i] allKeys];
        NSMutableDictionary *rowitems = [listEditMps objectAtIndex:i];
        NSMutableDictionary *hiddenitems = [listHiddenMps objectAtIndex:i];
        NSString *name = [listEditNames objectAtIndex:i];
        NSUInteger valcnt = [keys count];
        for (NSUInteger j=0; j < valcnt; ++j)
        {
            List *itemstr = [rowitems objectForKey:[keys objectAtIndex:j]];
            NSUInteger len = [itemstr.item length];
            if (!len)
            {
                continue;
            }
            List *item = [storeItems objectAtIndex:nTotCnt];
            item.name = name;
            item.item = itemstr.item;
            item.rowno = itemstr.rowno;
            NSNumber *hidden = [hiddenitems objectForKey:[keys objectAtIndex:j]];
            item.hidden = [hidden boolValue];
            ++nTotCnt;
            // NSLog(@"Storing item at index %@ %lu\n", item, (unsigned long)nTotCnt);
        }
        ListNames *mname = [storeNames objectAtIndex:i];
        mname.name = name;
        mname.current = YES;
        //NSLog(@"Storing master list name %@\n", mname);
        
    }
    
    if (nTotCnt < nStoreCnt)
    {
        for (NSUInteger i= nTotCnt ; i < nStoreCnt; ++i)
        {
            [self.easyManagedObjectContext deleteObject:[storeItems objectAtIndex:i]];
        }
    }
    
    if (itemsHidden > ecnt)
    {
        NSRange aR;
        aR.location = 0;
        aR.length = ecnt;
        [listEditNames removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
        [listEditMps removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
        [listHiddenMps removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
    }
    else
    {
        [listEditMps removeAllObjects];
        [listEditNames removeAllObjects];
        [listHiddenMps removeAllObjects];
    }
    itemsHidden -= ecnt;
   
    [self saveEasyContext];
    return;
}




-(void) updateSelectedItem
{
    
    ItemKey *selectedItm;
    
    selectedItm = selectedItem;
    
    
    NSUInteger mlnmcnt = [listNamesArr count];
    for (NSUInteger j=0; j < mlnmcnt; ++j)
    {
        ListNames *mname = [listNamesTmp objectAtIndex:j];
        // NSLog(@"Before updating current item %@", mname);
        if ([mname.name isEqualToString:selectedItm.name])
        mname.current = YES;
        else
        mname.current = NO;
        //NSLog(@"After updating current item %@", mname);
    }
    
    [self saveEasyContext];
    
    return;
}



-(void) storeNewEasyItems
{
    
    int nItems = easyItemsToAdd;
    int nStoreCnt=0;
  
    for (int i=0; i < nItems; ++i)
    {
        nStoreCnt += [[listMps objectAtIndex:i] count];
    }
    
    
    NSMutableArray *storeItems = [[NSMutableArray alloc] initWithCapacity:nStoreCnt];
    NSMutableArray *storeNames = [[NSMutableArray alloc] initWithCapacity:nItems];
    
    NSManagedObjectModel *managedObjectModel =
    [[self.easyManagedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
    NSEntityDescription *entity =
    [ent objectForKey:@"List"];
    
    for (int i=0 ; i < nStoreCnt; ++i)
    {
        List *newItem = [[List alloc]
                         initWithEntity:entity insertIntoManagedObjectContext:self.easyManagedObjectContext];
        //List *newItem = [[List alloc] init];
        
        [storeItems addObject:newItem];
    }
    NSEntityDescription *nameEntity = [ent objectForKey:@"ListNames"];
    if(nStoreCnt)
    {
        for (int i=0; i<nItems; ++i)
        {
            ListNames *newName = [[ListNames alloc] initWithEntity:nameEntity insertIntoManagedObjectContext:self.easyManagedObjectContext];
            [storeNames addObject:newName];
        }
    }
    
    
    NSUInteger nTotCnt=0;
    if (nStoreCnt)
    {
        for (int i=0; i <nItems; ++i)
        {
            NSArray *keys = [[listMps objectAtIndex:i] allKeys];
            NSMutableDictionary *rowitems = [listMps objectAtIndex:i];
            ItemKey *itk = [listNames objectAtIndex:i];
            NSUInteger valcnt = [keys count];
            for (NSUInteger j=0; j < valcnt; ++j)
            {
                LocalList *itemstr = [rowitems objectForKey:[keys objectAtIndex:j]];
                NSUInteger len = [itemstr.item length];
                if (!len)
                {
                    continue;
                }
                List *item = [storeItems objectAtIndex:nTotCnt];
                
                
                
                item.item = itemstr.item;
                item.name = itk.name;
                item.share_id = itk.share_id;
                item.hidden = itemstr.hidden;
                item.rowno = itemstr.rowno;
                ++nTotCnt;
                //NSLog(@"Storing item at index %@ %lu\n", item, (unsigned long)nTotCnt);
            }
            ListNames *mname = [storeNames objectAtIndex:i];
            
            
            mname.name = itk.name;
            mname.share_id = itk.share_id;
            
            //NSLog(@"Storing  list name %@\n", mname);
            
        }
    }
     [self saveEasyContext];
    if (easyItemsToAdd > nItems)
    {
        NSRange aR;
        aR.location = 0;
        aR.length = nItems;
        [listNames removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
        [listMps removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
    }
    else
    {
        [listMps removeAllObjects];
        [listNames removeAllObjects];
    }
    easyItemsToAdd -= nItems;
    
    return;
}

-(void) selectedItem: (ItemKey *) selectedItm
{
    [workToDo lock];
    itemSelectedChanged = true;
    selectedItem = selectedItm;
    [workToDo unlock];
    return;
}




-(void) storeNewPicItems
{
    
    int nItems = picItemsToAdd;
    NSMutableArray *storeNames = [[NSMutableArray alloc] initWithCapacity:nItems];
    
    NSManagedObjectModel *managedObjectModel =
    [[self.easyManagedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
    NSEntityDescription *nameEntity = [ent objectForKey:@"ListNames"];
    for (int i=0; i<nItems; ++i)
    {
        ListNames *newName = [[ListNames alloc] initWithEntity:nameEntity insertIntoManagedObjectContext:self.easyManagedObjectContext];
        [storeNames addObject:newName];
    }
    
    
    for (int i=0; i <nItems; ++i)
    {
        ItemKey *itk = [listPicNames objectAtIndex:i];
        NSString *url =  [listPicUrls objectAtIndex:i];
        ListNames *mname = [storeNames objectAtIndex:i];
        mname.name = itk.name;
        mname.share_id = itk.share_id;
        
        mname.picurl = url;
        // NSLog(@"Storing  list name %@\n", mname);
    }
    
    if (picItemsToAdd > nItems)
    {
        NSRange aR;
        aR.location = 0;
        aR.length = nItems;
        [listPicNames removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
        [listPicUrls removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
    }
    else
    {
        [listPicNames removeAllObjects];
        [listPicUrls removeAllObjects];
    }
    picItemsToAdd -= nItems;

    [self saveEasyContext];
    
    return;
}

-(void) storeNewTemplNames
{
    
    int nItems = templNameItemsToAdd;
    NSMutableArray *storeNames = [[NSMutableArray alloc] initWithCapacity:nItems];
    
    NSManagedObjectModel *managedObjectModel =
    [[self.easyManagedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
    
    NSEntityDescription *nameEntity = [ent objectForKey:@"MasterListNames"];
    for (int i=0; i<nItems; ++i)
    {
        MasterListNames *newName = [[MasterListNames alloc] initWithEntity:nameEntity insertIntoManagedObjectContext:[self easyManagedObjectContext]];
        [storeNames addObject:newName];
    }
    
    
    
    for (int i=0; i <nItems; ++i)
    {
        ItemKey *name = [masterListNamesOnly objectAtIndex:i];
        MasterListNames *mname = [storeNames objectAtIndex:i];
        mname.name = name.name;
        mname.share_id = name.share_id;
        mname.share_name = @"0";
        // NSLog(@"Storing master list name %@\n", mname);
        
    }
    
    if (templNameItemsToAdd > nItems)
    {
        NSRange aR;
        aR.location = 0;
        aR.length = nItems;
        [masterListNamesOnly removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
    }
    else
    {
        [masterListNamesOnly removeAllObjects];
    }
    templNameItemsToAdd -= nItems;
    
    [self saveEasyContext];
    
    return;
}



-(void) storeNewTemplShareItems
{
    
    int nItems = templShareItemsToAdd;
    int nStoreCnt=0;
    
    for (int i=0; i < nItems; ++i)
    {
        nStoreCnt += [[shareMasterListMps objectAtIndex:i] count];
    }
    
    
    NSMutableArray *storeItems = [[NSMutableArray alloc] initWithCapacity:nStoreCnt];
    NSMutableArray *storeNames = [[NSMutableArray alloc] initWithCapacity:nItems];
    
    NSManagedObjectModel *managedObjectModel =
    [[self.easyManagedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
    NSEntityDescription *entity =
    [ent objectForKey:@"MasterList"];
    
    for (int i=0 ; i < nStoreCnt; ++i)
    {
        MasterList *newItem = [[MasterList alloc]
                               initWithEntity:entity insertIntoManagedObjectContext:[self easyManagedObjectContext]];
        [storeItems addObject:newItem];
    }
    NSEntityDescription *nameEntity = [ent objectForKey:@"MasterListNames"];
    if(nStoreCnt)
    {
        for (int i=0; i<nItems; ++i)
        {
            MasterListNames *newName = [[MasterListNames alloc] initWithEntity:nameEntity insertIntoManagedObjectContext:[self easyManagedObjectContext]];
            [storeNames addObject:newName];
        }
    }
    
    
    NSUInteger nTotCnt=0;
    if (nStoreCnt)
    {
        for (int i=0; i <nItems; ++i)
        {
            NSArray *keys = [[shareMasterListMps objectAtIndex:i] allKeys];
            NSMutableDictionary *rowitems = [shareMasterListMps objectAtIndex:i];
            ItemKey *itk = [shareMasterListNames objectAtIndex:i];
            NSUInteger valcnt = [keys count];
            for (NSUInteger j=0; j < valcnt; ++j)
            {
                LocalMasterList *itemstr = [rowitems objectForKey:[keys objectAtIndex:j]];
                NSUInteger len = [itemstr.item length];
                if (!len)
                {
                    continue;
                }
                MasterList *item = [storeItems objectAtIndex:nTotCnt];
                item.name = itk.name;
                item.share_id = itk.share_id;
                item.item = itemstr.item;
                item.startMonth = itemstr.startMonth;
                item.endMonth = itemstr.endMonth;
                item.inventory = itemstr.inventory;
                item.rowno = [[keys objectAtIndex:j] intValue];
                ++nTotCnt;
                //  NSLog(@"Storing item at index %@ %lu\n", item, (unsigned long)nTotCnt);
            }
            MasterListNames *mname = [storeNames objectAtIndex:i];
            mname.name = itk.name;
            mname.share_id = itk.share_id;
                    
        }
    }
    if (templShareItemsToAdd > nItems)
    {
        NSRange aR;
        aR.location = 0;
        aR.length = nItems;
        [shareMasterListNames removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
        [shareMasterListMps removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
    }
    else
    {
        [shareMasterListMps removeAllObjects];
        [shareMasterListNames removeAllObjects];
    }
    templShareItemsToAdd -= nItems;
    
    [self saveEasyContext];
    
    return;
}

-(void) storeNewTemplItems
{
    
    int nItems = templItemsToAdd;
    int nStoreCnt=0;
    
    for (int i=0; i < nItems; ++i)
    {
        nStoreCnt += [[masterListMps objectAtIndex:i] count];
    }
   
    
    NSMutableArray *storeItems = [[NSMutableArray alloc] initWithCapacity:nStoreCnt];
 
    
    NSManagedObjectModel *managedObjectModel =
    [[self.easyManagedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
    NSEntityDescription *entity =
    [ent objectForKey:@"MasterList"];
    
    for (int i=0 ; i < nStoreCnt; ++i)
    {
        MasterList *newItem = [[MasterList alloc]
                               initWithEntity:entity insertIntoManagedObjectContext:[self easyManagedObjectContext]];
        [storeItems addObject:newItem];
    }
    
    NSUInteger nTotCnt=0;
    if (nStoreCnt)
    {
        for (int i=0; i <nItems; ++i)
        {
            NSArray *keys = [[masterListMps objectAtIndex:i] allKeys];
            NSMutableDictionary *rowitems = [masterListMps objectAtIndex:i];
            ItemKey *itk = [masterListNames objectAtIndex:i];
            NSUInteger valcnt = [keys count];
            for (NSUInteger j=0; j < valcnt; ++j)
            {
                LocalMasterList *itemstr = [rowitems objectForKey:[keys objectAtIndex:j]];
                NSUInteger len = [itemstr.item length];
                if (!len)
                {
                    continue;
                }
                MasterList *item = [storeItems objectAtIndex:nTotCnt];
                item.name = itk.name;
                item.share_id = itk.share_id;
                item.item = itemstr.item;
                item.startMonth = itemstr.startMonth;
                item.endMonth = itemstr.endMonth;
                item.inventory = itemstr.inventory;
                item.rowno = [[keys objectAtIndex:j] intValue];
                ++nTotCnt;
                 NSLog(@"Storing item at index %@ %lu\n", item, (unsigned long)nTotCnt);
            }
            
        }
    }
    if (templItemsToAdd > nItems)
    {
        NSRange aR;
        aR.location = 0;
        aR.length = nItems;
        [masterListNames removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
        [masterListMps removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
    }
    else
    {
        [masterListMps removeAllObjects];
        [masterListNames removeAllObjects];
    }
    templItemsToAdd -= nItems;
    [self saveEasyContext];
    
    return;
}



-(bool) checkMlistNameExist:(NSString *)name
{
    for (ItemKey *nm in masterListNamesArr)
    {
        if ([nm.name isEqualToString:name])
            return false;
    }
    return true;
}

//Lock and unlock manually
-(NSArray *) getMasterListNames
{
    return masterListNamesArr;
}

-(bool) shouldAddInScrtchList:(int)startMonth endM:(int) endMonth
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar  components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger month = [components month];
    
                if (endMonth > startMonth)
                {
                    if (month > endMonth || month < startMonth)
                        return true;
                    
                }
                else if (endMonth == startMonth)
                {
                    if (month != endMonth)
                        return true;
                }
                else
                {
                    if (month < startMonth && month > endMonth)
                        return true;
                }
    return false;
}
-(void) putAlexaItems:(NSArray *)items
{
    [workToDo lock];
    alexaEditDic = [[NSMutableDictionary alloc] init];
    alexaAddDic = [[NSMutableDictionary alloc] init];
   NSMutableDictionary *alexaNonTemplDic = [[NSMutableDictionary alloc] init];
    ItemKey *alexaKey = [self getAlexaListName];
    NSUInteger cnt = [items count];
    for (NSUInteger i=0; i < cnt; ++i)
    {
       
            AlexaItem *item = (AlexaItem *)[items objectAtIndex:i];
        NSLog(@"Adding item name=%@, masterList=%@, date=%ld add=%hhd", item.name, item.masterList, (long)item.date, (char)item.add);
        NSString *masterList = [item.masterList stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *alexaItemName = [item.name stringByReplacingOccurrencesOfString:@" " withString:@""];
        bool bFoundMlist = false;
        NSArray *keys = [masterListArr allKeys];
        NSUInteger mcnt = [keys count];
        bool bAddInScrtch = true;
        NSString *masterListInv = [masterList stringByAppendingString:@":INV"];
        NSString *masterListScrtch = [masterList stringByAppendingString:@":SCRTCH"];
        ItemKey *masterListName = [[ItemKey alloc] init];
        for (NSUInteger j=0; j < mcnt; ++j)
        {
            ItemKey *key = [keys objectAtIndex:j];
            
            NSString *keyName = [key.name stringByReplacingOccurrencesOfString:@" " withString:@""];
          
            if ([masterList caseInsensitiveCompare:keyName] == NSOrderedSame)
            {
                bFoundMlist = true;
                masterListName.name = key.name;
                masterListName.share_id = key.share_id;
                NSMutableArray* mlistarr =  [masterListArr objectForKey:key];
                NSUInteger mecnt = [mlistarr count];
                for (int k=0; k < mecnt; ++k)
                {
                    MasterList *itemM = [mlistarr objectAtIndex:k];
                    NSString *masterListItem = [itemM.item stringByReplacingOccurrencesOfString:@" " withString:@""];
                    if ([masterListItem caseInsensitiveCompare:alexaItemName] == NSOrderedSame)
                    {
                        bAddInScrtch = [self shouldAddInScrtchList:itemM.startMonth endM:itemM.endMonth];
                        break;
                      
                    }
                }
            }
            if ([masterListInv caseInsensitiveCompare:keyName] == NSOrderedSame)
            {
                bFoundMlist = true;
                masterListName.name = [key.name substringToIndex:[key.name length]-4];
                masterListName.share_id  = key.share_id;
                NSMutableArray* mlistarr =  [masterListArr objectForKey:key];
                NSUInteger mecnt = [mlistarr count];
                for (int k=0; k < mecnt; ++k)
                {
                    MasterList *itemM = [mlistarr objectAtIndex:k];
                    NSString *masterListItem = [itemM.item stringByReplacingOccurrencesOfString:@" " withString:@""];
                    if ([masterListItem caseInsensitiveCompare:alexaItemName] == NSOrderedSame)
                    {
                        bAddInScrtch = false;
                        if (item.add == YES)
                        {
                        itemM.inventory = 0;
                        }
                        else
                        {
                            itemM.inventory = 10;
                        }
                        if (![self updateAlexaTemplEditItem:itemM itemKey:key])
                        {
                            [self createAlexaTemplEditItems:mlistarr itemKey:key];
                            [self updateAlexaTemplEditItem:itemM itemKey:key];
                        }
                    }
                    
                }
            }
            
        }
        
        if(bFoundMlist && bAddInScrtch)
        {
            bool bFoundScrtchMlist=false;
            for (NSUInteger j=0; j < mcnt; ++j)
            {
                ItemKey *key = [keys objectAtIndex:j];
            
                NSString *keyName = [key.name stringByReplacingOccurrencesOfString:@" " withString:@""];
                if ([masterListScrtch caseInsensitiveCompare:keyName] == NSOrderedSame)
                {
                    bFoundScrtchMlist = true;
                    NSMutableArray* mlistarr =  [masterListArr objectForKey:key];
                    if (![self updateAlexaScrtchList:key alexaItem:item])
                    {
                        [self createAlexaTemplEditItems:mlistarr itemKey:key];
                        [self updateAlexaScrtchList:key alexaItem:item];
                    }
                        
                }
            }
            if (!bFoundScrtchMlist)
            {
                masterListName.name = [masterListName.name stringByAppendingString:@":SCRTCH"];
                [self addToAlexaMasterList:item itemKey:masterListName dic:alexaAddDic];
            }
        }
        else if (!bFoundMlist)
        {
            [self addToAlexaList:item itemKey:alexaKey dic:alexaNonTemplDic];
        }
    }
    [workToDo unlock];
    
    for (ItemKey *itk in alexaEditDic)
    {
        NSMutableDictionary *itemMp = [alexaEditDic objectForKey:itk];
        [self editedTemplItem:itk itemsDic:itemMp];
    }
    
    for (ItemKey *itk in alexaAddDic)
    {
        NSMutableDictionary *itemMp = [alexaAddDic objectForKey:itk];
        [self addTemplItem:itk itemsDic:itemMp];
    }
    
    for (ItemKey *itk in alexaNonTemplDic)
    {
        NSMutableDictionary *itemMp = [alexaNonTemplDic objectForKey:itk];
        [self addItem:itk itemsDic:itemMp];
    }
}

-(ItemKey *) getAlexaListName
{
    ItemKey *itk = [[ItemKey alloc] init];
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    itk.share_id =  pAppCmnUtil.share_id;
    NSString *name = @"List";
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *formattedDateString = [dateFormatter stringFromDate:today];
    name = [name stringByAppendingString:@" "];
    name = [name stringByAppendingString:formattedDateString];
    itk.name = name;
    return itk;
}

-(void) addToAlexaMasterList:(AlexaItem *) alexaItem itemKey:(ItemKey *) key dic:(NSMutableDictionary *)alexaDic
{
    NSMutableDictionary *itemMp = [alexaDic objectForKey:key];
    if (itemMp != nil)
    {
        [self updateAlexaMasterListItemMp:key alexaItem:alexaItem itemRowDic:itemMp];
    }
    else
    {
        if (alexaItem.add)
        {
            itemMp = [NSMutableDictionary dictionaryWithCapacity:10];
            LocalMasterList *itemL = [[LocalMasterList alloc] init];
            itemL.name = key.name;
            itemL.item = alexaItem.name;
            itemL.inventory = 10;
            itemL.rowno = [itemMp count]+1;
            itemL.share_id = key.share_id;
            
            [itemMp setObject:itemL forKey:[NSNumber numberWithLongLong:itemL.rowno]];
            [alexaDic setObject:itemMp forKey:key];
        }
    }
}

-(void) updateAlexaMasterListItemMp:(ItemKey *) key alexaItem:(AlexaItem*) alexaItem itemRowDic:(NSMutableDictionary *)itemMp
{
    bool bFound = false;
    bool bRemove = false;
    long long rowno = 0;
    NSNumber *keyItem;
    for(keyItem in itemMp) {
        LocalMasterList* value = [itemMp objectForKey:keyItem];
        if ([value.item isEqualToString:alexaItem.name])
        {
            bFound = true;
            rowno = value.rowno;
            if (!alexaItem.add)
            {
                bRemove = true;
            }
            break;
        }
    }
    if (bFound && bRemove)
    {
        [itemMp removeObjectForKey:[NSNumber numberWithLongLong:rowno]];
    }
    if (!bFound)
    {
        if (alexaItem.add)
        {
            
            LocalMasterList *itemL = [[LocalMasterList alloc] init];
            itemL.name = key.name;
            itemL.item = alexaItem.name;
            itemL.inventory = 10;
            itemL.rowno = [itemMp count]+1;
            itemL.share_id = key.share_id;
            [itemMp setObject:itemL forKey:[NSNumber numberWithLongLong:itemL.rowno]];
        }
        
    }
}

-(void) addToAlexaList:(AlexaItem *) alexaItem itemKey:(ItemKey *) key dic:(NSMutableDictionary *)alexaDic
{
    NSMutableDictionary *itemMp = [alexaDic objectForKey:key];
    if (itemMp != nil)
    {
        [self updateAlexaItemMp:key alexaItem:alexaItem itemRowDic:itemMp];
    }
    else
    {
        if (alexaItem.add)
        {
            itemMp = [NSMutableDictionary dictionaryWithCapacity:10];
            LocalList *itemL = [[LocalList alloc] init];
            itemL.name = key.name;
            itemL.item = alexaItem.name;
            itemL.hidden = false;
            itemL.rowno = [itemMp count]+1;
            itemL.share_id = key.share_id;
            
            [itemMp setObject:itemL forKey:[NSNumber numberWithLongLong:itemL.rowno]];
            [alexaDic setObject:itemMp forKey:key];
        }
    }
}

-(void) updateAlexaItemMp:(ItemKey *) key alexaItem:(AlexaItem*) alexaItem itemRowDic:(NSMutableDictionary *)itemMp
{
    bool bFound = false;
    bool bRemove = false;
    long long rowno = 0;
    NSNumber *keyItem;
    for(keyItem in itemMp) {
        LocalList* value = [itemMp objectForKey:keyItem];
        if ([value.item isEqualToString:alexaItem.name])
        {
            bFound = true;
            rowno = value.rowno;
            if (!alexaItem.add)
            {
                bRemove = true;
            }
            break;
        }
    }
    if (bFound && bRemove)
    {
        [itemMp removeObjectForKey:[NSNumber numberWithLongLong:rowno]];
    }
    if (!bFound)
    {
        if (alexaItem.add)
        {
            
            LocalList *itemL = [[LocalList alloc] init];
            itemL.name = key.name;
            itemL.item = alexaItem.name;
            itemL.hidden = false;
            itemL.rowno = [itemMp count]+1;
            itemL.share_id = key.share_id;
            [itemMp setObject:itemL forKey:[NSNumber numberWithLongLong:itemL.rowno]];
        }
        
    }
}

-(bool) updateAlexaScrtchList:(ItemKey *) key alexaItem:(AlexaItem*) alexaItem
{
    NSMutableDictionary *itemMp = [alexaEditDic objectForKey:key];
   
    if (itemMp != nil)
    {
        [self updateAlexaMasterListItemMp:key alexaItem:alexaItem itemRowDic:itemMp];
        return true;
    }
    
    return false;
}

-(bool) updateAlexaTemplEditItem : (MasterList *)item itemKey:(ItemKey *) key
{
    NSMutableDictionary *itemMp = [alexaEditDic objectForKey:key];
    if (itemMp != nil)
    {
        LocalMasterList *itemL = [itemMp objectForKey:[NSNumber numberWithLongLong:item.rowno]];
        if (itemL != nil)
        {
            itemL.inventory = item.inventory;
          return  true;
        }
        
        
    }
    return false;
}

-(void) createAlexaTemplEditItems:(NSArray *)mlist itemKey:(ItemKey *) key
{
    if (mlist != nil)
    {
        NSUInteger nRows = [mlist count]+1;
        NSUInteger mlistcnt = [mlist count];
        
       NSMutableDictionary * itemMp = [NSMutableDictionary dictionaryWithCapacity:nRows];
        for (NSUInteger i=0; i < mlistcnt; ++i)
        {
            MasterList *itemML = [mlist objectAtIndex:i];
            LocalMasterList *item = [[LocalMasterList alloc] initFromMasterList:itemML];
            NSNumber *rowNm = [NSNumber numberWithLongLong:item.rowno];
            if (item.rowno > nRows)
                nRows = (NSUInteger) item.rowno;
            [itemMp setObject:item forKey:rowNm];
        }
        [alexaEditDic setObject:itemMp forKey:key];
     
    NSLog(@"itemMp dictionary to set view %@\n", itemMp);
     //   [masterListEditNames addObject:key];
     //   [masterListEditMps addObject:itemMp];
    //    ++templItemsEdited;
    
    }
}


-(NSArray *) getMasterList: (ItemKey *)key
{
    [workToDo lock];
    if (key == nil)
    {
        return nil;
    }
    
    //Two questions 1) how to uniquely identify a name (with share id ) and how to display name
    // ie should share Id be displayed for a name clash
    NSMutableArray* mlistarr =  [masterListArr objectForKey:key];
    //NSLog(@"Master list in data ops %@ for key %@ in dictionary %@\n", mlistarr, key, masterListArr);
    if (mlistarr != nil)
    {
        NSMutableArray *mlist = [[NSMutableArray alloc] init];
        NSUInteger mlistcnt = [mlistarr count];
        for (NSUInteger i=0; i < mlistcnt; ++i)
        {
            MasterList *item = [mlistarr objectAtIndex:i];
            [mlist addObject:item];
        }
        [workToDo unlock];
        return mlist;
    }
    [workToDo unlock];
    return nil;
}

-(void) deletedEasyItem:(ItemKey *)name
{
    [workToDo lock];
    [listDeletedNames addObject:name];
    ++itemsEasyDeleted;
    NSLog(@"Added deleted item %@ %d and signalling work to do\n", name, itemsDeleted);
    [workToDo signal];
    [workToDo unlock];
    
    return;
}


-(void) updateEasyEditedItems
{
    
    NSUInteger ecnt = [listEditNames count];
    for (NSUInteger i=0; i < ecnt; ++i)
    {
        ItemKey *itk = [listEditNames objectAtIndex:i];
        NSMutableArray* listarr =  [listArr objectForKey:itk];
        if (listarr != nil)
        {
            NSUInteger enmcnt = [listarr count];
            for (NSUInteger j=0; j < enmcnt; ++j)
            {
                [self.easyManagedObjectContext deleteObject:[listarr objectAtIndex:j]];
            }
        }
    }
    
    int nStoreCnt=0;
    for (int i=0; i < ecnt; ++i)
    {
        nStoreCnt += [[listEditMps objectAtIndex:i] count];
    }
    
    
    NSUInteger mlnmcnt = [listNamesArr count];
    for (NSUInteger i=0; i < ecnt; ++i)
    {
        ItemKey *itk = [listEditNames objectAtIndex:i];
        
        for (NSUInteger j=0; j < mlnmcnt; ++j)
        {
            ItemKey *itr =[listNamesArr objectAtIndex:j];
            if ([itk.name isEqualToString:itr.name] && itr.share_id == itk.share_id)
            {
                ListNames *lname = [listNamesTmp objectAtIndex:j];
                
                [self.easyManagedObjectContext deleteObject:lname];
            }
        }
        
    }
    
    
    
    NSMutableArray *storeItems = [[NSMutableArray alloc] initWithCapacity:nStoreCnt];
    NSMutableArray *storeNames = [[NSMutableArray alloc] initWithCapacity:ecnt];
    
    
    NSManagedObjectModel *managedObjectModel =
    [[self.easyManagedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    NSLog(@"entity count %lu %s %d", (unsigned long)[[ent allKeys] count], __FILE__, __LINE__);
    NSEntityDescription *entity =
    [ent objectForKey:@"List"];
    
    for (int i=0 ; i < nStoreCnt; ++i)
    {
        List *newItem = [[List alloc]
                         initWithEntity:entity insertIntoManagedObjectContext:self.easyManagedObjectContext];
        [storeItems addObject:newItem];
    }
    NSEntityDescription *nameEntity = [ent objectForKey:@"ListNames"];
    for (int i=0; i<ecnt; ++i)
    {
        ListNames *newName = [[ListNames alloc] initWithEntity:nameEntity insertIntoManagedObjectContext:self.easyManagedObjectContext];
        [storeNames addObject:newName];
    }
    
    
    
    NSUInteger nTotCnt=0;
    for (int i=0; i <ecnt; ++i)
    {
        NSArray *keys = [[listEditMps objectAtIndex:i] allKeys];
        NSMutableDictionary *rowitems = [listEditMps objectAtIndex:i];
        
        ItemKey *itk = [listEditNames objectAtIndex:i];
        NSUInteger valcnt = [keys count];
        NSLog(@"Number of items to store %lu (no of keys)valcnt = %lu in list %@ %s %d", (unsigned long)[rowitems count], (unsigned long)valcnt, itk.name, __FILE__, __LINE__);
        
        for (NSUInteger j=0; j < valcnt; ++j)
        {
            LocalList *itemstr = [rowitems objectForKey:[keys objectAtIndex:j]];
            NSUInteger len = [itemstr.item length];
            if (!len)
            {
                NSLog(@"Zero length for key %@", [keys objectAtIndex:j]);
                continue;
            }
            List *item = [storeItems objectAtIndex:nTotCnt];
            item.name = itk.name;
            item.share_id = itk.share_id;
            item.item = itemstr.item;
            item.rowno = itemstr.rowno;
            item.hidden = itemstr.hidden;
            ++nTotCnt;
            NSLog(@"Storing item at index %@ %lld in list %@ hidden=%d %s %d", item.item, item.rowno, itk.name, item.hidden, __FILE__, __LINE__);
        }
        ListNames *mname = [storeNames objectAtIndex:i];
        mname.name = itk.name;
        mname.share_id = itk.share_id;
        mname.current = YES;
        
        //NSLog(@"Storing master list name %@\n", mname);
        
    }
    
    if (nTotCnt < nStoreCnt)
    {
        for (NSUInteger i= nTotCnt ; i < nStoreCnt; ++i)
        {
            [self.easyManagedObjectContext deleteObject:[storeItems objectAtIndex:i]];
        }
    }
    [self saveEasyContext];
    if (itemsEasyEdited > ecnt)
    {
        NSRange aR;
        aR.location = 0;
        aR.length = ecnt;
        [listEditNames removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
        [listEditMps removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
    }
    else
    {
        [listEditMps removeAllObjects];
        [listEditNames removeAllObjects];
    }
    itemsEasyEdited -= ecnt;
   
    return;
}






-(void) refreshTemplData
{
    
    NSManagedObjectContext *moc = [self easyManagedObjectContext];
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"MasterListNames" inManagedObjectContext:moc];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:descr];
    NSError *error = nil;
    NSSortDescriptor* masterlistNamesDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                              ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObject:masterlistNamesDescriptor];
    masterListNamesTmp = [[moc executeFetchRequest:req error:&error]sortedArrayUsingDescriptors:sortDescriptors];
    
    
    masterListCnt = [masterListNamesTmp count];
    masterListNamesArr = [[NSMutableArray alloc] initWithCapacity:masterListCnt];
    for (NSInteger i=0; i < masterListCnt; ++i)
    {
        MasterListNames *mnameRow = [masterListNamesTmp objectAtIndex:i];
        ItemKey *itk = [[ItemKey alloc] init];
        itk.name = mnameRow.name;
        itk.share_id = mnameRow.share_id;
        
        [masterListNamesArr addObject:itk];
    }
    //NSLog(@"Refreshing templ data count=%ld %@\n", (long)masterListCnt, masterListNamesArr);
    
  
    
    descr = [NSEntityDescription entityForName:@"MasterList" inManagedObjectContext:moc];
    [req setEntity:descr];
    NSSortDescriptor* masterlistDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                         ascending:YES];
    NSSortDescriptor* rownoDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rowno"
                                                                    ascending:YES];
    sortDescriptors = [NSArray arrayWithObjects:masterlistDescriptor, rownoDescriptor, nil];
    masterListTmp = [[moc executeFetchRequest:req error:&error]sortedArrayUsingDescriptors:sortDescriptors];
    NSUInteger mlistcnt = [masterListTmp count];
    
  
    // NSLog(@"No of items in Masterlist %lu", (unsigned long)mlistcnt);
    masterListArr = [NSMutableDictionary dictionaryWithCapacity:mlistcnt];
    for (NSUInteger i=0; i < mlistcnt; ++i)
    {
        MasterList *mitem = [masterListTmp objectAtIndex:i];
        //NSLog(@"Adding item to master list %@\n", mitem);
        ItemKey *itk = [[ItemKey alloc] init];
        itk.name = mitem.name;
        itk.share_id = mitem.share_id;

        NSMutableArray* mlistarr =  [masterListArr objectForKey:itk];
        if (mlistarr != nil)
        {
            [mlistarr addObject:mitem];
        }
        else
        {
            mlistarr = [[NSMutableArray alloc] init];
            [mlistarr addObject:mitem];
            [masterListArr setObject:mlistarr forKey:itk];
            
        }
        
    }
    NSLog(@"Refreshed templ data release second lock and done");
    return;
}


-(void) addTemplName:(ItemKey *)name
{
     [workToDo lock];
    [masterListNamesOnly addObject:name];
    ++templNameItemsToAdd;
    NSLog(@"Added  new template  name item %@ %d and signalling work to do\n", name.name, templNameItemsToAdd);
    [workToDo signal];
    [workToDo unlock];
    return;
}
-(void) addShareTemplItem:(ItemKey *)name itemsDic:(NSMutableDictionary*) itmsMp
{
    [workToDo lock];
    [shareMasterListNames addObject:name];
    [shareMasterListMps addObject:itmsMp];
    ++templShareItemsToAdd;
    NSLog(@"Added  new template item %@ %lld %d and signalling work to do\n", name.name, name.share_id, templShareItemsToAdd);
    [workToDo signal];
    [workToDo unlock];
    return;
}


-(void) addTemplItem:(ItemKey *)name itemsDic:(NSMutableDictionary*) itmsMp
{
    [workToDo lock];
    [masterListNames addObject:name];
    [masterListMps addObject:itmsMp];
    ++templItemsToAdd;
    NSLog(@"Added  new template item %@ %d and signalling work to do\n", name, templItemsToAdd);
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) addItem:(id)item
{
    [workToDo lock];
    [newItems addObject:item];
    ++itemsToAdd;
    NSLog(@"Added  new item  and signalling work to do\n");
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) editedItem:(id)item
{
    [workToDo lock];
    [editedItems addObject:item];
    ++itemsEdited;
    NSLog(@"Added edit item and signalling work to do\n");
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) deletedItem:(id)item
{
    [workToDo lock];
    [deletedItems addObject:item];
    ++itemsDeleted;
    NSLog(@"Added deleted item and signalling work to do\n");
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) updateDeletedItems
{
    
    NSArray *deletedItemsTmp = [NSArray arrayWithArray:deletedItems];
    
    NSUInteger cnt = [itemNamesTmp count];
    NSUInteger ecnt = [deletedItemsTmp count];
    for (NSUInteger j=0; j < ecnt; ++j)
    {
        id litem = [deletedItemsTmp objectAtIndex:j];
        for (NSUInteger i=0; i < cnt; ++i)
        {
            id item = [itemNamesTmp objectAtIndex:i];
            if ([[delegate getAlbumName:item]   isEqualToString:[delegate getAlbumName:litem]])
            {
                [self.managedObjectContext deleteObject:item];
                break;
            }
        }
    }
    
    
    if(itemsDeleted > ecnt)
    {
        NSRange aR;
        aR.location = 0;
        aR.length = ecnt;
        [deletedItems removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
        
    }
    else
    {
        [deletedItems removeAllObjects];
    }
    itemsDeleted -= ecnt;
   
    [self saveContext];
    return;
}


-(void) downloadItemsOnStartUp
{
    [workToDo lock];
    ++itemsToDownloadOnStartUp;
    NSLog(@"There are new items to download at start up \n");
    [workToDo signal];
    [workToDo unlock];
    return;
 
}

-(void) downloadItem:(NSString *)item
{
    [workToDo lock];
    [downloadIds addObject:item];
    ++itemsToDownload;
    NSLog(@"Added new item to download %@ and signalling work to do \n", item);
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) updateEditedItems
{
    
    NSArray *editedItemsTmp = [NSArray arrayWithArray:editedItems];
    
    NSUInteger cnt = [itemNamesTmp count];
    NSUInteger ecnt = [editedItemsTmp count];
    for (NSUInteger j=0; j < ecnt; ++j)
    {
        id litem = [editedItemsTmp objectAtIndex:j];
        for (NSUInteger i=0; i < cnt; ++i)
        {
            id item = [itemNamesTmp objectAtIndex:i];
            if ([delegate updateEditedItem:item local:litem])
                break;
        }
    }
    
    
    if(itemsEdited > ecnt)
    {
        NSRange aR;
        aR.location = 0;
        aR.length = ecnt;
        [editedItems removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
   
    }
    else
    {
        [editedItems removeAllObjects];
    }
    itemsEdited -= ecnt;
    [self saveContext];
    return;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    return;
}

-(void) addPicItem:(ItemKey *)name picItem:(NSString *)picUrl
{
    [workToDo lock];
    [listPicNames addObject:name];
    [listPicUrls addObject:picUrl];
    ++picItemsToAdd;
    NSLog(@"Added  new pic item %@ %@ %d and signalling work to do\n", name, picUrl, picItemsToAdd);
    [workToDo signal];
    [workToDo unlock];
    return;
}


-(void) storeNewItems
{
    int nItems = itemsToAdd;
    NSMutableArray *storeItems = [[NSMutableArray alloc] initWithCapacity:nItems];
    for (int i=0 ; i < nItems; ++i)
    {
        NSManagedObjectModel *managedObjectModel =
        [[self.managedObjectContext persistentStoreCoordinator] managedObjectModel];
        NSDictionary *ent = [managedObjectModel entitiesByName];
        printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
        NSEntityDescription *entity =
        [ent objectForKey:[delegate getEntityName]];
        id newItem = [delegate getNewItem:entity context:self.managedObjectContext];
        
        [storeItems addObject:newItem];
        
    }
    
    for (NSUInteger i=0; i < nItems; ++i)
    {
        [delegate copyFromLocalItem:[storeItems objectAtIndex:i] local:[newItems objectAtIndex:i]];
    }
    if (itemsToAdd > nItems)
    {
        NSRange aR;
        aR.location = 0;
        aR.length = nItems;
        [newItems removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aR]];
    }
    else
    {
        [newItems removeAllObjects];
    }
    itemsToAdd -= nItems;
   
    [self saveContext];
    
    [delegate addToCount];

    return;
}

-(void) refreshData
{
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSEntityDescription *descr = [NSEntityDescription entityForName:[delegate getEntityName] inManagedObjectContext:moc];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:descr];
    NSString *pSearchStr = [delegate getSearchStr];
    if (pSearchStr != nil && [pSearchStr length])
    {
        NSArray *searchComps = [pSearchStr componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSUInteger cnt = [searchComps count];
        NSMutableArray *srchStrs = [NSMutableArray arrayWithCapacity:cnt];
        for (NSUInteger i=0; i < cnt; i++)
        {
            NSString *srchStr = [searchComps objectAtIndex:i];
            if ([srchStr length] == 0)
                continue;
            [srchStrs addObject:srchStr];
        }
        NSString *predStr;
        NSUInteger scnt = [srchStrs count];
        for (NSUInteger i=0; i < scnt; ++i)
        {
            if (i ==0)
                predStr = @"(name contains [cd] %@";
            else
                predStr = [predStr stringByAppendingString:@"name contains [cd] %@"];
            if (i != scnt -1)
                predStr = [predStr stringByAppendingString:@" AND "];
            else
                predStr = [predStr stringByAppendingString:@" )"];
            
        }
        
        predStr = [predStr stringByAppendingString:@" OR "];
        for (NSUInteger i=0; i < scnt; ++i)
        {
            if (i == 0)
                predStr = [predStr stringByAppendingString:@"(street contains [cd] %@"];
            else
                predStr = [predStr stringByAppendingString:@"street contains [cd] %@"];
            
            if (i != scnt -1)
                predStr = [predStr stringByAppendingString:@" AND "];
            else
                predStr = [predStr stringByAppendingString:@" )"];
            
        }
        
        
        
        if ([delegate respondsToSelector:@selector(getAddtionalPredStr:predStrng:)])
        {
            predStr = [delegate getAddtionalPredStr:scnt predStrng:predStr];
        }
            
        int noOfPredicates = 3;
        
        if ([delegate respondsToSelector:@selector(getAdditionalPredArgs)])
        {
            noOfPredicates += [delegate getAdditionalPredArgs];
        }
        predStr = [predStr stringByAppendingString:@" OR "];
        for (NSUInteger i=0; i < scnt; ++i)
        {
            if (i == 0)
                predStr = [predStr stringByAppendingString:@"(notes contains [cd] %@"];
            else
                predStr = [predStr stringByAppendingString:@"notes contains [cd] %@"];
            if (i != scnt -1)
                predStr = [predStr stringByAppendingString:@" AND "];
            else
                predStr = [predStr stringByAppendingString:@" )"];
            
        }
        
        
        unsigned long predArrCnt = scnt*noOfPredicates;
        NSMutableArray *predArr = [NSMutableArray arrayWithCapacity:predArrCnt];
        for (int i=0; i < predArrCnt; ++i)
        {
            [predArr addObjectsFromArray:srchStrs];
        }
        
        NSLog(@"Predicate string %@\n", predStr);
        NSLog (@"Predicate array ");
        NSUInteger pcnt = [predArr count];
        for (NSUInteger i=0 ; i < pcnt; ++i)
        {
            NSLog(@"%@ " , [predArr objectAtIndex:i]);
        }
        //NSLog (@"\n ");
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predStr argumentArray:predArr];
        
        //    NSPredicate *predicate = [NSPredicate
        //      predicateWithFormat:@"(name contains[cd] %@) OR street contains[cd] %@",
        //  [pDlg.pSearchStr stringByAppendingString:@"*"]];
        //     pDlg.pSearchStr, pDlg.pSearchStr];
        [req setPredicate:predicate];
        NSLog(@"Setting predicate %@ \n", predicate);
    }
    
    NSError *error = nil;
    bool ascending;
    NSString *sortstr = [delegate sortDetails:&ascending];
    if ([sortstr isEqualToString:@"date"])
    {
        if (ascending)
            itemNamesTmp = [moc executeFetchRequest:req error:&error];
        else
            itemNamesTmp = [[[moc executeFetchRequest:req error:&error] reverseObjectEnumerator] allObjects];
    }
    else
    {
        NSSortDescriptor* ageDescriptor = [[NSSortDescriptor alloc] initWithKey:sortstr
                                                                      ascending:ascending?YES:NO];
        NSArray* sortDescriptors = [NSArray arrayWithObject:ageDescriptor];
        itemNamesTmp = [[moc executeFetchRequest:req error:&error]sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    NSFetchRequest *req1 = [[NSFetchRequest alloc] init];
    [req1 setEntity:descr];
    unFilteredItemsTmp = [moc executeFetchRequest:req1 error:&error];
    
    if (unFilteredItemsTmp == nil)
    {
        return;
    }
    
    
    [unFilteredItems removeAllObjects];
    NSUInteger noOfItems = [unFilteredItemsTmp count];
    for (NSUInteger i =0; i < noOfItems; ++i)
    {
        id litem = [delegate getLocalItem];
        [delegate copyFromItem:[unFilteredItemsTmp objectAtIndex:i] local:litem];
        [unFilteredItems addObject:litem];
    }
    
    
    if (itemNamesTmp == nil)
    {
        return;
    }
    //Fetch predicate add
    // nRows = [itemNames count];
    
    //seletedItems = [NSMutableArray arrayWithCapacity:nRows];
    NSUInteger nItems = [itemNamesTmp count];
    NSLog(@"Main list counts %lu %lu\n", (unsigned long)nItems, (unsigned long)[itemNamesTmp count]);
    indexesTmp = [[NSMutableArray alloc] initWithCapacity:nItems];
    seletedItemsTmp = [[NSMutableArray alloc] initWithCapacity:nItems];
    for (int i=0 ; i < nItems; ++i)
    {
        //need to revisit this
        bool add = true;
        
        if (add)
        {
            [seletedItemsTmp addObject:[NSNumber numberWithBool:NO]];
            [indexesTmp addObject:[NSNumber numberWithInt:i]];
        }
    }
    // nRows = [indexes count] + 1;
    NSLog(@"UPDATED Main list row count %lu %lu\n", (unsigned long)[itemNamesTmp count], (unsigned long)[indexesTmp count]);
    //Temp created so that there is no need to lock for the entire duration of refreshData
   
    seletedItems = [NSMutableArray arrayWithArray:seletedItemsTmp];
    indexes = [NSArray arrayWithArray:indexesTmp];
    [itemNames removeAllObjects];
    NSUInteger noOfNames = [itemNamesTmp count];
    for (NSUInteger i =0; i < noOfNames; ++i)
    {
        id litem = [delegate getLocalItem];
        [delegate copyFromItem:[itemNamesTmp objectAtIndex:i] local:litem];
        [itemNames addObject:litem];
    }
    
    return;
}

-(bool) isNewItem:(id) item
{
    NSUInteger cnt = [unFilteredItems count];
    for (NSUInteger i=0; i < cnt; ++i)
    {
        if ([delegate isEqualToLclItem:item local:[unFilteredItems objectAtIndex:i ]])
            return false;
    }
    return true;
}

-(NSString *) getAlbumName:(long long ) shareId itemName:(NSString *) iName
{
    [self refreshData];
    NSUInteger cnt = [unFilteredItems count];
    NSString *pAlName;
    for (NSUInteger i=0; i < cnt; ++i)
    {
        pAlName = [delegate getAlbumName:shareId itemName:iName item:[unFilteredItems objectAtIndex:i]];
        if (pAlName != nil)
            return pAlName;
    }
    return nil;
}

-(void) addItem:(ItemKey *)name itemsDic:(NSMutableDictionary*) itmsMp
{
    [workToDo lock];
    [listNames addObject:name];
    [listMps addObject:itmsMp];
    ++easyItemsToAdd;
    NSLog(@"Added  new item %@ %d and signalling work to do\n", name, easyItemsToAdd);
    [workToDo signal];
    [workToDo unlock];
    return;
}


-(NSArray *) getList: (ItemKey *)key
{
        [workToDo lock];
    
            if (easyItemsToAdd || itemsEasyEdited)
            {
                NSLog (@"in getList easyItemsToAdd=%d itemsEasyEdited=%d", easyItemsToAdd, itemsEasyEdited);
                NSDate *checkTime = [NSDate dateWithTimeIntervalSinceNow:1];
                [workToDo waitUntilDate:checkTime];
            }
        
        NSMutableArray* listarr =  [listArr objectForKey:key];
    NSArray *keys = [listArr allKeys];
    for (ItemKey *key in keys)
    {
        NSLog(@"key.name=%@ key.share_id=%d %s %d" , key.name, key.share_id, __FILE__, __LINE__);
    }
     NSLog(@"Master list in data ops %@ for key %@ in dictionary %@\n %s %d", listarr, key, listArr, __FILE__, __LINE__);
        if (listarr != nil)
        {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            NSUInteger listcnt = [listarr count];
            for (NSUInteger i=0; i < listcnt; ++i)
            {
                List *item = [listarr objectAtIndex:i];
                [list addObject:item];
            }
            [workToDo unlock];
            return list;
        }
        [workToDo unlock];
    return nil;
    
}


-(void) getAlexaItems
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    NSArray *vws = [pAppCmnUtil.navViewController viewControllers];
    NSUInteger vwcnt = [vws count];
    for (NSUInteger i=0; i < vwcnt; ++i)
    {
        if ([[vws objectAtIndex:i] isMemberOfClass:[EasyViewController class]])
        {
            EasyViewController *pLst = [vws objectAtIndex:i];
            [pLst getAlexaItems];
            break;
        }
    }
}

-(void) updateEasyMainLstVwCntrl
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSArray *vws = [pAppCmnUtil.navViewController viewControllers];
        NSUInteger vwcnt = [vws count];
        for (NSUInteger i=0; i < vwcnt; ++i)
        {
            if ([[vws objectAtIndex:i] isMemberOfClass:[EasyViewController class]])
            {
                EasyViewController *pLst = [vws objectAtIndex:i];
                [pLst.pAllItms refreshList];
                [pLst.pAllItms.tableView reloadData];
            }
        }
        [pAppCmnUtil.aViewController1.pAllItms refreshList];
        [pAppCmnUtil.aViewController1.pAllItms.tableView reloadData];
    });
    return;
}

-(void) updateShareMainLstVwCntrl:(MainViewController *) pMainVwCntrl
{
    //Invoke this always from main queue
    
    if (pMainVwCntrl == nil)
        return;
      [workToDo lock];
    pMainVwCntrl.pAllItms.itemNames = [NSMutableArray arrayWithArray:itemNames];
    pMainVwCntrl.pAllItms.indexes = [NSMutableArray arrayWithArray:indexes];
    pMainVwCntrl.pAllItms.seletedItems = [NSMutableArray arrayWithArray:seletedItems];
 [workToDo unlock];
    NSLog(@"Refreshing main row itemNames = %lu indexes = %lu seletedItems = %lu bShareView= %d %s %d", (unsigned long)[itemNames count], (unsigned long)[indexes count], (unsigned long)[seletedItems count], pMainVwCntrl.pAllItms.bShareView, __FILE__, __LINE__);
        [pMainVwCntrl.pAllItms.tableView reloadData];
    return;
}

-(void) updateMainLstVwCntrl
{
    
   
    MainViewController *pMainVwCntrl = [delegate getMainViewController];
    if (pMainVwCntrl == nil)
        return;
    
    [workToDo lock];
    pMainVwCntrl.pAllItms.itemNames = [NSMutableArray arrayWithArray:itemNames];
    pMainVwCntrl.pAllItms.indexes = [NSMutableArray arrayWithArray:indexes];
    pMainVwCntrl.pAllItms.seletedItems = [NSMutableArray arrayWithArray:seletedItems];
    [workToDo unlock];
    NSLog(@"Refreshing main row itemNames = %lu indexes = %lu seletedItems = %lu %s %d", (unsigned long)[itemNames count], (unsigned long)[indexes count], (unsigned long)[seletedItems count], __FILE__, __LINE__);
    
   // 
   // [pMainVwCntrl.pAllItms.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
    dispatch_sync(dispatch_get_main_queue(), ^{
         [pMainVwCntrl.pAllItms.tableView reloadData];  
    });
        return;
}

-(void) lock
{
    [workToDo lock];
    return;
}

-(void) unlockAndSignal
{
    NSLog(@"Unlocking and signalling work to do");
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) unlock
{
    
    [workToDo unlock];
    return;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error while saving MOC %@, %@", error, [error userInfo]);
            // abort();
        }
    }
}

#pragma mark - Core Data stack

- (void)saveEasyContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.easyManagedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        NSLog(@"Saved MOC in GrocList iPhone app");
    }
}


- (NSManagedObjectContext *)managedObjectContext {
    
    NSLog(@"getting moc");
    
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    NSLog(@"getting moc1");
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil)
    {
        // Make life easier by adopting the new NSManagedObjectContext concurrency API
        // the NSMainQueueConcurrencyType is good for interacting with views and controllers since
        // they are all bound to the main thread anyway
        NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [moc performBlockAndWait:^{
            // even the post initialization needs to be done within the Block
            [moc setPersistentStoreCoordinator: coordinator];
            
        }];
        __managedObjectContext = moc;
    }
    [__managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:appName withExtension:@"momd"];
    NSLog(@"Setting modelURL to %@", modelURL);
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
    
    
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSLog(@"getting psc");
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    NSLog(@"getting psc1");
    NSError *error = nil;
    NSString *storeUrlPath = [appName stringByAppendingString:@".sqlite"];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:storeUrlPath];
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSLog(@"Setting URL to %@", storeURL);
    
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        
        
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"System error" message:@"Restart the app. If Delete the app and reinstall and  restart." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [pAvw show];
    }
    return __persistentStoreCoordinator;
    
    
}

- (NSManagedObjectContext *)easyManagedObjectContext
{
    if (__easyManagedObjectContext != nil) {
        return __easyManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self easyPersistentStoreCoordinator];
    if (coordinator != nil) {
        __easyManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [__easyManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __easyManagedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)easyManagedObjectModel
{
    if (__easyManagedObjectModel != nil) {
        return __easyManagedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"EasyGrocList" withExtension:@"momd"];
    __easyManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __easyManagedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *) easyPersistentStoreCoordinator
{
    if (__easyPersistentStoreCoordinator != nil) {
        return __easyPersistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"EasyGrocList.sqlite"];
    
    NSError *error = nil;
    __easyPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self easyManagedObjectModel]];
    if (![__easyPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
       
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"System error" message:@"Restart the app. If required Delete the app and data and then reinstall and  restart." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [pAvw show];
        
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        
        
    }
    
    return __easyPersistentStoreCoordinator;
}



#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



@end
