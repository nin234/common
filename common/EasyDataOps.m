//
//  EasyDataOps.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 4/5/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import "EasyDataOps.h"
#import "AppDelegate.h"
#import "MasterList.h"
#import "List.h"
#import "MasterListNames.h"
#import "ListNames.h"
#import "EasyViewController.h"
#import "List1ViewController.h"

#define TIMER_INTERVAL_EasyDataOps 3
#define INAPP_SKIP_COUNT 40

@implementation EasyDataOps

@synthesize masterListCnt;
@synthesize listCnt;
@synthesize refreshMainLst;
@synthesize inAppCancelTimer;

-(void) main
{
    workToDo = [[NSCondition alloc]init];
    //refreshMainLst = false;
    inAppCancelTimer = false;
    masterListCnt = 0;
    templItemsToAdd = 0;
    itemsToAdd = 0;
    picItemsToAdd = 0;
    itemsEdited = 0;
    itemsHidden = 0;
    templItemsEdited = 0;
    templItemsDeleted = 0;
    itemsDeleted = 0;
    inapp_skip_count = 0;
    itemSelectedChanged = false;
    masterListNames = [[NSMutableArray alloc] init];
    masterListMps = [[NSMutableArray alloc] init];
    listNames = [[NSMutableArray alloc] init];
    listMps = [[NSMutableArray alloc] init];
    listPicNames = [[NSMutableArray alloc] init];
    listPicUrls = [[NSMutableArray alloc] init];
    listEditNames = [[NSMutableArray alloc] init];
    listEditMps = [[NSMutableArray alloc] init];
    listHiddenMps = [[NSMutableArray alloc] init];
    masterListEditNames = [[NSMutableArray alloc] init];
    masterListEditMps = [[NSMutableArray alloc] init];
    masterListArr = [[NSMutableDictionary alloc] init];
    listArr = [[NSMutableDictionary alloc] init];
    masterListDeletedNames = [[NSMutableArray alloc] init];
    listDeletedNames = [[NSMutableArray alloc] init];
    [self refreshTemplData];
    [self refreshItemData];
    bool bInitialMainScrnRefresh = false;
    
    for(;;)
        
    {
        [workToDo lock];
        if (!templItemsToAdd || !templItemsDeleted || !templItemsEdited || !itemsToAdd || !refreshMainLst || !itemsEdited || !itemsDeleted || !picItemsToAdd || !itemSelectedChanged || !itemsHidden || !inAppCancelTimer)
        {
            // NSLog(@"Waiting for work\n");
            if (bInitialMainScrnRefresh)
            {
                NSDate *checkTime = [NSDate dateWithTimeIntervalSinceNow:TIMER_INTERVAL_EasyDataOps];
                [workToDo waitUntilDate:checkTime];
            }
            else
            {
                NSDate *checkTime = [NSDate dateWithTimeIntervalSinceNow:0.1];
                [workToDo waitUntilDate:checkTime];
            }
            
        }
        [workToDo unlock];
        
        if (templItemsToAdd)
        {
            NSLog(@"Adding %d template items\n", templItemsToAdd);
            [self storeNewTemplItems];
            [self refreshTemplData];
            [self updateMasterLstVwCntrl];
        }
        
        if (inAppCancelTimer)
        {
            [self inAppTimerCheck];
        }
        
        if (refreshMainLst)
        {
            bInitialMainScrnRefresh = true;
            [self refreshItemData];
            [self updateMainLstVwCntrl];
            refreshMainLst = false;
        }
        
        if (itemsToAdd)
        {
           NSLog(@"Adding %d template items\n", itemsToAdd);
            [self storeNewItems];
            [self refreshItemData];
            [self updateMainLstVwCntrl];
            [self updateLstVwCntrl];
        }
        
        if (itemSelectedChanged)
        {
            [self updateSelectedItem];
            [self refreshItemData];
            itemSelectedChanged = false;
        }
        
        if (picItemsToAdd)
        {
            NSLog(@"Adding %d pic items\n", picItemsToAdd);
            [self storeNewPicItems];
            [self refreshItemData];
            [self updateMainLstVwCntrl];
        }
        
        if (itemsEdited)
        {
            NSLog(@"Editing %d items\n", itemsEdited);
            [self updateEditedItems];
            [self refreshItemData];
            [self updateMainLstVwCntrl];
            [self updateLstVwCntrl];
        }
        
        if (itemsHidden)
        {
            
            NSLog(@"Updating  %d hidden items\n", itemsHidden);
            [self updateHiddenItems];
            [self refreshItemData];
 
        }
        
        if (templItemsEdited)
        {
            NSLog(@"Editing %d items\n", templItemsEdited);
            [self updateTemplEditedItems];
            [self refreshTemplData];
           [self updateMasterLstVwCntrl];
        }
        
        if (templItemsDeleted)
        {
            NSLog(@"Deleting %d template items\n", templItemsDeleted);
            [self updateTemplDeletedItems];
            [self refreshTemplData];
           [self updateMasterLstVwCntrl];
        }
        
        if (itemsDeleted)
        {
            NSLog(@"Deleting %d items\n", itemsDeleted);
            [self updateDeletedItems];
            [self refreshItemData];
            [self updateMainLstVwCntrl];
        }

    }
    return;
}

