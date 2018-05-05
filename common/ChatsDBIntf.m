//
//  ChatsDBIntf.m
//  common
//
//  Created by Ninan Thomas on 3/2/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import "ChatsDBIntf.h"
#import "Chats.h"
#import "ChatsHeader.h"
#include <sys/time.h>

@implementation ChatsDBIntf

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    return;
}

-(bool) insertMsg:(FriendDetails *) to From:(FriendDetails *)from Msg:(NSString *) msg msgTyp:(int) mtyp
{
    NSManagedObjectModel *managedObjectModel =
    [[self.managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    
    NSEntityDescription *entity =
    [ent objectForKey:@"Chats"];
    Chats *newItem = [[Chats alloc]
                      initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    newItem.from = [from.name longLongValue];
    newItem.to = [to.name longLongValue];
    newItem.text = msg;
    newItem.type = mtyp;
    struct timeval now;
    gettimeofday(&now, NULL);
    newItem.timestamp = now.tv_sec;
    
    NSEntityDescription *chatsHeaderEntity = [NSEntityDescription entityForName:@"ChatsHeader" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:chatsHeaderEntity];
    long long fromShareId = [from.name longLongValue];
    long long toShareId = [to.name longLongValue];
    [req setPredicate:[NSPredicate predicateWithFormat:@"(from == %ld AND to == %ld) OR (from == %ld AND to == %ld)", fromShareId, toShareId, toShareId, fromShareId]];
    NSError *error = nil;
    NSArray *chatsHeaders = [self.managedObjectContext executeFetchRequest:req error:&error];
    if (chatsHeaders != nil && [chatsHeaders count] > 0)
    {
        NSUInteger cnt = [chatsHeaders  count];
        for (NSUInteger i=0; i < cnt; ++i)
        {
            [self.managedObjectContext deleteObject:[chatsHeaders objectAtIndex:i]];
        }
    }
    
    ChatsHeader *newHeaderItem = [[ChatsHeader alloc]
                                  initWithEntity:chatsHeaderEntity insertIntoManagedObjectContext:self.managedObjectContext];
    newHeaderItem.from = [from.name longLongValue];
    newHeaderItem.to = [to.name longLongValue];
    newHeaderItem.text = msg;
    newHeaderItem.type = mtyp;
    newHeaderItem.timestamp = now.tv_sec;
    [self saveContext];
    return true;
}

-(bool) insertTextMsg:(FriendDetails *) to From:(FriendDetails *)from Msg:(NSString *) msg
{
    return  [self insertMsg:to From:from Msg:msg msgTyp:eMsgTypeText];
}

-(bool) insertPicture:(FriendDetails *) to From:(FriendDetails *)from Msg:(NSURL *) picurl
{
  return [self insertMsg:to From:from Msg:[picurl lastPathComponent] msgTyp:eMsgTypePicture];
}
-(bool) insertVideo:(FriendDetails *) to From:(FriendDetails *)from Msg:(NSURL *) movurl
{
    return [self insertMsg:to From:from Msg:[movurl lastPathComponent] msgTyp:eMsgTypeVideo];
}

-(NSArray *) getChatItems:(NSUInteger) limit with:(FriendDetails *) frnd
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"Chats" inManagedObjectContext:moc];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:descr];
    //ascending:YES];
    NSSortDescriptor* rownoDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                    ascending:NO];
    [req setFetchLimit:limit];
    long long share_id = [frnd.name longLongValue];
    [req setPredicate:[NSPredicate predicateWithFormat:@"from == %ld OR to == %ld", share_id, share_id]];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: rownoDescriptor, nil];
    NSError *error = nil;
    return  [[moc executeFetchRequest:req error:&error]sortedArrayUsingDescriptors:sortDescriptors];
}

-(bool) chatExists:(FriendDetails *) contact
{
    if (contact == nil)
    {
        return false;
    }
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"ChatsHeader" inManagedObjectContext:moc];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:descr];
    long long contactNo = [contact.name longLongValue];
    [req setPredicate:[NSPredicate predicateWithFormat:@"from == %ld OR to == %ld", contactNo, contactNo]];
    NSError *error = nil;
    NSArray *chatsHeaders = [moc executeFetchRequest:req error:&error];
    if (chatsHeaders == nil || [chatsHeaders count] == 0)
    {
        return false;
    }
    return true;
}

-(NSArray *) getChatHeaders:(NSUInteger) limit
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"ChatsHeader" inManagedObjectContext:moc];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:descr];
    //ascending:YES];
    NSSortDescriptor* rownoDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                    ascending:YES];
    [req setFetchLimit:limit];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects: rownoDescriptor, nil];
    NSError *error = nil;
    return  [[moc executeFetchRequest:req error:&error]sortedArrayUsingDescriptors:sortDescriptors];
}

#pragma mark - Core Data stack

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

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSLog(@"getting psc");
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    NSLog(@"getting psc1");
    NSError *error = nil;
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"chatsdb.sqlite"];
    
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"chatsdb" withExtension:@"momd"];
    NSLog(@"Setting modelURL to %@", modelURL);
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
    
    
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

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
