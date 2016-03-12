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


@implementation DataOps
@synthesize dontRefresh;
@synthesize refreshNow;
@synthesize updateNow;
@synthesize updateNowSetDontRefresh;
@synthesize loginNow;
@synthesize shareQ;
@synthesize delegate;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

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

-(void) setDontRefresh:(bool)dontRef
{
    [workToDo lock];
    dontRefresh = dontRef;
    if (dontRefresh == false)
        [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) setUpdateNow:(bool)upNow
{
    [workToDo lock];
    updateNow = upNow;
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) setUpdateNowSetDontRefresh:(bool)upNow
{
    [workToDo lock];
    updateNowSetDontRefresh = upNow;
    [workToDo signal];
    [workToDo unlock];
    return;
}

-(void) main
{
    newItems = [[NSMutableArray alloc] init];
    workToDo = [[NSCondition alloc]init];
    dontRefresh = false;
    refreshNow = false;
    itemsToAdd = 0;
    itemsEdited = 0;
    itemsToShare = 0;
    itemsToDownload = 0;
    itemsToDownloadOnStartUp = 0;
    forceRefresh = false;
    itemsDeleted = 0;
    editedItems = [[NSMutableArray alloc] init];
    deletedItems = [[NSMutableArray alloc] init];
    itemNamesTmp = [[NSMutableArray alloc] init];
    itemNames = [[NSMutableArray alloc] init];
    sharedItems = [[NSMutableArray alloc]init];
    downloadIds = [[NSMutableArray alloc] init];
    updateNow = false;
    updateNowSetDontRefresh = false;
    bInitRefresh = true;
    bInUpload = false;
    bRedColor = false;
    waitTime = 3;
    bAnimateNow = false;
    bAnimateOnDwld = false;
    bAnimateOnStrtUp = false;
    bInStartUpDownload =false;
    bShowSelfHelp = true;
    upldBkTaskId = UIBackgroundTaskInvalid;
    dwldBkTaskId = UIBackgroundTaskInvalid;
    dwldStrtUpTaskId = UIBackgroundTaskInvalid;
    loginTaskId = UIBackgroundTaskInvalid;
    
    shareQ = dispatch_queue_create("P2P_SHAREQ", DISPATCH_QUEUE_SERIAL);
    [self refreshData];
    [self updateMainLstVwCntrl];
    for(;;)
    {
        [workToDo lock];
        if (!itemsToAdd || !itemsEdited ||!itemsDeleted || !refreshNow || dontRefresh || !updateNowSetDontRefresh || !updateNow || !loginNow)
        {
           // NSLog(@"Waiting for work\n");
            NSDate *checkTime = [NSDate dateWithTimeIntervalSinceNow:waitTime];
            [workToDo waitUntilDate:checkTime];
        }
        [workToDo unlock];
        
        
        if (dontRefresh)
        {
          //  NSLog(@"Dont refresh set to true continuing\n");
            continue;
        }
        
        
        if (itemsToAdd)
        {
            NSLog(@"Adding %d items\n", itemsToAdd);
            [self storeNewItems];
            [self refreshData];
            [self updateMainLstVwCntrl];

        }
        
        if (itemsEdited)
        {
            NSLog(@"Editing %d items\n", itemsEdited);
            [self updateEditedItems];
            [self refreshData];
            [self updateMainLstVwCntrl];
            
        }
        
        
        
        if(itemsDeleted)
        {
            NSLog(@"Deleted %d items\n", itemsDeleted);
            [self updateDeletedItems];
            [self refreshData];
            [self updateMainLstVwCntrl];

        }
        
        if (forceRefresh)
        {
            NSDate *now = [NSDate date];
            if ([now compare:refreshTime] == NSOrderedDescending)
            {
                forceRefresh = false;
                [self refreshData];
                NSLog(@"FORCE Refreshing main screen contents in DataOps.m\n");
                [self updateMainLstVwCntrl];
            }
        }
        
        if(refreshNow)
        {
            
              refreshNow = false;
          //  forceRefresh = true;
           //  refreshTime = [NSDate dateWithTimeIntervalSinceNow:10];
             [self refreshData];
             NSLog(@"Refreshing main screen contents in DataOps.m\n");
             [self updateMainLstVwCntrl];
        }
        
        if (updateNow)
        {
            updateNow = false;
            NSLog(@"Updating main screen contents in DataOps.m\n");
            [self updateMainLstVwCntrl];
        }
        if (updateNowSetDontRefresh)
        {
            updateNowSetDontRefresh = false;
            [self updateMainLstVwCntrl];
            dontRefresh = true;
            NSLog(@"Updating main screen contents and setting dontRefresh to true in DataOps.m\n");
            
        }
        
    }
    
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
    [workToDo lock];
    NSArray *deletedItemsTmp = [NSArray arrayWithArray:deletedItems];
    [workToDo unlock];
    
    NSUInteger cnt = [itemNamesTmp count];
    NSUInteger ecnt = [deletedItemsTmp count];
    for (NSUInteger j=0; j < ecnt; ++j)
    {
        id litem = [deletedItemsTmp objectAtIndex:j];
        for (NSUInteger i=0; i < cnt; ++i)
        {
            id item = [itemNamesTmp objectAtIndex:i];
            if ([[delegate getAlbumName:item]           isEqualToString:[delegate getAlbumName:litem]])
            {
                [self.managedObjectContext deleteObject:item];
                break;
            }
        }
    }
    
    [workToDo lock];
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
    [workToDo unlock];
    
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
    [workToDo lock];
    NSArray *editedItemsTmp = [NSArray arrayWithArray:editedItems];
    [workToDo unlock];
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
    
    [workToDo lock];
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
    [workToDo unlock];
   
    [self saveContext];
    return;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
        [ent objectForKey:@"Item"];
        id newItem = [delegate getNewItem:entity context:self.managedObjectContext];
        
        [storeItems addObject:newItem];
        
    }
    
    [workToDo lock];
    
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
    [workToDo unlock];
    [self saveContext];
    
    [delegate addToCount];

    return;
}

-(void) refreshData
{
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:moc];
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
        
        
        
        NSMutableArray *predArr = [NSMutableArray arrayWithCapacity:scnt*3];
        for (int i=0; i < 3; ++i)
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
    [workToDo lock];
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
    [workToDo unlock];
    return;
}

-(void) updateMainLstVwCntrl
{
    if (dontRefresh)
    {
        NSLog(@"Dont refresh set to true, not updating mainlstvwcntrl\n");
        return;
    }
   
    MainViewController *pMainVwCntrl = [delegate getMainViewController];
    
    [workToDo lock];
    pMainVwCntrl.pAllItms.itemNames = [NSMutableArray arrayWithArray:itemNames];
    pMainVwCntrl.pAllItms.indexes = [NSMutableArray arrayWithArray:indexes];
    pMainVwCntrl.pAllItms.seletedItems = [NSMutableArray arrayWithArray:seletedItems];
    [workToDo unlock];
    NSLog(@"Refreshing main row itemNames = %lu indexes = %lu seletedItems = %lu\n", (unsigned long)[itemNames count], (unsigned long)[indexes count], (unsigned long)[seletedItems count]);
    
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

- (NSManagedObjectContext *)managedObjectContext {
    
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Shopper" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
    
    
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSError *error = nil;
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Shopper.sqlite"];
    
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

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



@end