-(void) inAppTimerCheck
{
    if (inapp_skip_count > INAPP_SKIP_COUNT)
    {
        inapp_skip_count = 0;
        inAppCancelTimer = false;
    }
    else
    {
        ++inapp_skip_count;
    }
}

-(void) refreshItemData
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = pDlg.managedObjectContext;
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"ListNames" inManagedObjectContext:moc];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:descr];
    NSError *error = nil;
    listNamesTmp = [moc executeFetchRequest:req error:&error];
    
    [workToDo lock];
    listCnt = [listNamesTmp count];
    listNamesArr = [[NSMutableArray alloc] initWithCapacity:listCnt];
    picDic = [[NSMutableDictionary alloc] init];
    for (NSInteger i=0; i < listCnt; ++i)
    {
        ListNames *mnameRow = [listNamesTmp objectAtIndex:i];
        NSString *mname = mnameRow.name;
        
        [listNamesArr addObject:mname];
        if (mnameRow.picurl != nil)
        {
            [picDic setObject:mnameRow.picurl forKey:mname];
        }
    }
   // NSLog(@"Refreshing list data count=%ld %@ %@\n", (long)listCnt, listNamesArr, picDic);
    [workToDo unlock];
    
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
    [workToDo lock];
    NSLog(@"No of items in List %lu", (unsigned long)listcnt);
    listArr = [NSMutableDictionary dictionaryWithCapacity:listcnt];
    for (NSUInteger i=0; i < listcnt; ++i)
    {
        List *item = [listTmp objectAtIndex:i];
       // NSLog(@"Adding item to master list %@\n", item);
        NSMutableArray* listarr =  [listArr objectForKey:item.name];
        if (listarr != nil)
        {
            [listarr addObject:item];
        }
        else
        {
            listarr = [[NSMutableArray alloc] init];
            [listarr addObject:item];
            [listArr setObject:listarr forKey:item.name];
            
        }
        
    }
    [workToDo unlock];
    
    return;
}

-(void) updateLstVwCntrl
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSArray *vws = [pDlg.navViewController viewControllers];
        NSUInteger vwcnt = [vws count];
        //NSLog(@"No of view controllers EasyDataOps:updateLstVwCntrl %lu", (unsigned long)vwcnt);
        for (NSUInteger i=0; i < vwcnt; ++i)
        {
            if ([[vws objectAtIndex:i] isMemberOfClass:[List1ViewController class]])
            {
                List1ViewController *pLst = [vws objectAtIndex:i];
                [pLst refreshList];
                [pLst.tableView reloadData];
            }
          //  NSLog(@"View controller class EasyDataOps:updateLstVwCntrl %@", NSStringFromClass([[vws objectAtIndex:i] class]));
            

        }
    });
    return;
}

-(void) updateMainLstVwCntrl
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSArray *vws = [pDlg.navViewController viewControllers];
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
        [pDlg.aViewController1.pAllItms refreshList];
        [pDlg.aViewController1.pAllItms.tableView reloadData];
    });
    return;
}

