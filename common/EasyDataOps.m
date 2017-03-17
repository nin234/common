//
//  EasyDataOps.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 4/5/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import "EasyDataOps.h"

#import "MasterList.h"



#import "EasyViewController.h"
#import "List1ViewController.h"

#define TIMER_INTERVAL_EasyDataOps 3
#define INAPP_SKIP_COUNT 40

@implementation EasyDataOps



@synthesize refreshMainLst;
@synthesize inAppCancelTimer;

-(void) main
{
    workToDo = [[NSCondition alloc]init];
    //refreshMainLst = false;
    inAppCancelTimer = false;
    
   
    itemsToAdd = 0;
   
    itemsEdited = 0;
    itemsHidden = 0;
    
    
    itemsDeleted = 0;
    inapp_skip_count = 0;
    itemSelectedChanged = false;
    
    
    listMps = [[NSMutableArray alloc] init];
   
    
    listEditNames = [[NSMutableArray alloc] init];
    listEditMps = [[NSMutableArray alloc] init];
    listHiddenMps = [[NSMutableArray alloc] init];
      
    
    
    listDeletedNames = [[NSMutableArray alloc] init];
    
   
    bool bInitialMainScrnRefresh = false;
    
    for(;;)
        
    {
        [workToDo lock];
        if (  !itemsToAdd || !refreshMainLst || !itemsEdited || !itemsDeleted || !itemSelectedChanged || !itemsHidden || !inAppCancelTimer)
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