-(void) storeNewPicItems
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    int nItems = picItemsToAdd;
    NSMutableArray *storeNames = [[NSMutableArray alloc] initWithCapacity:nItems];
    
    NSManagedObjectModel *managedObjectModel =
    [[pDlg.managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
    NSEntityDescription *nameEntity = [ent objectForKey:@"ListNames"];
    for (int i=0; i<nItems; ++i)
    {
            ListNames *newName = [[ListNames alloc] initWithEntity:nameEntity insertIntoManagedObjectContext:pDlg.managedObjectContext];
            [storeNames addObject:newName];
    }
    
    
    [workToDo lock];
    for (int i=0; i <nItems; ++i)
    {
        NSString *name = [listPicNames objectAtIndex:i];
        NSString *url =  [listPicUrls objectAtIndex:i];
        ListNames *mname = [storeNames objectAtIndex:i];
        mname.name = name;
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
    [workToDo unlock];
    [pDlg saveContext];
    
    return;
}

-(void) storeNewItems
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    int nItems = itemsToAdd;
    int nStoreCnt=0;
    [workToDo lock];
    for (int i=0; i < nItems; ++i)
    {
        nStoreCnt += [[listMps objectAtIndex:i] count];
    }
    [workToDo unlock];
    
    NSMutableArray *storeItems = [[NSMutableArray alloc] initWithCapacity:nStoreCnt];
    NSMutableArray *storeNames = [[NSMutableArray alloc] initWithCapacity:nItems];
    
    NSManagedObjectModel *managedObjectModel =
    [[pDlg.managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
    NSEntityDescription *entity =
    [ent objectForKey:@"List"];
    
    for (int i=0 ; i < nStoreCnt; ++i)
    {
        List *newItem = [[List alloc]
                              initWithEntity:entity insertIntoManagedObjectContext:pDlg.managedObjectContext];
        //List *newItem = [[List alloc] init];
        
        [storeItems addObject:newItem];
    }
    NSEntityDescription *nameEntity = [ent objectForKey:@"ListNames"];
    if(nStoreCnt)
    {
        for (int i=0; i<nItems; ++i)
        {
            ListNames *newName = [[ListNames alloc] initWithEntity:nameEntity insertIntoManagedObjectContext:pDlg.managedObjectContext];
            [storeNames addObject:newName];
        }
    }
    
    [workToDo lock];
    NSUInteger nTotCnt=0;
    if (nStoreCnt)
    {
        for (int i=0; i <nItems; ++i)
        {
            NSArray *keys = [[listMps objectAtIndex:i] allKeys];
            NSMutableDictionary *rowitems = [listMps objectAtIndex:i];
            NSString *name = [listNames objectAtIndex:i];
            NSUInteger valcnt = [keys count];
            for (NSUInteger j=0; j < valcnt; ++j)
            {
                NSString *itemstr = [rowitems objectForKey:[keys objectAtIndex:j]];
                NSUInteger len = [itemstr length];
                if (!len)
                {
                    continue;
                }
                List *item = [storeItems objectAtIndex:nTotCnt];
                
                
                
                item.item = itemstr;
                item.name = name;
                item.hidden = NO;
                item.rowno = [[keys objectAtIndex:j] intValue];
                ++nTotCnt;
                //NSLog(@"Storing item at index %@ %lu\n", item, (unsigned long)nTotCnt);
            }
            ListNames *mname = [storeNames objectAtIndex:i];
            mname.name = name;
            //NSLog(@"Storing  list name %@\n", mname);
            
        }
    }
    if (itemsToAdd > nItems)
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
    itemsToAdd -= nItems;
    [workToDo unlock];
    [pDlg saveContext];

    return;
}

-(void) storeNewTemplItems
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    int nItems = templItemsToAdd;
    int nStoreCnt=0;
    [workToDo lock];
    for (int i=0; i < nItems; ++i)
    {
        nStoreCnt += [[masterListMps objectAtIndex:i] count];
    }
    [workToDo unlock];
    
    NSMutableArray *storeItems = [[NSMutableArray alloc] initWithCapacity:nStoreCnt];
    NSMutableArray *storeNames = [[NSMutableArray alloc] initWithCapacity:nItems];
    
        NSManagedObjectModel *managedObjectModel =
        [[pDlg.managedObjectContext persistentStoreCoordinator] managedObjectModel];
        NSDictionary *ent = [managedObjectModel entitiesByName];
        printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
        NSEntityDescription *entity =
        [ent objectForKey:@"MasterList"];
        
    for (int i=0 ; i < nStoreCnt; ++i)
    {
        MasterList *newItem = [[MasterList alloc]
                         initWithEntity:entity insertIntoManagedObjectContext:pDlg.managedObjectContext];
        [storeItems addObject:newItem];
    }
    NSEntityDescription *nameEntity = [ent objectForKey:@"MasterListNames"];
    if(nStoreCnt)
    {
        for (int i=0; i<nItems; ++i)
        {
            MasterListNames *newName = [[MasterListNames alloc] initWithEntity:nameEntity insertIntoManagedObjectContext:pDlg.managedObjectContext];
            [storeNames addObject:newName];
        }
    }
    
    [workToDo lock];
    NSUInteger nTotCnt=0;
    if (nStoreCnt)
    {
        for (int i=0; i <nItems; ++i)
        {
            NSArray *keys = [[masterListMps objectAtIndex:i] allKeys];   
            NSMutableDictionary *rowitems = [masterListMps objectAtIndex:i];
            NSString *name = [masterListNames objectAtIndex:i];
            NSUInteger valcnt = [keys count];
            for (NSUInteger j=0; j < valcnt; ++j)
            {
                NSString *itemstr = [rowitems objectForKey:[keys objectAtIndex:j]];
                NSUInteger len = [itemstr length];
                if (!len)
                {
                    continue;
                }
                MasterList *item = [storeItems objectAtIndex:nTotCnt];
                item.name = name;
                item.item = itemstr;
                item.rowno = [[keys objectAtIndex:j] intValue];
                ++nTotCnt;
              //  NSLog(@"Storing item at index %@ %lu\n", item, (unsigned long)nTotCnt);
            }
            MasterListNames *mname = [storeNames objectAtIndex:i];
            mname.name = name;
           // NSLog(@"Storing master list name %@\n", mname);
        
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
    [workToDo unlock];
    [pDlg saveContext];
    return;
}

-(NSArray *) getList: (NSString *)key
{
    [workToDo lock];
    NSMutableArray* listarr =  [listArr objectForKey:key];
   // NSLog(@"Master list in data ops %@ for key %@ in dictionary %@\n", listarr, key, listArr);
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

-(NSArray *) getMasterList: (NSString *)key
{
    [workToDo lock];
    NSMutableArray* mlistarr =  [masterListArr objectForKey:key];
    //NSLog(@"Master list in data ops %@ for key %@ in dictionary %@\n", mlistarr, key, masterListArr);
    if (mlistarr != nil)
    {
        NSMutableArray *mlist = [[NSMutableArray alloc] init];
        NSUInteger mlistcnt = [mlistarr count];
        for (NSUInteger i=0; i < mlistcnt; ++i)
        {
            MasterList *item = [mlistarr objectAtIndex:i];
            [mlist addObject:item.item];
        }
        [workToDo unlock];
        return mlist;
    }
    [workToDo unlock];
    return nil;
}

-(void) refreshTemplData
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = pDlg.managedObjectContext;
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"MasterListNames" inManagedObjectContext:moc];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:descr];
    NSError *error = nil;
    NSSortDescriptor* masterlistNamesDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                              ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObject:masterlistNamesDescriptor];
    masterListNamesTmp = [[moc executeFetchRequest:req error:&error]sortedArrayUsingDescriptors:sortDescriptors];
    
    [workToDo lock];
    masterListCnt = [masterListNamesTmp count];
    masterListNamesArr = [[NSMutableArray alloc] initWithCapacity:masterListCnt];
    for (NSInteger i=0; i < masterListCnt; ++i)
    {
        MasterListNames *mnameRow = [masterListNamesTmp objectAtIndex:i];
        NSString *mname = mnameRow.name;
        
        [masterListNamesArr addObject:mname];
    }
    //NSLog(@"Refreshing templ data count=%ld %@\n", (long)masterListCnt, masterListNamesArr);
    [workToDo unlock];
    
    descr = [NSEntityDescription entityForName:@"MasterList" inManagedObjectContext:moc];
    [req setEntity:descr];
    NSSortDescriptor* masterlistDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                         ascending:YES];
    NSSortDescriptor* rownoDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rowno"
                                                                         ascending:YES];
    sortDescriptors = [NSArray arrayWithObjects:masterlistDescriptor, rownoDescriptor, nil];
    masterListTmp = [[moc executeFetchRequest:req error:&error]sortedArrayUsingDescriptors:sortDescriptors];
    NSUInteger mlistcnt = [masterListTmp count];
    [workToDo lock];
   // NSLog(@"No of items in Masterlist %lu", (unsigned long)mlistcnt);
    masterListArr = [NSMutableDictionary dictionaryWithCapacity:mlistcnt];
    for (NSUInteger i=0; i < mlistcnt; ++i)
    {
        MasterList *mitem = [masterListTmp objectAtIndex:i];
        //NSLog(@"Adding item to master list %@\n", mitem);
        NSMutableArray* mlistarr =  [masterListArr objectForKey:mitem.name];
        if (mlistarr != nil)
        {
            [mlistarr addObject:mitem];
        }
        else
        {
            mlistarr = [[NSMutableArray alloc] init];
            [mlistarr addObject:mitem];
            [masterListArr setObject:mlistarr forKey:mitem.name];
            
        }
            
    }
    [workToDo unlock];
    
    return;
}

-(void) updateMasterLstVwCntrl
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSArray *vws = [pDlg.navViewController viewControllers];
        NSUInteger vwcnt = [vws count];
        //NSLog(@"No of view controllers EasyDataOps:updateMasterLstVwCntrl %lu", (unsigned long)vwcnt);
        for (NSUInteger i=0; i < vwcnt; ++i)
        {
            if ([[vws objectAtIndex:i] isMemberOfClass:[ListViewController class]])
            {
                ListViewController *pLst = [vws objectAtIndex:i];
               // NSLog(@"Refreshing ListViewController at index %lu", (unsigned long)i);
                [pLst refreshMasterList];
                [pLst.tableView reloadData];
            }
            else if ([[vws objectAtIndex:i] isMemberOfClass:[TemplListViewController class]])
            {
                TemplListViewController *pLst = [vws objectAtIndex:i];
               // NSLog(@"Refreshing TemplListViewController at index %lu", (unsigned long)i);
                [pLst refreshMasterList];
                [pLst.tableView reloadData];
            }
            else
            {
               // NSLog(@"View controller class EasyDataOps:updateMasterLstVwCntrl %@", NSStringFromClass([[vws objectAtIndex:i] class]));
            }
        }
    });
    return;
}

-(void) editedTemplItem:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp

{
    [workToDo lock];
    [masterListEditNames addObject:name];
    [masterListEditMps addObject:itmsMp];
    ++templItemsEdited;
    NSLog(@"Added edit item %@ %d and signalling work to do\n", name, templItemsEdited);
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) deletedTemplItem:(NSString *)name
{
    [workToDo lock];
    [masterListDeletedNames addObject:name];
    ++templItemsDeleted;
    NSLog(@"Added deleted item %@ %d and signalling work to do\n", name, templItemsDeleted);
    [workToDo signal];
    [workToDo unlock];

    return;
}

-(void) deletedItem:(NSString *)name
{
    [workToDo lock];
    [listDeletedNames addObject:name];
    ++itemsDeleted;
    NSLog(@"Added deleted item %@ %d and signalling work to do\n", name, itemsDeleted);
    [workToDo signal];
    [workToDo unlock];
    
    return;
}

-(void) updateDeletedItems
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [workToDo lock];
    NSUInteger mecnt = [listDeletedNames count];
    for (NSUInteger i=0; i < mecnt; ++i)
    {
        NSString *name = [listDeletedNames objectAtIndex:i];
        NSMutableArray* listarr =  [listArr objectForKey:name];
        if (listarr != nil)
        {
            NSUInteger enmcnt = [listarr count];
            for (NSUInteger j=0; j < enmcnt; ++j)
            {
                [pDlg.managedObjectContext deleteObject:[listarr objectAtIndex:j]];
            }
        }
    }
    
    NSUInteger mlnmcnt = [listNamesArr count];
    for (NSUInteger i=0; i < mecnt; ++i)
    {
        NSString *name = [listDeletedNames objectAtIndex:i];
        for (NSUInteger j=0; j < mlnmcnt; ++j)
        {
            if ([name isEqualToString:[listNamesArr objectAtIndex:j]])
            {
                [pDlg.managedObjectContext deleteObject:[listNamesTmp objectAtIndex:j]];
            }
        }
    }
    
    [listDeletedNames removeAllObjects];
    
    itemsDeleted -= mecnt;
    [workToDo unlock];
    
    [pDlg saveContext];
    return;
}


-(void) updateTemplDeletedItems
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [workToDo lock];
    NSUInteger mecnt = [masterListDeletedNames count];
    for (NSUInteger i=0; i < mecnt; ++i)
    {
        NSString *name = [masterListDeletedNames objectAtIndex:i];
        NSMutableArray* mlistarr =  [masterListArr objectForKey:name];
        if (mlistarr != nil)
        {
            NSUInteger enmcnt = [mlistarr count];
            for (NSUInteger j=0; j < enmcnt; ++j)
            {
                [pDlg.managedObjectContext deleteObject:[mlistarr objectAtIndex:j]];
            }
        }
    }
    
    NSUInteger mlnmcnt = [masterListNamesArr count];
    for (NSUInteger i=0; i < mecnt; ++i)
    {
        NSString *name = [masterListDeletedNames objectAtIndex:i];
        for (NSUInteger j=0; j < mlnmcnt; ++j)
        {
            if ([name isEqualToString:[masterListNamesArr objectAtIndex:j]])
            {
                [pDlg.managedObjectContext deleteObject:[masterListNamesTmp objectAtIndex:j]];
            }
        }
    }

    [masterListDeletedNames removeAllObjects];
 
    templItemsDeleted -= mecnt;
    [workToDo unlock];
    
    [pDlg saveContext];
    return;
}

-(void) updateSelectedItem
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *selectedItm;
    [workToDo lock];
    selectedItm = selectedItem;
    [workToDo unlock];
    
    NSUInteger mlnmcnt = [listNamesArr count];
    for (NSUInteger j=0; j < mlnmcnt; ++j)
    {
        ListNames *mname = [listNamesTmp objectAtIndex:j];
       // NSLog(@"Before updating current item %@", mname);
        if ([mname.name isEqualToString:selectedItm])
            mname.current = YES;
        else
            mname.current = NO;
        //NSLog(@"After updating current item %@", mname);
    }
    
    [pDlg saveContext];
    
    return;
}

-(void) updateHiddenItems
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [workToDo lock];
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
                [pDlg.managedObjectContext deleteObject:[listarr objectAtIndex:j]];
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
                [pDlg.managedObjectContext deleteObject:[listNamesTmp objectAtIndex:j]];
            }
        }
    }
    [workToDo unlock];
    
    
    NSMutableArray *storeItems = [[NSMutableArray alloc] initWithCapacity:nStoreCnt];
    NSMutableArray *storeNames = [[NSMutableArray alloc] initWithCapacity:ecnt];
    
    NSManagedObjectModel *managedObjectModel =
    [[pDlg.managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
    NSEntityDescription *entity =
    [ent objectForKey:@"List"];
    
    for (int i=0 ; i < nStoreCnt; ++i)
    {
        List *newItem = [[List alloc]
                         initWithEntity:entity insertIntoManagedObjectContext:pDlg.managedObjectContext];
        [storeItems addObject:newItem];
    }
    NSEntityDescription *nameEntity = [ent objectForKey:@"ListNames"];
    for (int i=0; i<ecnt; ++i)
    {
        ListNames *newName = [[ListNames alloc] initWithEntity:nameEntity insertIntoManagedObjectContext:pDlg.managedObjectContext];
        [storeNames addObject:newName];
    }
    
    
    [workToDo lock];
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
            NSString *itemstr = [rowitems objectForKey:[keys objectAtIndex:j]];
            NSUInteger len = [itemstr length];
            if (!len)
            {
                continue;
            }
            List *item = [storeItems objectAtIndex:nTotCnt];
            item.name = name;
            item.item = itemstr;
            item.rowno = [[keys objectAtIndex:j] intValue];
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
            [pDlg.managedObjectContext deleteObject:[storeItems objectAtIndex:i]];
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
    [workToDo unlock];
    
    [pDlg saveContext];
    
    return;
}


-(void) updateEditedItems
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [workToDo lock];
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
                [pDlg.managedObjectContext deleteObject:[listarr objectAtIndex:j]];
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
                [pDlg.managedObjectContext deleteObject:[listNamesTmp objectAtIndex:j]];
            }
        }
    }
    [workToDo unlock];
    
    
    NSMutableArray *storeItems = [[NSMutableArray alloc] initWithCapacity:nStoreCnt];
    NSMutableArray *storeNames = [[NSMutableArray alloc] initWithCapacity:ecnt];
    
    NSManagedObjectModel *managedObjectModel =
    [[pDlg.managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
    NSEntityDescription *entity =
    [ent objectForKey:@"List"];
    
    for (int i=0 ; i < nStoreCnt; ++i)
    {
        List *newItem = [[List alloc]
                               initWithEntity:entity insertIntoManagedObjectContext:pDlg.managedObjectContext];
        [storeItems addObject:newItem];
    }
    NSEntityDescription *nameEntity = [ent objectForKey:@"ListNames"];
    for (int i=0; i<ecnt; ++i)
    {
        ListNames *newName = [[ListNames alloc] initWithEntity:nameEntity insertIntoManagedObjectContext:pDlg.managedObjectContext];
        [storeNames addObject:newName];
    }
    
    
    [workToDo lock];
    NSUInteger nTotCnt=0;
    for (int i=0; i <ecnt; ++i)
    {
        NSArray *keys = [[listEditMps objectAtIndex:i] allKeys];
        NSMutableDictionary *rowitems = [listEditMps objectAtIndex:i];
        NSString *name = [listEditNames objectAtIndex:i];
        NSUInteger valcnt = [keys count];
        for (NSUInteger j=0; j < valcnt; ++j)
        {
            NSString *itemstr = [rowitems objectForKey:[keys objectAtIndex:j]];
            NSUInteger len = [itemstr length];
            if (!len)
            {
                continue;
            }
            List *item = [storeItems objectAtIndex:nTotCnt];
            item.name = name;
            item.item = itemstr;
            item.rowno = [[keys objectAtIndex:j] intValue];
            item.hidden = NO;
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
            [pDlg.managedObjectContext deleteObject:[storeItems objectAtIndex:i]];
        }
    }
    
    if (itemsEdited > ecnt)
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
    itemsEdited -= ecnt;
    [workToDo unlock];
    
    [pDlg saveContext];

    return;
}

-(void) updateTemplEditedItems
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [workToDo lock];
    NSUInteger mecnt = [masterListEditNames count];
    for (NSUInteger i=0; i < mecnt; ++i)
    {
        NSString *name = [masterListEditNames objectAtIndex:i];
        NSMutableArray* mlistarr =  [masterListArr objectForKey:name];
        if (mlistarr != nil)
        {
            NSUInteger enmcnt = [mlistarr count];
            for (NSUInteger j=0; j < enmcnt; ++j)
            {
                [pDlg.managedObjectContext deleteObject:[mlistarr objectAtIndex:j]];
            }
        }
    }

    int nStoreCnt=0;
    for (int i=0; i < mecnt; ++i)
    {
        nStoreCnt += [[masterListEditMps objectAtIndex:i] count];
    }
   
    
    
    NSUInteger mlnmcnt = [masterListNamesArr count];
    for (NSUInteger i=0; i < mecnt; ++i)
    {
        NSString *name = [masterListEditNames objectAtIndex:i];
        for (NSUInteger j=0; j < mlnmcnt; ++j)
        {
            if ([name isEqualToString:[masterListNamesArr objectAtIndex:j]])
            {
                [pDlg.managedObjectContext deleteObject:[masterListNamesTmp objectAtIndex:j]];
            }
        }
    }
    [workToDo unlock];
    
    
    NSMutableArray *storeItems = [[NSMutableArray alloc] initWithCapacity:nStoreCnt];
    NSMutableArray *storeNames = [[NSMutableArray alloc] initWithCapacity:mecnt];
    
    NSManagedObjectModel *managedObjectModel =
    [[pDlg.managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
    NSEntityDescription *entity =
    [ent objectForKey:@"MasterList"];
    
    for (int i=0 ; i < nStoreCnt; ++i)
    {
        MasterList *newItem = [[MasterList alloc]
                               initWithEntity:entity insertIntoManagedObjectContext:pDlg.managedObjectContext];
        [storeItems addObject:newItem];
    }
    NSEntityDescription *nameEntity = [ent objectForKey:@"MasterListNames"];
    for (int i=0; i<mecnt; ++i)
    {
        MasterListNames *newName = [[MasterListNames alloc] initWithEntity:nameEntity insertIntoManagedObjectContext:pDlg.managedObjectContext];
        [storeNames addObject:newName];
    }
    
    
    [workToDo lock];
    NSUInteger nTotCnt=0;
    for (int i=0; i <mecnt; ++i)
    {
        NSArray *keys = [[masterListEditMps objectAtIndex:i] allKeys];
        /*
        NSArray *keys = [keystmp sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            NSUInteger num1 = [obj1 intValue];
            NSUInteger num2 = [obj2 intValue];
            if(num1<num2) return NSOrderedAscending;
            if(num1>num2) return NSOrderedDescending;
            
            return NSOrderedSame;
        }];
         */
        NSMutableDictionary *rowitems = [masterListEditMps objectAtIndex:i];
        NSString *name = [masterListEditNames objectAtIndex:i];
        NSUInteger valcnt = [keys count];
        for (NSUInteger j=0; j < valcnt; ++j)
        {
            NSString *itemstr = [rowitems objectForKey:[keys objectAtIndex:j]];
            NSUInteger len = [itemstr length];
            if (!len)
            {
                continue;
            }
            MasterList *item = [storeItems objectAtIndex:nTotCnt];
            item.name = name;
            item.item = itemstr;
            item.rowno = [[keys objectAtIndex:j] intValue];
            ++nTotCnt;
           // NSLog(@"Storing item at index %@ %lu\n", item, (unsigned long)nTotCnt);
        }
        MasterListNames *mname = [storeNames objectAtIndex:i];
        mname.name = name;
       // NSLog(@"Storing master list name %@\n", mname);
        
    }
    
    if (nTotCnt < nStoreCnt)
    {
        for (NSUInteger i= nTotCnt ; i < nStoreCnt; ++i)
        {
            [pDlg.managedObjectContext deleteObject:[storeItems objectAtIndex:i]];
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
    [workToDo unlock];
    
    [pDlg saveContext];
    return;
}

-(void) addItem:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp
{
    [workToDo lock];
    [listNames addObject:name];
    [listMps addObject:itmsMp];
    ++itemsToAdd;
    NSLog(@"Added  new item %@ %d and signalling work to do\n", name, itemsToAdd);
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) addPicItem:(NSString *)name picItem:(NSString *)picUrl
{
    [workToDo lock];
    [listPicNames addObject:name];
    [listPicUrls addObject:picUrl];
    ++picItemsToAdd;
    NSLog(@"Added  new pic item %@ %@ %d and signalling work to do\n", name, picUrl, itemsToAdd);
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) selectedItem: (NSString *) selectedItm
{
    [workToDo lock];
    itemSelectedChanged = true;
    selectedItem = selectedItm;
    [workToDo unlock];
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

-(void) editItem:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp
{
    [workToDo lock];
    [listEditNames addObject:name];
    [listEditMps addObject:itmsMp];
    ++itemsEdited;
    NSLog(@"Added  new item %@ %d and signalling work to do\n", name, itemsEdited);
    [workToDo signal];
    [workToDo unlock];
    return;
}


-(void) addTemplItem:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp
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

-(void) refreshData
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = pDlg.managedObjectContext;
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"MasterListNames" inManagedObjectContext:moc];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:descr];
     NSError *error = nil;
    NSSortDescriptor* masterlistNamesDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                  ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObject:masterlistNamesDescriptor];
    masterListNamesTmp = [[moc executeFetchRequest:req error:&error]sortedArrayUsingDescriptors:sortDescriptors];
   
    [workToDo lock];
     masterListCnt = [masterListNamesTmp count];
    masterListNamesArr = [[NSMutableArray alloc] initWithCapacity:masterListCnt];
    for (NSInteger i=0; i < masterListCnt; ++i)
    {
        MasterListNames *mnameRow = [masterListNamesTmp objectAtIndex:i];
        NSString *mname = mnameRow.name;
        
        [masterListNamesArr addObject:mname];
    }
    [workToDo unlock];
    
    descr = [NSEntityDescription entityForName:@"MasterList" inManagedObjectContext:moc];
    [req setEntity:descr];    
    NSSortDescriptor* masterlistDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                              ascending:YES];
    NSSortDescriptor* rownoDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rowno"
                                                                    ascending:YES];
    sortDescriptors = [NSArray arrayWithObjects:masterlistDescriptor, rownoDescriptor, nil];
   masterListTmp = [[moc executeFetchRequest:req error:&error]sortedArrayUsingDescriptors:sortDescriptors];
   // NSLog(@"No of items in Masterlist %lu", (unsigned long)[masterListTmp count]);
    NSUInteger mlistcnt = [masterListTmp count];
    [workToDo lock];
    masterListArr = [NSMutableDictionary dictionaryWithCapacity:mlistcnt];
    for (NSUInteger i=0; i < mlistcnt; ++i)
    {
        MasterList *mitem = [masterListTmp objectAtIndex:i];
      //  NSLog(@"Adding item to master list %@\n", mitem);
        NSMutableArray* mlistarr =  [masterListArr objectForKey:mitem.name];
        if (mlistarr != nil)
        {
            [mlistarr addObject:mitem];
        }
        else
        {
            mlistarr = [[NSMutableArray alloc] init];
            [mlistarr addObject:mitem];
            [masterListArr setObject:mlistarr forKey:mitem.name];
            
        }
        
    }
   // NSLog(@"Master list items %@\n", masterListArr);
    [workToDo unlock];
    
    return;
}

-(NSArray *) getMasterListNames
{
    return masterListNamesArr;
}

-(NSArray *) getListNames
{
    [workToDo lock];
    NSArray *tmpArr = [NSArray arrayWithArray:listNamesArr];
    [workToDo unlock];
    return tmpArr;
}

-(NSDictionary *) getPics
{
    [workToDo lock];
        NSDictionary *pics = [NSDictionary dictionaryWithDictionary:picDic];
    [workToDo unlock];
    return pics;
}

-(void) lock
{
    [workToDo lock];
    return;
}

-(void) unlock
{
    [workToDo unlock];
    return;
}


@end
